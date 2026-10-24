param([Parameter(Mandatory)][ValidateSet('On','Off')][string]$Action)

# Cedule A : 8 jours actifs (mardi au mardi suivant) puis 6 jours off, cycle de 14 jours depuis le 6 oct 2026
$debutCycle = [datetime]'2026-10-06'
$heureDebut = [timespan]'07:30'
$heureFin   = [timespan]'17:13'
$dinerDebut = [timespan]'11:30'
$dinerFin   = [timespan]'12:20'
$entreeDebut = [timespan]'13:30'   # mardi d'entree (jour 0) : allume seulement a partir de 13:30
$sortieFin   = [timespan]'09:45'   # mardi de sortie (jour 7) : eteint des 09:45
$log = Join-Path $PSScriptRoot 'hotspot.log'

function Log($msg) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $Action  $msg" | Out-File $log -Append -Encoding utf8 }

$maintenant = Get-Date
$jourCycle = (($maintenant.Date - $debutCycle).Days % 14 + 14) % 14
$jourA = $jourCycle -le 7

if (-not $jourA) { Log "jour $jourCycle du cycle : hors cedule A, rien a faire"; exit }

# Le hotspot doit etre actif seulement dans la plage du jour, hors diner ; On et Off ne font rien si l'etat voulu ne change pas
$debut = if ($jourCycle -eq 0) { $entreeDebut } else { $heureDebut }
$fin   = if ($jourCycle -eq 7) { $sortieFin } else { $heureFin }
$t = $maintenant.TimeOfDay
$dansPlage = $t -ge $debut -and $t -lt $fin -and -not ($t -ge $dinerDebut -and $t -lt $dinerFin)
if ($Action -eq 'On' -and -not $dansPlage) { Log "jour $jourCycle : hors plage horaire, rien a faire"; exit }
if ($Action -eq 'Off' -and $dansPlage) { Log "jour $jourCycle : dans la plage horaire, rien a faire"; exit }

Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
function Await($op, [Type]$t) { $task = $asTask.MakeGenericMethod($t).Invoke($null, @($op)); $task.Wait(-1) | Out-Null; $task.Result }

try {
    $profil = [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]::GetInternetConnectionProfile()
    if (-not $profil) { Log 'aucune connexion Internet disponible'; exit 1 }
    $mgr = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]::CreateFromConnectionProfile($profil)

    if ($Action -eq 'On') {
        if ($mgr.TetheringOperationalState -eq 'On') { Log 'deja actif'; exit }
        $radios = Await ([Windows.Devices.Radios.Radio,Windows.System.Devices,ContentType=WindowsRuntime]::GetRadiosAsync()) ([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]])
        $wifi = $radios | Where-Object Kind -eq 'WiFi'
        if ($wifi -and $wifi.State -ne 'On') { Await ($wifi.SetStateAsync('On')) ([Windows.Devices.Radios.RadioAccessStatus]) | Out-Null; Start-Sleep 3 }
        $r = Await ($mgr.StartTetheringAsync()) ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])
    } else {
        if ($mgr.TetheringOperationalState -eq 'Off') { Log 'deja inactif'; exit }
        $r = Await ($mgr.StopTetheringAsync()) ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])
    }
    Log "resultat : $($r.Status) $($r.AdditionalErrorMessage)"
} catch {
    Log "erreur : $($_.Exception.Message)"
    exit 1
}
