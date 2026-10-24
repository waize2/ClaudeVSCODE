# CLAUDE.md

Automatisation du point d'accès mobile Windows selon la cédule A de l'utilisateur. Répondre en français.

## Poste

- HP ZBook Fury 15.6 G8, Windows 10 Pro, Windows PowerShell 5.1, session **sans droits admin**.
- Wi-Fi Intel AX201 ; connexion partagée : `Ethernet 2`. ExpressVPN est installé.
- BIOS « LAN / WLAN Auto Switching » mis sur `Disable` le 2026-10-21. Avec `Enable`, le BIOS coupe la radio Wi-Fi ~3 s après chaque allumage tant que l'Ethernet est branché. Le hotspot retombe alors à Off et la radio montre « Software Off ».
- Veille et veille prolongée à « Jamais » (secteur et batterie). Capot : « Ne rien faire » sur secteur, « Veille » sur batterie.

## Règles métier

- Cédule A : `(date - 2026-10-06).Days % 14` entre 0 et 7 inclus (8 jours, mardi au mardi). Hors cédule : ne rien faire, ni On ni Off.
- Le même cycle est copié dans `..\deconnexion-claude\deconnecter-sortie-cedule.ps1` : si `$debutCycle` change, le changer aussi là-bas.
- Plage active : 07:30–17:13, hors dîner 11:30–12:20. Jour 0 (mardi d'entrée) : début à 13:30. Jour 7 (mardi de sortie) : fin à 09:45.
- On n'agit que dans la plage active, Off seulement en dehors. Une tâche rattrapée en retard ne coupe donc pas le hotspot en pleine plage. Un Off lancé à la main pendant la plage ne fait rien.
- Le script ne garde aucun état (pas de fichier d'état) : un arrêt manuel par l'utilisateur ne bloque jamais la prochaine tâche On. Garder ce principe.
- 7 tâches : 4 quotidiennes (07:30, 11:30, 12:20, 17:13), 2 le mardi seulement (09:45 Off, 13:30 On) et « Ouverture Session » (On à l'ouverture de session, délai 30 s ; pas au déverrouillage, pour qu'un arrêt manuel tienne jusqu'à la plage suivante). Comme le cycle commence un mardi, chaque mardi est le jour 0 ou le jour 7.
- Les heures existent à deux endroits : les déclencheurs dans `installer-taches.ps1` et les variables en tête de `hotspot.ps1`. Toujours changer les deux, puis relancer `installer-taches.ps1`.

## Technique

- Le hotspot se pilote par WinRT : `NetworkOperatorTetheringManager.CreateFromConnectionProfile(GetInternetConnectionProfile())`, puis `StartTetheringAsync` / `StopTetheringAsync`. `netsh wlan hostednetwork` ne marche pas (pilote : « Hosted network supported : No »).
- `StartTetheringAsync` renvoie `WiFiDeviceOff` si la radio est coupée. Le script allume d'abord la radio via `Windows.Devices.Radios`.
- Les tâches tournent sous le compte de l'utilisateur (`LogonType Interactive`, `RunLevel Limited`), avec `StartWhenAvailable`.
- `NextRunTime` affiche des secondes parasites (7:30:30) ; le vrai déclencheur est à 07:30:00 (`Triggers.StartBoundary`).
- Les réglages BIOS se lisent sans admin : `Get-CimInstance -Namespace root\HP\InstrumentedBIOS -ClassName HP_BIOSEnumeration`. Les écrire (`HP_BIOSSettingInterface.SetBIOSSetting`) demande une console admin : donner la commande à l'utilisateur. Aucun mot de passe BIOS n'est défini.

## Vérifier

```powershell
$e=$null; [System.Management.Automation.Language.Parser]::ParseFile("$PWD\hotspot.ps1",[ref]$null,[ref]$e) | Out-Null; $e
Get-ScheduledTask 'Hotspot Cedule A*' | ForEach-Object { $i = Get-ScheduledTaskInfo $_; "$($_.TaskName) $($i.LastRunTime) $($i.LastTaskResult)" }
Get-Content .\hotspot.log -Tail 10
```

Ne pas lancer une tâche Off pour tester pendant les heures A : ça coupe le partage de l'utilisateur.

## Docs

- `README.md` : guide pour l'utilisateur. `SPEC.md` : spécification (copie de la spec en ligne : https://claude.ai/artifact/Hvw3iuZpo92Cr4ZZDT3d1g). Tenir les deux à jour à chaque changement.
