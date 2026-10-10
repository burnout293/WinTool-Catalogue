## WINTOOL:START
## id            : 0a69f536-0395-4ba3-8e39-f6682b4ff29d
## lang          : en
## title         : Check disk health
## desc          : Checks the health, wear and temperature of your disks and the free space left - changes nothing
## category      : health
## icon          : hard-drive
## tags          : smart, disk, ssd, hdd, wear, temperature, free space
## version       : 2.2
## admin         : true
## risk          : low
## duration      : fast
## reversible    : false
## interruptible : true
## reboot        : false
## engine        : auto
## scan          : true
## view          : light
## panels        : progress
## WINTOOL:END

## WINTOOL:OPTIONS
## WearWarnPercent  : [number] [scan] Wear warning — SSD wear level that triggers a warning, in percent
## TempWarnCelsius  : [number] [scan] Temperature warning — in degrees Celsius
## FreeWarnPercent  : [number] [scan] Low space warning — free space below this percentage
## SafeTest         : [bool]          Safe test — simulates every change, modifies nothing
## WINTOOL:END

## WINTOOL:REPORT
## Health      : Disks reported healthy
## Wear        : Highest wear level
## Temperature : Highest temperature
## PowerOn     : Longest power-on time
## FreeSpace   : Lowest free space
## ReadOnly    : [note:info] This script only measures. It never changes anything on your disks.
## WINTOOL:END

## WINTOOL:LANG fr
## title            : Vérifier la santé des disques
## desc             : Contrôle l'état, l'usure et la température de vos disques et la place restante - ne modifie rien
## WearWarnPercent  : Alerte d'usure — niveau d'usure d'un SSD qui déclenche une alerte, en pourcentage
## TempWarnCelsius  : Alerte de température — en degrés Celsius
## FreeWarnPercent  : Alerte d'espace — place libre sous ce pourcentage
## SafeTest         : Test sans risque — simule chaque modification, ne change rien
## Health           : Disques en bonne santé
## Wear             : Usure la plus élevée
## Temperature      : Température la plus élevée
## PowerOn          : Temps de fonctionnement le plus long
## FreeSpace        : Espace libre le plus bas
## ReadOnly         : Ce script ne fait que mesurer. Il ne change jamais rien sur vos disques.
## WINTOOL:END

