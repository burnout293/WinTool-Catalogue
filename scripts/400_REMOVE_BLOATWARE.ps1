## WINTOOL:START
## id            : add42e62-5277-4ff2-a4ab-f84184ad2fc6
## lang          : en
## title         : Remove unwanted apps
## desc          : Uninstalls the preinstalled apps you tick - Store apps and OEM desktop bloatware
## category      : apps
## icon          : package-minus
## tags          : bloatware, appx, oem, uninstall, preinstalled, candy crush, mcafee
## version       : 4.0
## admin         : true
## risk          : medium
## duration      : medium
## reversible    : false
## interruptible : true
## reboot        : false
## engine        : winps
## scan          : true
## panels        : plan progress
## WINTOOL:END

## WINTOOL:OPTIONS
## Remove            : [multi] Apps to remove — only those found on this PC are shown after the analysis
##   candycrush    : Candy Crush and King games
##   solitaire     : Solitaire Collection
##   othergames    : Other preinstalled games
##   news          : Microsoft News
##   weather       : Weather
##   msnapps       : Finance and Sports
##   gethelp       : Get Help
##   tips          : Tips
##   feedback      : Feedback Hub
##   officehub     : Office hub (promo)
##   todo          : Microsoft To Do
##   powerautomate : Power Automate
##   cortana       : Cortana
##   teams         : Teams personal (Chat)
##   family        : Microsoft Family
##   clipchamp     : Clipchamp
##   filmstv       : Films and TV
##   groove        : Groove Music
##   xbox          : Xbox apps — keep them if you play on PC
##   mixedreality  : Mixed Reality, 3D Viewer, Print 3D
##   people        : People
##   phonelink     : Phone Link
##   mail          : Mail and Calendar
##   outlooknew    : New Outlook
##   maps          : Maps
##   skype         : Skype
##   wallet        : Wallet
##   social        : Social network shortcuts — Facebook, Instagram, TikTok, LinkedIn
##   streaming     : Netflix and Spotify shortcuts
##   copilot       : Copilot
##   devhome       : Dev Home
##   mcafee        : McAfee (trial)
##   norton        : Norton (trial)
##   avast         : Avast / AVG (trial)
##   hpextras      : HP extras — JumpStart, Documentation, myHP
##   lenovoextras  : Lenovo extras — Welcome, Now
##   dellextras    : Dell extras — Customer Connect, Digital Delivery
##   asusextras    : ASUS extras — GiftBox
##   acerextras    : Acer extras — Jumpstart, Collection
##   promos        : Promotional installs — WildTangent, Booking.com, ExpressVPN
##   cyberlink     : CyberLink bundle — Power2Go, PowerDirector
## RemoveProvisioned : [bool]  Prevent reinstallation — also removes Store apps for future accounts
## SafeTest          : [bool]  Safe test — lists the apps, uninstalls nothing
## WINTOOL:END

## WINTOOL:REPORT
## Protected : [note:info] Windows, the Store, winget, security and framework apps are never touched.
## Win32Note : [note:warn] Desktop apps are removed by their own uninstaller, which may be slow or ask its own questions.
## WINTOOL:END

## WINTOOL:LANG fr
## title              : Retirer les applications inutiles
## desc               : Désinstalle les applications préinstallées que vous cochez - apps du Store et bloatware OEM
## Remove             : Applications à retirer — seules celles présentes sur ce PC s'affichent après l'analyse
##   candycrush    : Candy Crush et jeux King
##   solitaire     : Solitaire Collection
##   othergames    : Autres jeux préinstallés
##   news          : Actualités Microsoft
##   weather       : Météo
##   msnapps       : Finance et Sports
##   gethelp       : Obtenir de l'aide
##   tips          : Astuces
##   feedback      : Hub de commentaires
##   officehub     : Office (promotion)
##   todo          : Microsoft To Do
##   powerautomate : Power Automate
##   cortana       : Cortana
##   teams         : Teams personnel (Conversation)
##   family        : Microsoft Family
##   clipchamp     : Clipchamp
##   filmstv       : Films et TV
##   groove        : Groove Musique
##   xbox          : Applications Xbox — à garder si vous jouez sur PC
##   mixedreality  : Réalité mixte, Visionneuse 3D, Print 3D
##   people        : Contacts
##   phonelink     : Mobile connecté
##   mail          : Courrier et Calendrier
##   outlooknew    : Nouvel Outlook
##   maps          : Cartes
##   skype         : Skype
##   wallet        : Wallet
##   social        : Raccourcis réseaux sociaux — Facebook, Instagram, TikTok, LinkedIn
##   streaming     : Raccourcis Netflix et Spotify
##   copilot       : Copilot
##   devhome       : Dev Home
##   mcafee        : McAfee (version d'essai)
##   norton        : Norton (version d'essai)
##   avast         : Avast / AVG (version d'essai)
##   hpextras      : Extras HP — JumpStart, Documentation, myHP
##   lenovoextras  : Extras Lenovo — Welcome, Now
##   dellextras    : Extras Dell — Customer Connect, Digital Delivery
##   asusextras    : Extras ASUS — GiftBox
##   acerextras    : Extras Acer — Jumpstart, Collection
##   promos        : Installations promotionnelles — WildTangent, Booking.com, ExpressVPN
##   cyberlink     : Pack CyberLink — Power2Go, PowerDirector
## RemoveProvisioned  : Empêcher la réinstallation — retire aussi les apps du Store pour les futurs comptes
## SafeTest           : Test sans risque — liste les applications, ne désinstalle rien
## Protected          : Windows, le Store, winget, les apps de sécurité et les frameworks ne sont jamais touchés.
## Win32Note          : Les apps bureautiques sont retirées par leur propre désinstalleur, parfois lent ou posant ses propres questions.
## WINTOOL:END

