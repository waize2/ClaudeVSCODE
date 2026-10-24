# Spec – Déconnexion de Claude à la fermeture de VS Code

À jour au 2026-10-24.

## Objectif

Claude Code ne reste pas connecté quand VS Code n'est pas ouvert : la connexion est retirée à la fermeture de VS Code.

- **Dans la portée :** fermeture normale de VS Code, arrêt ou redémarrage du PC avec VS Code ouvert.
- **Hors portée :** fermeture d'un onglet ou d'une conversation Claude dans VS Code, Claude Code utilisé dans un terminal hors VS Code.

## Fonctionnement

| Événement | Action |
| --- | --- |
| Ouverture de session Windows | La tâche démarre `surveiller-vscode.ps1` ; si VS Code est fermé, déconnexion immédiate |
| VS Code fermé (plus aucun processus `Code`, vérifié toutes les 2 s) | Attente de 3 s ; si VS Code est toujours fermé, déconnexion |
| VS Code fermé puis rouvert en moins de 3 s (relance par une mise à jour) | Rien, le journal le note |
| Déjà déconnecté | Rien, le journal note « deja deconnecte » |

La déconnexion appelle `claude auth logout` (`%APPDATA%\npm\claude.cmd`), seulement si `claude auth status` répond connecté (code 0). Elle retire la connexion stockée dans `%USERPROFILE%\.claude\.credentials.json`, partagée par l'extension VS Code et le CLI.

## Tâche planifiée

- Nom : « Deconnexion Claude - Surveillance VS Code ».
- Déclencheur : ouverture de session de l'utilisateur.
- Compte de l'utilisateur, sans droits admin, PowerShell masqué, sans limite de durée, une seule instance.

## Limites

- Si le PC s'arrête brutalement, la déconnexion se fait à la prochaine ouverture de session (avant l'ouverture de VS Code).
- Une vérification toutes les 2 s : coût négligeable.
- Délai réduit le 2026-10-24 (avant : 15 s + 5 s) : au premier essai, VS Code a été rouvert assez vite pour être pris pour une relance, et rien n'a été déconnecté.

## Validation

| Test | Date | Résultat |
| --- | --- | --- |
| `claude auth logout` sans interaction (dossier de config de test) | 2026-10-24 | « Successfully logged out », code 0 |
| Logique « VS Code fermé » sur un dossier de config de test | 2026-10-24 | « deja deconnecte », pas d'appel inutile |
| Installation et démarrage de la tâche, VS Code ouvert | 2026-10-24 | Tâche en cours, toujours connecté |
| Première fermeture réelle de VS Code (délai de 15 s) | 2026-10-24 | Échec : aucune fermeture vue, pas de déconnexion ; délai réduit à 3 s et journal détaillé ajouté |

À vérifier :

- [ ] Déconnexion réelle après la première fermeture de VS Code
- [ ] Déconnexion à l'ouverture de session après un arrêt du PC avec VS Code ouvert
