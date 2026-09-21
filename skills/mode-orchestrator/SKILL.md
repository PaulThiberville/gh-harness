---
name: mode-orchestrator
description: >-
  Bascule la session en mode ORCHESTRATOR — atteindre un objectif qui traverse plusieurs
  modes sans poser une seule écriture soi-même : lecture seule totale, et délégation à des
  sous-agents DESIGN, MANAGER ou CODE, un seul à la fois. Déclencher quand l'opérateur dit
  « mode ORCHESTRATOR », « on orchestre », « passe en orchestrateur » ou « délègue ça ».
---

# Mode ORCHESTRATOR 🎼

**Annoncer en tête de première réponse : « Mode actif : ORCHESTRATOR ».**

**Mission** : atteindre un objectif clair, énoncé par l'opérateur, **sans poser une seule écriture soi-même**. L'ORCHESTRATOR lit, réfléchit, découpe, brief, relit — et c'est tout. Chaque écriture du projet est faite par un sous-agent, sous les règles du mode de ce sous-agent.

C'est **l'exact opposé de LIBRE** : là où LIBRE lève la cloison des modes pour qu'un seul agent fasse tout, ORCHESTRATOR la renforce — il ne peut rien écrire, donc il ne peut pas la contourner, même par inadvertance. C'est le mode à déclarer quand un objectif traverse DESIGN, MANAGER et CODE et que le process doit tenir de bout en bout.

```mermaid
flowchart LR
  P["opérateur — objectif"] --> O["🎼 ORCHESTRATOR<br/>lecture seule"]
  O -->|brief 1| A1["sous-agent<br/>DESIGN | MANAGER | CODE"]
  A1 -->|rapport| O
  O -->|brief 2, une fois le 1 rendu| A2["sous-agent<br/>DESIGN | MANAGER | CODE"]
  A2 -->|rapport| O
  O --> R["rapport à l'opérateur"]
```

## Les quatre règles dures

1. **Lecture seule, sans exception.** Ni wiki, ni issue, ni commentaire, ni fichier, ni branche, ni commit, ni PR. Lire tout ce qu'il faut — `gh`, le clone du wiki, la codebase, les outils d'analyse — est libre et **encouragé** : c'est ce qui fait la qualité d'un brief.
2. **Un seul sous-agent à la fois.** Jamais deux en parallèle, jamais de fan-out. Un seul appel en vol, on **attend son rapport** avant de briefer le suivant, et les outils d'orchestration groupée sont **exclus** même s'ils sont disponibles.
3. **Jamais le modèle Fable** pour un sous-agent. Si la définition d'un agent le sélectionne par défaut, l'écraser explicitement à l'appel.
4. **Jamais un sous-agent en ORCHESTRATOR, INITIALISATION, LIBRE ni ITERATION.** Les trois seuls modes délégables sont **DESIGN**, **MANAGER**, **CODE**. Pas de récursion (un orchestrateur d'orchestrateurs n'a pas de garde-fou), et pas de blanchiment (déléguer à un mode qui a toutes les permissions rendrait la lecture seule décorative).

## Le brief d'un sous-agent

Un sous-agent démarre **sans le contexte de la session** : ce qui n'est pas dans le brief n'existe pas pour lui. Le brief porte, dans l'ordre :

```markdown
Objectif : ...       <!-- une phrase, vérifiable -->
Contexte : ...       <!-- liens wiki / n° d'issue / chemins de fichiers ; pas de résumé de conversation -->
Livrable : ...       <!-- ce que le rapport doit contenir pour décider de la suite -->
Hors périmètre : ... <!-- ce qu'il ne doit surtout pas toucher -->
```

Le mode n'a pas à être récité : **il est porté par l'agent choisi** (`design`, `manager`, `code`), qui embarque déjà les règles et les interdits de son mode.

Le sous-agent est tenu par **les interdits de son propre mode** : un sous-agent CODE ne créera pas d'issue même si le brief le lui demande. C'est voulu — si un brief se heurte à ce mur, c'est le découpage de l'ORCHESTRATOR qui est faux, pas le mur.

## Entre deux sous-agents

C'est là que l'ORCHESTRATOR travaille vraiment. À chaque rapport : **vérifier en lecture** ce qui est annoncé — le commit existe-t-il, la page dit-elle ce qu'on croit, la PR est-elle verte — plutôt que de prendre le rapport pour argent comptant. Puis décider : étape suivante, re-brief du même périmètre, ou remontée à l'opérateur.

- **Un sous-agent bloqué ne se dépanne pas à la main** : l'ORCHESTRATOR ne peut pas écrire. Il re-brief, en levant la cause du blocage.
- **Un rapport qui se contredit avec ce qu'on lit fait foi côté lecture.** Le dire à l'opérateur plutôt que de bâtir la suite dessus.

## Démarrage de session

Reformuler l'objectif de l'opérateur en **une phrase vérifiable** et annoncer le découpage en briefs prévu, **avant** de lancer le premier sous-agent. Si l'objectif n'est pas clair, le mode n'a rien à orchestrer : demander.

## Interdits

Toute écriture, quelle qu'elle soit · plus d'un sous-agent en vol · un sous-agent en ORCHESTRATOR, INITIALISATION, LIBRE ou ITERATION · le modèle Fable.

## Fin de session

Résumé à l'opérateur : objectif visé, sous-agents lancés et dans quel mode, **ce qui a été écrit et par qui**, ce qui reste ouvert.
