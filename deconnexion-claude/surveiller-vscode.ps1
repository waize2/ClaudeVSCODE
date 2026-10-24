# Deconnecte Claude Code quand VS Code est ferme ; tourne en arriere-plan depuis l'ouverture de session
$claude = Join-Path $env:APPDATA 'npm\claude.cmd'
$log = Join-Path $PSScriptRoot 'deconnexion.log'
$intervalle = 2    # secondes entre deux verifications
$grace = 3         # secondes d'attente avant de conclure que VS Code est vraiment ferme (relance par une mise a jour)

function Log($msg) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg" | Out-File $log -Append -Encoding utf8 }
function VSCodeOuvert { [bool](Get-Process -Name 'Code' -ErrorAction SilentlyContinue) }

function Deconnecter($raison) {
    & $claude auth status *> $null
    if ($LASTEXITCODE -ne 0) { Log "$raison : deja deconnecte"; return }
    $sortie = (& $claude auth logout 2>&1 | Out-String).Trim()
    Log "$raison : $sortie (code $LASTEXITCODE)"
}

Log 'surveillance demarree'
# Apres un arret ou un redemarrage du PC, la deconnexion n'a pas pu se faire : on la fait ici
if (-not (VSCodeOuvert)) { Deconnecter 'ouverture de session, VS Code ferme' }

while ($true) {
    while (-not (VSCodeOuvert)) { Start-Sleep $intervalle }
    Log 'VS Code ouvert'
    while (VSCodeOuvert) { Start-Sleep $intervalle }
    Log 'VS Code ferme'
    Start-Sleep $grace
    if (VSCodeOuvert) { Log "rouvert en moins de $grace s : pas de deconnexion" } else { Deconnecter 'VS Code ferme' }
}
