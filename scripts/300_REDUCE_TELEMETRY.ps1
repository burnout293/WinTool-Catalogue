## WINTOOL:START
## id            : 769bf6f5-1025-4fa4-a6dc-c126dd271a74
## lang          : en
## title         : Reduce telemetry
## desc          : Reduces the diagnostic data Windows sends to Microsoft
## category      : privacy
## icon          : shield-check
## tags          : telemetry, diagtrack, diagnostic data, ceip, privacy, restart required, redémarrage
## version       : 2.3
## admin         : true
## risk          : medium
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
## DisablePolicy   : [bool] [scan] Data collection policy — lowest level allowed by your Windows edition
## DisableServices : [bool] [scan] Telemetry services — Connected User Experiences, WAP push
## DisableTasks    : [bool] [scan] Scheduled tasks — compatibility appraiser, improvement program
## Details         : [items] [view:tree] Exact changes — expand a part to see each registry value, service or task, current -> target
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
## Details         : Modifications exactes — dépliez une partie pour voir chaque valeur de registre, service ou tâche, actuel -> cible
## SafeTest        : Test sans risque — simule chaque modification, ne change rien
## EditionNote     : Famille et Pro ne peuvent pas descendre sous « Données de diagnostic requises » ; ce niveau est appliqué.
## RebootNote      : Un redémarrage est nécessaire pour que les changements de télémétrie s'appliquent entièrement.
## WINTOOL:END

$CONFIG = @{
    DisablePolicy   = $true
    DisableServices = $true
    DisableTasks    = $true
    Details         = @()
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
    @{ Name = 'DiagTrack';        Label = 'Connected User Experiences and Telemetry' },
    @{ Name = 'dmwappushservice'; Label = 'Device Management WAP Push' }
)
$Tasks = @(
    '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
    '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
    '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
    '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
    '\Microsoft\Windows\Autochk\Proxy'
)

