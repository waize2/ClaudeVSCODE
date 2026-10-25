# Cree (ou recree) la tache qui nettoie le poste le mardi de sortie de la cedule A a 08:30.
# La tache tourne avec les privileges les plus eleves (RunLevel Highest) pour pouvoir vider les journaux Windows.
$nom = 'Nettoyage Cedule - Mardi Sortie'
$script = Join-Path $PSScriptRoot 'nettoyer-sortie-cedule.ps1'
$user = "$env:USERDOMAIN\$env:USERNAME"

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Tuesday -At ([datetime]"$((Get-Date).ToString('yyyy-MM-dd')) 08:30:00")
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 10)
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Highest

Register-ScheduledTask -TaskName $nom -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Nettoie Edge, les identifiants ajoutes et 3 journaux Windows le mardi de sortie de la cedule A' -Force | Out-Null
"Installee : $nom (mardi 08:30, privileges eleves)"
