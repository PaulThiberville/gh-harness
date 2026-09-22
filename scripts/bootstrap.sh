#!/usr/bin/env bash
# Bootstrap du harnais GitHub sur un repo : labels, milestones, Inbox épinglée,
# epics et, si demandé, GitHub Project avec ses champs Status et Epic.
#
# Idempotent : relançable sans doublon (labels mis à jour, issues retrouvées par
# titre, options de champ complétées). Ne supprime jamais rien.
#
# Usage :
#   scripts/bootstrap.sh [--dry-run] [--repo OWNER/REPO]
#                        [--areas api,ui,infra] [--milestones v0.1,v0.2]
#                        [--epics FICHIER] [--project "Nom du projet"]
#
# --epics FICHIER : une ligne par epic, `titre|milestone|area` (area facultatif).
#                   Le titre est libre : les virgules y sont acceptées.
# --project NOM   : crée (ou retrouve) un GitHub Project de l'owner du repo,
#                   pose les statuts du harnais sur le champ Status, crée le
#                   champ Epic (liste) à partir des epics, et y ajoute les issues
#                   ouvertes. Nécessite le scope `project` : `gh auth refresh -s project`.
#
# Prérequis : bash >= 4 (tableaux associatifs), gh authentifié, jq.
# Le script n'utilise pas sed : aucune dépendance à GNU sed.
set -euo pipefail

# ---------- prérequis ----------------------------------------------------------

if ((BASH_VERSINFO[0] < 4)); then
  echo "bash >= 4 requis (ici ${BASH_VERSION}). macOS : brew install bash, puis lancer avec /opt/homebrew/bin/bash." >&2
  exit 1
fi
for tool in gh jq; do
  command -v "$tool" >/dev/null || { echo "outil manquant : $tool" >&2; exit 1; }
done
gh auth status >/dev/null 2>&1 || { echo "gh n'est pas authentifié : gh auth login" >&2; exit 1; }

# ---------- arguments ----------------------------------------------------------

DRY=0; REPO=""; AREAS=""; MILESTONES="v0.1"; EPICS_FILE=""; PROJECT=""
while (($#)); do
  case "$1" in
    --dry-run) DRY=1 ;;
    --repo) REPO="$2"; shift ;;
    --areas) AREAS="$2"; shift ;;
    --milestones) MILESTONES="$2"; shift ;;
    --epics) EPICS_FILE="$2"; shift ;;
    --project) PROJECT="$2"; shift ;;
    -h|--help) awk 'NR>1 && /^#/ {sub(/^# ?/, ""); print} NR>1 && !/^#/ {exit}' "$0"; exit 0 ;;
    *) echo "argument inconnu : $1" >&2; exit 1 ;;
  esac
  shift
done
[ -n "$REPO" ] || REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
OWNER=${REPO%%/*}
INBOX_TITLE="📥 Inbox — Triage"

run() { if ((DRY)); then echo "+ $*"; else "$@"; fi; }
log() { echo "  $*"; }

# ---------- issues : lecture par la liste, jamais par la recherche ---------------
#
# `gh issue list --search` interroge l'index de recherche, qui a plusieurs
# secondes de retard sur une création. La liste (API REST) est immédiate.
# Après une création, on attend quand même que l'issue soit visible dans la
# liste avant de s'en servir : c'est ce que fait wait_issue.

list_issues() { gh issue list -R "$REPO" --state all --limit 1000 --json number,title,labels; }
ISSUES=$(list_issues)
refresh_issues() { ISSUES=$(list_issues); }
num_of_title() { jq -r --arg t "$1" '.[] | select(.title == $t) | .number' <<<"$ISSUES" | head -1; }
num_of_label() { jq -r --arg l "$1" '.[] | select(any(.labels[]; .name == $l)) | .number' <<<"$ISSUES" | head -1; }

# Attend que l'issue $1 apparaisse dans la liste (30 s max).
wait_issue() {
  local n=$1 i
  for i in $(seq 1 30); do
    if gh issue list -R "$REPO" --state all --limit 1000 --json number --jq '.[].number' | grep -qx "$n"; then
      return 0
    fi
    sleep 1
  done
  echo "issue #$n toujours absente de la liste après 30 s" >&2; return 1
}

# Crée une issue et renvoie son numéro, une fois visible dans la liste.
# (S'exécute en sous-shell via $(...) : l'appelant rafraîchit le cache ensuite.)
create_issue() { # title labels milestone body
  local url n
  url=$(gh issue create -R "$REPO" --title "$1" --label "$2" ${3:+--milestone "$3"} --body "$4")
  n=${url##*/}
  wait_issue "$n" >/dev/null
  echo "$n"
}

# ---------- 1. labels ----------------------------------------------------------

