## WINTOOL:START
## id            : 29f03b7b-bdc8-4e77-857b-e7b772524a8c
## lang          : en
## title         : Reduce browser telemetry
## desc          : Turns off the usage data browsers send to their makers, using managed-browser policies
## category      : privacy
## icon          : shield-check
## tags          : telemetry, browser, edge, chrome, firefox, brave, opera, policy
## version       : 1.2
## admin         : true
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
## Mode        : [select] [scan] Action — turn browser telemetry off or on
##   disable   : Disable telemetry — reduce what browsers report
##   enable    : Enable telemetry — remove the policies, back to each browser's default
## Browsers    : [multi] [scan]  Browsers — pick one or more
##   edge      : Microsoft Edge
##   chrome    : Google Chrome
##   firefox   : Mozilla Firefox
##   brave     : Brave
##   opera     : Opera
## Details     : [items] [view:tree] Exact changes — expand a browser to see each policy, current -> target
## SafeTest    : [bool]   Safe test — simulates every change, modifies nothing
## WINTOOL:END

## WINTOOL:LANG fr
## title       : Réduire la télémétrie des navigateurs
## desc        : Coupe les données d'usage que les navigateurs envoient à leur éditeur, via des stratégies de navigateur géré
## Mode        : Action — désactiver ou activer la télémétrie des navigateurs
##   disable   : Désactiver la télémétrie — réduire ce que les navigateurs transmettent
##   enable    : Appliquer la télémétrie — retirer les stratégies, retour au réglage d'origine
## Browsers    : Navigateurs — un ou plusieurs
##   edge      : Microsoft Edge
##   chrome    : Google Chrome
##   firefox   : Mozilla Firefox
##   brave     : Brave
##   opera     : Opera
## Details     : Modifications exactes — dépliez un navigateur pour voir chaque stratégie, actuelle -> cible
## SafeTest    : Test sans risque — simule chaque modification, ne change rien
## WINTOOL:END

