# Deconnecte Claude Code quand VS Code est ferme, et en tout temps pendant la cedule B ; tourne en arriere-plan depuis l'ouverture de session
$claude = Join-Path $env:APPDATA 'npm\claude.cmd'
$log = Join-Path $PSScriptRoot 'deconnexion.log'
$debutCycle = [datetime]'2026-10-06'   # meme cycle que hotspot-cedule\hotspot.ps1
$intervalle = 2    # secondes entre deux verifications de VS Code
$grace = 3         # secondes d'attente avant de conclure que VS Code est vraiment ferme (relance par une mise a jour)
$verifB = 60       # secondes entre deux verifications de la cedule B

function Log($msg) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg" | Out-File $log -Append -Encoding utf8 }
function VSCodeOuvert { [bool](Get-Process -Name 'Code' -ErrorAction SilentlyContinue) }
# Cedule B = les 6 jours hors cedule A (jours 8 a 13 du cycle de 14 jours)
function JourB { ((((Get-Date).Date - $debutCycle).Days % 14 + 14) % 14) -ge 8 }

function Deconnecter($raison, [switch]$Discret) {
    & $claude auth status *> $null
    if ($LASTEXITCODE -ne 0) { if (-not $Discret) { Log "$raison : deja deconnecte" }; return }
    $sortie = (& $claude auth logout 2>&1 | Out-String).Trim()
    Log "$raison : $sortie (code $LASTEXITCODE)"
}

Log 'surveillance demarree'
# Apres un arret ou un redemarrage du PC, la deconnexion n'a pas pu se faire : on la fait ici
if (-not (VSCodeOuvert)) { Deconnecter 'ouverture de session, VS Code ferme' }

$avant = VSCodeOuvert
if ($avant) { Log 'VS Code ouvert' }
$derniereVerifB = [datetime]::MinValue
while ($true) {
    $ouvert = VSCodeOuvert
    if ($ouvert -and -not $avant) { Log 'VS Code ouvert' }
    if ($avant -and -not $ouvert) {
        Log 'VS Code ferme'
        Start-Sleep $grace
        if (VSCodeOuvert) { Log "rouvert en moins de $grace s : pas de deconnexion"; $ouvert = $true } else { Deconnecter 'VS Code ferme' }
    }
    $avant = $ouvert

    # Discret : pendant la cedule B on verifie chaque minute, sans remplir le journal de « deja deconnecte »
    if (((Get-Date) - $derniereVerifB).TotalSeconds -ge $verifB) {
        $derniereVerifB = Get-Date
        if (JourB) { Deconnecter 'cedule B' -Discret }
    }
    Start-Sleep $intervalle
}
