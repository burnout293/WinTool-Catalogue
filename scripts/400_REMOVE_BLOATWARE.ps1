## WINTOOL:START
## id            : add42e62-5277-4ff2-a4ab-f84184ad2fc6
## lang          : en
## title         : Remove unwanted apps
## desc          : Uninstalls apps that Windows added without asking - games, news, promoted apps
## category      : apps
## icon          : package-minus
## tags          : bloatware, appx, candy crush, preinstalled, uninstall
## version       : 2.1
## admin         : true
## risk          : medium
## duration      : medium
## reversible    : false
## interruptible : true
## reboot        : false
## engine        : winps
## scan          : true
## view          : table
## panels        : plan progress
## WINTOOL:END

## WINTOOL:OPTIONS
## Apps              : [items] [view:table] Unwanted apps found on this PC
## RemoveProvisioned : [bool]  Prevent reinstallation — also removes them for future user accounts
## SafeTest          : [bool]  Safe test — simulates every change, modifies nothing
## WINTOOL:END

## WINTOOL:REPORT
## App      : App
## Protected : [note:info] The Store, winget, the Calculator, Photos and security apps are never listed or removed.
## WINTOOL:END

## WINTOOL:LANG fr
## title              : Retirer les applications inutiles
## desc               : Désinstalle ce que Windows a ajouté sans votre accord - jeux, actualités, applications promues
## Apps               : Applications inutiles trouvées sur ce PC
## RemoveProvisioned  : Empêcher la réinstallation — les retire aussi pour les futurs comptes
## SafeTest           : Test sans risque — simule chaque modification, ne change rien
## App                : Application
## Protected          : Le Store, winget, la Calculatrice, Photos et les applications de sécurité ne sont jamais listés ni retirés.
## WINTOOL:END

