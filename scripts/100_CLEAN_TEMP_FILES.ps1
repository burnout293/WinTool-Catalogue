## WINTOOL:START
## id            : b1ac0e0b-ef61-48b9-b609-9a900b1521fa
## lang          : en
## title         : Clean temporary files
## desc          : Deletes temporary files, error reports and crash dumps left behind by Windows and apps
## category      : cleaning
## icon          : broom
## tags          : temp, temporary, cache, dumps, disk space
## version       : 2.1
## admin         : true
## risk          : low
## duration      : medium
## reversible    : false
## interruptible : true
## reboot        : false
## engine        : auto
## scan          : true
## view          : donut
## panels        : plan progress
## WINTOOL:END

## WINTOOL:OPTIONS
## Targets      : [multi]  What to clean — pick one or more
##   usertemp   : [group:Junk] User temporary files — the TEMP folder of each user
##   wintemp    : [group:Junk] Windows temporary files — C:\Windows\Temp
##   reports    : [group:Junk] Error reports — reports queued for Microsoft
##   dumps      : [group:Junk] Crash dumps — memory snapshots written after a crash
##   thumbnails : [group:Junk] Thumbnail cache — rebuilt automatically by Explorer
##   deliveryopt : [group:OldUpdates] Update sharing cache — Delivery Optimization downloads
##   oldlogs    : [group:Logs] Old setup and servicing logs — CBS, DISM, upgrade logs
## AllProfiles  : [bool]   All user accounts — otherwise only the current account
## MinAgeHours  : [number] [scan] Minimum file age — in hours, newer files are kept
## SafeTest     : [bool]   Safe test — simulates every change, modifies nothing
## WINTOOL:END

## WINTOOL:REPORT
## Junk       : [group] Junk files — Temporary files, reports and crash dumps
## OldUpdates : [group] Downloaded updates — What Windows keeps after sharing updates
## Logs       : [group] Old logs — Setup and servicing logs
## FreeSpace  : Free space on drive C:
## UpdateNote : [note:warn] If an update is waiting to be installed, Windows will download it again.
## WINTOOL:END

## WINTOOL:LANG fr
## title        : Supprimer les fichiers temporaires
## desc         : Supprime les fichiers temporaires, rapports d'erreur et vidages laissés par Windows et les applications
## Targets      : Quoi nettoyer — un ou plusieurs éléments
##   usertemp   : Fichiers temporaires de l'utilisateur — le dossier TEMP de chaque compte
##   wintemp    : Fichiers temporaires de Windows — C:\Windows\Temp
##   reports    : Rapports d'erreur — rapports en attente d'envoi à Microsoft
##   dumps      : Vidages après plantage — copies de la mémoire écrites après un plantage
##   thumbnails : Cache des miniatures — reconstruit automatiquement par l'Explorateur
##   deliveryopt : Cache de partage des mises à jour — fichiers Delivery Optimization
##   oldlogs    : Anciens journaux d'installation et de maintenance — CBS, DISM, mise à niveau
## AllProfiles  : Tous les comptes — sinon uniquement le compte actuel
## MinAgeHours  : Ancienneté minimale — en heures, les fichiers plus récents sont conservés
## SafeTest     : Test sans risque — simule chaque modification, ne change rien
## Junk       : Fichiers inutiles — Fichiers temporaires, rapports et vidages
## OldUpdates : Mises à jour téléchargées — Ce que Windows garde après avoir partagé les mises à jour
## Logs       : Anciens journaux — Journaux d'installation et de maintenance
## FreeSpace  : Espace libre sur le disque C:
## UpdateNote : Si une mise à jour attend d'être installée, Windows la téléchargera de nouveau.
## WINTOOL:END

$CONFIG = @{
    Targets     = @("usertemp", "wintemp", "reports", "dumps", "deliveryopt")
    AllProfiles = $false
    MinAgeHours = 24
    SafeTest    = $false
}

# --- WinTool override (ne pas supprimer) ---
if ($env:WINTOOL_CONFIG) {
    ($env:WINTOOL_CONFIG | ConvertFrom-Json).PSObject.Properties |
        ForEach-Object { $CONFIG[$_.Name] = $_.Value }
}

# ==============================================================================
# Code et sortie en anglais, commentaires en francais (docs/FORMAT_SCRIPT.md).
#
# Le script est lance deux fois (contrat du mode analyse, 1.4) :
#   1. ANALYSE  — WinTool pose WINTOOL_MODE=scan. Le script MESURE chaque cible
#      et ne supprime RIEN. Il ecrit une ligne [FIND] par choix de Targets.
#   2. ACTION   — WinTool relance le script sans WINTOOL_MODE, avec dans
#      $CONFIG les seuls choix coches. Le code d'action existant lit $CONFIG.
#
# Seul, en double-clic (sans WinTool), il agit avec ses valeurs par defaut.
# La MEME fonction (Get-TargetSpecs) donne les chemins a l'analyse et a l'action :
# ce que l'analyse mesure est exactement ce que l'action supprime.
# ==============================================================================

