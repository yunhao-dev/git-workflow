# 一键安装 git-workflow 技能到 Claude Code 用户级技能目录（Windows PowerShell）
$ErrorActionPreference = 'Stop'

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Target  = Join-Path $HOME '.claude\skills\git-workflow'

New-Item -ItemType Directory -Force -Path $Target | Out-Null
Copy-Item -Force (Join-Path $RepoDir 'SKILL.md') (Join-Path $Target 'SKILL.md')

Write-Host "已安装: $Target\SKILL.md"
Write-Host '重启 Claude Code 或新开会话后生效。'