$CONFIG = @{
    Remove            = @("candycrush", "solitaire", "othergames", "news", "weather", "msnapps", "gethelp", "tips", "feedback", "officehub", "powerautomate", "cortana", "teams", "family", "clipchamp", "filmstv", "mixedreality", "people", "maps", "skype", "wallet", "social", "devhome")
    RemoveProvisioned = $true
    SafeTest          = $false
}

# --- WinTool override (ne pas supprimer) ---
if ($env:WINTOOL_CONFIG) {
    ($env:WINTOOL_CONFIG | ConvertFrom-Json).PSObject.Properties |
        ForEach-Object { $CONFIG[$_.Name] = $_.Value }
}

# ==============================================================================
# Code et sortie en anglais, commentaires en francais (docs/FORMAT_SCRIPT.md).
#
# engine : winps - le module Appx n'est pas fiable sous PowerShell 7.
#
# v4 : l'option est un [multi] a choix declares (liste a cocher en configuration
# comme en analyse). La cle a ete renommee (Apps -> Remove) pour qu'aucune
# configuration memorisee par une version precedente ne bloque le lancement.
#
# Chaque choix = un ou plusieurs motifs de noms de paquets (Appx) ou de noms
# affiches (Win32). Les motifs Win32 sont volontairement etroits : jamais de
# pilote, d'outil de mise a jour ni de securite constructeur.
#
# Lance deux fois (contrat du mode analyse, 1.4) :
#   1. ANALYSE (WINTOOL_MODE=scan) — un [FIND] par choix PRESENT sur le PC.
#   2. ACTION — WinTool renvoie dans $CONFIG.Remove les choix coches.
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')

