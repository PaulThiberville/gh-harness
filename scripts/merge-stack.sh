#!/usr/bin/env bash
# merge-stack.sh — fusionne une pile de PR en « rebase and merge », une par une, sur une branche cible.
#
#   scripts/merge-stack.sh [--base main] [--ci] [--dry-run] 12 13 14
#   scripts/merge-stack.sh [--base develop] --stack 14     # 14 = PR du sommet, la pile est déduite
#
# Pour chaque PR, dans l'ordre (la plus basse d'abord) :
#   1. rebase local de sa branche sur la cible (en HEAD détachée, le clone n'est pas touché)
#   2. push --force-with-lease
#   3. gh pr edit --base <cible>   (une PR empilée visait la branche d'en dessous)
#   4. (--ci) attente des checks
#   5. gh pr merge --rebase   (les branches ne sont jamais supprimées)
#
# Conflit de rebase → le script s'arrête, code 2, le rebase reste en cours. Résoudre, puis :
#   git add -A && git rebase --continue && git push --force-with-lease origin HEAD:<branche>
# et relancer le script sur les PR restantes (la commande exacte est affichée).
# Exige : git, gh authentifié.

set -euo pipefail

base="main"; ci=0; dry=0; stack_top=""; prs=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --base) base="$2"; shift 2 ;;
    --ci) ci=1; shift ;;
    --dry-run) dry=1; shift ;;
    --stack) stack_top="$2"; shift 2 ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    -*) echo "option inconnue : $1" >&2; exit 1 ;;
    *) prs+=("$1"); shift ;;
  esac
done

run() { if (( dry )); then echo "  [dry-run] $*"; else "$@"; fi; }
die() { echo "✖ $*" >&2; exit 1; }

command -v gh >/dev/null || die "gh introuvable"
gh auth status >/dev/null 2>&1 || die "gh non authentifié"
[[ -z "$(git status --porcelain)" ]] || die "le clone n'est pas propre"
[[ ! -d "$(git rev-parse --git-path rebase-merge)" ]] || die "un rebase est déjà en cours : le terminer ou l'abandonner d'abord"

# --stack N : redescendre la chaîne des bases depuis le sommet jusqu'à la cible.
if [[ -n "$stack_top" ]]; then
  [[ ${#prs[@]} -eq 0 ]] || die "--stack et une liste de PR sont exclusifs"
  n="$stack_top"
  while :; do
    prs=("$n" "${prs[@]}")
    b=$(gh pr view "$n" --json baseRefName -q .baseRefName)
    [[ "$b" == "$base" ]] && break
    n=$(gh pr list --state open --head "$b" --json number -q '.[0].number')
    [[ -n "$n" ]] || die "la PR #${prs[0]} vise « $b », qui n'est ni « $base » ni la branche d'une PR ouverte"
  done
fi
[[ ${#prs[@]} -gt 0 ]] || die "aucune PR : numéros dans l'ordre (basse → haute), ou --stack <PR du sommet>"

echo "Cible : $base — pile : ${prs[*]}"
git fetch -q origin "$base"

conflict() {  # $1 = branche, $2 = index de la PR courante
  echo "✖ conflit en rebasant « $1 » sur « $base ». Fichiers :" >&2
  git diff --name-only --diff-filter=U >&2
  echo "→ résoudre, puis : git add -A && git rebase --continue && git push --force-with-lease origin HEAD:$1" >&2
  echo "→ puis relancer : "$0" --base $base ${prs[*]:$2}" >&2
  exit 2
}

prev_head=""   # tête d'origine de la PR précédente : le rebase --onto saute exactement ses commits
for i in "${!prs[@]}"; do
  n="${prs[$i]}"
  read -r branch state < <(gh pr view "$n" --json headRefName,state -q '[.headRefName,.state]|join(" ")')
  [[ "$state" == "OPEN" ]] || die "PR #$n n'est pas ouverte ($state)"
  echo
  echo "▶ PR #$n — $branch"

  git fetch -q origin "$branch"
  old_head=$(git rev-parse "origin/$branch")
  run git checkout -q --detach "origin/$branch"
  if [[ -n "$prev_head" ]]; then
    run git rebase --onto "origin/$base" "$prev_head" || conflict "$branch" "$i"
  else
    run git rebase "origin/$base" || conflict "$branch" "$i"
  fi
  prev_head="$old_head"

  run git push -q --force-with-lease origin "HEAD:refs/heads/$branch"
  run gh pr edit "$n" --base "$base"
  (( ci )) && run gh pr checks "$n" --watch --fail-fast
  run gh pr merge "$n" --rebase
  git fetch -q origin "$base"
  echo "✔ PR #$n fusionnée dans $base"
done

echo
echo "Pile fusionnée : ${prs[*]} → $base (HEAD détachée sur la dernière PR ; git checkout $base pour revenir)"
