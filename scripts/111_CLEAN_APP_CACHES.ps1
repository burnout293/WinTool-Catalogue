## WINTOOL:START
## id            : 3092147a-c8de-453f-b73d-582daba270f0
## lang          : en
## title         : Clear app caches
## desc          : Frees disk space used by the caches of common apps - your accounts and settings are not touched
## category      : cleaning
## icon          : eraser
## tags          : cache, discord, teams, spotify, slack, nvidia, adobe, disk space
## version       : 1.1
## admin         : false
## risk          : low
## duration      : medium
## reversible    : false
## interruptible : true
## reboot        : false
## engine        : auto
## scan          : true
## view          : bars
## panels        : plan progress
## WINTOOL:END

## WINTOOL:OPTIONS
## Apps         : [multi]  Apps to clean — pick one or more
##   teams      : Microsoft Teams — classic and new
##   discord    : Discord
##   slack      : Slack
##   spotify    : Spotify
##   zoom       : Zoom
##   vscode     : Visual Studio Code
##   nvidia     : NVIDIA and DirectX shader cache — rebuilt automatically
##   adobe      : Adobe media cache — Premiere, After Effects, Media Encoder
##   steam      : Steam web cache
##   epic       : Epic Games Launcher web cache
##   onedrive   : OneDrive cache — not your files, only the temporary cache
## CustomPaths  : [string] [scan] Extra cache folders — full paths separated by semicolons
## CloseApps    : [bool]   Close open apps — otherwise an open app is skipped
## MinAge       : [select] [scan] Minimum file age — newer files are kept
##   h0         : No minimum — every file
##   h1         : Older than 1 hour
##   h24        : Older than 1 day
##   h48        : Older than 2 days
##   h168       : Older than 1 week
## SafeTest     : [bool]   Safe test — simulates every change, modifies nothing
## WINTOOL:END

## WINTOOL:LANG fr
## title        : Vider le cache des applications
## desc         : Libère la place occupée par le cache des applications courantes - vos comptes et réglages ne sont pas touchés
## Apps         : Applications à nettoyer — une ou plusieurs
##   teams      : Microsoft Teams — classique et nouveau
##   discord    : Discord
##   slack      : Slack
##   spotify    : Spotify
##   zoom       : Zoom
##   vscode     : Visual Studio Code
##   nvidia     : Cache de shaders NVIDIA et DirectX — reconstruit automatiquement
##   adobe      : Cache multimédia Adobe — Premiere, After Effects, Media Encoder
##   steam      : Cache web de Steam
##   epic       : Cache web de l'Epic Games Launcher
##   onedrive   : Cache OneDrive — pas vos fichiers, seulement le cache temporaire
## CustomPaths  : Dossiers de cache supplémentaires — chemins complets séparés par des points-virgules
## CloseApps    : Fermer les applications ouvertes — sinon une application ouverte est ignorée
## MinAge       : Ancienneté minimale — les fichiers plus récents sont conservés
##   h0         : Aucune — tous les fichiers
##   h1         : Plus d'une heure
##   h24        : Plus d'un jour
##   h48        : Plus de 2 jours
##   h168       : Plus d'une semaine
## SafeTest     : Test sans risque — simule chaque modification, ne change rien
## WINTOOL:END

