# Cree (ou recree) les 7 taches planifiees qui pilotent le hotspot selon la cedule A
$script = Join-Path $PSScriptRoot 'hotspot.ps1'
$user = "$env:USERDOMAIN\$env:USERNAME"
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited

$taches = @(
    @{ Nom = 'Hotspot Cedule A - On';        Action = 'On';  Heure = '07:30' }
    @{ Nom = 'Hotspot Cedule A - Diner Off'; Action = 'Off'; Heure = '11:30' }
    @{ Nom = 'Hotspot Cedule A - Diner On';  Action = 'On';  Heure = '12:20' }
    @{ Nom = 'Hotspot Cedule A - Off';       Action = 'Off'; Heure = '17:13' }
    @{ Nom = 'Hotspot Cedule A - Mardi Sortie Off'; Action = 'Off'; Heure = '09:45'; Mardi = $true }
    @{ Nom = 'Hotspot Cedule A - Mardi Entree On';  Action = 'On';  Heure = '13:30'; Mardi = $true }
    @{ Nom = 'Hotspot Cedule A - Ouverture Session'; Action = 'On'; Heure = 'session'; Session = $true }
)

foreach ($t in $taches) {
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`" -Action $($t.Action)"
    if ($t.Session) {
        # A l'ouverture de session ; 30 s de delai pour laisser la connexion Ethernet monter
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $user
        $trigger.Delay = 'PT30S'
    } else {
        $at = [datetime]"$((Get-Date).ToString('yyyy-MM-dd')) $($t.Heure):00"
        $trigger = if ($t.Mardi) { New-ScheduledTaskTrigger -Weekly -DaysOfWeek Tuesday -At $at } else { New-ScheduledTaskTrigger -Daily -At $at }
    }
    Register-ScheduledTask -TaskName $t.Nom -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Cedule A : 8 jours actifs / 6 off depuis le 6 oct 2026' -Force | Out-Null
    "$($t.Heure)  $($t.Nom)"
}
