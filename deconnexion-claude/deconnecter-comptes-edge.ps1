# Ferme Edge et remet a zero ses profils : deconnecte tous les comptes web (Google, Hotmail...),
# efface les mots de passe enregistres, et deconnecte le profil de son compte Microsoft/Hotmail (synchro coupee).
# Edge recree un profil Default propre et deconnecte a sa prochaine ouverture.
#
#   -Simulation : liste ce qui serait fait, sans rien supprimer.
#   -Log <chemin> : fichier journal (par defaut deconnexion.log a cote de ce script).
param([switch]$Simulation, [string]$Log)

if (-not $Log) { $Log = Join-Path $PSScriptRoot 'deconnexion.log' }
$userData = Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data'
$mode = if ($Simulation) { 'SIMULATION' } else { 'EDGE' }
function Log($m) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $mode  $m" | Out-File $Log -Append -Encoding utf8 }

if (-not (Test-Path $userData)) { Log 'Edge absent'; return }

# 1. Fermer Edge (tous les processus), sinon les fichiers du profil sont verrouilles
if (Get-Process msedge -ErrorAction SilentlyContinue) {
    if ($Simulation) { Log 'fermerait Edge' }
    else { taskkill /IM msedge.exe /F *> $null; Start-Sleep 3; Log 'Edge ferme' }
}

# 2. Reinitialiser chaque profil (Default, Profile *) : supprime le dossier, Edge le recree propre
$profils = Get-ChildItem $userData -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'Default' -or $_.Name -like 'Profile *' }
foreach ($p in $profils) {
    if ($Simulation) { Log "reinitialiserait le profil $($p.Name) (comptes, mots de passe, cookies, synchro, favoris)" ; continue }
    try { Remove-Item $p.FullName -Recurse -Force -ErrorAction Stop; Log "profil $($p.Name) reinitialise" }
    catch { Log "echec profil $($p.Name) : $($_.Exception.Message)" }
}
