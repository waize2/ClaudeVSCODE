# Spec – Déconnexion de Claude à la fermeture de VS Code

À jour au 2026-10-24.

## Objectif

Claude Code ne reste pas connecté quand il ne doit pas l'être : à la fermeture de VS Code, le mardi de sortie de la cédule A à 10:55, et pendant toute la cédule B.

- **Dans la portée :** fermeture normale de VS Code, arrêt ou redémarrage du PC avec VS Code ouvert, mardi de sortie, jours de cédule B.
- **Hors portée :** fermeture d'un onglet ou d'une conversation Claude dans VS Code, Claude Code utilisé dans un terminal hors VS Code.

## Fonctionnement

| Événement | Action |
| --- | --- |
| Ouverture de session Windows | La tâche démarre `surveiller-vscode.ps1` ; si VS Code est fermé, déconnexion immédiate |
| VS Code fermé (plus aucun processus `Code`, vérifié toutes les 2 s) | Attente de 3 s ; si VS Code est toujours fermé, déconnexion |
| VS Code fermé puis rouvert en moins de 3 s (relance par une mise à jour) | Rien, le journal le note |
| Mardi à 10:55, jour 7 du cycle (mardi de sortie de la cédule A) | Déconnexion, même si VS Code est ouvert |
| Mardi à 10:55, jour 0 (mardi d'entrée) | Rien, le journal le note |
| Pendant la cédule B (jours 8 à 13 du cycle) | Déconnexion, vérifiée chaque minute, même si VS Code est ouvert |
| Déjà déconnecté | Rien, le journal note « deja deconnecte » |

Cédule A : jour du cycle = (date − 2026-10-06) en jours, modulo 14 ; même règle que `hotspot-cedule\hotspot.ps1`. Jours 0 à 7 = cédule A, jours 8 à 13 = cédule B. Prochains mardis de sortie : 27 oct., 10 nov., 24 nov. 2026 ; cédules B : 14–19 oct., 28 oct.–2 nov., 11–16 nov. 2026.

La déconnexion appelle `claude auth logout` (`%APPDATA%\npm\claude.cmd`), seulement si `claude auth status` répond connecté (code 0). Elle retire la connexion stockée dans `%USERPROFILE%\.claude\.credentials.json`, partagée par l'extension VS Code et le CLI.

## Tâches planifiées

| Tâche | Déclencheur | Script |
| --- | --- | --- |
| Deconnexion Claude - Surveillance VS Code | Ouverture de session ; sans limite de durée, une seule instance | `surveiller-vscode.ps1` |
| Deconnexion Claude - Mardi Sortie Cedule A | Chaque mardi à 10:55 ; rattrapage si le PC était éteint, limite de 5 min | `deconnecter-sortie-cedule.ps1` |

Les deux tournent sous le compte de l'utilisateur, sans droits admin, en PowerShell masqué.

## Limites

- Si le PC s'arrête brutalement, la déconnexion se fait à la prochaine ouverture de session (avant l'ouverture de VS Code).
- Une vérification toutes les 2 s : coût négligeable.
- Mardi de sortie : si le PC était éteint à 10:55, la tâche est rattrapée au démarrage ; un rattrapage le lendemain (jour 8) ne fait rien.
- Le cycle est copié de `hotspot-cedule` : s'il change, modifier `$debutCycle` dans les deux projets.
- Délai réduit le 2026-10-24 (avant : 15 s + 5 s) : au premier essai, VS Code a été rouvert assez vite pour être pris pour une relance, et rien n'a été déconnecté.

## Validation

| Test | Date | Résultat |
| --- | --- | --- |
| `claude auth logout` sans interaction (dossier de config de test) | 2026-10-24 | « Successfully logged out », code 0 |
| Logique « VS Code fermé » sur un dossier de config de test | 2026-10-24 | « deja deconnecte », pas d'appel inutile |
| Installation et démarrage de la tâche, VS Code ouvert | 2026-10-24 | Tâche en cours, toujours connecté |
| Première fermeture réelle de VS Code (délai de 15 s) | 2026-10-24 | Échec : aucune fermeture vue, pas de déconnexion ; délai réduit à 3 s et journal détaillé ajouté |

| Mardi de sortie simulé : 20 oct., 27 oct., 3 nov., 10 nov. (dossier de config de test) | 2026-10-24 | Rien les jours 0, déconnexion les jours 7 |

À vérifier :

- [ ] Déconnexion réelle le 2026-10-27 à 10:55, premier mardi de sortie

- [ ] Déconnexion réelle après la première fermeture de VS Code
- [ ] Déconnexion à l'ouverture de session après un arrêt du PC avec VS Code ouvert
