# Arrete et supprime la tache de nettoyage (le script et le journal restent en place)
$nom = 'Nettoyage Cedule - Mardi Sortie'
if (Get-ScheduledTask -TaskName $nom -ErrorAction SilentlyContinue) {
    Stop-ScheduledTask -TaskName $nom -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $nom -Confirm:$false
    "Supprimee : $nom"
}
