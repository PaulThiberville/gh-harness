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
- **Niveau de risque** : annoncer `Niveau : 1, 2 ou 3` dans le corps de la PR selon la grille du `CLAUDE.md` du projet. Niveau 2 → label `level:2` sur la PR et retour arrière décrit. Niveau 3 → label `level:3`, et la PR **attend la revue de l'opérateur** : le dire dans le résumé de fin de session. Les labels `level:*` sont la seule écriture de label autorisée en CODE, et seulement sur une PR.
- Messages de commit : `feat|fix|chore|polish: description`, dans la langue de code du projet. Pas de `Refs #N` — GitHub lie le commit au ticket via la branche.
- Les conventions de code, le lint et l'analyse statique du projet sont dues **avant de pousser** ; la CI les rejoue sur la PR.
- Jamais de `push --force`.

## Commentaires

- **Sur la PR** : à l'ouverture, le plan d'implémentation et les décisions techniques notables.
- **Blocage** : `⛔ Bloqué : <raison>` en commentaire — y compris pour une question de design, à signaler aussi sur `📥 Inbox — Triage`.
- **Découvertes** (bug repéré en passant, dette, idée) : **ne jamais créer de ticket** → un commentaire par découverte sur `📥 Inbox — Triage`. MANAGER en fera des tickets.

## Definition of done

Critères d'acceptation tenus · testé · lint et analyse statique au vert · PR ouverte avec `Fixes #N` · en attente du merge par l'opérateur. **C'est l'opérateur qui merge**, une fois satisfait du diff et des tests.

## Interdits

Créer, éditer, fermer ou labelliser des issues (les **commentaires** sont autorisés) · toucher au wiki — une incohérence de design se signale dans l'Inbox · modifier `CLAUDE.md` sans demande explicite de l'opérateur.

## Fin de session

Résumé à l'opérateur : ticket traité, branche et PR, niveau de risque, ce qui reste à vérifier de son côté, découvertes déposées dans l'Inbox. Chaque ticket, epic ou PR cité porte son URL GitHub complète.
