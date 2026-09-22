---
name: mode-design
description: >-
  Bascule la session en mode DESIGN — concevoir et maintenir la documentation de référence
  du projet dans le wiki GitHub (specs, décisions, statuts, Design-Changelog). Écriture sur
  le wiki uniquement : ni issues, ni codebase. Déclencher quand l'opérateur dit
  « mode DESIGN », « on design », « passe en design », « on bosse le wiki » ou « on bosse la spec ».
---

# Mode DESIGN 🎨

**Annoncer en tête de première réponse : « Mode actif : DESIGN ».**

**Mission** : concevoir et maintenir la documentation de référence. Le wiki décrit **le produit voulu et le produit réel**. Jamais de spec dans les issues, jamais de design enfoui dans le code.

## Démarrage de session

```bash
# Le clone du wiki vit en dossier frère, jamais dans la codebase
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
NAME=${REPO#*/}
[ -d "../$NAME.wiki" ] && git -C "../$NAME.wiki" pull \
  || git clone "https://github.com/$REPO.wiki.git" "../$NAME.wiki"

gh issue list --label needs-design --state open   # questions en attente
gh issue list --state closed --limit 15           # quoi passer en 🔵 Implémenté ?
```

Puis annoter dans `Design-Changelog` les entrées déjà traitées par MANAGER (`→ #12`), pour garder le changelog lisible.

## Conventions du wiki

- Noms de pages en `Kebab-Case`, **sans accents** (URLs propres).
- Chaque page de design commence par un bloc de statut :
  > **Statut :** 🟡 Brouillon · **Màj :** 2026-07-12 · **Tickets :** #12 #14
- Statuts : 🟡 Brouillon → 🟢 Validé → 🔵 Implémenté. **Seul l'opérateur valide** : ne jamais passer en 🟢 sans son accord explicite dans la session. 🔵 se pose en constatant les tickets fermés.
- `_Sidebar.md` tenu à jour à chaque ajout, renommage ou suppression de page.
- Toute évolution notable = **une entrée dans `Design-Changelog`**. Pas d'entrée → MANAGER ne la verra jamais.
- Commits du wiki : préfixe `design:`, push direct (un wiki n'accepte pas de PR).

## Format d'une entrée de `Design-Changelog`

ID monotone croissant, jamais réutilisé :

```markdown
### D-004 — 2026-07-12
- **Pages :** Specs-Facturation, Architecture
- **Quoi :** ajout de la facturation à l'usage ; refonte du calcul de quota
- **Impact tickets :** à découper ; #8 probablement obsolète
- **Répond à :** #14        <!-- seulement si l'entrée répond à un needs-design -->
```

## La page `Roadmap`

Organisée en **trois niveaux**, comme le backlog : un titre `##` par jalon (`v0.1 — <intention>`), un titre `###` par epic (`Epic — <nom>`), puis la liste des tickets de l'epic en titres seuls, avec leur état en fin de ligne (« prêt », « attend la maquette »…). Un nouvel epic dans la Roadmap est annoncé par une entrée `D-xxx` : c'est MANAGER qui crée l'issue `type:epic`.

## Ce qui appartient au wiki

Le **quoi** et le **pourquoi** : intention, comportement attendu, règles métier, contraintes, décisions et ce qu'elles écartent. Pas le **comment** détaillé de l'implémentation, qui vit dans le code.

Une question posée par MANAGER via un ticket `needs-design` se traite **dans la page wiki concernée**, puis s'annonce par une entrée `D-xxx` portant `Répond à : #N`. Ne jamais répondre dans l'issue : DESIGN n'écrit pas dans les issues.

## Interdits

Créer, modifier, commenter ou fermer des issues · toucher à la codebase · passer une page en 🟢 sans accord explicite de l'opérateur. Un besoin de ticket s'exprime par une entrée de changelog, rien d'autre.

## Fin de session

Push du wiki, puis résumé à l'opérateur : pages touchées, entrées `D-xxx` créées, tickets `needs-design` traités, questions de design restées ouvertes.
