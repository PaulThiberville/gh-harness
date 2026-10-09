# gh-harness

Un harnais de gestion de projet agentique qui ne repose que sur **GitHub** :

- le **wiki** est la documentation de référence — specs, design, décisions ;
- les **issues** sont le gestionnaire de tickets ;
- le **repo** est la codebase.

Aucun outil externe, aucun service tiers. Le CLI `gh` et `git` suffisent.

## Le principe : les modes

Une session démarre **en lecture seule**. L'opérateur déclare un mode de travail (« mode CODE », « on itère », « passe en design »…), ce qui charge le skill correspondant et ouvre les permissions de ce mode — et **seulement** celles-là. Le mode ne change jamais à l'initiative de l'agent.

| Mode | Écrit sur | En une phrase |
|---|---|---|
| 🌱 **INITIALISATION** | *délègue* | Brainstorme le MVP avec l'opérateur, puis fait installer le wiki et les premiers tickets. |
| 🎨 **DESIGN** | wiki | Conçoit et maintient la documentation de référence. |
| 📋 **MANAGER** | issues | Transforme le design validé en tickets, priorise, débloque, vérifie. |
| ⌨️ **CODE** | codebase + commentaires | Implémente les tickets `status:ready`, branche + PR. |
| 🎼 **ORCHESTRATOR** | *rien* | Traverse plusieurs modes sans jamais écrire : il délègue, un sous-agent à la fois. En variante **MULTI**, jusqu'à N en parallèle sur des périmètres disjoints (3 par défaut). |
| ⚡ **ITERATION** | tout | Absorbe une rafale de corrections dans le code ; la doc rattrape à la fin. |
| 🔓 **LIBRE** | tout | Suspend le cloisonnement. Pour le transversal et l'exceptionnel. |

Les modes ne s'écrivent jamais dessus directement : ils communiquent par des **passerelles** — le `Design-Changelog` du wiki, le label `needs-design`, les tickets `status:ready`, la PR, l'issue épinglée `📥 Inbox — Triage`.

Le backlog a **trois niveaux** : le **jalon** (milestone, une version testable), l'**epic** (une issue `type:epic`, un livrable fonctionnel, avec sa liste de tickets à cocher), le **ticket** (une unité livrable en une session de code). La page wiki `Roadmap` est organisée de la même façon.

## Installation

### Pour une personne seule

```
/plugin marketplace add PaulThiberville/gh-harness
/plugin install gh-harness@gh-harness
```

Dans l'app desktop, où `/plugin` n'existe pas : bouton **+** à côté du champ de saisie → **Plugins** → **Add plugin**. Le panneau demande une **portée** — `User` (tous tes projets), `Project` (ce repo, partagé via git) ou `Local` (ce repo, toi seul).

### Pour une équipe, projet par projet

Committer ce fichier dans le repo du projet, en `.claude/settings.json` :

```json
{
  "extraKnownMarketplaces": {
    "gh-harness": {
      "source": { "source": "github", "repo": "PaulThiberville/gh-harness" },
      "autoUpdate": true
    }
  },
  "enabledPlugins": { "gh-harness@gh-harness": true }
}
```

`extraKnownMarketplaces` enregistre le catalogue chez qui ouvre le repo, et `enabledPlugins` active le plugin — **dans ce repo uniquement**. `autoUpdate` est à mettre explicitement : les marketplaces tiers ne se mettent pas à jour par défaut.

Chaque personne doit ensuite, **une seule fois** : accepter le dialogue de confiance du dossier (sans quoi `extraKnownMarketplaces` est ignoré silencieusement), puis installer le plugin — par le bouton **+** de l'app desktop, ou avec `claude plugin install gh-harness@gh-harness`. Déclarer un plugin dans `enabledPlugins` ne l'installe pas à la place des autres.

Pour s'en exclure sur sa machine sans toucher au repo : `"gh-harness@gh-harness": false` dans son `.claude/settings.local.json` (gitignoré) — le mettre dans son `~/.claude/settings.json` ne suffirait pas, le projet l'emporte sur l'utilisateur.

### Pour développer le plugin

```bash
claude --plugin-dir /chemin/vers/gh-harness
```

Puis `/reload-plugins` après chaque modification.

## Démarrer un projet

Sur un repo neuf, wiki activé :

> mode INITIALISATION

La session enchaîne alors : elle fait raconter l'idée, la creuse en plusieurs tours de brainstorm jusqu'à cerner le périmètre du MVP, rend une synthèse à valider, écrit le `CLAUDE.md` du projet, puis délègue à un sous-agent DESIGN (le wiki) et à un sous-agent MANAGER (labels, Inbox, milestone, epics, premiers tickets).

En fin de session : un wiki qui documente le MVP, une Inbox épinglée, un milestone `v0.1`, des epics, et des tickets `status:ready` prêts pour une première session CODE.

### Le script de bootstrap

Le sous-agent MANAGER pose l'ossature avec `scripts/bootstrap.sh`, utilisable aussi à la main sur un repo existant :

```bash
scripts/bootstrap.sh --areas api,ui,infra --milestones v0.1,v0.2 --epics epics.txt --project "Mon projet — MVP"
```

