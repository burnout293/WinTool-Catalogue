## WINTOOL:START
## id            : 17b895a4-0675-404a-a5db-b0943eb08803
## lang          : en
## title         : Empty the recycle bin
## desc          : Permanently deletes the files in the recycle bin, drive by drive
## category      : cleaning
## icon          : trash-2
## tags          : recycle bin, trash, disk space
## version       : 2.1
## admin         : false
## risk          : medium
## duration      : fast
## reversible    : false
## interruptible : true
## reboot        : false
## engine        : auto
## scan          : true
## view          : bars
## panels        : plan progress
## WINTOOL:END

## WINTOOL:OPTIONS
## Drives     : [multi] Recycle bins to empty — pick one or more drives
##   c        : [group:Bin] Drive C:
##   d        : [group:Bin] Drive D:
##   e        : [group:Bin] Drive E:
##   f        : [group:Bin] Drive F:
##   g        : [group:Bin] Drive G:
##   h        : [group:Bin] Drive H:
## SafeTest   : [bool]  Safe test — simulates every change, modifies nothing
## WINTOOL:END

## WINTOOL:REPORT
## Bin      : [group] Recycle bin — Files waiting to be permanently deleted
## Reminder : [note:warn] Emptying the recycle bin deletes these files for good. They cannot be restored afterwards.
## WINTOOL:END

## WINTOOL:LANG fr
## title      : Vider la corbeille
## desc       : Supprime définitivement les fichiers de la corbeille, disque par disque
## Drives     : Corbeilles à vider — un ou plusieurs disques
##   c        : Disque C:
##   d        : Disque D:
##   e        : Disque E:
##   f        : Disque F:
##   g        : Disque G:
##   h        : Disque H:
## SafeTest   : Test sans risque — simule chaque modification, ne change rien
## Bin        : Corbeille — Fichiers en attente de suppression définitive
## Reminder   : Vider la corbeille supprime ces fichiers pour de bon. Ils ne pourront plus être restaurés.
## WINTOOL:END

$CONFIG = @{
    Drives   = @("c", "d", "e", "f", "g", "h")
    SafeTest = $false
}

# --- WinTool override (ne pas supprimer) ---
if ($env:WINTOOL_CONFIG) {
    ($env:WINTOOL_CONFIG | ConvertFrom-Json).PSObject.Properties |
        ForEach-Object { $CONFIG[$_.Name] = $_.Value }
}

# ==============================================================================
# Code et sortie en anglais, commentaires en francais (docs/FORMAT_SCRIPT.md).
#
# Le contenu est lu via l'objet COM Shell.Application (dossier special 10 =
# corbeille de l'utilisateur courant). Chaque element est range par la lettre de
# son disque d'origine. La MEME fonction (Measure-Bins) sert a l'analyse et a
# l'action : ce que l'analyse mesure par disque est ce que l'action supprime.
#
# Le script est lance deux fois (contrat du mode analyse, 1.4) :
#   1. ANALYSE (WINTOOL_MODE=scan) — une ligne [FIND] par disque, avec sa taille.
#      La vue "bars" affiche une barre proportionnelle par disque. Rien supprime.
#   2. ACTION — WinTool renvoie dans $CONFIG.Drives les seules lettres cochees.
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')

function Format-Size {
    param([long] $Bytes)
    if ($Bytes -ge 1GB) { return ('{0:N2} GB' -f ($Bytes / 1GB)) }
    if ($Bytes -ge 1MB) { return ('{0:N1} MB' -f ($Bytes / 1MB)) }
    return ('{0:N0} KB' -f ($Bytes / 1KB))
}

# Lit la corbeille et regroupe taille + nombre par lettre de disque (minuscule).
# Lecture seule : utilisee par l'analyse ET par l'action.
function Measure-Bins {
    $byDrive = @{}
    try {
        $shell = New-Object -ComObject Shell.Application
        $bin   = $shell.Namespace(10)
        foreach ($item in $bin.Items()) {
            $size = [long]0
            try { $size = [long]$item.ExtendedProperty('System.Size') } catch { }
            $path = "$($item.Path)"
            if ($path.Length -lt 1) { continue }
            $letter = "$($path.Substring(0,1))".ToLower()
            if ($letter -notmatch '[a-z]') { continue }
            if (-not $byDrive.ContainsKey($letter)) { $byDrive[$letter] = @{ Size = [long]0; Count = 0 } }
            $byDrive[$letter].Size += $size
            $byDrive[$letter].Count++
        }
    } catch {
        Write-Host "[WARN] Could not read the recycle bin content: $($_.Exception.Message)"
    }
    return $byDrive
}