$cutoff = (Get-Date).AddHours(-[double]$CONFIG.MinAgeHours)

function Format-Size {
    param([long] $Bytes)
    if ($Bytes -ge 1GB) { return ('{0:N2} GB' -f ($Bytes / 1GB)) }
    if ($Bytes -ge 1MB) { return ('{0:N1} MB' -f ($Bytes / 1MB)) }
    return ('{0:N0} KB' -f ($Bytes / 1KB))
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    return ([Security.Principal.WindowsPrincipal] $identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Profils a traiter : le compte courant, ou tous les profils reels de C:\Users.
function Get-ProfileRoots {
    if (("$($CONFIG.AllProfiles)" -eq 'True')) {
        $usersRoot = Split-Path $env:USERPROFILE -Parent
        return @(Get-ChildItem -LiteralPath $usersRoot -Directory -Force -ErrorAction SilentlyContinue |
                 Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'AppData\Local') } |
                 ForEach-Object { Join-Path $_.FullName 'AppData\Local' })
    }
    return @($env:LOCALAPPDATA)
}

# La source unique de verite : pour un choix de Targets, les dossiers a examiner.
# Chaque entree = @{ Path; Filter; TopOnly }. Appelee par l'analyse ET l'action.
function Get-TargetSpecs {
    param([string] $Target)
    switch ($Target) {
        'usertemp' {
            if (("$($CONFIG.AllProfiles)" -eq 'True')) { return @(Get-ProfileRoots | ForEach-Object { @{ Path = (Join-Path $_ 'Temp'); Filter = '*'; TopOnly = $false } }) }
            return @(@{ Path = $env:TEMP; Filter = '*'; TopOnly = $false })
        }
        'wintemp'  { return @(@{ Path = (Join-Path $env:SystemRoot 'Temp'); Filter = '*'; TopOnly = $false }) }
        'reports'  {
            $s = @(
                @{ Path = (Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportArchive'); Filter = '*'; TopOnly = $false }
                @{ Path = (Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportQueue');   Filter = '*'; TopOnly = $false }
            )
            return $s + @(Get-ProfileRoots | ForEach-Object { @{ Path = (Join-Path $_ 'Microsoft\Windows\WER'); Filter = '*'; TopOnly = $false } })
        }
        'dumps'    {
            $s = @(
                @{ Path = (Join-Path $env:SystemRoot 'Minidump'); Filter = '*'; TopOnly = $false }
                @{ Path = $env:SystemRoot; Filter = 'MEMORY.DMP'; TopOnly = $true }
            )
            return $s + @(Get-ProfileRoots | ForEach-Object { @{ Path = (Join-Path $_ 'CrashDumps'); Filter = '*'; TopOnly = $false } })
        }
        'thumbnails' { return @(Get-ProfileRoots | ForEach-Object { @{ Path = (Join-Path $_ 'Microsoft\Windows\Explorer'); Filter = 'thumbcache_*.db'; TopOnly = $true } }) }
        'deliveryopt' { return @(@{ Path = (Join-Path $env:SystemRoot 'ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache'); Filter = '*'; TopOnly = $false }) }
        'oldlogs'  {
            return @(
                @{ Path = (Join-Path $env:SystemRoot 'Logs\CBS');  Filter = '*.log'; TopOnly = $false }
                @{ Path = (Join-Path $env:SystemRoot 'Logs\DISM'); Filter = '*.log'; TopOnly = $false }
                @{ Path = (Join-Path $env:SystemRoot 'Panther');   Filter = '*';     TopOnly = $false }
                @{ Path = (Join-Path $env:SystemDrive '$WINDOWS.~BT\Sources\Panther'); Filter = '*'; TopOnly = $false }
            )
        }
        default    { return @() }
    }
}

# Fichiers plus anciens que le seuil, dans une liste de specs. Lecture seule.
function Get-SpecFiles {
    param($Specs)
    $out = @()
    foreach ($s in $Specs) {
        if (-not (Test-Path -LiteralPath $s.Path)) { continue }
        $out += @(Get-ChildItem -LiteralPath $s.Path -Filter $s.Filter -Recurse:(-not $s.TopOnly) -Force -File -ErrorAction SilentlyContinue |
                  Where-Object { $_.LastWriteTime -lt $cutoff })
    }
    return $out
}

# Mesure (analyse) : taille + nombre pour un choix de Targets.
function Measure-Target {
    param([string] $Target)
    $files = Get-SpecFiles (Get-TargetSpecs $Target)
    [pscustomobject]@{ Size = [long](($files | Measure-Object -Property Length -Sum).Sum); Count = [int]$files.Count }
}

# ==============================================================================
# 1. ANALYSE — on mesure, on decrit, on ne supprime RIEN
# ==============================================================================

if ($env:WINTOOL_MODE -eq 'scan') {

    $order = @('usertemp', 'wintemp', 'reports', 'dumps', 'thumbnails', 'deliveryopt', 'oldlogs')
    $i = 0
    foreach ($t in $order) {
        $i++
        Write-Output "[STEP] $i/$($order.Count) Measuring $t"
        $m = Measure-Target $t
        if ($t -eq 'deliveryopt') {
            # Gros mais encore utile si une MAJ est en attente : montre, PAS coche.
            Write-Output "[FIND] Targets.deliveryopt size=$($m.Size) count=$($m.Count) checked=false"
            Write-Output "[NOTE] UpdateNote Targets.deliveryopt"
        } else {
            Write-Output "[FIND] Targets.$t size=$($m.Size) count=$($m.Count)"
        }
        Write-Output "[LOG] Measure $($t): $($m.Count) files, $($m.Size) bytes"
    }

    # Une mesure sans case : l'espace libre, pour situer le reste.
    $drive = Get-PSDrive -Name C -ErrorAction SilentlyContinue
    if ($drive) {
        $pct = [math]::Round(100 * $drive.Free / ($drive.Used + $drive.Free))
        $health = if ($pct -lt 10) { 'crit' } elseif ($pct -lt 20) { 'warn' } else { 'ok' }
        Write-Output "[METRIC] FreeSpace value=$pct unit=pct health=$health max=100"
    }

    exit 0
}

# ==============================================================================
# 2. ACTION — uniquement les choix coches (ou les valeurs par defaut en double-clic)
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')
$errors   = 0
$freed    = [long]0

# Supprime les fichiers d'une liste de specs, puis les dossiers vides laisses.
function Clear-Specs {
    param($Specs, [string] $Label)
    $files = Get-SpecFiles $Specs
    if ($files.Count -eq 0) { Write-Host "[OK]   $($Label): nothing to clean"; return }

    $size = [long](($files | Measure-Object -Property Length -Sum).Sum)
    if ($SafeTest) {
        Write-Host "[INFO] SafeTest - would delete $($files.Count) file(s), $(Format-Size $size) in $Label"
        $script:freed += $size
        return
    }

    $deleted = 0; $locked = 0; $freedHere = [long]0
    foreach ($f in $files) {
        try { Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop; $deleted++; $freedHere += $f.Length }
        catch { $locked++ }
    }
    foreach ($s in $Specs) {
        if ($s.TopOnly -or -not (Test-Path -LiteralPath $s.Path)) { continue }
        Get-ChildItem -LiteralPath $s.Path -Recurse -Force -Directory -ErrorAction SilentlyContinue |
            Sort-Object { $_.FullName.Length } -Descending |
            ForEach-Object {
                if (-not (Get-ChildItem -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue)) {
                    Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
                }
            }
    }
    $script:freed += $freedHere
    Write-Host "[OK]   $($Label): $deleted file(s) deleted, $(Format-Size $freedHere) freed"
    if ($locked -gt 0) { Write-Host "[INFO] $($Label): $locked file(s) in use, left in place" }
}

if ($SafeTest) { Write-Host "[INFO] SafeTest mode - files are measured, nothing is deleted" }
if (-not (Test-Admin)) { Write-Host "[WARN] Not running as administrator - system folders may be skipped" }

$targets = @($CONFIG.Targets | Where-Object { @('usertemp','wintemp','reports','dumps','thumbnails','deliveryopt','oldlogs') -contains "$_" })
if ($targets.Count -eq 0) {
    Write-Host "[WARN] No target selected - nothing to do"
    Write-Host "[DONE] Nothing cleaned"
    exit 0
}

Write-Host "[INFO] Keeping files newer than $($CONFIG.MinAgeHours) hour(s)"
$step = 0
$total = $targets.Count
foreach ($target in $targets) {
    $step++
    Write-Host "[STEP] $step/$total Cleaning $target"
    if ($target -eq 'deliveryopt' -and -not $SafeTest -and (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue)) {
        # Cmdlet native quand elle existe : plus propre que la suppression du dossier.
        try { Delete-DeliveryOptimizationCache -Force -ErrorAction Stop; Write-Host "[OK]   Delivery Optimization cache cleared" }
        catch { Write-Host "[WARN] Could not clear Delivery Optimization cache: $($_.Exception.Message)" }
        continue
    }
    Clear-Specs (Get-TargetSpecs $target) $target
}

if ($SafeTest) {
    Write-Host "[INFO] SafeTest - about $(Format-Size $freed) could be freed"
    Write-Host "[DONE] SafeTest finished - nothing was deleted"
    exit 0
}

Write-Output "[FREED] $freed"
Write-Host "[INFO] Total freed: $(Format-Size $freed)"
if ($errors -gt 0) { Write-Host "[DONE] Finished with $errors error(s)"; exit 1 }
Write-Host "[DONE] Temporary files cleaned"
exit 0
