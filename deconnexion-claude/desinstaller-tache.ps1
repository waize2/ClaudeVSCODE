# Arrete et supprime la tache de surveillance (le script et le journal restent en place)
$nom = 'Deconnexion Claude - Surveillance VS Code'
if (Get-ScheduledTask -TaskName $nom -ErrorAction SilentlyContinue) {
    Stop-ScheduledTask -TaskName $nom
    Unregister-ScheduledTask -TaskName $nom -Confirm:$false
    "Supprimee : $nom"
}
