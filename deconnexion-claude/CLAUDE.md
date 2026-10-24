# CLAUDE.md

Déconnecte Claude Code quand VS Code est fermé. Répondre en français.

## Technique

- `claude auth logout` / `claude auth status` (CLI 2.1.308, `%APPDATA%\npm\claude.cmd`). `status` sort en code 1 quand on n'est pas connecté.
- La connexion est dans `%USERPROFILE%\.claude\.credentials.json`, partagée par l'extension VS Code et le CLI.
- VS Code = processus `Code` (plusieurs instances).
- Pas de hook SessionEnd de Claude Code : il se déclenche aussi à la fin d'une conversation, pas seulement à la fermeture de VS Code.

## Tester sans se déconnecter

Ne jamais lancer `claude auth logout` sur la vraie config pendant une session : ça coupe la session en cours. Tester avec `$env:CLAUDE_CONFIG_DIR` pointé sur un dossier vide.

```powershell
Get-ScheduledTask 'Deconnexion Claude*' | Select-Object TaskName, State
Get-Content .\deconnexion.log -Tail 10
```
