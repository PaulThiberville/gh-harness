# Techniques de brainstorm — phase 2 de l'INITIALISATION

Ces techniques servent un seul objectif : **cerner le périmètre du MVP**. Chacune fait sortir une classe d'information que les autres laissent dans l'ombre. Ne pas toutes les dérouler mécaniquement — en choisir 4 ou 5 selon ce que le projet a besoin de clarifier.

L'ordre ci-dessous est un ordre utile : on part de l'intention, on descend vers le concret, on remonte pour trancher.

---

## Tour 1 — L'intention

### Le pitch contraint

Faire compléter, mot pour mot :

> **<PRODUIT>** est un(e) **<CATÉGORIE>** pour **<QUI>** qui permet de **<QUOI>**, contrairement à **<L'ALTERNATIVE ACTUELLE>**.

La contrainte de format est l'outil : elle force à choisir une catégorie, un public et un concurrent. Si l'opérateur n'arrive pas à remplir une case, c'est la première chose à creuser — pas un détail à laisser vide.

### Les 5 pourquoi

Partir de « pourquoi tu veux faire ça ? » et redemander « pourquoi ? » jusqu'à cinq fois. On cherche la motivation réelle sous la motivation affichée, parce qu'elle dicte les arbitrages du MVP. Un projet fait « pour apprendre une techno » et un projet fait « pour avoir 100 utilisateurs en 3 mois » n'ont pas le même MVP, même avec le même pitch.

S'arrêter dès que la réponse devient une tautologie ou un goût personnel — on a touché le fond, c'est le but.

### Les 3 piliers

Faire nommer **trois** propositions qui doivent être vraies, sinon le produit n'a plus de sens. Pas quatre, pas cinq : la contrainte force la hiérarchie.

Un pilier est falsifiable (« on peut publier en moins de 10 secondes »), pas une valeur (« c'est simple et rapide »). Les piliers deviennent la grille d'arbitrage de tout le reste : une capacité qui ne sert aucun pilier est hors MVP par construction.

---

## Tour 2 — Le concret

### Le parcours de première session

La technique la plus rentable du lot. Faire raconter, **minute par minute**, ce que vit un utilisateur qui découvre le produit :

> Il arrive. Il voit quoi ? Il fait quoi en premier ? Et après ? Au bout de 5 minutes, qu'est-ce qui lui a donné envie de rester — ou de partir ?

Chaque étape du récit est une capacité à construire. C'est ce qui fait sortir tout l'implicite : l'authentification dont personne n'avait parlé, l'état vide, le message d'erreur, le moment où il faut sauvegarder quelque chose. Relancer sur les transitions (« et entre les deux, il se passe quoi ? ») plutôt que sur les écrans.

### Les scénarios limites

Une fois le parcours nominal posé, demander les trois cas qui le cassent : l'utilisateur revient le lendemain · il n'y a encore aucune donnée · deux personnes font la même chose en même temps. Adapter au domaine. Ces trois-là suffisent en général à faire apparaître la moitié des specs manquantes.

### Les entités et leur vocabulaire

Faire nommer les objets que le produit manipule et, pour chacun, ce qui les distingue. Le vocabulaire de l'opérateur devient le vocabulaire du wiki, des tickets et du code — le fixer maintenant évite trois renommages plus tard. Noter les synonymes employés pour le même objet : c'est presque toujours le signe de deux concepts qu'on n'a pas encore séparés.

---

## Tour 3 — L'arbitrage

### MoSCoW sur les capacités

Reprendre chaque capacité sortie du parcours et la classer avec l'opérateur :

| | Sens |
|---|---|
| **Must** | sans elle le MVP ne démontre aucun pilier — elle est dedans |
| **Should** | utile, mais le MVP tient debout sans — `v0.2` |
| **Could** | agréable — backlog, sans milestone |
| **Won't** | décidé hors périmètre — **à écrire noir sur blanc** |

Le **Won't** est la colonne qui compte : un hors-périmètre explicite est ce qui empêche le MVP de regonfler à chaque session. Il va dans la page `Overview` du wiki.

### Le pré-mortem

> On est dans six mois. Le projet est abandonné. Qu'est-ce qui s'est passé ?

Faire donner trois causes. Elles sortent les risques réels — techniques, de motivation, de périmètre — bien mieux qu'une question directe sur les risques, parce que la formulation au passé lève l'autocensure. Chaque cause se traite ensuite : soit une contrainte à documenter dans `Architecture`, soit une capacité à faire remonter en **Must**, soit un risque assumé à noter dans `Overview`.

### La coupe de moitié

Quand le MVP semble arrêté, demander : **« s'il fallait livrer la moitié de ça, tu gardes quoi ? »** La réponse est presque toujours le vrai MVP. Ne pas l'imposer — mais poser la question, et écrire la réponse dans la `Roadmap` comme une `v0.1` possible.

---

## Ce qu'on ne fait pas

- **Proposer une architecture avant le tour 3.** Parler technique trop tôt fige le périmètre sur ce qui est facile à construire plutôt que sur ce qui a de la valeur.
- **Accepter une réponse abstraite.** « Il faut que ce soit intuitif » n'est pas une spec — redemander ce que ça veut dire concrètement, dans le parcours.
- **Combler un silence.** Si l'opérateur ne sait pas, c'est un **point ouvert** : il part en 🟡 dans le wiki et en `needs-design` dans les issues. Une spec inventée par l'agent coûte plus cher qu'un trou assumé.
- **Enchaîner plus de 4 questions d'un coup.** Au-delà, les réponses se dégradent.
