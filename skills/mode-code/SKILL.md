---
name: mode-code
description: >-
  Bascule la session en mode CODE — implémenter les tickets status:ready dans la codebase,
  sur une branche issue/N-slug, avec une PR portant Fixes #N. Écriture sur la codebase et
  les commentaires d'issues : ni wiki, ni création ou édition de tickets. Déclencher quand
  l'opérateur dit « mode CODE », « on code », « passe en code », « on implémente »
  ou « on attaque le ticket #N ».
---

# Mode CODE ⌨️

**Annoncer en tête de première réponse : « Mode actif : CODE ».**

**Mission** : implémenter les tickets `status:ready` dans l'ordre de priorité, en laissant une trace écrite sur chaque ticket.

## Démarrage de session

1. `git pull`
2. Le ticket désigné par l'opérateur ; à défaut :
   ```bash
   gh issue list --label status:ready --state open
   ```
   Prendre la priorité la plus haute (P0 > P1 > P2 > P3 ; à égalité : milestone en cours, puis le plus ancien).
3. Annoncer le ticket choisi, lire sa page wiki de contexte et son epic (`Epic : #N` dans le Contexte), puis commenter sur le ticket : `🔨 Démarrage — plan : …`. Si le projet a un GitHub Project, passer le Status du ticket à **En cours** (`gh project item-edit`), puis à **À review** à l'ouverture de la PR.

## Git

- **Toujours une branche + une PR.** Jamais de commit direct sur la branche principale. Nommer la branche `issue/N-slug` (ex. `issue/12-usage-billing`).
- PR : `Fixes #N` ou `Closes #N` dans le corps, pour fermeture automatique au merge (`Refs #N` pour une PR de process sans ticket à fermer). Respecter le template de PR du projet s'il en a un.
- **Plafond de diff** : viser moins de 400 lignes utiles, 500 maximum justifié dans la PR ; au-delà, s'arrêter et signaler que le ticket est à redécouper. Formatage mécanique et fichiers générés identifiés à part. Jamais de compression du code pour tenir le seuil.
- **Niveau de risque** : annoncer `Niveau : 1, 2 ou 3` dans le corps de la PR selon la grille du `CLAUDE.md` du projet. Niveau 2 → label `level:2` sur la PR et retour arrière décrit. Niveau 3 → label `level:3`, et la PR **attend la revue de l'opérateur**, dont la demande de fusion vaut accord : le dire dans le résumé de fin de session. Les labels `level:*` sont la seule écriture de label autorisée en CODE, et seulement sur une PR.
- Messages de commit : `feat|fix|chore|polish: description`, dans la langue de code du projet. Pas de `Refs #N` — GitHub lie le commit au ticket via la branche.
- Les conventions de code, le lint et l'analyse statique du projet sont dues **avant de pousser** ; la CI les rejoue sur la PR.
- **Historique** : jamais de réécriture sur la branche principale, jamais de `--force` nu. Sur la branche d'une PR de la session, `git push --force-with-lease` est permis après un rebase sur la branche principale (PR empilée dont la base vient d'être fusionnée, conflit à résoudre) ou à la demande de l'opérateur. Hors ces cas, une correction s'ajoute en commit.

## Commentaires

- **Sur la PR** : à l'ouverture, le plan d'implémentation et les décisions techniques notables.
- **Blocage** : `⛔ Bloqué : <raison>` en commentaire — y compris pour une question de design, à signaler aussi sur `📥 Inbox — Triage`.
- **Découvertes** (bug repéré en passant, dette, idée) : **ne jamais créer de ticket** → un commentaire par découverte sur `📥 Inbox — Triage`. MANAGER en fera des tickets.
- **Vérification humaine** : ce que l'opérateur dit avoir testé ou vérifié dans la session, l'agent le consigne lui-même — case cochée dans la PR, commentaire qui dit qui, quoi, quand et sur quoi. Il ne demande pas à l'opérateur de l'écrire à sa place, et ne consigne rien que l'opérateur n'a pas déclaré.

## Fusion

**L'opérateur décide, l'agent exécute.** Quand l'opérateur demande de fusionner (« merge », « c'est bon, fusionne », « fusionne la pile »), l'agent fusionne lui-même, avec la méthode de fusion du projet, une fois la CI verte. Jamais de sa propre initiative. La demande de l'opérateur vaut accord pour tous les niveaux de risque, `level:3` compris : l'agent rappelle seulement le niveau de ce qu'il fusionne.

Une pile de PR se fusionne de bas en haut sur une seule demande : fusionner la PR du bas, rebaser la suivante sur la branche principale, `git push --force-with-lease`, rebrancher sa base sur la branche principale, attendre la CI, fusionner, et ainsi de suite. Une CI rouge, ou un conflit dont la résolution change le code, arrête la pile : le dire, ne rien forcer.

Pour une pile en rebase and merge, cette mécanique se **délègue au sous-agent `merger`** (brief : la branche cible, les numéros dans l'ordre ou la PR du sommet, `--ci` si la CI doit être attendue ; le script est `"${CLAUDE_PLUGIN_ROOT}/scripts/merge-stack.sh"`, à nommer tel quel dans le brief). C'est le seul sous-agent que CODE lance, et **seulement pour une pile** — deux PR ou plus, empilées. Une PR seule se fusionne à la main, `gh pr merge`, sans sous-agent. Son rapport se vérifie en lecture (`gh pr view` dit `MERGED`) avant de l'annoncer à l'opérateur.

## Definition of done

Critères d'acceptation tenus · testé · lint et analyse statique au vert · PR ouverte avec `Fixes #N` · fusionnée si l'opérateur l'a demandé, sinon en attente de sa décision.

## Interdits

Créer, éditer, fermer ou labelliser des issues (les **commentaires** sont autorisés) · toucher au wiki — une incohérence de design se signale dans l'Inbox · modifier `CLAUDE.md` sans demande explicite de l'opérateur.

## Fin de session

Résumé à l'opérateur : ticket traité, branche et PR, niveau de risque, ce qui reste à vérifier de son côté, découvertes déposées dans l'Inbox. Chaque ticket, epic ou PR cité porte son URL GitHub complète.
