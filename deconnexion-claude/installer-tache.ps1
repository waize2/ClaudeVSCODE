# Cree (ou recree) les 2 taches planifiees de deconnexion de Claude, puis demarre la surveillance de VS Code
$user = "$env:USERDOMAIN\$env:USERNAME"
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
function Action($fichier) { New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$(Join-Path $PSScriptRoot $fichier)`"" }

# 1. Surveillance de VS Code, lancee a l'ouverture de session et sans limite de duree
$nom = 'Deconnexion Claude - Surveillance VS Code'
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew
Register-ScheduledTask -TaskName $nom -Action (Action 'surveiller-vscode.ps1') -Trigger $trigger -Settings $settings -Principal $principal -Description 'Deconnecte Claude Code (claude auth logout) quand VS Code est ferme' -Force | Out-Null
Start-ScheduledTask -TaskName $nom
"Installee et demarree : $nom"

# 2. Chaque mardi a 10:55 ; le script n'agit que le mardi de sortie de la cedule A
$nom = 'Deconnexion Claude - Mardi Sortie Cedule A'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Tuesday -At ([datetime]"$((Get-Date).ToString('yyyy-MM-dd')) 10:55:00")
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName $nom -Action (Action 'deconnecter-sortie-cedule.ps1') -Trigger $trigger -Settings $settings -Principal $principal -Description 'Deconnecte Claude Code a 10:55 le mardi de sortie de la cedule A' -Force | Out-Null
"Installee : $nom (mardi 10:55)"
