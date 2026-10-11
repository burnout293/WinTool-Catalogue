## WINTOOL:START
## id            : 02fec307-3a3d-477c-9ea6-f322170e0d74
## lang          : en
## title         : Disable ad tracking
## desc          : Stops Windows from profiling you to show targeted ads and suggestions
## category      : privacy
## icon          : eye-off
## tags          : advertising id, ads, tracking, suggestions, tailored experiences
## version       : 2.2
## admin         : false
## risk          : low
## duration      : fast
## reversible    : false
## interruptible : true
## reboot        : false
## engine        : auto
## scan          : true
## view          : tree
## panels        : plan progress
## WINTOOL:END

## WINTOOL:OPTIONS
## Mode          : [select] [scan] Action — turn the checked items off or on
##   disable     : Turn the checked items off
##   enable      : Turn the checked items on
## Items         : [multi] [scan]  What to disable — pick one or more
##   adid        : Advertising ID — used by apps to show targeted ads
##   apptracking : App launch tracking — used to personalise Start and search
##   tailored    : Tailored experiences — tips and offers based on your diagnostic data
## Details       : [items] [view:tree] Exact changes — expand an item to see each registry value, current -> target
## SafeTest      : [bool]   Safe test — simulates every change, modifies nothing
## WINTOOL:END

## WINTOOL:LANG fr
## title         : Désactiver la publicité ciblée
## desc          : Empêche Windows de vous profiler pour afficher des publicités et des suggestions
## Mode          : Action — désactiver ou activer les éléments cochés
##   disable     : Désactiver les éléments cochés
##   enable      : Activer les éléments cochés
## Items         : Quoi désactiver — un ou plusieurs éléments
##   adid        : Identifiant publicitaire — utilisé par les applications pour cibler les publicités
##   apptracking : Suivi des lancements d'applications — sert à personnaliser Démarrer et la recherche
##   tailored    : Expériences personnalisées — astuces et offres basées sur vos données de diagnostic
## Details       : Modifications exactes — dépliez un élément pour voir chaque valeur de registre, actuelle -> cible
## SafeTest      : Test sans risque — simule chaque modification, ne change rien
## WINTOOL:END

$CONFIG = @{
    Mode     = "disable"
    Items    = @("adid", "apptracking", "tailored")
    Details  = @()
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
# Reglages du compte courant (HKCU) : WinTool etant eleve, c'est le compte qui a
# accepte l'elevation. Chaque element = une liste de valeurs DWORD, avec la
# valeur "desactive" et la valeur d'origine de Windows.
# SafeTest : les valeurs sont lues, rien n'est ecrit.
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')
$Restore  = ($CONFIG.Mode -eq 'enable')
$errors   = 0

$Definitions = @{
    adid = @{ Label = 'Advertising ID'; Values = @(
        @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; Name = 'Enabled'; Off = 0; Default = 1 }
    ) }
    apptracking = @{ Label = 'App launch tracking'; Values = @(
        @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_TrackProgs'; Off = 0; Default = 1 }
    ) }
    tailored = @{ Label = 'Tailored experiences'; Values = @(
        @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy'; Name = 'TailoredExperiencesWithDiagnosticDataEnabled'; Off = 0; Default = 1 }
    ) }
}

# Chemin lisible d'une cle (HKCU:\... -> HKCU\...).
function Format-Key([string] $p) { return ($p -replace '^(HK[A-Z]+):', '$1') }
function Format-Val($v) { if ($null -eq $v) { return 'not set' } return "$v" }