function Format-Key([string] $p) { return ($p -replace '^(HK[A-Z]+):', '$1') }
function Split-Task([string] $full) {
    @{ Path = $full.Substring(0, $full.LastIndexOf('\') + 1); Name = $full.Substring($full.LastIndexOf('\') + 1) }
}

# Source unique : chaque modification possible, avec son etat actuel. Lecture seule.
# Id : "policy-<i>", "services-<i>", "tasks-<i>" (index dans les tables ci-dessus).
function Get-Changes {
    $out = @()
    for ($i = 0; $i -lt $PolicyPaths.Count; $i++) {
        $p = $PolicyPaths[$i]
        $cur = (Get-ItemProperty -Path $p -Name 'AllowTelemetry' -ErrorAction SilentlyContinue).AllowTelemetry
        $out += [pscustomobject]@{ Id = "policy-$i"; Part = 'policy'; Kind = 'registry'; Index = $i
            Name = "AllowTelemetry: $(if ($null -eq $cur) { 'not set' } else { $cur }) -> 0"; Path = (Format-Key $p)
            Done = ($null -ne $cur -and [int]$cur -le 1) }
    }
    for ($i = 0; $i -lt $Services.Count; $i++) {
        $s = Get-Service -Name $Services[$i].Name -ErrorAction SilentlyContinue
        if (-not $s) { continue }
        $out += [pscustomobject]@{ Id = "services-$i"; Part = 'services'; Kind = 'service'; Index = $i
            Name = "$($Services[$i].Name): $($s.StartType) -> Disabled"; Path = $Services[$i].Label
            Done = ("$($s.StartType)" -eq 'Disabled') }
    }
    for ($i = 0; $i -lt $Tasks.Count; $i++) {
        $tp = Split-Task $Tasks[$i]
        $task = Get-ScheduledTask -TaskPath $tp.Path -TaskName $tp.Name -ErrorAction SilentlyContinue
        if (-not $task) { continue }
        $out += [pscustomobject]@{ Id = "tasks-$i"; Part = 'tasks'; Kind = 'task'; Index = $i
            Name = "$($tp.Name): $($task.State) -> Disabled"; Path = $tp.Path
            Done = ("$($task.State)" -eq 'Disabled') }
    }
    return $out
}

# ==============================================================================
# 1. ANALYSE — arbre : parent = partie (strategie, services, taches), enfant =
# chaque valeur / service / tache reels. Coche d'office si pas encore fait ET la
# partie est activee dans la config. On ne modifie RIEN.
# ==============================================================================

if ($env:WINTOOL_MODE -eq 'scan') {
    Write-Output "[STEP] 1/1 Reading current telemetry settings"
    Write-Output "[NOTE] EditionNote Details"
    Write-Output "[NOTE] RebootNote"
    $enabled = @{
        policy   = ("$($CONFIG.DisablePolicy)"   -eq 'True')
        services = ("$($CONFIG.DisableServices)" -eq 'True')
        tasks    = ("$($CONFIG.DisableTasks)"    -eq 'True')
    }
    Write-Output "[ITEM] Details id=policy name=""Data collection policy"" kind=registry"
    Write-Output "[ITEM] Details id=services name=""Telemetry services"" kind=service"
    Write-Output "[ITEM] Details id=tasks name=""Telemetry scheduled tasks"" kind=task"
    foreach ($c in Get-Changes) {
        $state = if ($c.Done) { 'ok' } else { 'todo' }
        $chk   = if (-not $c.Done -and $enabled[$c.Part]) { 'true' } else { 'false' }
        Write-Output "[ITEM] Details id=$($c.Id) parent=$($c.Part) kind=$($c.Kind) name=""$($c.Name)"" path=""$($c.Path)"" state=$state checked=$chk"
    }
    exit 0
}

# ==============================================================================
# 2. ACTION — apres une analyse, uniquement les elements coches (Details) ;
# sans analyse, les parties activees (DisablePolicy / Services / Tasks).
# ==============================================================================

$errors = 0
function Invoke-Change {
    param([string] $What, [scriptblock] $Action)
    if ($SafeTest) { Write-Host "[INFO] SafeTest - would $What"; Start-Sleep -Milliseconds 150; return }
    & $Action
}

if ($SafeTest) { Write-Host "[INFO] SafeTest mode - settings are read, nothing is changed" }

$edition = (Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption
Write-Host "[INFO] Edition: $edition"
$isEnterprise = ($edition -match 'Enterprise|Education|Entreprise')

$detail = @($CONFIG.Details | ForEach-Object { "$_" } | Where-Object { $_ -match '^(policy|services|tasks)-\d+$' })
function Test-Wanted([string] $Part, [int] $Index) {
    if ($detail.Count -gt 0) { return ($detail -contains "$Part-$Index") }
    switch ($Part) {
        'policy'   { return ("$($CONFIG.DisablePolicy)"   -eq 'True') }
        'services' { return ("$($CONFIG.DisableServices)" -eq 'True') }
        'tasks'    { return ("$($CONFIG.DisableTasks)"    -eq 'True') }
    }
    return $false
}
$doPolicy   = @(0..($PolicyPaths.Count - 1) | Where-Object { Test-Wanted 'policy' $_ }).Count -gt 0
$doServices = @(0..($Services.Count - 1)    | Where-Object { Test-Wanted 'services' $_ }).Count -gt 0
$doTasks    = @(0..($Tasks.Count - 1)       | Where-Object { Test-Wanted 'tasks' $_ }).Count -gt 0

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
    if (-not $isEnterprise) { Write-Host "[INFO] This edition cannot go below 'Required diagnostic data' - that level will be applied" }
    for ($i = 0; $i -lt $PolicyPaths.Count; $i++) {
        if (-not (Test-Wanted 'policy' $i)) { continue }
        $path = $PolicyPaths[$i]
        try {
            Invoke-Change "set $(Format-Key $path)\AllowTelemetry = 0" {
                if (-not (Test-Path $path)) { New-Item -Path $path -Force -ErrorAction Stop | Out-Null }
                Set-ItemProperty -Path $path -Name 'AllowTelemetry' -Value 0 -Type DWord -ErrorAction Stop
            }
            if (-not $SafeTest) { Write-Host "[OK]   $(Format-Key $path)\AllowTelemetry = 0" }
        } catch { Write-Host "[ERR]  $($path): $($_.Exception.Message)"; $errors++ }
    }
}

if ($doServices) {
    $step++
    Write-Host "[STEP] $step/$total Telemetry services"
    for ($i = 0; $i -lt $Services.Count; $i++) {
        if (-not (Test-Wanted 'services' $i)) { continue }
        $name = $Services[$i].Name
        $s = Get-Service -Name $name -ErrorAction SilentlyContinue
        if (-not $s) { Write-Host "[INFO] Service $name not present - skipped"; continue }
        try {
            Invoke-Change "stop and disable service $name (currently $($s.Status), $($s.StartType))" {
                Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
                Set-Service -Name $name -StartupType Disabled -ErrorAction Stop
            }
            if (-not $SafeTest) { Write-Host "[OK]   Service $name stopped and disabled" }
        } catch { Write-Host "[ERR]  $($name): $($_.Exception.Message)"; $errors++ }
    }
}

if ($doTasks) {
    $step++
    Write-Host "[STEP] $step/$total Scheduled tasks"
    for ($i = 0; $i -lt $Tasks.Count; $i++) {
        if (-not (Test-Wanted 'tasks' $i)) { continue }
        $tp = Split-Task $Tasks[$i]
        $task = Get-ScheduledTask -TaskPath $tp.Path -TaskName $tp.Name -ErrorAction SilentlyContinue
        if (-not $task) { Write-Host "[INFO] Task $($tp.Name) not present - skipped"; continue }
        try {
            Invoke-Change "disable task $($Tasks[$i])" {
                Disable-ScheduledTask -TaskPath $tp.Path -TaskName $tp.Name -ErrorAction Stop | Out-Null
            }
            if (-not $SafeTest) { Write-Host "[OK]   Task disabled: $($Tasks[$i])" }
        } catch { Write-Host "[ERR]  $($tp.Name): $($_.Exception.Message)"; $errors++ }
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
