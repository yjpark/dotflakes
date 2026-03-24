#!/usr/bin/env bash
set -euo pipefail

REPO="Jamie-BitFlight/claude_skills"
FLAKES_DIR="${HOME}/agents/flakes"
SKILLS_DIR="${FLAKES_DIR}/modules/home/programs/claude/skills"
TARBALL_URL="https://github.com/${REPO}/archive/refs/heads/main.tar.gz"

echo "Fetching latest claude_skills from github.com/${REPO}..."
TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

curl -sL "${TARBALL_URL}" -o "${TMPDIR}/archive.tar.gz"

update_skill() {
  local skill_name="$1"
  # Path inside tarball: claude_skills-main/plugins/<skill>/skills/<skill>/
  # strip-components=4 removes: claude_skills-main/plugins/<skill>/skills/
  # leaving: <skill>/ as the top-level dir
  local tar_path="claude_skills-main/plugins/${skill_name}/skills/${skill_name}"
  local extract_dir="${TMPDIR}/extract"
  local dest="${SKILLS_DIR}/${skill_name}"

  echo "Updating ${skill_name}..."
  mkdir -p "${extract_dir}"
  tar -xzf "${TMPDIR}/archive.tar.gz" \
    --strip-components=4 \
    -C "${extract_dir}" \
    "${tar_path}"

  mkdir -p "${dest}"
  rsync -a --delete "${extract_dir}/${skill_name}/" "${dest}/"
  echo "  Done: ${dest}"
}

update_skill "brainstorming-skill"

echo ""
echo "Run 'mise run _activate-home' to apply updated skills."
