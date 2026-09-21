---
name: mode-libre
description: >-
  Bascule la session en mode LIBRE — suspend le cloisonnement des modes : écriture autorisée
  sur le wiki, les issues, les commentaires et la codebase dans la même session. Pour les
  tâches transversales et l'exceptionnel. Déclencher quand l'opérateur dit « mode LIBRE »,
  « libre », « passe en libre » ou « lève les restrictions ».
---

# Mode LIBRE 🔓

**Annoncer en tête de première réponse : « Mode actif : LIBRE ».**

**Mission** : suspendre le cloisonnement quand un mode unique est trop restrictif. L'agent peut agir sur le wiki, les issues, les commentaires et la codebase dans la même session.

À utiliser pour les tâches transversales, les réparations de process, les migrations, ou tout ce qui n'entre pas proprement dans une case. Une fois LIBRE déclaré, **la session reste en LIBRE** jusqu'à ce que l'opérateur déclare un autre mode.

## Ce que LIBRE ne lève pas

- **Les garde-fous globaux** restent entiers : jamais de settings du repo, de webhooks, de collaborateurs ou de protections de branche ; jamais de suppression d'issue, de page wiki, de branche distante ou d'historique ; jamais de `push --force`. Sauf demande explicite de l'opérateur.
- **Les conventions du projet** restent dues : format des tickets, bloc de statut des pages wiki, `_Sidebar.md` à jour, `Design-Changelog` alimenté, branche + PR pour le code, conventions de commit, lint et analyse statique avant de pousser.
- **La validation reste à l'opérateur** : une page ne passe pas en 🟢 Validé sans son accord explicite, et c'est lui qui merge les PR.

LIBRE lève le **cloisonnement**, pas la **qualité**. Ce qui est écrit doit rester lisible par une session DESIGN, MANAGER ou CODE ultérieure — donc écrit comme elles l'auraient écrit.

## La discipline minimale

Le risque du mode est de laisser le projet dans un état incohérent, parce que rien n'oblige à finir ce qu'on a commencé sur une surface avant d'en toucher une autre.

- **Annoncer le plan** avant d'agir quand la tâche touche plus d'une surface, et dire dans quel ordre.
- **Une entrée `D-xxx`** reste due pour toute évolution notable du wiki — sinon MANAGER ne la verra jamais, même écrite en LIBRE.
- **Un lien wiki** reste dû dans le contexte de tout ticket `type:feature`.
- Si la tâche pouvait tenir dans un mode unique, **le dire** et proposer de basculer : LIBRE est un outil d'exception, pas un mode de confort.

## Fin de session

Résumé à l'opérateur, **surface par surface** : pages wiki touchées et entrées `D-xxx` créées · tickets créés, fermés ou modifiés · branches, commits et PR · ce qui reste ouvert. C'est ce résumé qui permet aux sessions cloisonnées suivantes de reprendre sans rien deviner.
