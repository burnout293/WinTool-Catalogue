## WINTOOL:START
## id            : 769bf6f5-1025-4fa4-a6dc-c126dd271a74
## lang          : en
## title         : Reduce telemetry
## desc          : Reduces the diagnostic data Windows sends to Microsoft
## category      : privacy
## icon          : shield-check
## tags          : telemetry, diagtrack, diagnostic data, ceip, privacy
## version       : 2.1
## admin         : true
## risk          : medium
## duration      : fast
## reversible    : true
## interruptible : true
## reboot         : true
## engine        : auto
## scan          : true
## view          : compare
## panels        : plan progress
## WINTOOL:END

## WINTOOL:OPTIONS
## DisablePolicy   : [bool] Data collection policy — lowest level allowed by your Windows edition
## DisableServices : [bool] Telemetry services — Connected User Experiences, WAP push
## DisableTasks    : [bool] Scheduled tasks — compatibility appraiser, improvement program
## SafeTest        : [bool] Safe test — simulates every change, modifies nothing
## WINTOOL:END

## WINTOOL:REPORT
## EditionNote : [note:info] Home and Pro cannot go below "Required diagnostic data"; that level is applied.
## RebootNote  : [note:warn] A restart is needed for the telemetry changes to fully apply.
## WINTOOL:END

## WINTOOL:LANG fr
## title           : Protéger ma vie privée
## desc            : Réduit ce que Windows transmet à Microsoft
## DisablePolicy   : Règle de collecte — le niveau le plus bas permis par votre édition de Windows
## DisableServices : Services de télémétrie — expériences utilisateur connectées, messages WAP
## DisableTasks    : Tâches planifiées — évaluation de compatibilité, programme d'amélioration
## SafeTest        : Test sans risque — simule chaque modification, ne change rien
## EditionNote     : Famille et Pro ne peuvent pas descendre sous « Données de diagnostic requises » ; ce niveau est appliqué.
## RebootNote      : Un redémarrage est nécessaire pour que les changements de télémétrie s'appliquent entièrement.
## WINTOOL:END

$CONFIG = @{
    DisablePolicy   = $true
    DisableServices = $true
    DisableTasks    = $true
    SafeTest        = $false
}

# --- WinTool override (ne pas supprimer) ---
if ($env:WINTOOL_CONFIG) {
    ($env:WINTOOL_CONFIG | ConvertFrom-Json).PSObject.Properties |
        ForEach-Object { $CONFIG[$_.Name] = $_.Value }
}

# ==============================================================================
# Code et sortie en anglais, commentaires en francais (docs/FORMAT_SCRIPT.md).
#
# AllowTelemetry = 0 n'est respecte que par les editions Entreprise / Education.
# Famille et Pro le ramenent a 1 ("donnees requises") : c'est le minimum possible.
#
# Chaque reglage est une case [bool] "Desactiver X". L'analyse constate l'ETAT
# actuel (state=ok deja fait / state=todo a faire) ; la vue "compare" l'affiche
# en "aujourd'hui -> apres". Les fonctions Test-* (etat) et Set-* (action) lisent
# et ecrivent exactement les memes cibles.
#
# Le script est lance deux fois (contrat du mode analyse, 1.4) :
#   1. ANALYSE (WINTOOL_MODE=scan) — une ligne [FIND] par case, avec son state=.
#   2. ACTION — WinTool renvoie dans $CONFIG les seules cases cochees ($true).
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')

$PolicyPaths = @(
    'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
)
$Services = @(
    @{ Name = 'DiagTrack';        Default = 'Automatic' },
    @{ Name = 'dmwappushservice'; Default = 'Manual' }
)
$Tasks = @(
    '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
    '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
    '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
    '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
    '\Microsoft\Windows\Autochk\Proxy'
)

