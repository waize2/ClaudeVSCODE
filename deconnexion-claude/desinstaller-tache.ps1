# Arrete et supprime les 2 taches de deconnexion de Claude (les scripts et le journal restent en place)
Get-ScheduledTask -TaskName 'Deconnexion Claude*' -ErrorAction SilentlyContinue | ForEach-Object {
    Stop-ScheduledTask -TaskName $_.TaskName
    Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false
    "Supprimee : $($_.TaskName)"
}