# Les lettres de disques fixes reellement presents sur la machine.
function Get-FixedDriveLetters {
    @(Get-Volume -ErrorAction SilentlyContinue |
        Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' } |
        ForEach-Object { "$($_.DriveLetter)".ToLower() })
}

# ==============================================================================
# 1. ANALYSE — on mesure par disque, on ne supprime RIEN
# ==============================================================================

if ($env:WINTOOL_MODE -eq 'scan') {

    Write-Output "[STEP] 1/1 Reading the recycle bin"
    Write-Output "[NOTE] Reminder"

    $byDrive = Measure-Bins
    $fixed   = Get-FixedDriveLetters

    # Une ligne [FIND] par disque fixe declare (c..h) et present sur la machine.
    foreach ($letter in @('c', 'd', 'e', 'f', 'g', 'h')) {
        if ($fixed -notcontains $letter) { continue }
        $size  = [long]0
        $count = 0
        if ($byDrive.ContainsKey($letter)) { $size = [long]$byDrive[$letter].Size; $count = [int]$byDrive[$letter].Count }
        Write-Output "[FIND] Drives.$letter size=$size count=$count"
        Write-Output "[LOG] Bin $($letter.ToUpper()): $count item(s), $size bytes"
    }

    exit 0
}

# ==============================================================================
# 2. ACTION — uniquement les disques coches (ou tous par defaut en double-clic)
# ==============================================================================

if ($SafeTest) { Write-Host "[INFO] SafeTest mode - the recycle bin is read, nothing is deleted" }

$byDrive = Measure-Bins
$fixed   = Get-FixedDriveLetters
$wanted  = @($CONFIG.Drives | ForEach-Object { "$_".ToLower() } | Where-Object { $fixed -contains $_ })

if ($wanted.Count -eq 0) {
    Write-Host "[WARN] No drive selected - nothing to do"
    Write-Host "[DONE] Nothing deleted"
    exit 0
}

$total  = $wanted.Count
$step   = 0
$freed  = [long]0
$errors = 0

foreach ($letter in $wanted) {
    $step++
    $drive = $letter.ToUpper()
    $size  = [long]0
    $count = 0
    if ($byDrive.ContainsKey($letter)) { $size = [long]$byDrive[$letter].Size; $count = [int]$byDrive[$letter].Count }

    Write-Host "[STEP] $step/$total Emptying the recycle bin on $drive`:"

    if ($count -eq 0) {
        Write-Host "[OK]   $drive`: already empty"
        continue
    }
    if ($SafeTest) {
        Write-Host "[INFO] SafeTest - would delete $count item(s), $(Format-Size $size) on $drive`:"
        $freed += $size
        continue
    }
    try {
        Clear-RecycleBin -DriveLetter $drive -Force -ErrorAction Stop
        Write-Host "[OK]   $drive`: $count item(s) deleted, $(Format-Size $size) freed"
        $freed += $size
    } catch {
        # Clear-RecycleBin peut echouer sur un disque sans corbeille : on verifie.
        $left = 0
        try { $left = @((New-Object -ComObject Shell.Application).Namespace(10).Items() | Where-Object { "$($_.Path)".ToLower().StartsWith($letter) }).Count } catch { }
        if ($left -eq 0) {
            Write-Host "[OK]   $drive`: emptied, $(Format-Size $size) freed"
            $freed += $size
        } else {
            Write-Host "[ERR]  $drive`: could not empty - $($_.Exception.Message)"
            $errors++
        }
    }
}

if ($SafeTest) {
    Write-Host "[INFO] SafeTest - about $(Format-Size $freed) could be freed"
    Write-Host "[DONE] SafeTest finished - nothing was deleted"
    exit 0
}

Write-Output "[FREED] $freed"
Write-Host "[INFO] Total freed: $(Format-Size $freed)"
if ($errors -gt 0) { Write-Host "[DONE] Finished with $errors error(s)"; exit 1 }
Write-Host "[DONE] Recycle bin emptied"
exit 0
