#!/usr/bin/env bash
# Copies the shared conventions into every skill, and each narrow skill's
# playbook into the meta skill, so each installed skill is self-contained.
# Edit shared/sdr-conventions.md and the narrow SKILL.md files, then run this.
set -euo pipefail
cd "$(dirname "$0")/.."

for dir in skills/*/; do
  mkdir -p "${dir}references"
  cp shared/sdr-conventions.md "${dir}references/sdr-conventions.md"
done

stages=skills/sdr-prospect/references/stages
rm -rf "$stages" && mkdir -p "$stages"
for dir in skills/*/; do
  name=$(basename "$dir")
  [ "$name" = "sdr-prospect" ] && continue
  # Strip the YAML frontmatter; the meta skill only needs the body.
  awk 'BEGIN{n=0} /^---$/ && n<2 {n++; next} n>=2' "${dir}SKILL.md" > "$stages/$name.md"
done
echo "Synced conventions to $(ls -d skills/*/ | wc -l) skills and $(ls "$stages" | wc -l) stage playbooks."
