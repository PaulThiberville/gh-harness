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
| 🎼 **ORCHESTRATOR** | *rien* | Traverse plusieurs modes sans jamais écrire : il délègue, un sous-agent à la fois. |
| ⚡ **ITERATION** | tout | Absorbe une rafale de corrections dans le code ; la doc rattrape à la fin. |
| 🔓 **LIBRE** | tout | Suspend le cloisonnement. Pour le transversal et l'exceptionnel. |

Les modes ne s'écrivent jamais dessus directement : ils communiquent par des **passerelles** — le `Design-Changelog` du wiki, le label `needs-design`, les tickets `status:ready`, la PR, l'issue épinglée `📥 Inbox — Triage`.

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

La session enchaîne alors : elle fait raconter l'idée, la creuse en plusieurs tours de brainstorm jusqu'à cerner le périmètre du MVP, rend une synthèse à valider, écrit le `CLAUDE.md` du projet, puis délègue à un sous-agent DESIGN (le wiki) et à un sous-agent MANAGER (labels, Inbox, milestone, premiers tickets).

En fin de session : un wiki qui documente le MVP, une Inbox épinglée, un milestone `v0.1`, et des tickets `status:ready` prêts pour une première session CODE.

## Contenu

```
.claude-plugin/
  plugin.json          manifeste du plugin
  marketplace.json     ce repo comme marketplace local/privé
agents/                les trois modes délégables, pour les sous-agents
  design.md  manager.md  code.md
skills/                un skill par mode — chargé à la déclaration du mode
  mode-initialisation/ SKILL.md + brainstorm.md (techniques de brainstorm)
  mode-design/  mode-manager/  mode-code/
  mode-orchestrator/  mode-iteration/  mode-libre/
templates/
  CLAUDE.md            le contrat de projet, instancié par l'INITIALISATION
```

Les agents ne dupliquent pas les skills : leur frontmatter `skills:` précharge le skill du mode correspondant. **Une procédure, un fichier** — qu'elle serve la session principale ou un sous-agent.

## Conventions

**Vocabulaire** — l'**opérateur** est la personne qui pilote le harnais : elle seule déclare le mode, valide les specs et merge les PR. L'**agent** est Claude.

**Statuts de page wiki** : 🟡 Brouillon → 🟢 Validé → 🔵 Implémenté. Seul l'opérateur valide.

**Labels** : `type:feature|bug|chore|polish` · `prio:P0..P3` · `status:ready` · `status:blocked` · `needs-design` · `area:*` propres au projet.

**Git** : une branche `issue/N-slug` par ticket, une PR par branche, `Fixes #N` dans le corps. Jamais de commit direct sur la branche principale, jamais de `push --force`.

## Limites connues

Le cloisonnement des modes est **déclaratif** dans cette version : il tient par les instructions des skills et, pour les sous-agents, par le champ `tools` de leur frontmatter (le sous-agent MANAGER, par exemple, n'a ni `Write` ni `Edit`). Une session principale déclarée en DESIGN garde techniquement accès à `gh issue create` — c'est la discipline du mode qui l'en empêche, pas le harnais.

Une v2 rendrait la matrice infalsifiable avec deux hooks : `SessionStart` pour forcer la lecture seule au démarrage, et `PreToolUse` pour refuser les écritures hors périmètre du mode actif.
