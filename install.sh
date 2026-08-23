#!/usr/bin/env bash
# 一键安装 git-workflow 技能到 Claude Code 用户级技能目录（macOS / Linux / WSL）
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME}/.claude/skills/git-workflow"

mkdir -p "${TARGET}"
cp "${REPO_DIR}/SKILL.md" "${TARGET}/SKILL.md"

printf '已安装: %s/SKILL.md\n' "${TARGET}"
printf '重启 Claude Code 或新开会话后生效。\n'