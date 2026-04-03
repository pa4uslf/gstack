#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
shift || true

if [ -z "$mode" ]; then
  echo "usage: scripts/git-ignore-guard.sh <pre-commit|pre-push> [hook args...]" >&2
  exit 2
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

tmp_paths="$(mktemp)"
tmp_matches="$(mktemp)"
cleanup() {
  rm -f "$tmp_paths" "$tmp_matches"
}
trap cleanup EXIT

collect_commit_paths() {
  git diff-tree --no-commit-id --name-only -r --diff-filter=ACMR "$1"
}

case "$mode" in
  pre-commit)
    git diff --cached --name-only --diff-filter=ACMR | sort -u >"$tmp_paths"
    ;;
  pre-push)
    remote_name="${1:-}"
    if [ -z "$remote_name" ]; then
      echo "pre-push mode requires the remote name as the first hook argument" >&2
      exit 2
    fi

    while read -r local_ref local_oid remote_ref remote_oid; do
      [ -z "$local_oid" ] && continue

      if [ "$remote_oid" = "0000000000000000000000000000000000000000" ]; then
        git rev-list "$local_oid" --not --remotes="$remote_name"
      else
        git rev-list "${remote_oid}..${local_oid}"
      fi
    done | while read -r commit_oid; do
      [ -n "$commit_oid" ] || continue
      collect_commit_paths "$commit_oid"
    done | sort -u >"$tmp_paths"
    ;;
  *)
    echo "unknown mode: $mode" >&2
    exit 2
    ;;
esac

if [ ! -s "$tmp_paths" ]; then
  exit 0
fi

git check-ignore --no-index --verbose --stdin <"$tmp_paths" >"$tmp_matches" || true

if [ ! -s "$tmp_matches" ]; then
  exit 0
fi

echo "Blocked: you are trying to commit or push paths that match .gitignore." >&2
echo >&2
echo "These are typically generated binaries, local state, secrets, or runtime artifacts." >&2
echo "Common causes: running ./setup or bun run build, then using git add . or git add -A." >&2
echo >&2
echo "Matched paths:" >&2
awk -F'\t' '{print "  - " $2 "    (" $1 ")"}' "$tmp_matches" >&2
echo >&2
echo "Fix:" >&2
echo "  1. Unstage the paths above." >&2
echo "  2. Stage only the files you intentionally changed." >&2
echo "  3. Re-run commit or push." >&2
echo >&2
echo "For this repo, do not commit compiled outputs like bin/gstack-global-discover, browse/dist/, or design/dist/." >&2
exit 1