$CONFIG = @{
    Apps              = @()
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
# Les motifs sont des noms de paquets precis : aucun joker assez large pour
# toucher au Store, a App Installer (winget), aux VCLibs ou a la Calculatrice.
#
# Apps est une liste [items] : vide dans l'entete, remplie par l'analyse.
# L'id d'un element est le NOM du paquet (stable entre analyse et action). A
# l'action, on re-enumere les paquets installes et on ne garde que ceux dont le
# nom a ete coche : un id recu ne sert jamais a fabriquer un chemin.
#
# Le script est lance deux fois (contrat du mode analyse, 1.4) :
#   1. ANALYSE (WINTOOL_MODE=scan) — une ligne [ITEM] par application inutile
#      trouvee. La vue "table" les affiche en tableau triable et cherchable.
#   2. ACTION — WinTool renvoie dans $CONFIG.Apps les seuls ids coches.
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')

# Motifs par groupe (le groupe n'est plus une case : il sert a reconnaitre et a
# etiqueter les paquets trouves).
$Groups = @{
    games   = @('king.com.*', 'Microsoft.MicrosoftSolitaireCollection', '*.BubbleWitch3Saga', '*.MarchofEmpires', '*.AsphaltStreetStormRacing', '*.Disney*')
    news    = @('Microsoft.BingNews', 'Microsoft.BingWeather', 'Microsoft.BingFinance', 'Microsoft.BingSports')
    promo   = @('Microsoft.GetHelp', 'Microsoft.Getstarted', 'Microsoft.WindowsFeedbackHub', 'Microsoft.MicrosoftOfficeHub', 'Microsoft.Todos', 'Microsoft.PowerAutomateDesktop')
    social  = @('*Facebook*', '*Instagram*', '*TikTok*', '*Twitter*', '7EE7776C.LinkedInforWindows')
    cortana = @('Microsoft.549981C3F5F10')
    teams   = @('MicrosoftTeams')
    media   = @('Clipchamp.Clipchamp', 'Microsoft.ZuneVideo')
    xbox    = @('Microsoft.XboxApp', 'Microsoft.GamingApp', 'Microsoft.XboxGamingOverlay', 'Microsoft.XboxSpeechToTextOverlay')
}

# Garde-fou : jamais ces paquets, quel que soit le motif.
$Protected = @('Microsoft.WindowsStore', 'Microsoft.DesktopAppInstaller', 'Microsoft.VCLibs*', 'Microsoft.NET.*',
               'Microsoft.UI.Xaml*', 'Microsoft.WindowsCalculator', 'Microsoft.Windows.Photos', 'Microsoft.SecHealthUI',
               'Microsoft.Xbox.TCUI', 'Microsoft.XboxIdentityProvider')

function Test-Protected {
    param([string] $Name)
    foreach ($p in $Protected) { if ($Name -like $p) { return $true } }
    return $false
}

# Source unique de verite : les paquets installes reconnus comme inutiles.
# Retourne des objets { Name; Group; Publisher; FullName }. Lecture seule.
function Get-UnwantedPackages {
    $installed = @(Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue)
    $seen = @{}
    $out  = @()
    foreach ($group in $Groups.Keys) {
        foreach ($pattern in $Groups[$group]) {
            foreach ($pkg in @($installed | Where-Object { $_.Name -like $pattern -and -not (Test-Protected $_.Name) })) {
                if ($seen.ContainsKey($pkg.Name)) { continue }
                $seen[$pkg.Name] = $true
                $out += [pscustomobject]@{
                    Name      = $pkg.Name
                    Group     = $group
                    Publisher = "$($pkg.Publisher)"
                    FullName  = $pkg.PackageFullName
                }
            }
        }
    }
    return $out
}

# Nom d'editeur court et lisible a partir du champ Publisher (CN=...).
function Get-ShortPublisher {
    param([string] $Publisher)
    if ($Publisher -match 'CN=([^,]+)') { return $Matches[1] }
    if ($Publisher) { return $Publisher }
    return 'Unknown'
}

# ==============================================================================
# 1. ANALYSE — on liste les applications inutiles, on ne desinstalle RIEN
# ==============================================================================

if ($env:WINTOOL_MODE -eq 'scan') {

    Write-Output "[STEP] 1/1 Looking for unwanted apps"
    Write-Output "[NOTE] Protected"

    $found = @(Get-UnwantedPackages)
    foreach ($p in $found) {
        $pub = Get-ShortPublisher $p.Publisher
        # id = nom du paquet (stable). name = ce que l'utilisateur lit. Coche d'office.
        Write-Output "[ITEM] Apps id=$($p.Name) label=App name=""$($p.Name)"" publisher=""$pub"" kind=app confidence=high checked=true"
        Write-Output "[LOG] Apps $($p.Group): $($p.Name)"
    }
    if ($found.Count -eq 0) { Write-Output "[LOG] Apps No unwanted app found" }

    exit 0
}

# ==============================================================================
# 2. ACTION — uniquement les paquets coches
# ==============================================================================

$errors  = 0
$removed = 0

if ($SafeTest) { Write-Host "[INFO] SafeTest mode - apps are listed, nothing is uninstalled" }

$wanted = @($CONFIG.Apps | ForEach-Object { "$_" })
if ($wanted.Count -eq 0) {
    Write-Host "[WARN] No app selected - nothing to do"
    Write-Host "[DONE] Nothing removed"
    exit 0
}

# On re-enumere et on ne garde que ce que WinTool a coche, re-verifie protege.
$installed = @(Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue)
$targets   = @($installed | Where-Object { $wanted -contains $_.Name -and -not (Test-Protected $_.Name) })
$provisioned = @()
if ($CONFIG.RemoveProvisioned) {
    $provisioned = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue)
}

$total = $targets.Count
$step  = 0
foreach ($pkg in $targets) {
    $step++
    Write-Host "[STEP] $step/$total $($pkg.Name)"
    if ($SafeTest) {
        Write-Host "[INFO] SafeTest - would uninstall $($pkg.Name) $($pkg.Version)"
        Start-Sleep -Milliseconds 120
    } else {
        try {
            Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
            Write-Host "[OK]   Removed $($pkg.Name)"
            $removed++
        } catch {
            try {
                Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
                Write-Host "[OK]   Removed $($pkg.Name) (current account)"
                $removed++
            } catch {
                Write-Host "[WARN] Could not remove $($pkg.Name): $($_.Exception.Message)"
            }
        }
    }

    if ($CONFIG.RemoveProvisioned) {
        foreach ($prov in @($provisioned | Where-Object { $_.DisplayName -eq $pkg.Name -and -not (Test-Protected $_.DisplayName) })) {
            if ($SafeTest) {
                Write-Host "[INFO] SafeTest - would deprovision $($prov.DisplayName)"
                continue
            }
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction Stop | Out-Null
                Write-Host "[OK]   Will not be reinstalled: $($prov.DisplayName)"
            } catch {
                Write-Host "[WARN] Could not deprovision $($prov.DisplayName): $($_.Exception.Message)"
            }
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
