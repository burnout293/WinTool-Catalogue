## WINTOOL:START
## id            : 9a0b1c2d-3e4f-5a6b-7c8d-9e0f1a2b3c4d
## lang          : en
## title         : Analysis lab — test every view
## desc          : A safe sandbox that feeds fake data to every analysis view and marker. Changes nothing, ever.
## category      : tools
## icon          : flask-conical
## tags          : lab, test, analysis, views, demo, sandbox
## version       : 1.0
## admin         : false
## risk          : low
## duration      : fast
## reversible    : true
## interruptible : true
## reboot        : false
## engine        : auto
## scan          : true
## panels        : progress plan payload config attention
## WINTOOL:END

## WINTOOL:OPTIONS
## Sections     : [multi] [scan] Which demos to show — pick one or more views to feed with fake data
##   bars       : Bar chart (multi with sizes)
##   donut      : Donut chart (multi with sizes)
##   chart      : Column comparison (select with response times)
##   tree       : Tree of items (parent / children)
##   table      : Sortable table of items
##   tiles      : Tiles of items
##   treemap    : Proportional treemap of items
##   keepone    : Duplicates — keep one copy
##   metrics    : Metrics (gauge / traffic-light data)
## BarsDemo     : [multi] [view:bars] Bars — recoverable space by category
##   logs       : [group:Caches] Application logs
##   thumbs     : [group:Caches] Thumbnail cache
##   updates    : [group:Updates] Old updates — big but still useful
##   dumps      : Crash dumps
## DonutDemo    : [multi] [view:donut] Donut — space used by media type
##   pictures   : Pictures
##   videos     : Videos
##   music      : Music
##   documents  : Documents
## ChartDemo    : [select] [view:chart] Columns — response time by provider, lower is faster
##   alpha      : Provider Alpha
##   bravo      : Provider Bravo
##   charlie    : Provider Charlie
##   delta      : Provider Delta
## TreeDemo     : [items] [view:tree] Tree — browsers and their profiles
## TableDemo    : [items] [view:table] Table — installed apps, sortable and searchable
## TilesDemo    : [items] [view:tiles] Tiles — one tile per item
## TreemapDemo  : [items] [view:treemap] Treemap — proportional rectangles
## KeepDemo     : [items:keep-one] Duplicates — choose the copy to keep
## Switches     : [bool] A simple switch — shows "Already done" when already set
## Selector     : [select] A plain selector — current and recommended choice
##   low        : Low
##   medium     : Medium
##   high       : High
## SafeTest     : [bool] Safe test — this lab changes nothing in any case
## WINTOOL:END

## WINTOOL:REPORT
## Caches    : [group] Caches — Temporary files that come back on their own
## Updates   : [group] Old updates — What Windows keeps after installing
## Cache     : Cache
## App       : App
## Media     : Media file
## Folder    : Folder
## Dup       : Copy
## InfoNote  : [note:info] This is a laboratory. Every number below is fake and nothing is ever modified.
## WarnNote  : [note:warn] Shown but not ticked by default: big, yet it may still be useful.
## SimpleNote : [note:info] This note only appears in Simple mode.
## DiskFree  : Free disk space
## CpuTemp   : CPU temperature
## RamUsage  : Memory in use
## BootTime  : Last boot time
## DisksOk   : Disks reported healthy
## WINTOOL:END

