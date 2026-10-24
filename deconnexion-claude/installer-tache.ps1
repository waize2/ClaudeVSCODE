# Cree (ou recree) la tache planifiee qui lance la surveillance de VS Code a l'ouverture de session, puis la demarre
$nom = 'Deconnexion Claude - Surveillance VS Code'
$script = Join-Path $PSScriptRoot 'surveiller-vscode.ps1'
$user = "$env:USERDOMAIN\$env:USERNAME"

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $nom -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Deconnecte Claude Code (claude auth logout) quand VS Code est ferme' -Force | Out-Null
Start-ScheduledTask -TaskName $nom
"Installee et demarree : $nom"
