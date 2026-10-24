# Supprime les 7 taches planifiees du hotspot (le script et le journal restent en place)
Get-ScheduledTask -TaskName 'Hotspot Cedule A*' -ErrorAction SilentlyContinue | ForEach-Object {
    Unregister-ScheduledTask -TaskName $_.TaskName -Confirm:$false
    "Supprimee : $($_.TaskName)"
}