## WINTOOL:LANG fr
## title        : Laboratoire d'analyse — tester chaque vue
## desc         : Un bac à sable sûr qui alimente chaque vue et chaque marqueur d'analyse avec de fausses données. Ne modifie jamais rien.
## Sections     : Quelles démos afficher — une ou plusieurs vues à alimenter en fausses données
##   bars       : Graphique en barres (multi avec tailles)
##   donut      : Graphique en anneau (multi avec tailles)
##   chart      : Comparaison en colonnes (select avec temps de réponse)
##   tree       : Arborescence d'éléments (parent / enfants)
##   table      : Tableau triable d'éléments
##   tiles      : Tuiles d'éléments
##   treemap    : Treemap proportionnelle d'éléments
##   keepone    : Doublons — garder un exemplaire
##   metrics    : Mesures (données jauge / feu tricolore)
## BarsDemo     : Barres — espace récupérable par catégorie
##   logs       : Journaux d'applications
##   thumbs     : Cache des miniatures
##   updates    : Anciennes mises à jour — gros mais encore utile
##   dumps      : Vidages après plantage
## DonutDemo    : Anneau — espace occupé par type de média
##   pictures   : Images
##   videos     : Vidéos
##   music      : Musique
##   documents  : Documents
## ChartDemo    : Colonnes — temps de réponse par fournisseur, plus bas = plus rapide
##   alpha      : Fournisseur Alpha
##   bravo      : Fournisseur Bravo
##   charlie    : Fournisseur Charlie
##   delta      : Fournisseur Delta
## TreeDemo     : Arborescence — navigateurs et leurs profils
## TableDemo    : Tableau — applications installées, triable et cherchable
## TilesDemo    : Tuiles — une tuile par élément
## TreemapDemo  : Treemap — rectangles proportionnels
## KeepDemo     : Doublons — choisir l'exemplaire à garder
## Switches     : Un interrupteur simple — grisé « Déjà en place » si déjà réglé
## Selector     : Un sélecteur simple — choix actuel et recommandé
##   low        : Bas
##   medium     : Moyen
##   high       : Élevé
## SafeTest     : Test sans risque — ce laboratoire ne modifie rien de toute façon
## Caches       : Caches — Fichiers temporaires qui reviennent d'eux-mêmes
## Updates      : Anciennes mises à jour — Ce que Windows garde après installation
## Cache        : Cache
## App          : Application
## Media         : Fichier média
## Folder       : Dossier
## Dup          : Exemplaire
## InfoNote     : Ceci est un laboratoire. Tous les nombres ci-dessous sont fictifs et rien n'est jamais modifié.
## WarnNote     : Affiché mais non coché par défaut : volumineux, mais peut encore servir.
## SimpleNote   : Cette note n'apparaît qu'en mode Simple.
## DiskFree     : Espace disque libre
## CpuTemp      : Température du processeur
## RamUsage     : Mémoire utilisée
## BootTime     : Dernier démarrage
## DisksOk      : Disques en bonne santé
## WINTOOL:END

