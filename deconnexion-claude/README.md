# Déconnexion de Claude à la fermeture de VS Code

Déconnecte automatiquement Claude Code (`claude auth logout`) quand VS Code est fermé. À la prochaine ouverture de VS Code, il faut se reconnecter à Claude.

## Fonctionnement

Une tâche planifiée lance `surveiller-vscode.ps1` en arrière-plan à l'ouverture de la session Windows. Le script vérifie toutes les 2 s si VS Code tourne :

- VS Code se ferme : 3 s plus tard, s'il ne s'est pas rouvert, Claude est déconnecté.
- Ouverture de session avec VS Code fermé : Claude est déconnecté. Ça couvre le cas où le PC a été éteint avec VS Code ouvert.

## Fichiers

| Fichier | Rôle |
| --- | --- |
| `surveiller-vscode.ps1` | Surveille VS Code et déconnecte Claude |
| `installer-tache.ps1` | Crée la tâche « Deconnexion Claude - Surveillance VS Code » et la démarre |
| `desinstaller-tache.ps1` | Arrête et supprime la tâche |
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