# ==============================================================================
# ANALYSE (WINTOOL_MODE=scan) — lecture seule. Arbre : un parent par element,
# un enfant par valeur de registre (nom: actuel -> cible, et le chemin de la cle).
# L'id d'un enfant est "<element>-<index>" : stable pour une version du fichier.
# Coche d'office : la valeur n'est pas a la cible ET l'element est dans Items.
# ==============================================================================
if ($env:WINTOOL_MODE -eq 'scan') {
    Write-Output "[STEP] 1/1 Reading current settings"
    $selected = @($CONFIG.Items | ForEach-Object { "$_" })
    foreach ($key in @('adid', 'apptracking', 'tailored')) {
        $def = $Definitions[$key]
        Write-Output "[ITEM] Details id=$key name=""$($def.Label)"" kind=registry"
        for ($i = 0; $i -lt $def.Values.Count; $i++) {
            $v       = $def.Values[$i]
            $wanted  = if ($Restore) { $v.Default } else { $v.Off }
            $current = (Get-ItemProperty -Path $v.Path -Name $v.Name -ErrorAction SilentlyContinue).($v.Name)
            $done    = ($null -ne $current -and [int]$current -eq $wanted)
            $state   = if ($done) { 'ok' } else { 'todo' }
            $chk     = if (-not $done -and $selected -contains $key) { 'true' } else { 'false' }
            Write-Output "[ITEM] Details id=$key-$i parent=$key kind=registry name=""$($v.Name): $(Format-Val $current) -> $wanted"" path=""$(Format-Key $v.Path)"" state=$state checked=$chk"
        }
    }
    exit 0
}

if ($SafeTest) { Write-Host "[INFO] SafeTest mode - settings are read, nothing is changed" }

# Apres une analyse, Details contient les valeurs cochees ("<element>-<index>").
# Sans analyse (double-clic, lancement direct), Details est vide : on applique
# tous les elements de Items, comme avant.
$detail = @($CONFIG.Details | ForEach-Object { "$_" } | Where-Object { $_ -match '^[a-z]+-\d+$' })
if ($detail.Count -gt 0) {
    $items = @(@('adid', 'apptracking', 'tailored') | Where-Object { $k = $_; @($detail | Where-Object { $_ -like "$k-*" }).Count -gt 0 })
} else {
    $items = @($CONFIG.Items)
}
if ($items.Count -eq 0) {
    Write-Host "[WARN] Nothing selected - nothing to do"
    Write-Host "[DONE] Nothing changed"
    exit 0
}

$step  = 0
$total = $items.Count
foreach ($key in $items) {
    $step++
    $def = $Definitions[$key]
    if (-not $def) {
        Write-Host "[STEP] $step/$total Unknown item '$key'"
        Write-Host "[WARN] Unknown item '$key' - skipped"
        continue
    }
    Write-Host "[STEP] $step/$total $($def.Label)"

    for ($i = 0; $i -lt $def.Values.Count; $i++) {
        if ($detail.Count -gt 0 -and $detail -notcontains "$key-$i") { continue }
        $v = $def.Values[$i]
        if ($Restore) { $wanted = $v.Default } else { $wanted = $v.Off }
        $current = (Get-ItemProperty -Path $v.Path -Name $v.Name -ErrorAction SilentlyContinue).($v.Name)

        if ($null -ne $current -and [int]$current -eq $wanted) {
            Write-Host "[OK]   $($v.Name) already $wanted"
            continue
        }
        if ($SafeTest) {
            Write-Host "[INFO] SafeTest - would set $(Format-Key $v.Path)\$($v.Name) = $wanted (currently $(Format-Val $current))"
            continue
        }
        try {
            if (-not (Test-Path $v.Path)) { New-Item -Path $v.Path -Force -ErrorAction Stop | Out-Null }
            Set-ItemProperty -Path $v.Path -Name $v.Name -Value $wanted -Type DWord -ErrorAction Stop
            Write-Host "[OK]   $(Format-Key $v.Path)\$($v.Name) = $wanted"
        } catch {
            Write-Host "[ERR]  $($v.Name): $($_.Exception.Message)"
            $errors++
        }
    }
}

if ($SafeTest) {
    Write-Host "[DONE] SafeTest finished - nothing was changed"
    exit 0
}
if ($errors -gt 0) {
    Write-Host "[DONE] Finished with $errors error(s)"
    exit 1
}
if ($Restore) { Write-Host "[DONE] Ad tracking settings restored" } else { Write-Host "[DONE] Ad tracking disabled" }
exit 0
