# Nettoie le poste le mardi de sortie de la cedule A (jour 7 du cycle de 14 jours depuis le 6 oct 2026), lance chaque mardi a 08:30.
# But : confidentialite sur un poste partage. Efface les traces de navigation Edge et les identifiants ajoutes depuis l'origine.
#
#   -Simulation : liste ce qui serait efface, sans rien effacer, quel que soit le jour. A lancer pour verifier avant le premier vrai nettoyage.
#
# Efface aussi les 3 journaux Windows principaux (Application, Security, System) : demande les droits admin,
# donc la tache planifiee tourne avec les privileges les plus eleves (RunLevel Highest).
param([switch]$Simulation)

$debutCycle = [datetime]'2026-10-06'   # meme cycle que hotspot-cedule\hotspot.ps1 : si ca change, changer les deux
$log = Join-Path $PSScriptRoot 'nettoyage.log'
$journauxWindows = 'Application', 'Security', 'System'

# Identifiants Windows a GARDER : ceux du compte Microsoft, necessaires a Windows. Tout le reste est efface.
$credentialsGardes = '(MicrosoftAccount:|WindowsLive:|LegacyGeneric:target=MicrosoftAccount:)'

# Edge : la reinitialisation des profils est faite par le script partage de deconnexion-claude
$edgeScript = Join-Path $PSScriptRoot '..\deconnexion-claude\deconnecter-comptes-edge.ps1'

$mode = if ($Simulation) { 'SIMULATION' } else { 'NETTOYAGE' }
function Log($m) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $mode  $m" | Out-File $log -Append -Encoding utf8 }
function Agir($quoi, [scriptblock]$action) {
    if ($Simulation) { Log "effacerait : $quoi"; return }
    try { & $action; Log "efface : $quoi" } catch { Log "echec : $quoi : $($_.Exception.Message)" }
}

$jourCycle = (((Get-Date).Date - $debutCycle).Days % 14 + 14) % 14
if (-not $Simulation -and $jourCycle -ne 7) { Log "jour $jourCycle du cycle : pas le mardi de sortie, rien a faire"; exit }
Log "debut (jour $jourCycle du cycle)"

# 1. Edge : fermeture + reinitialisation complete des profils (comptes, mots de passe, cookies, synchro)
if (Test-Path $edgeScript) {
    if ($Simulation) { & $edgeScript -Simulation -Log $log } else { & $edgeScript -Log $log }
} else { Log "script Edge introuvable : $edgeScript" }

# 2. Identifiants Windows : tout ce qui n'est pas le compte Microsoft
$cibles = cmdkey /list | ForEach-Object { if ($_ -match 'Target:\s*(.+?)\s*$') { $Matches[1] } }
foreach ($cible in $cibles) {
    if ($cible -match $credentialsGardes) { Log "garde : $cible"; continue }
    $nom = $cible -replace '^[^:]+:target=', ''
    Agir "identifiant Windows $nom" { $r = cmdkey "/delete:$nom" 2>&1; if ($LASTEXITCODE -ne 0) { throw ($r | Out-String).Trim() } }
}

# 3. Identifiants Web (gestionnaire d'identification Windows, onglet Web) : aucun a l'origine, on efface tout
try {
    $vault = New-Object ([Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime])
    $tous = @($vault.RetrieveAll())
    if ($tous.Count -eq 0) { Log 'identifiants Web : aucun' }
    foreach ($c in $tous) { Agir "identifiant Web $($c.Resource) ($($c.UserName))" { $vault.Remove($c) } }
} catch { Log "identifiants Web illisibles : $($_.Exception.Message)" }

# 4. Journaux Windows (Application, Security, System). Requiert les droits admin.
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $Simulation -and -not $admin) {
    Log 'journaux Windows : droits admin manquants, ignores (la tache planifiee tourne en admin)'
} else {
    foreach ($j in $journauxWindows) {
        Agir "journal Windows $j" { $r = wevtutil cl "$j" 2>&1; if ($LASTEXITCODE -ne 0) { throw ($r | Out-String).Trim() } }
    }
}

Log 'fin'