$Choices = [ordered]@{
    candycrush    = @{ Kind = 'appx'; Checked = $true; Patterns = @('king.com.*') }
    solitaire     = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.MicrosoftSolitaireCollection') }
    othergames    = @{ Kind = 'appx'; Checked = $true; Patterns = @('*.BubbleWitch*', '*.MarchofEmpires', '*.AsphaltStreetStormRacing', '*.Disney*', '*.FarmVille*') }
    news          = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.BingNews') }
    weather       = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.BingWeather') }
    msnapps       = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.BingFinance', 'Microsoft.BingSports') }
    gethelp       = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.GetHelp') }
    tips          = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.Getstarted') }
    feedback      = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.WindowsFeedbackHub') }
    officehub     = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.MicrosoftOfficeHub') }
    todo          = @{ Kind = 'appx'; Checked = $false; Patterns = @('Microsoft.Todos') }
    powerautomate = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.PowerAutomateDesktop') }
    cortana       = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.549981C3F5F10') }
    teams         = @{ Kind = 'appx'; Checked = $true; Patterns = @('MicrosoftTeams') }
    family        = @{ Kind = 'appx'; Checked = $true; Patterns = @('MicrosoftCorporationII.MicrosoftFamily') }
    clipchamp     = @{ Kind = 'appx'; Checked = $true; Patterns = @('Clipchamp.Clipchamp') }
    filmstv       = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.ZuneVideo') }
    groove        = @{ Kind = 'appx'; Checked = $false; Patterns = @('Microsoft.ZuneMusic') }
    xbox          = @{ Kind = 'appx'; Checked = $false; Patterns = @('Microsoft.XboxApp', 'Microsoft.GamingApp', 'Microsoft.XboxGamingOverlay', 'Microsoft.XboxSpeechToTextOverlay') }
    mixedreality  = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.MixedReality.Portal', 'Microsoft.Microsoft3DViewer', 'Microsoft.Print3D') }
    people        = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.People') }
    phonelink     = @{ Kind = 'appx'; Checked = $false; Patterns = @('Microsoft.YourPhone') }
    mail          = @{ Kind = 'appx'; Checked = $false; Patterns = @('Microsoft.windowscommunicationsapps') }
    outlooknew    = @{ Kind = 'appx'; Checked = $false; Patterns = @('Microsoft.OutlookForWindows') }
    maps          = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.WindowsMaps') }
    skype         = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.SkypeApp') }
    wallet        = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.Wallet') }
    social        = @{ Kind = 'appx'; Checked = $true; Patterns = @('*Facebook*', '*Instagram*', '*TikTok*', '*Twitter*', '7EE7776C.LinkedInforWindows') }
    streaming     = @{ Kind = 'appx'; Checked = $false; Patterns = @('*.Netflix', '*.Spotify*') }
    copilot       = @{ Kind = 'appx'; Checked = $false; Patterns = @('Microsoft.Copilot') }
    devhome       = @{ Kind = 'appx'; Checked = $true; Patterns = @('Microsoft.Windows.DevHome') }
    mcafee        = @{ Kind = 'win32'; Checked = $false; Patterns = @('McAfee*') }
    norton        = @{ Kind = 'win32'; Checked = $false; Patterns = @('*Norton*') }
    avast         = @{ Kind = 'win32'; Checked = $false; Patterns = @('Avast*', 'AVG *') }
    hpextras      = @{ Kind = 'win32'; Checked = $false; Patterns = @('HP JumpStart*', 'HP Documentation', 'myHP', 'HP Audio Switch') }
    lenovoextras  = @{ Kind = 'win32'; Checked = $false; Patterns = @('Lenovo Welcome*', 'Lenovo Now*') }
    dellextras    = @{ Kind = 'win32'; Checked = $false; Patterns = @('Dell Customer Connect', 'Dell Digital Delivery*', 'My Dell') }
    asusextras    = @{ Kind = 'win32'; Checked = $false; Patterns = @('ASUS GiftBox*') }
    acerextras    = @{ Kind = 'win32'; Checked = $false; Patterns = @('Acer Jumpstart*', 'Acer Collection*') }
    promos        = @{ Kind = 'win32'; Checked = $false; Patterns = @('*WildTangent*', '*Booking.com*', '*ExpressVPN*', 'Dropbox Promotion') }
    cyberlink     = @{ Kind = 'win32'; Checked = $false; Patterns = @('CyberLink Power2Go*', 'CyberLink PowerDirector*', 'Power2Go*', 'PowerDirector*') }
}

# --- Appx : essentiels jamais listes ------------------------------------------
$ProtectedAppx = @(
    'Microsoft.WindowsStore', 'Microsoft.DesktopAppInstaller', 'Microsoft.StorePurchaseApp',
    'Microsoft.VCLibs*', 'Microsoft.NET.*', 'Microsoft.UI.Xaml*', 'Microsoft.Services.*',
    'Microsoft.WindowsCalculator', 'Microsoft.Windows.Photos', 'Microsoft.SecHealthUI',
    'Microsoft.XboxIdentityProvider', 'Microsoft.WindowsNotepad', 'Microsoft.Paint',
    'Microsoft.ScreenSketch', 'Microsoft.WindowsTerminal', 'Microsoft.WindowsCamera',
    'Microsoft.AAD.BrokerPlugin', 'Microsoft.AccountsControl', 'Microsoft.Win32WebViewHost',
    'Microsoft.MicrosoftEdge*', 'Microsoft.WebMediaExtensions', 'Microsoft.HEIFImageExtension',
    'Microsoft.VP9VideoExtensions', 'Microsoft.WebpImageExtension', 'MicrosoftWindows.Client.*',
    'Microsoft.LockApp', 'Microsoft.Windows.ShellExperienceHost', 'Microsoft.Windows.StartMenuExperienceHost',
    'Microsoft.UI.Xaml.CBS', 'Microsoft.AsyncTextService', 'Microsoft.CredDialogHost'
)

function Test-Match {
    param([string] $Name, [string[]] $Patterns)
    foreach ($p in $Patterns) { if ($Name -like $p) { return $true } }
    return $false
}

# Paquets Appx supprimables (hors essentiels), lus une fois. Lecture seule.
function Get-RemovableAppx {
    try { $pkgs = @(Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue) } catch { $pkgs = @() }
    @($pkgs | Where-Object {
        $_.Name -and -not $_.IsFramework -and "$($_.SignatureKind)" -ne 'System' -and
        $_.NonRemovable -ne $true -and -not (Test-Match "$($_.Name)" $ProtectedAppx)
    })
}

