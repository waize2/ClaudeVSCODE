# Nettoyage du poste (mardi de sortie de la cédule A)

Confidentialité sur un poste partagé. Chaque mardi de sortie de la cédule A, à 8h30, le poste est remis dans un état propre : traces de navigation d'Edge, identifiants ajoutés et journaux Windows principaux sont effacés.

## Ce qui est effacé

| Catégorie | Détail |
| --- | --- |
| Edge (tous les profils) | Remise à zéro complète : comptes web, mots de passe, cookies, synchro, favoris, extensions (via `..\deconnexion-claude\deconnecter-comptes-edge.ps1`) |
| Identifiants Windows | Tout sauf ceux du compte Microsoft (p. ex. `git:https://github.com` est effacé) |
| Identifiants Web | Tous (aucun à l'origine) |
| Journaux Windows | Application, Sécurité, Système |

Edge est fermé de force s'il est ouvert, pour pouvoir réinitialiser ses profils. La partie Edge est partagée avec le projet `deconnexion-claude`, qui fait la même chose à chaque fermeture de VS Code.

## Quand

Une tâche tourne chaque mardi à 8h30, mais n'agit que le mardi de sortie (jour 7 du cycle de 14 jours commencé le 2026-10-06). Les autres mardis, elle ne fait rien. Si le PC est éteint à 8h30, la tâche est rattrapée au démarrage.

## Simulation

Avant tout, on peut voir ce qui serait effacé sans rien supprimer :

```powershell
.\nettoyer-sortie-cedule.ps1 -Simulation
Get-Content .\nettoyage.log
```

## Fichiers

| Fichier | Rôle |
| --- | --- |
| `nettoyer-sortie-cedule.ps1` | Fait le nettoyage (ou le simule avec `-Simulation`) |
| `installer-tache.ps1` | Crée la tâche « Nettoyage Cedule - Mardi Sortie » (droits admin requis) |
| `desinstaller-tache.ps1` | Supprime la tâche |
| `nettoyage.log` | Journal : une ligne par élément effacé |
| `SPEC.md` | Spécification |

## Installation

```powershell
# Droits admin requis (la tâche vide les journaux Windows) : une fenêtre d'élévation s'ouvre
.\installer-tache.ps1

# Tout retirer
.\desinstaller-tache.ps1
```

## Conséquences

- Après le nettoyage, tu es déconnecté de tous les sites dans Edge et tu devras te reconnecter à GitHub au prochain push.
- Vider les journaux Windows nuit au dépannage : l'historique des erreurs système est perdu.
