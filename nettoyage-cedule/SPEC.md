# Spec – Nettoyage du poste (mardi de sortie de la cédule A)

À jour au 2026-10-25.

## Objectif

Confidentialité sur un poste partagé : à chaque fin de cédule A, retirer les traces personnelles et remettre les identifiants comme à l'origine.

- **Dans la portée :** Edge, identifiants Windows et Web ajoutés, 3 journaux Windows principaux.
- **Hors portée :** autres navigateurs (aucun sur ce poste), fichiers personnels, corbeille, cache système.

## Déclenchement

Tâche « Nettoyage Cedule - Mardi Sortie », chaque mardi à 8h30, rattrapage si le PC était éteint, privilèges élevés (RunLevel Highest, requis pour les journaux). Le script n'agit qu'au jour 7 du cycle (mardi de sortie). Cycle identique à `hotspot-cedule\hotspot.ps1` : (date − 2026-10-06) en jours, modulo 14. Prochains mardis de sortie : 27 oct., 10 nov., 24 nov. 2026.

## Ce qui est effacé

| Catégorie | Détail | Gardé |
| --- | --- | --- |
| Edge (profils Default et Profile *) | Remise à zéro complète du profil (comptes web, mots de passe, cookies, synchro, favoris) via `..\deconnexion-claude\deconnecter-comptes-edge.ps1` | — |
| Identifiants Windows | Tout sauf compte Microsoft | `MicrosoftAccount:`, `WindowsLive:`, `LegacyGeneric:target=MicrosoftAccount:` |
| Identifiants Web (PasswordVault) | Tous | — |
| Journaux Windows | Application, Security, System | les autres journaux |

La réinitialisation d'Edge est déléguée au script partagé `..\deconnexion-claude\deconnecter-comptes-edge.ps1`, appelé avec `-Log` sur le même journal (et `-Simulation` en simulation). Ce script ferme Edge puis supprime les dossiers de profil.

## Sécurité et vérification

- **Mode simulation** (`-Simulation`) : journalise « effacerait : … » sans rien supprimer, quel que soit le jour. À lancer avant la première vraie exécution.
- Les suppressions passent par une fonction `Agir` qui attrape les erreurs et les note au journal sans interrompre le reste.
- Sans droits admin, les journaux Windows sont ignorés (notés au journal) ; la tâche planifiée, elle, tourne en admin.

## Limites

- Vider les journaux Windows efface l'historique de dépannage ; c'est voulu, mais irréversible.
- Les mots de passe d'Edge effacés ne sont pas récupérables.
- Le cycle est copié de `hotspot-cedule` : si `$debutCycle` change, modifier les deux projets.
- Une meilleure isolation sur un poste partagé serait un compte Windows distinct par personne ; ce nettoyage est un compromis.

## Validation

| Test | Date | Résultat |
| --- | --- | --- |
| Syntaxe du script | 2026-10-25 | Aucune erreur |
| Simulation complète (Edge, identifiants, journaux) | 2026-10-25 | Liste conforme à l'inventaire : garde les 4 du compte Microsoft, effacerait GitHub et les 3 journaux |
| Installation de la tâche (élévation) | 2026-10-25 | Tâche Ready, RunLevel Highest, prochaine le 2026-10-27 08:30 |
| Déclenchement un jour hors sortie (jour 5) | 2026-10-25 | Code 0, « pas le mardi de sortie », rien effacé |

À vérifier :

- [ ] Vrai nettoyage le 2026-10-27 à 08:30 (premier mardi de sortie)