# Entrees Win32 desinstallables, lues une fois. Lecture seule.
function Get-UninstallEntries {
    $roots = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $out = @(); $seen = @{}
    foreach ($root in $roots) {
        try { $keys = @(Get-ItemProperty -Path $root -ErrorAction SilentlyContinue) } catch { $keys = @() }
        foreach ($k in $keys) {
            $name = "$($k.DisplayName)"
            if (-not $name -or $seen.ContainsKey($name)) { continue }
            if ($k.SystemComponent -eq 1 -or $k.ParentKeyName) { continue }
            if ($k.ReleaseType -match 'Update|Hotfix|Security Update') { continue }
            if (-not $k.UninstallString -and -not $k.QuietUninstallString) { continue }
            $seen[$name] = $true
            $out += [pscustomobject]@{ Name = $name; Quiet = "$($k.QuietUninstallString)"; Uninstall = "$($k.UninstallString)" }
        }
    }
    return $out
}

# Ce qu'un choix vise sur CE PC : la meme fonction pour l'analyse et l'action.
function Get-ChoiceTargets {
    param([string] $Key, $Appx, $Win32)
    $c = $Choices[$Key]
    if (-not $c) { return @() }
    if ($c.Kind -eq 'appx') { return @($Appx  | Where-Object { Test-Match "$($_.Name)" $c.Patterns }) }
    return @($Win32 | Where-Object { Test-Match "$($_.Name)" $c.Patterns })
}

# ==============================================================================
# 1. ANALYSE — un [FIND] par choix present, on ne desinstalle RIEN
# ==============================================================================

if ($env:WINTOOL_MODE -eq 'scan') {
    Write-Output "[STEP] 1/2 Reading installed Store apps"
    $appx  = Get-RemovableAppx
    Write-Output "[STEP] 2/2 Reading installed desktop apps"
    $win32 = Get-UninstallEntries
    Write-Output "[NOTE] Protected"
    $anyWin32 = $false
    foreach ($key in @('candycrush', 'solitaire', 'othergames', 'news', 'weather', 'msnapps', 'gethelp', 'tips', 'feedback', 'officehub', 'todo', 'powerautomate', 'cortana', 'teams', 'family', 'clipchamp', 'filmstv', 'groove', 'xbox', 'mixedreality', 'people', 'phonelink', 'mail', 'outlooknew', 'maps', 'skype', 'wallet', 'social', 'streaming', 'copilot', 'devhome', 'mcafee', 'norton', 'avast', 'hpextras', 'lenovoextras', 'dellextras', 'asusextras', 'acerextras', 'promos', 'cyberlink')) {
        $found = @(Get-ChoiceTargets $key $appx $win32)
        if ($found.Count -eq 0) { continue }
        $c = $Choices[$key]
        if ($c.Kind -eq 'win32') { $anyWin32 = $true }
        $chk = if ($c.Checked) { 'true' } else { 'false' }
        Write-Output "[FIND] Remove.$key count=$($found.Count) checked=$chk"
        Write-Output "[LOG] Scan $key -> $(($found | ForEach-Object { $_.Name }) -join ', ')"
    }
    if ($anyWin32) { Write-Output "[NOTE] Win32Note" }
    exit 0
}

# ==============================================================================
# 2. ACTION — uniquement les choix coches
# ==============================================================================

$errors  = 0
$removed = 0
if ($SafeTest) { Write-Host "[INFO] SafeTest mode - apps are listed, nothing is uninstalled" }

$wanted = @($CONFIG.Remove | ForEach-Object { "$_" } | Where-Object { $Choices.Contains($_) })
if ($wanted.Count -eq 0) {
    Write-Host "[WARN] No app selected - nothing to do"
    Write-Host "[DONE] Nothing removed"
    exit 0
}

$appx  = Get-RemovableAppx
$win32 = Get-UninstallEntries
$targets = @()
$done = @{}
foreach ($key in $wanted) {
    foreach ($t in @(Get-ChoiceTargets $key $appx $win32)) {
        if ($done.ContainsKey("$($t.Name)")) { continue }
        $done["$($t.Name)"] = $true
        $targets += [pscustomobject]@{
            Kind = $Choices[$key].Kind; Name = "$($t.Name)"
            FullName = if ($Choices[$key].Kind -eq 'appx') { $t.PackageFullName } else { '' }
            Quiet = if ($Choices[$key].Kind -eq 'win32') { $t.Quiet } else { '' }
            Uninstall = if ($Choices[$key].Kind -eq 'win32') { $t.Uninstall } else { '' }
        }
    }
}
if ($targets.Count -eq 0) {
    Write-Host "[OK]   None of the selected apps are installed"
    Write-Host "[DONE] Nothing removed"
    exit 0
}