echo "Labels"
declare -A LABELS=(
  ["type:feature"]="1D76DB|Nouvelle fonctionnalité"
  ["type:bug"]="D73A4A|Défaut"
  ["type:chore"]="BFD4F2|Outillage, infra, process"
  ["type:polish"]="C5DEF5|Finition, UX, performance"
  ["type:epic"]="3E4B9E|Epic : regroupe des tickets vers un livrable"
  ["prio:P0"]="B60205|Bloquant"
  ["prio:P1"]="D93F0B|Haute"
  ["prio:P2"]="FBCA04|Normale"
  ["prio:P3"]="E4E669|Basse"
  ["status:ready"]="0E8A16|Spec complète, prêt à coder"
  ["status:blocked"]="000000|Bloqué, voir commentaire ⛔"
  ["needs-design"]="D876E3|Question ou maquette à produire en mode DESIGN"
  ["level:2"]="FBCA04|Risque niveau 2 : sensible et borné"
  ["level:3"]="B60205|Risque niveau 3 : critique, fusion suspendue"
  ["inbox"]="EDEDED|Issue de triage épinglée"
)
AREA_COLORS=(5319E7 006B75 0052CC 1D3F6B 5A7FCF BFD7EA 0E8A16 D4C5F9)
if [ -n "$AREAS" ]; then
  i=0
  IFS=',' read -ra area_list <<<"$AREAS"
  for a in "${area_list[@]}"; do
    a=${a// /}
    LABELS["area:$a"]="${AREA_COLORS[i % ${#AREA_COLORS[@]}]}|$a"
    ((i += 1))
  done
fi
EXISTING_LABELS=$(gh label list -R "$REPO" --limit 300 --json name --jq '.[].name')
for name in $(printf '%s\n' "${!LABELS[@]}" | sort); do
  color=${LABELS[$name]%%|*}; desc=${LABELS[$name]#*|}
  if grep -qxF "$name" <<<"$EXISTING_LABELS"; then
    run gh label edit "$name" -R "$REPO" --color "$color" --description "$desc" >/dev/null
    log "à jour : $name"
  else
    run gh label create "$name" -R "$REPO" --color "$color" --description "$desc" >/dev/null
    log "créé : $name"
  fi
done

# ---------- 2. milestones ------------------------------------------------------

echo "Milestones"
EXISTING_MS=$(gh api "repos/$REPO/milestones?state=all&per_page=100" --jq '.[].title')
IFS=',' read -ra ms_list <<<"$MILESTONES"
for ms in "${ms_list[@]}"; do
  ms=${ms// /}
  if grep -qxF "$ms" <<<"$EXISTING_MS"; then log "existe : $ms"
  else run gh api -X POST "repos/$REPO/milestones" -f title="$ms" >/dev/null; log "créé : $ms"; fi
done

# ---------- 3. Inbox épinglée --------------------------------------------------

echo "Inbox"
INBOX=$(num_of_label inbox)
[ -n "$INBOX" ] || INBOX=$(num_of_title "$INBOX_TITLE")
if [ -z "$INBOX" ]; then
  if ((DRY)); then log "à créer : $INBOX_TITLE (label inbox, épinglée)"
  else
    INBOX=$(create_issue "$INBOX_TITLE" inbox "" "Issue épinglée de triage. Le mode CODE y dépose en commentaire ce qu'il découvre hors du périmètre de son ticket : bugs, dette, idées, questions de design. Le mode MANAGER en fait des tickets et répond \`→ #N\` sous chaque commentaire traité.

Format d'un commentaire : contexte (ticket ou PR d'origine), constat, proposition éventuelle.")
    refresh_issues
    gh issue pin "$INBOX" -R "$REPO" >/dev/null
    log "créée et épinglée : #$INBOX"
  fi
else
  run gh issue edit "$INBOX" -R "$REPO" --add-label inbox >/dev/null
  gh issue view "$INBOX" -R "$REPO" --json isPinned --jq .isPinned | grep -q true || run gh issue pin "$INBOX" -R "$REPO" >/dev/null
  log "existe : #$INBOX"
fi

# ---------- 4. epics -----------------------------------------------------------

EPIC_TITLES=()
if [ -n "$EPICS_FILE" ]; then
  echo "Epics"
  [ -r "$EPICS_FILE" ] || { echo "fichier d'epics illisible : $EPICS_FILE" >&2; exit 1; }
  while IFS='|' read -r title ms area; do
    [ -z "$title" ] && continue
    case "$title" in \#*) continue ;; esac
    title="Epic — ${title#Epic — }"
    labels="type:epic${area:+,area:$area}"
    n=$(num_of_title "$title")
    if [ -n "$n" ]; then log "existe : $title (#$n)"
    elif ((DRY)); then log "à créer : $title ($ms, $labels)"
    else
      n=$(create_issue "$title" "$labels" "$ms" "## Objectif
<!-- ce que l'utilisateur peut faire une fois l'epic livré, en une ou deux phrases -->

## Spécification
<!-- liens vers les pages wiki qui font foi -->

## Livrable
<!-- ce qui est démontrable à la fin, concrètement -->

## Tickets
<!-- une case par ticket, cochée à sa fermeture -->
- [ ] #")
      refresh_issues
      log "créé : $title (#$n)"
    fi
    EPIC_TITLES+=("$title")
  done <"$EPICS_FILE"
fi

# ---------- 5. GitHub Project (facultatif) ---------------------------------------

# Encode une liste d'options pour --single-select-options : le flag découpe sur
# la virgule, donc une option qui en contient (« Filtres, recherche et
# recommandation ») doit être entourée de guillemets, et ses guillemets doublés.
csv_options() {
  local out="" o
  for o in "$@"; do
    o=${o//\"/\"\"}
    out+="${out:+,}\"$o\""
  done
  printf '%s' "$out"
}

if [ -n "$PROJECT" ]; then
  echo "GitHub Project « $PROJECT »"
  gh auth status 2>&1 | grep -qE "(^|[ ,'])project\b" \
    || { echo "scope project manquant : gh auth refresh -s project" >&2; exit 1; }

  PNUM=$(gh project list --owner "$OWNER" --limit 100 --format json --jq ".projects[] | select(.title == \"$PROJECT\") | .number" | head -1)
  if [ -z "$PNUM" ]; then
    if ((DRY)); then log "à créer : projet « $PROJECT » (owner $OWNER)"; PNUM=0
    else
      PNUM=$(gh project create --owner "$OWNER" --title "$PROJECT" --format json --jq .number)
      log "créé : projet #$PNUM"
    fi
  else log "existe : projet #$PNUM"; fi

  if ((PNUM > 0)); then
    FIELDS=$(gh project field-list "$PNUM" --owner "$OWNER" --format json)

    # Status : champ intégré, ses options se remplacent par GraphQL.
    STATUS_ID=$(jq -r '.fields[] | select(.name == "Status") | .id' <<<"$FIELDS")
    if ((DRY)); then log "Status : options Cadrage, Prêts, En cours, À review, À déployer, Terminés"
    else
      jq -n --arg field "$STATUS_ID" '{
        query: "mutation($field: ID!, $opts: [ProjectV2SingleSelectFieldOptionInput!]!) { updateProjectV2Field(input: {fieldId: $field, singleSelectOptions: $opts}) { projectV2Field { ... on ProjectV2SingleSelectField { id } } } }",
        variables: { field: $field, opts: [
          {name: "Cadrage",    color: "GRAY",   description: "À spécifier, maquetter ou découper"},
          {name: "Prêts",      color: "GREEN",  description: "status:ready, posé par MANAGER"},
          {name: "En cours",   color: "BLUE",   description: "CODE, à l\u2019ouverture de la branche"},
          {name: "À review",   color: "PURPLE", description: "CODE, à l\u2019ouverture de la PR"},
          {name: "À déployer", color: "ORANGE", description: "Issue fermée par le merge"},
          {name: "Terminés",   color: "PINK",   description: "Vérifié en staging par l\u2019opérateur"}
        ] } }' | gh api graphql --input - >/dev/null
      log "Status : options posées"
    fi

    # Epic : liste à choix unique, une option par epic (titre sans le préfixe).
    if ((${#EPIC_TITLES[@]})); then
      opts=(); for t in "${EPIC_TITLES[@]}"; do opts+=("${t#Epic — }"); done
      if jq -e '.fields[] | select(.name == "Epic")' <<<"$FIELDS" >/dev/null; then
        log "Epic : champ existant, options non modifiées (à compléter dans l'UI si besoin)"
      else
        run gh project field-create "$PNUM" --owner "$OWNER" --name Epic --data-type SINGLE_SELECT \
          --single-select-options "$(csv_options "${opts[@]}")" >/dev/null
        log "Epic : champ créé (${#opts[@]} options)"
      fi
    fi

    # Ajoute au projet les issues ouvertes qui n'y sont pas.
    if ((DRY)); then log "ajout des issues ouvertes au projet"
    else
      IN_PROJECT=$(gh project item-list "$PNUM" --owner "$OWNER" --limit 1000 --format json --jq '.items[].content.number // empty')
      while read -r n; do
        grep -qx "$n" <<<"$IN_PROJECT" && continue
        gh project item-add "$PNUM" --owner "$OWNER" --url "https://github.com/$REPO/issues/$n" >/dev/null
        log "ajoutée : #$n"
      done < <(gh issue list -R "$REPO" --state open --limit 1000 --json number --jq '.[].number')
    fi
  fi
fi

echo "Terminé."
