## WINTOOL:START
## id            : 3f3ff641-24dd-4aef-9479-ae110192963a
## lang          : en
## title         : Take control of Windows updates
## desc          : Decides when and how Windows updates - defer, delay restarts, exclude drivers, or stop auto-updates
## category      : tools
## icon          : settings
## tags          : windows update, defer, restart, active hours, drivers, policy
## version       : 1.1
## admin         : true
## risk          : medium
## duration      : fast
## reversible    : false
## interruptible : true
## reboot        : false
## engine        : auto
## scan          : true
## WINTOOL:END

## WINTOOL:OPTIONS
## Mode              : [select] [scan] Action — turn the checked controls on or off
##   enable          : Turn the checked controls on
##   disable         : Turn the checked controls off — back to the Windows defaults
## Items             : [multi]  Controls — pick one or more
##   notifydownload  : Ask before downloading — Windows notifies instead of auto-downloading
##   noautorestart   : No restart while signed in — never auto-restart with a user logged on
##   noforcedrestart : No forced restart — disable deadline-based automatic restarts
##   activehours     : Set active hours — no restarts during your working hours
##   deferfeature    : Delay feature updates — the big yearly upgrades
##   deferquality    : Delay monthly updates — the monthly quality/security updates
##   excludedrivers  : Keep my drivers — do not get drivers from Windows Update
##   pausep2p        : Do not share updates — turn off update sharing to other PCs
##   stopauto        : Stop automatic updates — you decide when to check (advanced)
## FeatureDelay      : [select] [scan] Feature update delay
##   d0              : No delay
##   d30             : 30 days
##   d60             : 60 days
##   d90             : 90 days
##   d180            : 180 days
##   d365            : 365 days
## QualityDelay      : [select] [scan] Monthly update delay
##   d0              : No delay
##   d7              : 7 days
##   d14             : 14 days
##   d15             : 15 days
##   d21             : 21 days
##   d30             : 30 days
## ActiveFrom        : [select] [scan] Active hours start
##   h0              : 0:00
##   h1              : 1:00
##   h2              : 2:00
##   h3              : 3:00
##   h4              : 4:00
##   h5              : 5:00
##   h6              : 6:00
##   h7              : 7:00
##   h8              : 8:00
##   h9              : 9:00
##   h10             : 10:00
##   h11             : 11:00
##   h12             : 12:00
##   h13             : 13:00
##   h14             : 14:00
##   h15             : 15:00
##   h16             : 16:00
##   h17             : 17:00
##   h18             : 18:00
##   h19             : 19:00
##   h20             : 20:00
##   h21             : 21:00
##   h22             : 22:00
##   h23             : 23:00
## ActiveTo          : [select] [scan] Active hours end
##   h0              : 0:00
##   h1              : 1:00
##   h2              : 2:00
##   h3              : 3:00
##   h4              : 4:00
##   h5              : 5:00
##   h6              : 6:00
##   h7              : 7:00
##   h8              : 8:00
##   h9              : 9:00
##   h10             : 10:00
##   h11             : 11:00
##   h12             : 12:00
##   h13             : 13:00
##   h14             : 14:00
##   h15             : 15:00
##   h16             : 16:00
##   h17             : 17:00
##   h18             : 18:00
##   h19             : 19:00
##   h20             : 20:00
##   h21             : 21:00
##   h22             : 22:00
##   h23             : 23:00
## SafeTest          : [bool]   Safe test — simulates every change, modifies nothing
## WINTOOL:END