$CONFIG = @{
    Apps        = @("teams", "discord", "slack", "spotify", "vscode", "nvidia")
    CustomPaths = ""
    CloseApps   = $false
    MinAge      = "h0"
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
# On ne vide QUE des dossiers de cache reconstructibles : jamais un dossier de
# donnees, de compte ou de configuration. Chaque application declare son ou ses
# processus (pour l'option "fermer") et une liste de dossiers de cache.
# SafeTest : les caches sont mesures (lecture seule), rien n'est ferme ni supprime.
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')
$freed    = [long]0
# Correspondance des choix MinAge -> heures.
$MinAgeMap = @{ h0 = 0; h1 = 1; h24 = 24; h48 = 48; h168 = 168 }
$MinAgeHours = $MinAgeMap["$($CONFIG.MinAge)"]
if ($null -eq $MinAgeHours) { $MinAgeHours = 0 }
$cutoff   = (Get-Date).AddHours(-[double]$MinAgeHours)

$LOCAL = $env:LOCALAPPDATA
$ROAM  = $env:APPDATA

# Definition par application : nom affiche, processus a fermer, dossiers de cache.
$AppDefs = @{
    teams   = @{ Name = 'Microsoft Teams'; Proc = @('Teams', 'ms-teams'); Dirs = @(
        (Join-Path $ROAM 'Microsoft\Teams\Cache'),
        (Join-Path $ROAM 'Microsoft\Teams\Code Cache'),
        (Join-Path $ROAM 'Microsoft\Teams\GPUCache'),
        (Join-Path $ROAM 'Microsoft\Teams\Service Worker\CacheStorage'),
        (Join-Path $LOCAL 'Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\PreviousEBWebView\Default\Cache'),
        (Join-Path $LOCAL 'Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\EBWebView\Default\Cache')
    ) }
    discord = @{ Name = 'Discord'; Proc = @('Discord'); Dirs = @(
        (Join-Path $ROAM 'discord\Cache'),
        (Join-Path $ROAM 'discord\Code Cache'),
        (Join-Path $ROAM 'discord\GPUCache')
    ) }
    slack   = @{ Name = 'Slack'; Proc = @('slack'); Dirs = @(
        (Join-Path $ROAM 'Slack\Cache'),
        (Join-Path $ROAM 'Slack\Code Cache'),
        (Join-Path $ROAM 'Slack\GPUCache'),
        (Join-Path $ROAM 'Slack\Service Worker\CacheStorage')
    ) }
    spotify = @{ Name = 'Spotify'; Proc = @('Spotify'); Dirs = @(
        (Join-Path $LOCAL 'Spotify\Data'),
        (Join-Path $LOCAL 'Spotify\Storage'),
        (Join-Path $LOCAL 'Spotify\Browser\Cache')
    ) }
    zoom    = @{ Name = 'Zoom'; Proc = @('Zoom'); Dirs = @(
        (Join-Path $ROAM 'Zoom\data\Structured'),
        (Join-Path $LOCAL 'Zoom\data\GPUCache')
    ) }
    vscode  = @{ Name = 'Visual Studio Code'; Proc = @('Code'); Dirs = @(
        (Join-Path $ROAM 'Code\Cache'),
        (Join-Path $ROAM 'Code\CachedData'),
        (Join-Path $ROAM 'Code\Code Cache'),
        (Join-Path $ROAM 'Code\GPUCache')
    ) }
    nvidia  = @{ Name = 'NVIDIA / DirectX shader cache'; Proc = @(); Dirs = @(
        (Join-Path $LOCAL 'NVIDIA\DXCache'),
        (Join-Path $LOCAL 'NVIDIA\GLCache'),
        (Join-Path $LOCAL 'NVIDIA Corporation\NV_Cache'),
        (Join-Path $LOCAL 'D3DSCache')
    ) }
    adobe   = @{ Name = 'Adobe media cache'; Proc = @(); Dirs = @(
        (Join-Path $ROAM 'Adobe\Common\Media Cache Files'),
        (Join-Path $ROAM 'Adobe\Common\Media Cache')
    ) }
    steam   = @{ Name = 'Steam web cache'; Proc = @(); Dirs = @(
        (Join-Path $LOCAL 'Steam\htmlcache')
    ) }
    epic    = @{ Name = 'Epic Games Launcher'; Proc = @(); Dirs = @(
        (Join-Path $LOCAL 'EpicGamesLauncher\Saved\webcache'),
        (Join-Path $LOCAL 'EpicGamesLauncher\Saved\webcache_4147'),
        (Join-Path $LOCAL 'EpicGamesLauncher\Saved\webcache_4430')
    ) }
    onedrive = @{ Name = 'OneDrive cache'; Proc = @(); Dirs = @(
        (Join-Path $LOCAL 'Microsoft\OneDrive\cache')
    ) }
}

function Format-Size {
    param([long] $Bytes)
    if ($Bytes -ge 1GB) { return ('{0:N2} GB' -f ($Bytes / 1GB)) }
    if ($Bytes -ge 1MB) { return ('{0:N1} MB' -f ($Bytes / 1MB)) }
    return ('{0:N0} KB' -f ($Bytes / 1KB))
}

# Vide un dossier de cache : fichiers plus vieux que le seuil, puis dossiers vides.
# Renvoie les octets liberes (ou qui le seraient en SafeTest).
function Clear-CacheDir {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) { return [long]0 }

    $files = @(Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
               Where-Object { $_.LastWriteTime -lt $cutoff })
    if ($files.Count -eq 0) { return [long]0 }

    if ($SafeTest) {
        return [long](($files | Measure-Object -Property Length -Sum).Sum)
    }

    $done = [long]0
    foreach ($f in $files) {
        try { $len = $f.Length; Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop; $done += $len } catch { }
    }
    Get-ChildItem -LiteralPath $Path -Recurse -Force -Directory -ErrorAction SilentlyContinue |
        Sort-Object { $_.FullName.Length } -Descending |
        ForEach-Object {
            if (-not (Get-ChildItem -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue)) {
                Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
            }
        }
    return $done
}

