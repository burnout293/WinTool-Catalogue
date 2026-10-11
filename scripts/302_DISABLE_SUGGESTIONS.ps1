## WINTOOL:START
## id            : 0f94ad12-4807-4bc7-abbe-0ef0e6b28c1f
## lang          : en
## title         : Remove Windows ads and suggestions
## desc          : Turns off the ads, tips and suggested content Windows shows across the system
## category      : privacy
## icon          : eye-off
## tags          : ads, suggestions, spotlight, lock screen, tips, recommendations, start
## version       : 1.2
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
## Items         : [multi] [scan]  What to clean up — pick one or more
##   startapps   : Suggested apps in Start — apps Windows suggests in the Start menu
##   settingsads : Suggestions in Settings — promoted content on Settings pages
##   lockscreen  : Lock screen ads — Spotlight tips and "fun facts" on the lock screen
##   tips        : Tips and tricks — Windows welcome tips and notifications
##   explorer    : File Explorer ads — "sync provider" promotions in File Explorer
##   finishsetup : Finish setting up prompts — the full-screen setup nag after updates
##   welcome     : Welcome experience — the "what's new" screen after updates
##   timeline    : Timeline suggestions — suggested activities and content
##   getstarted  : Suggested content everywhere — remaining suggested-content feeds
## Details       : [items] [view:tree] Exact changes — expand an item to see each registry value, current -> target
## SafeTest      : [bool]   Safe test — simulates every change, modifies nothing
## WINTOOL:END

## WINTOOL:LANG fr
## title         : Supprimer les publicités et suggestions de Windows
## desc          : Désactive les publicités, astuces et contenus suggérés que Windows affiche partout
## Mode          : Action — désactiver ou activer les éléments cochés
##   disable     : Désactiver les éléments cochés
##   enable      : Activer les éléments cochés
## Items         : Quoi nettoyer — un ou plusieurs éléments
##   startapps   : Applications suggérées dans Démarrer — applications que Windows propose dans le menu
##   settingsads : Suggestions dans les Paramètres — contenus promus dans les pages de réglages
##   lockscreen  : Publicités de l'écran de verrouillage — astuces Spotlight et « anecdotes »
##   tips        : Astuces et conseils — conseils de bienvenue et notifications de Windows
##   explorer    : Publicités de l'Explorateur — promotions « fournisseur de synchronisation »
##   finishsetup : Invites « Terminer la configuration » — l'écran plein écran après les mises à jour
##   welcome     : Expérience de bienvenue — l'écran « nouveautés » après les mises à jour
##   timeline    : Suggestions de la Timeline — activités et contenus suggérés
##   getstarted  : Contenus suggérés partout — les flux de contenu suggéré restants
## Details       : Modifications exactes — dépliez un élément pour voir chaque valeur de registre, actuelle -> cible
## SafeTest      : Test sans risque — simule chaque modification, ne change rien
## WINTOOL:END

$CONFIG = @{
    Mode     = "disable"
    Items    = @("startapps", "settingsads", "lockscreen", "tips", "explorer", "finishsetup", "welcome", "timeline", "getstarted")
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
# valeur "desactive" (Off) et la valeur d'origine de Windows (Default).
# En mode restore, on ecrit la valeur Default.
# SafeTest : les valeurs sont lues, rien n'est ecrit.
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')
$Restore  = ($CONFIG.Mode -eq 'enable')
$errors   = 0

$cdm      = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
$explorer = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

$Definitions = @{
    startapps = @{ Label = 'Suggested apps in Start'; Values = @(
        @{ Path = $cdm; Name = 'SystemPaneSuggestionsEnabled'; Off = 0; Default = 1 },
        @{ Path = $cdm; Name = 'SubscribedContent-338388Enabled'; Off = 0; Default = 1 },
        @{ Path = $cdm; Name = 'SilentInstalledAppsEnabled'; Off = 0; Default = 1 },
        @{ Path = $cdm; Name = 'PreInstalledAppsEnabled'; Off = 0; Default = 1 },
        @{ Path = $cdm; Name = 'OEMPreInstalledAppsEnabled'; Off = 0; Default = 1 }
    ) }
    settingsads = @{ Label = 'Suggestions in Settings'; Values = @(
        @{ Path = $cdm; Name = 'SubscribedContent-338393Enabled'; Off = 0; Default = 1 },
        @{ Path = $cdm; Name = 'SubscribedContent-353694Enabled'; Off = 0; Default = 1 },
        @{ Path = $cdm; Name = 'SubscribedContent-353696Enabled'; Off = 0; Default = 1 }
    ) }
    lockscreen = @{ Label = 'Lock screen ads'; Values = @(
        @{ Path = $cdm; Name = 'SubscribedContent-338387Enabled'; Off = 0; Default = 1 },
        @{ Path = $cdm; Name = 'RotatingLockScreenOverlayEnabled'; Off = 0; Default = 1 },
        @{ Path = $cdm; Name = 'RotatingLockScreenEnabled'; Off = 0; Default = 1 }
    ) }
    tips = @{ Label = 'Tips and tricks'; Values = @(
        @{ Path = $cdm; Name = 'SubscribedContent-338389Enabled'; Off = 0; Default = 1 },
        @{ Path = $cdm; Name = 'SoftLandingEnabled'; Off = 0; Default = 1 }
    ) }
    explorer = @{ Label = 'File Explorer ads'; Values = @(
        @{ Path = $explorer; Name = 'ShowSyncProviderNotifications'; Off = 0; Default = 1 }
    ) }
    finishsetup = @{ Label = 'Finish setting up prompts'; Values = @(
        @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement'; Name = 'ScoobeSystemSettingEnabled'; Off = 0; Default = 1 }
    ) }
    welcome = @{ Label = 'Welcome experience'; Values = @(
        @{ Path = $cdm; Name = 'SubscribedContent-310093Enabled'; Off = 0; Default = 1 }
    ) }
    timeline = @{ Label = 'Timeline suggestions'; Values = @(
        @{ Path = $cdm; Name = 'SubscribedContent-353698Enabled'; Off = 0; Default = 1 }
    ) }
    getstarted = @{ Label = 'Suggested content'; Values = @(
        @{ Path = $cdm; Name = 'ContentDeliveryAllowed'; Off = 0; Default = 1 },
        @{ Path = $cdm; Name = 'FeatureManagementEnabled'; Off = 0; Default = 1 }
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
    foreach ($key in @('startapps', 'settingsads', 'lockscreen', 'tips', 'explorer', 'finishsetup', 'welcome', 'timeline', 'getstarted')) {
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
    $items = @(@('startapps', 'settingsads', 'lockscreen', 'tips', 'explorer', 'finishsetup', 'welcome', 'timeline', 'getstarted') | Where-Object { $k = $_; @($detail | Where-Object { $_ -like "$k-*" }).Count -gt 0 })
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
if ($Restore) { Write-Host "[DONE] Windows ads and suggestions restored" } else { Write-Host "[DONE] Windows ads and suggestions removed" }
exit 0