$provisioned = @()
if ($CONFIG.RemoveProvisioned) {
    try { $provisioned = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue) } catch { $provisioned = @() }
}

# Desinstallation silencieuse d'une app Win32.
function Invoke-Win32Uninstall {
    param($Cand)
    $cmd = if ($Cand.Quiet) { $Cand.Quiet } else { $Cand.Uninstall }
    if (-not $cmd) { Write-Host "[WARN] No uninstall command for $($Cand.Name)"; return $false }
    if ($cmd -match 'msiexec') {
        $code = ''
        if ($cmd -match '\{[0-9A-Fa-f-]+\}') { $code = $Matches[0] }
        if (-not $code) { Write-Host "[WARN] Could not read MSI code for $($Cand.Name)"; return $false }
        if ($SafeTest) { Write-Host "[INFO] SafeTest - would run: msiexec /x $code /qn /norestart"; return $true }
        $p = Start-Process -FilePath 'msiexec.exe' -ArgumentList "/x $code /qn /norestart" -Wait -PassThru -ErrorAction Stop
        return ($p.ExitCode -eq 0 -or $p.ExitCode -eq 3010)
    }
    $file = ''; $argStr = ''
    if ($cmd -match '^\s*"([^"]+)"\s*(.*)$') { $file = $Matches[1]; $argStr = $Matches[2] }
    elseif ($cmd -match '^\s*(\S+)\s*(.*)$')  { $file = $Matches[1]; $argStr = $Matches[2] }
    if (-not $Cand.Quiet -and $argStr -notmatch '/S|/silent|/quiet|/qn') { $argStr = "$argStr /S".Trim() }
    if ($SafeTest) { Write-Host "[INFO] SafeTest - would run: $file $argStr"; return $true }
    try {
        $p = if ($argStr) { Start-Process -FilePath $file -ArgumentList $argStr -Wait -PassThru -ErrorAction Stop }
             else         { Start-Process -FilePath $file -Wait -PassThru -ErrorAction Stop }
        return ($p.ExitCode -eq 0 -or $p.ExitCode -eq 3010)
    } catch {
        Write-Host "[WARN] Uninstaller failed for $($Cand.Name): $($_.Exception.Message)"
        return $false
    }
}

$total = $targets.Count
$step  = 0
foreach ($t in $targets) {
    $step++
    Write-Host "[STEP] $step/$total $($t.Name)"
    if ($t.Kind -eq 'appx') {
        if ($SafeTest) {
            Write-Host "[INFO] SafeTest - would uninstall $($t.Name)"
        } else {
            $ok = $false
            try { Remove-AppxPackage -Package $t.FullName -AllUsers -ErrorAction Stop; $ok = $true }
            catch {
                try { Remove-AppxPackage -Package $t.FullName -ErrorAction Stop; $ok = $true }
                catch { Write-Host "[WARN] Could not remove $($t.Name): $($_.Exception.Message)" }
            }
            if ($ok) { Write-Host "[OK]   Removed $($t.Name)"; $removed++ }
        }
        if ($CONFIG.RemoveProvisioned) {
            foreach ($prov in @($provisioned | Where-Object { $_.DisplayName -eq $t.Name })) {
                if ($SafeTest) { Write-Host "[INFO] SafeTest - would deprovision $($prov.DisplayName)"; continue }
                try { Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction Stop | Out-Null
                      Write-Host "[OK]   Will not be reinstalled: $($t.Name)" }
                catch { Write-Host "[WARN] Could not deprovision $($prov.DisplayName): $($_.Exception.Message)" }
            }
        }
    } else {
        Write-Host "[INFO] Running the desktop uninstaller (it may take a moment)"
        if (Invoke-Win32Uninstall $t) {
            if (-not $SafeTest) { Write-Host "[OK]   Removed $($t.Name)"; $removed++ }
        } else {
            Write-Host "[WARN] $($t.Name) was not fully removed - it may need to be uninstalled by hand"
        }
    }
}

if ($SafeTest) {
    Write-Host "[DONE] SafeTest finished - nothing was uninstalled"
    exit 0
}
if ($errors -gt 0) {
    Write-Host "[DONE] Finished with $errors error(s)"
    exit 1
}
Write-Host "[DONE] $removed app(s) removed"
exit 0
