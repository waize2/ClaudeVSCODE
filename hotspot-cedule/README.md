# Hotspot cédule A

Active et coupe automatiquement le point d'accès mobile Windows (partage de la connexion Ethernet en Wi-Fi) selon la cédule A.

## Horaire

La cédule A dure 8 jours (du mardi au mardi suivant), suivis de 6 jours sans partage. Le cycle de 14 jours a commencé le 2026-10-06 et n'a pas de date de fin.

| Heure | Action |
| --- | --- |
| 07:30 | Hotspot activé |
| 11:30 | Coupé pour le dîner |
| 12:20 | Réactivé |
| 17:13 | Coupé pour la journée |

Les deux mardis ont un horaire spécial :

| Jour | Horaire |
| --- | --- |
| Mardi d'entrée (1er jour de la cédule) | Activé seulement à 13:30, coupé à 17:13 |
| Mardi de sortie (dernier jour) | Activé à 07:30, coupé à 09:45 pour le reste de la journée |

À l'ouverture de la session Windows, le hotspot s'allume aussi, 30 s plus tard, si on est dans une plage active (jour A, bonnes heures, hors dîner).

Hors cédule A, le script ne touche jamais au hotspot.

## Fichiers

| Fichier | Rôle |
| --- | --- |
| `hotspot.ps1` | Vérifie la cédule et l'heure, puis démarre ou arrête le hotspot (`-Action On` ou `-Action Off`) |
| `installer-taches.ps1` | Crée ou recrée les 7 tâches planifiées « Hotspot Cedule A - … » |
| `desinstaller-taches.ps1` | Supprime les 7 tâches |
| `hotspot.log` | Journal : une ligne par exécution |
| `SPEC.md` | Spécification complète |

## Utilisation

```powershell
# Installer ou réinstaller les tâches (sans droits admin)
.\installer-taches.ps1

# Tester tout de suite
Start-ScheduledTask -TaskName 'Hotspot Cedule A - On'
Get-Content .\hotspot.log -Tail 5

# Suspendre pendant les vacances, puis reprendre
Get-ScheduledTask 'Hotspot Cedule A*' | Disable-ScheduledTask
Get-ScheduledTask 'Hotspot Cedule A*' | Enable-ScheduledTask

# Tout retirer
.\desinstaller-taches.ps1
```

## Conditions

- La session Windows doit être ouverte. Elle peut être verrouillée (Windows + L), mais pas déconnectée.
- Le câble Ethernet doit être branché.
- Sur batterie, fermer le capot met le PC en veille et coupe le hotspot.
- L'option BIOS HP « LAN / WLAN Auto Switching » doit rester sur **Disable**. Sinon, le Wi-Fi est coupé dès que l'Ethernet est branché.
- L'économie d'énergie du point d'accès mobile doit rester **désactivée** (`PeerlessTimeoutEnabled = 0` dans `HKLM:\SYSTEM\CurrentControlSet\Services\icssvc\Settings`, réglé le 2026-10-22). Sinon, Windows coupe le hotspot après 5 minutes sans appareil connecté.

## Dépannage

Commencez par lire `hotspot.log`. Le tableau de diagnostic est dans [SPEC.md](SPEC.md#journal-et-dépannage).
