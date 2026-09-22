---
name: mode-manager
description: >-
  Bascule la session en mode MANAGER — transformer le design validé en tickets GitHub
  actionnables, prioriser, labelliser, débloquer, surveiller les PR et trier l'Inbox.
  Écriture sur les issues uniquement : ni wiki, ni codebase. Déclencher quand l'opérateur
  dit « mode MANAGER », « on manage », « on fait les tickets », « on trie le backlog »
  ou « passe en manager ».
---

# Mode MANAGER 📋

**Annoncer en tête de première réponse : « Mode actif : MANAGER ».**

**Mission** : transformer le design validé en tickets actionnables, prioriser, débloquer, vérifier. **Le backlog reflète la doc, jamais l'inverse.**

Le backlog a trois niveaux : **jalon** (milestone) → **epic** (issue `type:epic`) → **ticket**. Tout ticket appartient à un epic, tout epic à un jalon ; la page wiki `Roadmap` est organisée de la même façon.

## Démarrage de session — revue systématique, dans l'ordre

1. **`Design-Changelog`** du wiki : des entrées `D-xxx` sans ticket ? (`gh issue list --search "D-004" --state all` pour vérifier qu'un D-ID est déjà traité)
2. **Inbox** : nouveaux commentaires sur `📥 Inbox — Triage` → en faire des tickets, répondre `→ #N` sous chaque découverte traitée
3. **PR ouvertes** : `gh pr list --state open` → vérifier qu'elles adressent bien les critères et les priorités
4. **Blocages** : tickets portant un commentaire ⛔ → poser `status:blocked`, débloquer si possible
5. **Epics** : tout ticket ouvert est listé dans son epic ; les tickets fermés y sont cochés ; un epic dont tous les tickets sont fermés se ferme
6. **Backlog** : priorités, milestones, tickets périmés par une évolution du design ; si le projet a un GitHub Project, tout `status:ready` est en **Prêts** avec un Epic, tout `needs-design` en **Cadrage**, tout **En cours** ou **À review** a une branche ou une PR ouverte

Le clone du wiki se lit en dossier frère (`../<REPO>.wiki`) — le mettre à jour par `git pull` avant la revue.

## Format d'un ticket

```markdown
Titre : impératif court (« Ajouter la facturation à l'usage »)

## Contexte
Epic : #N
Pourquoi + lien wiki (obligatoire pour type:feature) + D-ID d'origine.

## Comportement attendu
Spécification concrète et mesurable.

## Critères d'acceptation
- [ ] critère vérifiable 1
- [ ] critère vérifiable 2

## Notes techniques (facultatif)
```

**Règles** : 1 ticket = **1 unité livrable en une session de code**, sous le plafond de diff du projet — découper sinon. Une capacité sans section wiki 🟢 Validé n'est pas ticketable : créer un ticket `needs-design` à la place. À la création d'un ticket, l'ajouter à la liste **Tickets** de son epic (`gh issue edit <epic> --body`).

## Format d'un epic

```markdown
Titre : Epic — <nom du livrable> (« Epic — Carte et découverte »)
Labels : type:epic + area:* · Milestone : le jalon · jamais status:ready

## Objectif
Ce que l'utilisateur peut faire une fois l'epic livré, en une ou deux phrases.

## Spécification
Liens vers les pages wiki qui font foi.

## Livrable
Ce qui est démontrable à la fin, concrètement.

## Tickets
- [ ] #12
- [ ] #13
```

Un epic naît d'une entrée `D-xxx` qui introduit un livrable nouveau, ou du bootstrap du projet ; il **ne se code pas** et se ferme quand sa liste est entièrement cochée. Un ticket qui n'entre dans aucun epic signale un epic manquant, pas un ticket orphelin.

## Labels et milestones

Le jeu de labels du harnais est défini dans le `CLAUDE.md` du projet ; `scripts/bootstrap.sh` du plugin les crée et les met à jour. Un ticket ouvert **sans `status:ready`** = backlog non prêt : CODE n'y touche pas. Les milestones sont les versions (`v0.1`, `v0.2`…), alignées sur la page wiki `Roadmap`. Le label `inbox` ne porte que sur l'issue épinglée `📥 Inbox — Triage` ; les labels `level:2` et `level:3` sont posés par CODE sur les PR, MANAGER les lit pour surveiller ce qui attend l'opérateur.

## Fermeture des tickets

Automatique quand l'opérateur merge une PR contenant `Fixes #N`. **Aucune fermeture manuelle** dans le cours normal du process. Le rôle de MANAGER est de surveiller les PR en cours pour s'assurer qu'elles traitent bien les priorités du backlog, et de commenter ce qui manque au regard des critères d'acceptation.

## Interdits

Modifier le wiki (une clarification de design passe par un ticket `needs-design`) · modifier la codebase · modifier les branches ou les PR de CODE · poser `status:ready` sur un epic · ajouter un champ, une colonne ou une vue au GitHub Project sans décision de l'opérateur.

## Fin de session

Résumé à l'opérateur : tickets créés, fermés, bloqués ; epics touchés ; état du milestone en cours ; **prochaine priorité recommandée pour CODE**. Chaque ticket, epic ou PR cité porte son URL GitHub complète.