Il crée ou met à jour les labels, les milestones, l'Inbox épinglée (label `inbox`), les epics (`epics.txt` : une ligne `titre|milestone|area` par epic, virgules acceptées dans le titre) et, avec `--project`, un GitHub Project dont le champ Status porte les six statuts du harnais et le champ Epic les epics. Idempotent, ne supprime jamais rien, `--dry-run` pour voir sans faire. Il exige bash 4 (`brew install bash` sur macOS), `gh` authentifié et `jq` ; `--project` demande le scope `project` (`gh auth refresh -s project`). Il lit les issues par la liste, jamais par la recherche, dont l'index a plusieurs secondes de retard.

### Fusionner une pile de PR

Le sous-agent `merger` fusionne une pile de PR en **rebase and merge**, une par une, sur `main` ou sur la branche de son choix, et résout les conflits de rebase quand ils surviennent. Il tourne sur Haiku avec un effort de raisonnement moyen : c'est une tâche mécanique. Le script qu'il pilote s'utilise aussi à la main :

```bash
scripts/merge-stack.sh --base develop 12 13 14   # numéros dans l'ordre, la plus basse d'abord
scripts/merge-stack.sh --base develop --stack 14 # ou la PR du sommet : la pile est déduite des bases
```

Chaque PR est rebasée localement sur la cible, poussée, retargetée sur la cible, puis fusionnée avec `gh pr merge --rebase`. Sur un conflit, le script s'arrête en laissant le rebase en cours et affiche la commande de reprise. `--ci` attend les checks, `--keep-branches` garde les branches, `--dry-run` montre sans faire.

## Contenu

```
.claude-plugin/
  plugin.json          manifeste du plugin
  marketplace.json     ce repo comme marketplace local/privé
agents/                les trois modes délégables, pour les sous-agents, plus un utilitaire
  design.md  manager.md  code.md
  merger.md            fusionne une pile de PR en rebase and merge (Haiku, effort moyen)
skills/                un skill par mode — chargé à la déclaration du mode
  mode-initialisation/ SKILL.md + brainstorm.md (techniques de brainstorm)
  mode-design/  mode-manager/  mode-code/
  mode-orchestrator/  mode-iteration/  mode-libre/
scripts/
  bootstrap.sh         labels, milestones, Inbox, epics, GitHub Project — idempotent
  merge-stack.sh       fusionne une pile de PR une par une, rebase and merge, sur main ou une autre branche
templates/
  CLAUDE.md            le contrat de projet, instancié par l'INITIALISATION
  epics.example.txt    le format du fichier d'epics du bootstrap
```

Les agents ne dupliquent pas les skills : leur frontmatter `skills:` précharge le skill du mode correspondant. **Une procédure, un fichier** — qu'elle serve la session principale ou un sous-agent.

## Conventions

**Vocabulaire** — l'**opérateur** est la personne qui pilote le harnais : elle seule déclare le mode, valide les specs et décide des fusions ; l'agent fusionne quand elle le demande. Un projet peut avoir plusieurs opérateurs : celui qui pilote la session décide, sans renvoi vers un autre. L'**agent** est Claude.

**Statuts de page wiki** : 🟡 Brouillon → 🟢 Validé → 🔵 Implémenté. Seul l'opérateur valide.

**Labels** : `type:feature|bug|chore|polish|epic` · `prio:P0..P3` · `status:ready` · `status:blocked` · `needs-design` · `level:2|3` (niveau de risque, sur les PR) · `inbox` (l'issue de triage) · `area:*` propres au projet.

**Epics** : issue `Epic — <nom>`, `type:epic`, dans le milestone de son jalon ; corps Objectif / Spécification / Livrable / Tickets (cases à cocher). Jamais `status:ready`. Chaque ticket porte `Epic : #N` en tête de son Contexte.

**Niveaux de risque** d'une PR : 1 courant (tests et CI) · 2 sensible et borné (`level:2`, retour arrière décrit, validation de l'opérateur avant production) · 3 critique (`level:3`, fusion suspendue jusqu'à ce que l'opérateur la demande).

**Git** : une branche `issue/N-slug` par ticket, une PR par branche, `Fixes #N` dans le corps. Plafond de diff : 400 lignes utiles visées, 500 maximum justifié. Jamais de commit direct ni de réécriture d'historique sur la branche principale ; `push --force-with-lease` sur la branche d'une PR seulement après un rebase ou à la demande de l'opérateur. L'agent fusionne à la demande de l'opérateur, une PR ou toute une pile.

**Vérifications humaines** : ce que l'opérateur dit avoir testé ou vérifié dans la session, l'agent le consigne lui-même (case cochée, commentaire qui dit qui, quoi, quand et sur quoi), sans lui demander de l'écrire. Il ne consigne rien que l'opérateur n'a pas déclaré.

## Limites connues

Le cloisonnement des modes est **déclaratif** dans cette version : il tient par les instructions des skills et, pour les sous-agents, par le champ `tools` de leur frontmatter (le sous-agent MANAGER, par exemple, n'a ni `Write` ni `Edit`). Une session principale déclarée en DESIGN garde techniquement accès à `gh issue create` — c'est la discipline du mode qui l'en empêche, pas le harnais.

Une v2 rendrait la matrice infalsifiable avec deux hooks : `SessionStart` pour forcer la lecture seule au démarrage, et `PreToolUse` pour refuser les écritures hors périmètre du mode actif.