## WINTOOL:LANG fr
## title             : Reprendre le contrôle des mises à jour
## desc              : Décide quand et comment Windows se met à jour - reporter, retarder les redémarrages, exclure les pilotes, ou stopper l'auto-MAJ
## Mode              : Action — activer ou désactiver les contrôles cochés
##   enable          : Activer les contrôles cochés
##   disable         : Désactiver les contrôles cochés — retour aux réglages de Windows
## Items             : Contrôles — un ou plusieurs éléments
##   notifydownload  : Demander avant de télécharger — Windows prévient au lieu de télécharger seul
##   noautorestart   : Pas de redémarrage si connecté — jamais de redémarrage auto avec une session ouverte
##   noforcedrestart : Pas de redémarrage forcé — désactive les redémarrages automatiques à échéance
##   activehours     : Définir les heures d'activité — aucun redémarrage pendant vos heures de travail
##   deferfeature    : Retarder les mises à jour de fonctionnalités — les grosses mises à niveau annuelles
##   deferquality    : Retarder les mises à jour mensuelles — les mises à jour qualité/sécurité
##   excludedrivers  : Garder mes pilotes — ne pas recevoir les pilotes via Windows Update
##   pausep2p        : Ne pas partager les mises à jour — coupe le partage vers d'autres PC
##   stopauto        : Stopper les mises à jour automatiques — vous décidez quand chercher (avancé)
## FeatureDelay      : Report des mises à jour de fonctionnalités
##   d0              : Aucun report
##   d30             : 30 jours
##   d60             : 60 jours
##   d90             : 90 jours
##   d180            : 180 jours
##   d365            : 365 jours
## QualityDelay      : Report des mises à jour mensuelles
##   d0              : Aucun report
##   d7              : 7 jours
##   d14             : 14 jours
##   d15             : 15 jours
##   d21             : 21 jours
##   d30             : 30 jours
## ActiveFrom        : Début des heures d'activité
##   h0              : 0 h
##   h1              : 1 h
##   h2              : 2 h
##   h3              : 3 h
##   h4              : 4 h
##   h5              : 5 h
##   h6              : 6 h
##   h7              : 7 h
##   h8              : 8 h
##   h9              : 9 h
##   h10             : 10 h
##   h11             : 11 h
##   h12             : 12 h
##   h13             : 13 h
##   h14             : 14 h
##   h15             : 15 h
##   h16             : 16 h
##   h17             : 17 h
##   h18             : 18 h
##   h19             : 19 h
##   h20             : 20 h
##   h21             : 21 h
##   h22             : 22 h
##   h23             : 23 h
## ActiveTo          : Fin des heures d'activité
##   h0              : 0 h
##   h1              : 1 h
##   h2              : 2 h
##   h3              : 3 h
##   h4              : 4 h
##   h5              : 5 h
##   h6              : 6 h
##   h7              : 7 h
##   h8              : 8 h
##   h9              : 9 h
##   h10             : 10 h
##   h11             : 11 h
##   h12             : 12 h
##   h13             : 13 h
##   h14             : 14 h
##   h15             : 15 h
##   h16             : 16 h
##   h17             : 17 h
##   h18             : 18 h
##   h19             : 19 h
##   h20             : 20 h
##   h21             : 21 h
##   h22             : 22 h
##   h23             : 23 h
## SafeTest          : Test sans risque — simule chaque modification, ne change rien
## WINTOOL:END

$CONFIG = @{
    Mode             = "enable"
    Items            = @("noautorestart", "noforcedrestart", "activehours", "excludedrivers")
    FeatureDelay     = "d180"
    QualityDelay     = "d15"
    ActiveFrom       = "h8"
    ActiveTo         = "h20"
    SafeTest         = $false
}

# --- WinTool override (ne pas supprimer) ---
if ($env:WINTOOL_CONFIG) {
    ($env:WINTOOL_CONFIG | ConvertFrom-Json).PSObject.Properties |
        ForEach-Object { $CONFIG[$_.Name] = $_.Value }
}

# ==============================================================================
# Code et sortie en anglais, commentaires en francais (docs/FORMAT_SCRIPT.md).
#
# Uniquement des strategies machine sous HKLM\SOFTWARE\Policies\Microsoft\Windows.
# "Activer" = poser les valeurs. "Desactiver" = les supprimer (retour au defaut
# Windows). Certaines valeurs dependent des nombres (report, heures d'activite).
#
# ATTENTION : "stopauto" (NoAutoUpdate) coupe les mises a jour de securite
# automatiques - on l'annonce clairement. Le but est de rendre le controle,
# le user choisit.
# SafeTest : les valeurs sont lues, rien n'est ecrit.
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')
$Enable   = ($CONFIG.Mode -ne 'disable')
$errors   = 0