$CONFIG = @{
    Mode     = "disable"
    Browsers = @("edge", "chrome", "firefox", "brave", "opera")
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
# On agit UNIQUEMENT par strategies machine (HKLM\SOFTWARE\Policies) : c'est le
# mecanisme officiel, propre a desinstaller, et il ne modifie aucun profil
# utilisateur. Effet de bord assume : le navigateur affichera "gere par votre
# organisation". En mode "enable", on SUPPRIME les valeurs qu'on avait posees
# (retour au defaut du navigateur), on ne force pas la telemetrie a ON.
# Brave et Opera etant bases sur Chromium, ils lisent les strategies Google\Chrome
# ET leurs propres cles : on ecrit les deux.
# SafeTest : les strategies sont lues, rien n'est ecrit.
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')
$Disable  = ($CONFIG.Mode -ne 'enable')
$errors   = 0

# Chaque navigateur : une liste de valeurs de strategie {Path, Name, Off}.
# "Off" = valeur qui reduit la telemetrie. En mode enable, la valeur est supprimee.
$P = 'HKLM:\SOFTWARE\Policies'
$BrowserDefs = @{
    edge = @{ Name = 'Microsoft Edge'; Values = @(
        @{ Path = "$P\Microsoft\Edge"; Name = 'MetricsReportingEnabled'; Off = 0 },
        @{ Path = "$P\Microsoft\Edge"; Name = 'SendSiteInfoToImproveServices'; Off = 0 },
        @{ Path = "$P\Microsoft\Edge"; Name = 'DiagnosticData'; Off = 0 },
        @{ Path = "$P\Microsoft\Edge"; Name = 'PersonalizationReportingEnabled'; Off = 0 },
        @{ Path = "$P\Microsoft\Edge"; Name = 'UserFeedbackAllowed'; Off = 0 },
        @{ Path = "$P\Microsoft\Edge"; Name = 'SpotlightExperiencesAndRecommendationsEnabled'; Off = 0 }
    ) }
    chrome = @{ Name = 'Google Chrome'; Values = @(
        @{ Path = "$P\Google\Chrome"; Name = 'MetricsReportingEnabled'; Off = 0 },
        @{ Path = "$P\Google\Chrome"; Name = 'UrlKeyedAnonymizedDataCollectionEnabled'; Off = 0 },
        @{ Path = "$P\Google\Chrome"; Name = 'FeedbackSurveysEnabled'; Off = 0 }
    ) }
    firefox = @{ Name = 'Mozilla Firefox'; Values = @(
        @{ Path = "$P\Mozilla\Firefox"; Name = 'DisableTelemetry'; Off = 1 },
        @{ Path = "$P\Mozilla\Firefox"; Name = 'DisableFirefoxStudies'; Off = 1 }
    ) }
    brave = @{ Name = 'Brave'; Values = @(
        @{ Path = "$P\BraveSoftware\Brave"; Name = 'MetricsReportingEnabled'; Off = 0 },
        @{ Path = "$P\Google\Chrome"; Name = 'MetricsReportingEnabled'; Off = 0 }
    ) }
    opera = @{ Name = 'Opera'; Values = @(
        @{ Path = "$P\Opera Software\Opera"; Name = 'MetricsReportingEnabled'; Off = 0 },
        @{ Path = "$P\Google\Chrome"; Name = 'MetricsReportingEnabled'; Off = 0 }
    ) }
}

function Format-Key([string] $p) { return ($p -replace '^(HK[A-Z]+):', '$1') }
function Format-Val($v) { if ($null -eq $v) { return 'not set' } return "$v" }

# ==============================================================================
# ANALYSE (WINTOOL_MODE=scan) - lecture seule. Arbre : un parent par navigateur,
# un enfant par strategie (nom: actuel -> cible, et le chemin de la cle).
# Cible : disable = valeur Off ; enable = valeur supprimee ("removed").
# Id d'un enfant : "<navigateur>-<index>". Coche d'office si pas a la cible ET
# navigateur dans Browsers.
# ==============================================================================
if ($env:WINTOOL_MODE -eq 'scan') {
    Write-Output "[STEP] 1/1 Reading current policies"
    $selected = @($CONFIG.Browsers | ForEach-Object { "$_" })
    foreach ($key in @('edge', 'chrome', 'firefox', 'brave', 'opera')) {
        $def = $BrowserDefs[$key]
        Write-Output "[ITEM] Details id=$key name=""$($def.Name)"" kind=browser"
        for ($i = 0; $i -lt $def.Values.Count; $i++) {
            $v       = $def.Values[$i]
            $current = (Get-ItemProperty -Path $v.Path -Name $v.Name -ErrorAction SilentlyContinue).($v.Name)
            if ($Disable) { $done = ($null -ne $current -and [int]$current -eq $v.Off); $target = "$($v.Off)" }
            else          { $done = ($null -eq $current); $target = 'removed' }
            $state = if ($done) { 'ok' } else { 'todo' }
            $chk   = if (-not $done -and $selected -contains $key) { 'true' } else { 'false' }
            Write-Output "[ITEM] Details id=$key-$i parent=$key kind=registry name=""$($v.Name): $(Format-Val $current) -> $target"" path=""$(Format-Key $v.Path)"" state=$state checked=$chk"
        }
    }
    exit 0
}

if ($SafeTest) { Write-Host "[INFO] SafeTest mode - policies are read, nothing is changed" }
if ($Disable) {
    Write-Host "[WARN] Browsers will show 'Managed by your organization' - this is normal, it is how the setting is enforced"
} else {
    Write-Host "[INFO] Removing the telemetry policies - browsers go back to their own default"
}

# Apres une analyse : Details = strategies cochees. Sans analyse : tous les Browsers.
$detail = @($CONFIG.Details | ForEach-Object { "$_" } | Where-Object { $_ -match '^[a-z]+-\d+$' })
if ($detail.Count -gt 0) {
    $browsers = @(@('edge', 'chrome', 'firefox', 'brave', 'opera') | Where-Object { $k = $_; @($detail | Where-Object { $_ -like "$k-*" }).Count -gt 0 })
} else {
    $browsers = @($CONFIG.Browsers)
}
if ($browsers.Count -eq 0) {
    Write-Host "[WARN] No browser selected - nothing to do"
    Write-Host "[DONE] Nothing changed"
    exit 0
}

$step  = 0
$total = $browsers.Count
foreach ($key in $browsers) {
    $step++
    $def = $BrowserDefs[$key]
    if (-not $def) {
        Write-Host "[STEP] $step/$total Unknown browser '$key'"
        Write-Host "[WARN] Unknown browser '$key' - skipped"
        continue
    }
    Write-Host "[STEP] $step/$total $($def.Name)"

    for ($i = 0; $i -lt $def.Values.Count; $i++) {
        if ($detail.Count -gt 0 -and $detail -notcontains "$key-$i") { continue }
        $v = $def.Values[$i]
        if ($Disable) {
            $current = (Get-ItemProperty -Path $v.Path -Name $v.Name -ErrorAction SilentlyContinue).($v.Name)
            if ($null -ne $current -and [int]$current -eq $v.Off) { Write-Host "[OK]   $($v.Name) already $($v.Off)"; continue }
            if ($SafeTest) { Write-Host "[INFO] SafeTest - would set $(Format-Key $v.Path)\$($v.Name) = $($v.Off)"; continue }
            try {
                if (-not (Test-Path $v.Path)) { New-Item -Path $v.Path -Force -ErrorAction Stop | Out-Null }
                Set-ItemProperty -Path $v.Path -Name $v.Name -Value $v.Off -Type DWord -ErrorAction Stop
                Write-Host "[OK]   $(Format-Key $v.Path)\$($v.Name) = $($v.Off)"
            } catch { Write-Host "[ERR]  $($v.Name): $($_.Exception.Message)"; $errors++ }
        } else {
            $exists = $null -ne (Get-ItemProperty -Path $v.Path -Name $v.Name -ErrorAction SilentlyContinue)
            if (-not $exists) { Write-Host "[OK]   $($v.Name) not set - nothing to remove"; continue }
            if ($SafeTest) { Write-Host "[INFO] SafeTest - would remove $(Format-Key $v.Path)\$($v.Name)"; continue }
            try {
                Remove-ItemProperty -Path $v.Path -Name $v.Name -ErrorAction Stop
                Write-Host "[OK]   $(Format-Key $v.Path)\$($v.Name) removed"
            } catch { Write-Host "[ERR]  $($v.Name): $($_.Exception.Message)"; $errors++ }
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
if ($Disable) { Write-Host "[DONE] Browser telemetry reduced" } else { Write-Host "[DONE] Browser telemetry policies removed" }
exit 0
