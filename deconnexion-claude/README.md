# Déconnexion de Claude à la fermeture de VS Code

Déconnecte automatiquement Claude Code (`claude auth logout`) quand VS Code est fermé. À la prochaine ouverture de VS Code, il faut se reconnecter à Claude.

## Fonctionnement

Une tâche planifiée lance `surveiller-vscode.ps1` en arrière-plan à l'ouverture de la session Windows. Le script vérifie toutes les 2 s si VS Code tourne :

- VS Code se ferme : 3 s plus tard, s'il ne s'est pas rouvert, Claude est déconnecté.
- Ouverture de session avec VS Code fermé : Claude est déconnecté. Ça couvre le cas où le PC a été éteint avec VS Code ouvert.

Claude est aussi déconnecté le **mardi de sortie de la cédule A, à 10:55**, même si VS Code est ouvert. Une tâche tourne chaque mardi à 10:55, mais n'agit que le mardi de sortie (jour 7 du cycle de 14 jours commencé le 2026-10-06).

## Fichiers

| Fichier | Rôle |
| --- | --- |
| `surveiller-vscode.ps1` | Surveille VS Code et déconnecte Claude |
| `deconnecter-sortie-cedule.ps1` | Déconnecte Claude si on est le mardi de sortie de la cédule A |
| `installer-tache.ps1` | Crée les 2 tâches « Deconnexion Claude - … » et démarre la surveillance |
| `desinstaller-tache.ps1` | Arrête et supprime les 2 tâches |
| `deconnexion.log` | Journal : démarrage, ouverture et fermeture de VS Code, déconnexions |
| `SPEC.md` | Spécification |

## Utilisation

```powershell
# Installer (sans droits admin)
.\installer-tache.ps1

# Voir ce qui s'est passé
Get-Content .\deconnexion.log -Tail 10

# Tout retirer
.\desinstaller-tache.ps1
```