$WU = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
$AU = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
$DO = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'

# Correspondance id de choix -> nombre ; id inconnu -> valeur par defaut.
$FeatureDays = @{ d0 = 0; d30 = 30; d60 = 60; d90 = 90; d180 = 180; d365 = 365 }
$QualityDays = @{ d0 = 0; d7 = 7; d14 = 14; d15 = 15; d21 = 21; d30 = 30 }
$Hours = @{}
foreach ($h in 0..23) { $Hours["h$h"] = $h }
function Pick { param($map, $id, $def) $k = "$id"; if ($map.ContainsKey($k)) { return $map[$k] }; return $def }
$FeatureDeferDays = Pick $FeatureDays $CONFIG.FeatureDelay 180
$QualityDeferDays = Pick $QualityDays $CONFIG.QualityDelay 15
$ActiveStart      = Pick $Hours $CONFIG.ActiveFrom 8
$ActiveEnd        = Pick $Hours $CONFIG.ActiveTo 20

# Chaque item -> liste de valeurs {Path, Name, On}. On calcule On au moment voulu
# pour injecter les nombres de config.
function Get-ItemValues {
    param([string] $Key)
    switch ($Key) {
        'notifydownload'  { return @(@{ Path = $AU; Name = 'NoAutoUpdate'; On = 0 }, @{ Path = $AU; Name = 'AUOptions'; On = 2 }) }
        'noautorestart'   { return @(@{ Path = $AU; Name = 'NoAutoRebootWithLoggedOnUsers'; On = 1 }) }
        'noforcedrestart' { return @(@{ Path = $AU; Name = 'AutoRestartDeadlinePeriodInDays'; On = 0 }, @{ Path = $WU; Name = 'SetAutoRestartDeadline'; On = 0 }) }
        'activehours'     { return @(@{ Path = $WU; Name = 'SetActiveHours'; On = 1 },
                                     @{ Path = $WU; Name = 'ActiveHoursStart'; On = $ActiveStart },
                                     @{ Path = $WU; Name = 'ActiveHoursEnd';   On = $ActiveEnd }) }
        'deferfeature'    { return @(@{ Path = $WU; Name = 'DeferFeatureUpdates'; On = 1 },
                                     @{ Path = $WU; Name = 'DeferFeatureUpdatesPeriodInDays'; On = $FeatureDeferDays }) }
        'deferquality'    { return @(@{ Path = $WU; Name = 'DeferQualityUpdates'; On = 1 },
                                     @{ Path = $WU; Name = 'DeferQualityUpdatesPeriodInDays'; On = $QualityDeferDays }) }
        'excludedrivers'  { return @(@{ Path = $WU; Name = 'ExcludeWUDriversInQualityUpdate'; On = 1 }) }
        'pausep2p'        { return @(@{ Path = $DO; Name = 'DODownloadMode'; On = 0 }) }
        'stopauto'        { return @(@{ Path = $AU; Name = 'NoAutoUpdate'; On = 1 }) }
        default           { return @() }
    }
}

$Labels = @{
    notifydownload = 'Ask before downloading'; noautorestart = 'No restart while signed in'
    noforcedrestart = 'No forced restart'; activehours = 'Set active hours'
    deferfeature = 'Delay feature updates'; deferquality = 'Delay monthly updates'
    excludedrivers = 'Keep my drivers'; pausep2p = 'Do not share updates'; stopauto = 'Stop automatic updates'
}

