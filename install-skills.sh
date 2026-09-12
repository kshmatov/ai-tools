#!/usr/bin/env bash
# Link this repository's skills into one or more agent skill directories.

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source_dir="$script_dir/skills"
force=false
targets=()

usage() {
  cat <<'EOF'
Usage: install-skills.sh [--agent codex|claude]... [--target DIRECTORY]... [--force]

Links every direct child of ./skills that contains SKILL.md into agent skill
directories. Existing directories are never replaced. --force may replace an
existing symbolic link, but still refuses to replace a regular directory.

Options:
  --agent codex       Install into ${CODEX_HOME:-~/.codex}/skills.
  --agent claude      Install into ~/.claude/skills (Claude Code).
  --target DIRECTORY  Install into a compatible agent's skills directory.
  --force             Replace conflicting symbolic links only.
  -h, --help          Show this help.

With no --agent or --target, installs for both Codex and Claude Code.
Examples:
  ./install-skills.sh
  CODEX_HOME=/work/codex ./install-skills.sh --agent codex
  ./install-skills.sh --target ~/.config/my-agent/skills
EOF
}

add_agent_target() {
  case "$1" in
    codex) targets+=("${CODEX_HOME:-$HOME/.codex}/skills") ;;
    claude) targets+=("$HOME/.claude/skills") ;;
    *)
      printf 'Unknown agent: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
}

while (($#)); do
  case "$1" in
    --agent)
      (($# >= 2)) || { printf '%s requires an agent name\n' "$1" >&2; exit 2; }
      add_agent_target "$2"
      shift 2
      ;;
    --target)
      (($# >= 2)) || { printf '%s requires a directory\n' "$1" >&2; exit 2; }
      targets+=("$2")
      shift 2
      ;;
    --force)
      force=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ((${#targets[@]} == 0)); then
  add_agent_target codex
  add_agent_target claude
fi

[[ -d "$source_dir" ]] || { printf 'Skills directory not found: %s\n' "$source_dir" >&2; exit 1; }

skills=()
for skill_dir in "$source_dir"/*; do
  [[ -f "$skill_dir/SKILL.md" ]] && skills+=("$skill_dir")
done
(( ${#skills[@]} > 0 )) || { printf 'No skills found in %s\n' "$source_dir" >&2; exit 1; }

for target_dir in "${targets[@]}"; do
  mkdir -p -- "$target_dir"
  target_dir=$(cd -- "$target_dir" && pwd -P)

  for skill_dir in "${skills[@]}"; do
    skill_name=$(basename -- "$skill_dir")
    link_path="$target_dir/$skill_name"

    if [[ -L "$link_path" ]]; then
      if [[ $(readlink -f -- "$link_path") == "$skill_dir" ]]; then
        printf 'Already linked: %s\n' "$link_path"
        continue
      fi
      if ! "$force"; then
        printf 'Conflicting symbolic link: %s (rerun with --force to replace it)\n' "$link_path" >&2
        continue
      fi
      rm -- "$link_path"
    elif [[ -e "$link_path" ]]; then
      printf 'Existing non-link is preserved: %s\n' "$link_path" >&2
      continue
    fi

    ln -s -- "$skill_dir" "$link_path"
    printf 'Linked: %s -> %s\n' "$link_path" "$skill_dir"
  done
done