$CONFIG = @{
    WearWarnPercent = 80
    TempWarnCelsius = 60
    FreeWarnPercent = 10
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
# Script en LECTURE SEULE : il ne modifie jamais rien, en analyse comme en action.
#
# Le script est lance deux fois (contrat du mode analyse, 1.4) :
#   1. ANALYSE (WINTOOL_MODE=scan) — il MESURE l'etat des disques et ecrit des
#      [METRIC] avec un health= (ok / warn / crit). La vue "light" les affiche en
#      feu tricolore : tout va bien, un point a surveiller, un probleme.
#   2. ACTION — comme ce script ne rapporte QUE des mesures (aucune case a cocher),
#      WinTool ne le relance PAS : le diagnostic a deja ete fait pendant l'analyse.
#
# Hors WinTool (double-clic), tout le corps ci-dessous s'execute et affiche le
# detail en clair, disque par disque.
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')

function Format-Size {
    param([double] $Bytes)
    if ($Bytes -ge 1TB) { return ('{0:N2} TB' -f ($Bytes / 1TB)) }
    return ('{0:N0} GB' -f ($Bytes / 1GB))
}

# La source unique de verite : lue a l'identique par l'analyse et par le corps.
# Retourne un objet avec le pire cas observe sur l'ensemble des disques / volumes.
function Get-DiskSummary {
    $disks   = @(Get-PhysicalDisk -ErrorAction SilentlyContinue)
    $healthy = 0
    $worstHealth = 'ok'
    $maxWear = $null
    $maxTemp = $null
    $maxHours = $null

    foreach ($d in $disks) {
        switch ("$($d.HealthStatus)") {
            'Healthy'   { $healthy++ }
            'Warning'   { if ($worstHealth -ne 'crit') { $worstHealth = 'warn' } }
            'Unhealthy' { $worstHealth = 'crit' }
        }
        $rel = $d | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue
        if (-not $rel) { continue }
        if ($null -ne $rel.Wear)        { if ($null -eq $maxWear  -or $rel.Wear        -gt $maxWear)  { $maxWear  = [int]$rel.Wear } }
        if ($rel.Temperature -gt 0)     { if ($null -eq $maxTemp  -or $rel.Temperature -gt $maxTemp)  { $maxTemp  = [int]$rel.Temperature } }
        if ($rel.PowerOnHours -gt 0)    { if ($null -eq $maxHours -or $rel.PowerOnHours -gt $maxHours) { $maxHours = [int]$rel.PowerOnHours } }
    }

    $volumes = @(Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' -and $_.Size -gt 0 })
    $minFree = $null
    foreach ($v in $volumes) {
        $pct = [math]::Round(100 * $v.SizeRemaining / $v.Size)
        if ($null -eq $minFree -or $pct -lt $minFree) { $minFree = [int]$pct }
    }

    [pscustomobject]@{
        Disks       = $disks
        Volumes     = $volumes
        DiskCount   = $disks.Count
        Healthy     = $healthy
        WorstHealth = $worstHealth
        MaxWear     = $maxWear
        MaxTemp     = $maxTemp
        MaxHours    = $maxHours
        MinFree     = $minFree
    }
}

# ==============================================================================
# 1. ANALYSE — on mesure, on decrit en [METRIC], on ne modifie RIEN
# ==============================================================================

if ($env:WINTOOL_MODE -eq 'scan') {

    Write-Output "[STEP] 1/2 Reading physical disks"
    $s = Get-DiskSummary

    # Une note en tete : ce script ne touche a rien.
    Write-Output "[NOTE] ReadOnly"

    # --- Disques : sante globale, usure, temperature, anciennete ---
    $hc = if ($s.WorstHealth -eq 'crit') { 'crit' } elseif ($s.WorstHealth -eq 'warn') { 'warn' } else { 'ok' }
    Write-Output "[METRIC] Health value=$($s.Healthy) unit=count health=$hc max=$([math]::Max(1,$s.DiskCount))"
    Write-Output "[LOG] Disks $($s.Healthy)/$($s.DiskCount) disk(s) reported healthy"

    if ($null -ne $s.MaxWear) {
        $wh = if ($s.MaxWear -ge $CONFIG.WearWarnPercent) { 'warn' } else { 'ok' }
        Write-Output "[METRIC] Wear value=$($s.MaxWear) unit=pct health=$wh max=100"
    }
    if ($null -ne $s.MaxTemp) {
        $th = if ($s.MaxTemp -ge $CONFIG.TempWarnCelsius) { 'warn' } else { 'ok' }
        Write-Output "[METRIC] Temperature value=$($s.MaxTemp) unit=celsius health=$th"
    }
    if ($null -ne $s.MaxHours) {
        Write-Output "[METRIC] PowerOn value=$($s.MaxHours) unit=hours health=ok"
    }

    Write-Output "[STEP] 2/2 Reading free space"
    if ($null -ne $s.MinFree) {
        $fh = if ($s.MinFree -lt $CONFIG.FreeWarnPercent) { 'crit' } elseif ($s.MinFree -lt ($CONFIG.FreeWarnPercent * 2)) { 'warn' } else { 'ok' }
        Write-Output "[METRIC] FreeSpace value=$($s.MinFree) unit=pct health=$fh max=100"
    }

    exit 0
}

# ==============================================================================
# 2. CORPS / DOUBLE-CLIC — le detail en clair (lecture seule)
# ==============================================================================
# Un disque "Unhealthy" est une erreur (exit 1) pour qu'il apparaisse en echec
# dans le bilan. En SafeTest, le script se termine toujours en succes.

$errors   = 0
$warnings = 0
$ErrTag = '[ERR] '
if ($SafeTest) { $ErrTag = '[WARN]' }

if ($SafeTest) { Write-Host "[INFO] SafeTest mode - this script only reads, the run ends as a success" }

Write-Host "[STEP] 1/2 Physical disks"

$disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue)
if ($disks.Count -eq 0) {
    Write-Host "[WARN] No physical disk could be read"
    $warnings++
}

foreach ($d in $disks) {
    $media = "$($d.MediaType)"
    if ($media -eq 'Unspecified' -or -not $media) { $media = "$($d.BusType)" }
    Write-Host "[INFO] $($d.FriendlyName) - $media, $(Format-Size $d.Size)"

    switch ("$($d.HealthStatus)") {
        'Healthy'   { Write-Host "[OK]   Health: good" }
        'Warning'   { Write-Host "[WARN] Health: warning - back up your data"; $warnings++ }
        'Unhealthy' { Write-Host "$ErrTag Health: failing - back up your data now and replace this disk"; $errors++ }
        default     { Write-Host "[INFO] Health: unknown" }
    }

    $rel = $d | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue
    if (-not $rel) {
        Write-Host "[INFO] Detailed counters not available for this disk"
        continue
    }
    if ($null -ne $rel.Wear) {
        if ($rel.Wear -ge $CONFIG.WearWarnPercent) {
            Write-Host "[WARN] Wear: $($rel.Wear)% used - plan a replacement"; $warnings++
        } else {
            Write-Host "[OK]   Wear: $($rel.Wear)% used"
        }
    }
    if ($rel.Temperature -gt 0) {
        if ($rel.Temperature -ge $CONFIG.TempWarnCelsius) {
            Write-Host "[WARN] Temperature: $($rel.Temperature) C - check the cooling"; $warnings++
        } else {
            Write-Host "[OK]   Temperature: $($rel.Temperature) C"
        }
    }
    if ($rel.ReadErrorsUncorrected -gt 0) {
        Write-Host "[WARN] Uncorrected read errors: $($rel.ReadErrorsUncorrected)"; $warnings++
    }
    if ($rel.PowerOnHours -gt 0) {
        Write-Host "[INFO] Powered on for $($rel.PowerOnHours) hours"
    }
}

Write-Host "[STEP] 2/2 Free space"

$volumes = @(Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' -and $_.Size -gt 0 })
foreach ($v in $volumes) {
    $pct = [math]::Round(100 * $v.SizeRemaining / $v.Size, 1)
    $msg = "$($v.DriveLetter): $(Format-Size $v.SizeRemaining) free of $(Format-Size $v.Size) ($pct%)"
    if ($pct -lt $CONFIG.FreeWarnPercent) {
        Write-Host "[WARN] $msg - running low"; $warnings++
    } else {
        Write-Host "[OK]   $msg"
    }
}

if ($SafeTest) {
    Write-Host "[INFO] SafeTest - $errors error(s) and $warnings warning(s) found"
    Write-Host "[DONE] SafeTest finished - nothing was changed"
    exit 0
}
if ($errors -gt 0) {
    Write-Host "[DONE] Disk problem found - $errors error(s), $warnings warning(s)"
    exit 1
}
if ($warnings -gt 0) {
    Write-Host "[DONE] Disks checked - $warnings warning(s)"
    exit 0
}
Write-Host "[DONE] All disks are healthy"
exit 0