# Mesure (analyse, lecture seule) : memes fichiers que Clear-CacheDir (seuil compris).
function Measure-CacheDirs {
    param($Dirs)
    $size = [long]0; $count = 0
    foreach ($d in $Dirs) {
        if (-not (Test-Path -LiteralPath $d)) { continue }
        $files = @(Get-ChildItem -LiteralPath $d -Recurse -Force -File -ErrorAction SilentlyContinue |
                   Where-Object { $_.LastWriteTime -lt $cutoff })
        $size  += [long](($files | Measure-Object -Property Length -Sum).Sum)
        $count += $files.Count
    }
    [pscustomobject]@{ Size = $size; Count = $count }
}

# ==============================================================================
# ANALYSE - on mesure, on ne supprime ni ne ferme RIEN
# ==============================================================================

if ($env:WINTOOL_MODE -eq 'scan') {
    $order = @('teams', 'discord', 'slack', 'spotify', 'zoom', 'vscode', 'nvidia', 'adobe', 'steam', 'epic', 'onedrive')
    $i = 0
    foreach ($a in $order) {
        $i++
        Write-Output "[STEP] $i/$($order.Count) Measuring $a"
        $existing = @($AppDefs[$a].Dirs | Where-Object { Test-Path -LiteralPath $_ })
        # Application absente : aucun constat.
        if ($existing.Count -eq 0) { continue }
        $m = Measure-CacheDirs $existing
        Write-Output "[FIND] Apps.$a size=$($m.Size) count=$($m.Count)"
    }
    exit 0
}

# ==============================================================================

if ($SafeTest) { Write-Host "[INFO] SafeTest mode - caches are measured, nothing is closed or deleted" }

# Liste de travail : applications choisies + une entree "custom" si des chemins
# manuels ont ete fournis.
$selected = @($CONFIG.Apps)
$custom   = @("$($CONFIG.CustomPaths)" -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$total    = $selected.Count + $(if ($custom.Count -gt 0) { 1 } else { 0 })

if ($total -eq 0) {
    Write-Host "[WARN] Nothing selected - nothing to do"
    Write-Host "[DONE] Nothing cleaned"
    exit 0
}

$step = 0
foreach ($key in $selected) {
    $step++
    $def = $AppDefs[$key]
    if (-not $def) {
        Write-Host "[STEP] $step/$total Unknown app '$key'"
        Write-Host "[WARN] Unknown app '$key' - skipped"
        continue
    }
    Write-Host "[STEP] $step/$total $($def.Name)"

    $existing = @($def.Dirs | Where-Object { Test-Path -LiteralPath $_ })
    if ($existing.Count -eq 0) {
        Write-Host "[INFO] Not installed or no cache found - skipped"
        continue
    }

    # Une application ouverte verrouille son cache.
    $running = @()
    foreach ($pname in $def.Proc) { $running += @(Get-Process -Name $pname -ErrorAction SilentlyContinue) }
    if ($running.Count -gt 0) {
        if (-not $CONFIG.CloseApps) {
            Write-Host "[WARN] $($def.Name) is open - skipped (enable 'Close open apps' to include it)"
            continue
        }
        if ($SafeTest) {
            Write-Host "[INFO] SafeTest - would close $($def.Name) ($($running.Count) process(es))"
        } else {
            Write-Host "[INFO] Closing $($def.Name)"
            $running | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
    }

    $appFreed = [long]0
    foreach ($dir in $existing) { $appFreed += Clear-CacheDir $dir }
    $freed += $appFreed

    if ($SafeTest) {
        Write-Host "[INFO] SafeTest - would free $(Format-Size $appFreed) in $($existing.Count) cache folder(s)"
        Start-Sleep -Milliseconds 200
    } else {
        Write-Host "[OK]   $($def.Name): $(Format-Size $appFreed) freed"
    }
}

if ($custom.Count -gt 0) {
    $step++
    Write-Host "[STEP] $step/$total Custom cache folders"
    $customFreed = [long]0
    foreach ($path in $custom) {
        if (-not (Test-Path -LiteralPath $path)) {
            Write-Host "[WARN] Not found: $path"
            continue
        }
        $got = Clear-CacheDir $path
        $customFreed += $got
        if ($SafeTest) {
            Write-Host "[INFO] SafeTest - would free $(Format-Size $got) in $path"
        } else {
            Write-Host "[OK]   $path : $(Format-Size $got) freed"
        }
    }
    $freed += $customFreed
}

if ($SafeTest) {
    Write-Host "[INFO] SafeTest - about $(Format-Size $freed) could be freed"
    Write-Host "[DONE] SafeTest finished - nothing was deleted"
    exit 0
}
Write-Output "[FREED] $freed"
Write-Host "[INFO] Total freed: $(Format-Size $freed)"
Write-Host "[DONE] App caches cleared"
exit 0