$CONFIG = @{
    Sections    = @("bars", "donut", "chart", "tree", "table", "tiles", "treemap", "keepone", "metrics")
    BarsDemo    = @("logs", "thumbs")
    DonutDemo   = @("pictures", "videos")
    ChartDemo   = "alpha"
    TreeDemo    = @()
    TableDemo   = @()
    TilesDemo   = @()
    TreemapDemo = @()
    KeepDemo    = @()
    Switches    = $true
    Selector    = "medium"
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
# LABORATOIRE D'ANALYSE. Ce script ne lit ni n'ecrit RIEN sur la machine : il
# invente des donnees et les decrit, pour exercer toutes les vues par-option et
# tous les marqueurs du mode analyse (1.4) en un seul ecran.
#
# Vue globale laissee vide -> cadre "checklist". Chaque option porte sa propre
# etiquette [view:...], donc bars, donut, chart, tree, table, tiles et treemap
# s'affichent cote a cote. L'option [scan] "Sections" choisit lesquelles sont
# alimentees (tu peux en montrer une seule ou plusieurs a la fois).
#
# Le script est lance deux fois (contrat du mode analyse) :
#   1. ANALYSE (WINTOOL_MODE=scan) — ecrit [FIND]/[ITEM]/[METRIC]/[NOTE]/[LOG]. Rien touche.
#   2. ACTION — journalise ce qu'il FERAIT avec la selection, emet un faux [FREED]
#      (pour tester la vue history), et se termine. Aucune modification, jamais.
# ==============================================================================

$SafeTest = ("$($CONFIG.SafeTest)" -eq 'True')

function Test-Section {
    param([string] $Name)
    return (@($CONFIG.Sections | ForEach-Object { "$_" }) -contains $Name)
}

# ==============================================================================
# 1. ANALYSE — fausses donnees, aucune lecture ni ecriture reelle
# ==============================================================================

if ($env:WINTOOL_MODE -eq 'scan') {

    # --- Des notes en tete : une info, un avertissement, une note Simple ---
    Write-Output "[NOTE] InfoNote"
    Write-Output "[NOTE] SimpleNote show=simple"

    # --- bars : un [multi] dont les choix ont une size ---
    if (Test-Section 'bars') {
        Write-Output "[STEP] 1/9 Bars demo"
        Write-Output "[FIND] BarsDemo.logs size=734003200 count=182"
        Write-Output "[FIND] BarsDemo.thumbs size=268435456 count=47"
        # Gros mais encore utile : montre, PAS coche, avec sa note.
        Write-Output "[FIND] BarsDemo.updates size=3221225472 count=12 checked=false"
        Write-Output "[NOTE] WarnNote BarsDemo.updates"
        # Expert seulement.
        Write-Output "[FIND] BarsDemo.dumps size=104857600 count=3 show=expert"
        Write-Output "[LOG] Bars 4 categories measured (fake)"
    }

    # --- donut : meme forme, rendu en anneau ---
    if (Test-Section 'donut') {
        Write-Output "[STEP] 2/9 Donut demo"
        Write-Output "[FIND] DonutDemo.pictures size=5368709120 count=1240"
        Write-Output "[FIND] DonutDemo.videos size=12884901888 count=63"
        Write-Output "[FIND] DonutDemo.music size=2147483648 count=812"
        Write-Output "[FIND] DonutDemo.documents size=1073741824 count=4096"
    }

    # --- chart : un [select] dont les choix ont un ms= ---
    if (Test-Section 'chart') {
        Write-Output "[STEP] 3/9 Column comparison demo"
        Write-Output "[FIND] ChartDemo.alpha ms=12 current=true"
        Write-Output "[FIND] ChartDemo.bravo ms=28"
        Write-Output "[FIND] ChartDemo.charlie ms=9 recommended=true"
        Write-Output "[FIND] ChartDemo.delta ms=41"
        Write-Output "[LOG] Chart lowest response time wins (fake)"
    }

    # --- tree : un [items] avec des parent= (feuilles seules reviennent) ---
    if (Test-Section 'tree') {
        Write-Output "[STEP] 4/9 Tree demo"
        Write-Output "[ITEM] TreeDemo id=chrome name=""Google Chrome"" kind=browser"
        Write-Output "[ITEM] TreeDemo id=chrome-default parent=chrome kind=folder label=Cache name=""Default"" path=""C:\fake\Chrome\Default"" size=314572800"
        Write-Output "[ITEM] TreeDemo id=chrome-work parent=chrome kind=folder label=Cache name=""Work"" path=""C:\fake\Chrome\Work"" size=167772160 show=expert"
        Write-Output "[ITEM] TreeDemo id=edge name=""Microsoft Edge"" kind=browser locked=inuse"
        Write-Output "[ITEM] TreeDemo id=edge-default parent=edge kind=folder label=Cache name=""Default"" path=""C:\fake\Edge\Default"" size=92274688 locked=inuse"
        Write-Output "[LOG] Tree edge is 'in use' -> visible but not tickable"
    }

    # --- table : un [items] plat, triable et cherchable ---
    if (Test-Section 'table') {
        Write-Output "[STEP] 5/9 Table demo"
        Write-Output "[ITEM] TableDemo id=app-candy label=App name=""Candy Crush Saga"" publisher=""king.com"" version=1.2.3 kind=app date=2025-01-14 confidence=high checked=true"
        Write-Output "[ITEM] TableDemo id=app-news label=App name=""Bing News"" publisher=""Microsoft"" version=4.55.1 kind=app date=2024-11-02 confidence=high checked=true"
        Write-Output "[ITEM] TableDemo id=app-maybe label=App name=""Unknown Vendor Tool"" publisher=""Unknown"" version=0.9 kind=app date=2023-06-30 confidence=low risk=medium"
        Write-Output "[ITEM] TableDemo id=app-core label=App name=""System Component"" publisher=""Microsoft"" version=10.0 kind=app locked=system"
        Write-Output "[LOG] Table one low-confidence row is never auto-checked; one system row is not tickable"
    }

    # --- tiles : un [items], une tuile par element ---
    if (Test-Section 'tiles') {
        Write-Output "[STEP] 6/9 Tiles demo"
        Write-Output "[ITEM] TilesDemo id=tile-1 label=Media name=""Holiday 2024.mp4"" kind=file size=2684354560 impact=high date=2024-08-12"
        Write-Output "[ITEM] TilesDemo id=tile-2 label=Media name=""Backup.zip"" kind=file size=1610612736 impact=medium date=2025-02-01"
        Write-Output "[ITEM] TilesDemo id=tile-3 label=Media name=""Old ISO.iso"" kind=file size=4294967296 impact=low date=2022-12-25"
    }

    # --- treemap : un [items] avec des size varies ---
    if (Test-Section 'treemap') {
        Write-Output "[STEP] 7/9 Treemap demo"
        Write-Output "[ITEM] TreemapDemo id=tm-win label=Folder name=""Windows"" kind=folder size=42949672960"
        Write-Output "[ITEM] TreemapDemo id=tm-users label=Folder name=""Users"" kind=folder size=85899345920"
        Write-Output "[ITEM] TreemapDemo id=tm-prog label=Folder name=""Program Files"" kind=folder size=21474836480"
        Write-Output "[ITEM] TreemapDemo id=tm-temp label=Folder name=""Temp"" kind=folder size=3221225472"
    }

    # --- keepone : des exemplaires d'un meme fichier, un a garder ---
    if (Test-Section 'keepone') {
        Write-Output "[STEP] 8/9 Duplicate (keep-one) demo"
        Write-Output "[ITEM] KeepDemo id=dup-a1 group=photo1 label=Dup name=""IMG_042.jpg (Desktop)"" kind=file size=5242880 keep=true"
        Write-Output "[ITEM] KeepDemo id=dup-a2 group=photo1 label=Dup name=""IMG_0042.jpg (Downloads)"" kind=file size=5242880"
        Write-Output "[ITEM] KeepDemo id=dup-b1 group=report label=Dup name=""report.pdf (Documents)"" kind=file size=1048576 keep=true"
        Write-Output "[ITEM] KeepDemo id=dup-b2 group=report label=Dup name=""report (copy).pdf (Documents)"" kind=file size=1048576"
        Write-Output "[LOG] KeepOne what comes back to the script are the ids to DELETE (the ones not kept)"
    }

    # --- metrics : donnees pour gauge (max=) et light (health=) ---
    if (Test-Section 'metrics') {
        Write-Output "[STEP] 9/9 Metrics demo"
        Write-Output "[METRIC] DiskFree value=42 unit=pct health=ok max=100"
        Write-Output "[METRIC] CpuTemp value=71 unit=celsius health=warn"
        Write-Output "[METRIC] RamUsage value=88 unit=pct health=crit max=100"
        Write-Output "[METRIC] BootTime value=18 unit=s health=ok show=expert"
        Write-Output "[METRIC] DisksOk value=2 unit=count health=ok max=3"
    }

    # --- un interrupteur avec etat, et un selecteur simple ---
    # Switches : state=ok -> grise "Deja en place". Change au hasard a chaque analyse
    # pour que tu voies les deux cas (coche / grise).
    $state = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { 'todo' } else { 'ok' }
    Write-Output "[FIND] Switches state=$state"

    Write-Output "[FIND] Selector.low current=false"
    Write-Output "[FIND] Selector.medium current=true"
    Write-Output "[FIND] Selector.high recommended=true"

    # --- une barre de progression libre, en plus des [STEP] ---
    Write-Output "[PROGRESS] 100"
    Write-Output "[LOG] Scan done - all data above is fake, nothing was read or changed"

    exit 0
}

# ==============================================================================
# 2. ACTION — journalise ce qui SERAIT fait, ne modifie RIEN
# ==============================================================================
# Apres l'analyse, WinTool renvoie dans $CONFIG les cases cochees. On ne fait que
# les afficher, puis on emet un faux [FREED] pour nourrir la vue "history".

Write-Host "[INFO] Analysis lab - action phase. This script never changes anything."
if ($SafeTest) { Write-Host "[INFO] SafeTest is on, but it makes no difference here: the lab is always read-only." }

function Show-List {
    param([string] $Label, $Values)
    $v = @($Values | ForEach-Object { "$_" })
    if ($v.Count -eq 0) { Write-Host "[INFO] $($Label): nothing selected"; return }
    Write-Host "[OK]   $($Label): $($v -join ', ')"
}

Write-Host "[STEP] 1/3 Reading back your selection"
Show-List "Bars"     $CONFIG.BarsDemo
Show-List "Donut"    $CONFIG.DonutDemo
Write-Host "[OK]   Chart: $($CONFIG.ChartDemo)"
Show-List "Tree"     $CONFIG.TreeDemo
Show-List "Table"    $CONFIG.TableDemo
Show-List "Tiles"    $CONFIG.TilesDemo
Show-List "Treemap"  $CONFIG.TreemapDemo
Show-List "KeepOne (ids to delete)" $CONFIG.KeepDemo
Write-Host "[OK]   Switch: $($CONFIG.Switches)"
Write-Host "[OK]   Selector: $($CONFIG.Selector)"

Write-Host "[STEP] 2/3 Pretending to work"
foreach ($i in 1..3) {
    Write-Output "[PROGRESS] $([int]($i * 33))"
    Start-Sleep -Milliseconds 200
}

Write-Host "[STEP] 3/3 Reporting a fake result"
# Un faux chiffre "libere" : il alimente le bilan et la vue history, sans qu'aucun
# octet n'ait reellement bouge.
Write-Output "[FREED] 1932735283"
Write-Host "[INFO] That freed number is fake - nothing was deleted."
Write-Host "[DONE] Lab run finished - no change was made to this PC"
exit 0
