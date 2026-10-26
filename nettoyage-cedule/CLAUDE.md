# CLAUDE.md

Nettoie le poste le mardi de sortie de la cédule A (confidentialité sur poste partagé). Répondre en français.

## Règles métier

- Cédule A : `(date - 2026-10-06).Days % 14` ; mardi de sortie = jour 7. Même `$debutCycle` que `..\hotspot-cedule\hotspot.ps1` et `..\deconnexion-claude` : toujours changer les trois.
- Identifiants Windows gardés (compte Microsoft, sinon Windows casse) : préfixes `MicrosoftAccount:`, `WindowsLive:`, `LegacyGeneric:target=MicrosoftAccount:`. Tout le reste est effacé, GitHub compris (choix de l'utilisateur).
- Journaux Windows effacés : Application, Security, System seulement (pas tous).

## Technique

- Poste `DESKTOP-253TOSF`, utilisateur `test1`, **membre des administrateurs mais non élevé** par défaut. Enregistrer une tâche `RunLevel Highest` exige une élévation : `installer-tache.ps1` doit être lancé via `Start-Process -Verb RunAs` (pas de mot de passe demandé, l'utilisateur est admin).
- Edge : la réinitialisation est déléguée à `..\deconnexion-claude\deconnecter-comptes-edge.ps1` (remise à zéro complète des profils). Ne pas dupliquer la logique Edge ici. Dépendance entre les deux projets : si l'un bouge, vérifier le chemin relatif.
- `PasswordVault.RetrieveAll()` renvoie un objet COM : `.Count` n'est lisible qu'après `@(...)`.
- `cmdkey /delete:<nom>` attend le nom SANS le préfixe de type (`target=` retiré).
- `wevtutil cl <journal>` exige l'élévation. Sans admin, le script saute cette étape et le note.

## Tester sans détruire

**Toujours** `-Simulation` d'abord. Ne jamais lancer le vrai nettoyage pour « voir » : les mots de passe et journaux ne se récupèrent pas. Pour vérifier que la tâche tourne, la déclencher un jour hors sortie : le script s'arrête de lui-même.

```powershell
.\nettoyer-sortie-cedule.ps1 -Simulation ; Get-Content .\nettoyage.log
Get-ScheduledTask 'Nettoyage Cedule*' | Select-Object TaskName, State
```
