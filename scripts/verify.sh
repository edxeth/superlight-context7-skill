#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_home=$(mktemp -d)
trap 'rm -rf "$test_home"' EXIT

HOME="$test_home" npx --yes skills@1.5.17 add "$repo_root" \
  --skill context7 \
  --agent pi \
  --global \
  --yes >/dev/null

installed="$test_home/.pi/agent/skills/context7"

test -f "$installed/SKILL.md"
test -x "$installed/scripts/context7.sh"
test -f "$installed/reference/troubleshooting.md"
"$installed/scripts/context7.sh" --help >/dev/null

printf 'Context7 skill packaging verified.\n'