# ==============================================================================
# ANALYSE (WINTOOL_MODE=scan) — lecture seule. Mode enable : state=ok si toutes
# les valeurs sont deja posees (avec les nombres choisis) ; mode disable :
# state=ok si toutes les valeurs sont absentes.
# ==============================================================================
if ($env:WINTOOL_MODE -eq 'scan') {
    Write-Output "[STEP] 1/1 Reading current policies"
    foreach ($key in @('notifydownload', 'noautorestart', 'noforcedrestart', 'activehours', 'deferfeature', 'deferquality', 'excludedrivers', 'pausep2p', 'stopauto')) {
        $done = $true
        foreach ($v in (Get-ItemValues $key)) {
            $current = (Get-ItemProperty -Path $v.Path -Name $v.Name -ErrorAction SilentlyContinue).($v.Name)
            if ($Enable) {
                if ($null -eq $current -or [int]$current -ne [int]$v.On) { $done = $false }
            } elseif ($null -ne $current) { $done = $false }
        }
        $state = if ($done) { 'ok' } else { 'todo' }
        Write-Output "[FIND] Items.$key state=$state"
    }
    exit 0
}

if ($SafeTest) { Write-Host "[INFO] SafeTest mode - policies are read, nothing is changed" }

$items = @($CONFIG.Items)
if ($items.Count -eq 0) {
    Write-Host "[WARN] Nothing selected - nothing to do"
    Write-Host "[DONE] Nothing changed"
    exit 0
}
if ($Enable -and ($items -contains 'stopauto')) {
    Write-Host "[WARN] 'Stop automatic updates' turns off automatic security updates - you will need to check for updates yourself"
}

$step  = 0
$total = $items.Count
foreach ($key in $items) {
    $step++
    $vals = Get-ItemValues $key
    if ($vals.Count -eq 0) {
        Write-Host "[STEP] $step/$total Unknown control '$key'"
        Write-Host "[WARN] Unknown control '$key' - skipped"
        continue
    }
    Write-Host "[STEP] $step/$total $($Labels[$key])"

    foreach ($v in $vals) {
        if ($Enable) {
            $current = (Get-ItemProperty -Path $v.Path -Name $v.Name -ErrorAction SilentlyContinue).($v.Name)
            if ($null -ne $current -and [int]$current -eq [int]$v.On) { Write-Host "[OK]   $($v.Name) already $($v.On)"; continue }
            if ($SafeTest) { Write-Host "[INFO] SafeTest - would set $($v.Name) = $($v.On)"; continue }
            try {
                if (-not (Test-Path $v.Path)) { New-Item -Path $v.Path -Force -ErrorAction Stop | Out-Null }
                Set-ItemProperty -Path $v.Path -Name $v.Name -Value ([int]$v.On) -Type DWord -ErrorAction Stop
                Write-Host "[OK]   $($v.Name) = $($v.On)"
            } catch { Write-Host "[ERR]  $($v.Name): $($_.Exception.Message)"; $errors++ }
        } else {
            $exists = $null -ne (Get-ItemProperty -Path $v.Path -Name $v.Name -ErrorAction SilentlyContinue)
            if (-not $exists) { Write-Host "[OK]   $($v.Name) not set - nothing to remove"; continue }
            if ($SafeTest) { Write-Host "[INFO] SafeTest - would remove $($v.Name)"; continue }
            try {
                Remove-ItemProperty -Path $v.Path -Name $v.Name -ErrorAction Stop
                Write-Host "[OK]   $($v.Name) removed"
            } catch { Write-Host "[ERR]  $($v.Name): $($_.Exception.Message)"; $errors++ }
        }
    }
}

if (-not $SafeTest) {
    # Rafraichit la strategie pour un effet immediat (echec sans gravite).
    & gpupdate.exe /target:computer /force 2>&1 | Out-Null
}

if ($SafeTest) {
    Write-Host "[DONE] SafeTest finished - nothing was changed"
    exit 0
}
if ($errors -gt 0) {
    Write-Host "[DONE] Finished with $errors error(s)"
    exit 1
}
Write-Host "[INFO] Open Settings > Windows Update to see the new behaviour"
if ($Enable) { Write-Host "[DONE] Update controls applied" } else { Write-Host "[DONE] Update controls removed" }
exit 0