# --- Etat actuel (lecture seule) : $true = deja en place -----------------------
function Test-PolicyDone {
    foreach ($path in $PolicyPaths) {
        $v = (Get-ItemProperty -Path $path -Name 'AllowTelemetry' -ErrorAction SilentlyContinue).AllowTelemetry
        if ($null -ne $v -and [int]$v -le 1) { return $true }
    }
    return $false
}
function Test-ServicesDone {
    foreach ($svc in $Services) {
        $s = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($s -and $s.StartType -ne 'Disabled') { return $false }
    }
    return $true
}
function Test-TasksDone {
    $any = $false
    foreach ($full in $Tasks) {
        $taskPath = $full.Substring(0, $full.LastIndexOf('\') + 1)
        $taskName = $full.Substring($full.LastIndexOf('\') + 1)
        $t = Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue
        if (-not $t) { continue }
        $any = $true
        if ($t.State -ne 'Disabled') { return $false }
    }
    return $any
}

# ==============================================================================
# 1. ANALYSE — on constate l'etat, on ne modifie RIEN
# ==============================================================================

if ($env:WINTOOL_MODE -eq 'scan') {

    Write-Output "[STEP] 1/1 Reading current telemetry settings"
    Write-Output "[NOTE] EditionNote DisablePolicy"
    Write-Output "[NOTE] RebootNote"

    $p = if (Test-PolicyDone)   { 'ok' } else { 'todo' }
    $s = if (Test-ServicesDone) { 'ok' } else { 'todo' }
    $t = if (Test-TasksDone)    { 'ok' } else { 'todo' }

    Write-Output "[FIND] DisablePolicy state=$p"
    Write-Output "[FIND] DisableServices state=$s"
    Write-Output "[FIND] DisableTasks state=$t"
    Write-Output "[LOG] Telemetry policy=$p services=$s tasks=$t"

    exit 0
}

# ==============================================================================
# 2. ACTION — on desactive uniquement les cases cochees
# ==============================================================================

$errors = 0

function Invoke-Change {
    param([string] $What, [scriptblock] $Action)
    if ($SafeTest) {
        Write-Host "[INFO] SafeTest - would $What"
        Start-Sleep -Milliseconds 150
        return
    }
    & $Action
}

if ($SafeTest) { Write-Host "[INFO] SafeTest mode - settings are read, nothing is changed" }

$edition = (Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption
Write-Host "[INFO] Edition: $edition"
$isEnterprise = ($edition -match 'Enterprise|Education|Entreprise')

$doPolicy   = ("$($CONFIG.DisablePolicy)"   -eq 'True')
$doServices = ("$($CONFIG.DisableServices)" -eq 'True')
$doTasks    = ("$($CONFIG.DisableTasks)"    -eq 'True')

$total = [int]$doPolicy + [int]$doServices + [int]$doTasks
if ($total -eq 0) {
    Write-Host "[WARN] Nothing selected - nothing to do"
    Write-Host "[DONE] Nothing changed"
    exit 0
}
$step = 0

if ($doPolicy) {
    $step++
    Write-Host "[STEP] $step/$total Data collection policy"
    if (-not $isEnterprise) {
        Write-Host "[INFO] This edition cannot go below 'Required diagnostic data' - that level will be applied"
    }
    foreach ($path in $PolicyPaths) {
        try {
            Invoke-Change "set AllowTelemetry = 0 in $path" {
                if (-not (Test-Path $path)) { New-Item -Path $path -Force -ErrorAction Stop | Out-Null }
                Set-ItemProperty -Path $path -Name 'AllowTelemetry' -Value 0 -Type DWord -ErrorAction Stop
            }
            if (-not $SafeTest) { Write-Host "[OK]   AllowTelemetry = 0 in $path" }
        } catch {
            Write-Host "[ERR]  $($path): $($_.Exception.Message)"
            $errors++
        }
    }
}

if ($doServices) {
    $step++
    Write-Host "[STEP] $step/$total Telemetry services"
    foreach ($svc in $Services) {
        $s = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if (-not $s) { Write-Host "[INFO] Service $($svc.Name) not present - skipped"; continue }
        try {
            Invoke-Change "stop and disable service $($svc.Name) (currently $($s.Status))" {
                Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
            }
            if (-not $SafeTest) { Write-Host "[OK]   $($svc.Name) stopped and disabled" }
        } catch {
            Write-Host "[ERR]  $($svc.Name): $($_.Exception.Message)"
            $errors++
        }
    }
}

if ($doTasks) {
    $step++
    Write-Host "[STEP] $step/$total Scheduled tasks"
    foreach ($full in $Tasks) {
        $taskPath = $full.Substring(0, $full.LastIndexOf('\') + 1)
        $taskName = $full.Substring($full.LastIndexOf('\') + 1)
        $t = Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue
        if (-not $t) { Write-Host "[INFO] Task $taskName not present - skipped"; continue }
        try {
            Invoke-Change "disable task $taskName" {
                Disable-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction Stop | Out-Null
            }
            if (-not $SafeTest) { Write-Host "[OK]   Task disabled: $taskName" }
        } catch {
            Write-Host "[ERR]  $($taskName): $($_.Exception.Message)"
            $errors++
        }
    }
}

if ($SafeTest) {
    Write-Host "[DONE] SafeTest finished - nothing was changed"
    exit 0
}

Write-Host "[REBOOT] Restart the PC to fully apply the telemetry settings"
if ($errors -gt 0) {
    Write-Host "[DONE] Finished with $errors error(s)"
    exit 1
}
Write-Host "[DONE] Telemetry settings updated"
exit 0
