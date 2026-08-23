# git-workflow (Claude Code 技能)

Claude Code 的一个**用户级技能**，统一 Git 提交与分支规范，**适用于任意项目**；当项目是多仓库（如后端 + 前端拆分、控制面 + 站点）时，每个仓库各自独立 git、禁止混合提交。

- 提交信息按前置前缀标注性质：`feat / fix / docs / style / refactor / chore / revert / perf / test / improvement / build / ci`。
- 分支模型 `main + release-xxx + dev + test + feature + hotfix`：只有 `feature` / `hotfix` 允许直接提交，`main / release / dev / test` 只经合并流入。
- 多仓库各自独立 git；提交前扫敏感项，不提交 `.env` / 密钥。

---

## 安装

Claude Code 技能放在 `~/.claude/skills/<skill-name>/SKILL.md`（个人级，所有项目可见）或项目的 `.claude/skills/<skill-name>/SKILL.md`（仅该项目）。安装本技能：

### 方式一：克隆整个仓库（推荐）

```bash
git clone git@github.com:yunhao-dev/git-workflow.git
# macOS / Linux
mkdir -p ~/.claude/skills/git-workflow
cp git-workflow/SKILL.md ~/.claude/skills/git-workflow/
# Windows（PowerShell）
# mkdir $HOME\.claude\skills\git-workflow
# copy git-workflow\SKILL.md $HOME\.claude\skills\git-workflow\
```

> 也可以直接把 `git-workflow` 整个目录连同 `SKILL.md` 一并拷贝到 `~/.claude/skills/` 下（README 可保留，无害）。

### 方式二：仅手动复制 SKILL.md

把本仓库根目录的 `SKILL.md` 复制到：

```text
~/.claude/skills/git-workflow/SKILL.md   (Windows: C:\Users\<用户名>\.claude\skills\git-workflow\SKILL.md)
```

### 生效

- **重启 Claude Code 或新开会话**后，技能会被自动发现并载入。
- 之后只要你说「git commit」「push」「切分支/合并」等，Claude 就会自动套用这套规范。

---

## 使用

### 自动生效

在任意项目的 Git 操作中，Claude 会：

1. 先 `git status` / `git branch --show-current` 确认**仓库与分支**。
2. 新功能/修复 → 基于 `main` 建 `feature/<编号>` 或 `hotfix/<编号>` 分支，在其上提交。
3. 按 Commit 前缀表给提交信息标注类型（如 `feat: ...`、`fix: ...`）。
4. 不混入无关改动（按文件分组提交，慎用 `git add -A`）。
5. 合并按 flow：`feature → dev → test → release-xxx → main + tag`；push 只推 feature/hotfix 或用户明确的合并请求；不直接改 `main / release / dev / test`，绝不用 `--force`。
6. 提交前扫描敏感项，不提交 `.env` / 令牌。

### 手动触发

也可直接以斜杠命令调用：

```text
/git-workflow 提交这次改动
/git-workflow 帮我按规范把当前改动起 feature 分支提交
```

---

## 规范速查

| 前缀 | 含义 |
| --- | --- |
| `feat` | 新功能 |
| `fix` | 修补 bug |
| `docs` | 文档 |
| `style` | 格式（不影响运行） |
| `refactor` | 重构（非新增、非修 bug） |
| `chore` | 构建 / 辅助工具 |
| `revert` | 撤销、回退 |
| `perf` | 性能优化 |
| `test` | 测试 |
| `improvement` | 改进 |
| `build` | 打包 |
| `ci` | 持续集成 |

| 分支 | 允许直接提交 |
| --- | --- |
| `main`（线上稳定） | ❌ 禁止；由 release-xxx 验收后合并 + 打 tag |
| `release-xxx`（预发布） | ❌ 禁止 |
| `dev`（开发） / `test`（测试） | ❌ 禁止 |
| `feature` / `hotfix`（基于 main 切出） | ✅ 允许 |

**开发流程**：`feature/00001`（基于 main）→ 合 `dev`（开发环境）→ 合 `test`（提测，bug 在 feature 上修并反复合并）→ 基于 main 建 `release-xxx` 合入待上线 feature → 上线验收 → 合 `main` + 打 tag → 删 `release-xxx` 与 `feature` 分支。hotfix 同 feature。