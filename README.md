# git-workflow (Claude Code 技能)

Claude Code 的一个**用户级技能**，统一 Git 提交与分支规范，**适用于任意项目**；当项目是多仓库（如后端 + 前端拆分、控制面 + 站点）时，每个仓库各自独立 git、禁止混合提交。

- 提交信息按前置前缀标注性质：`feat / fix / docs / style / refactor / chore / revert / perf / test / improvement / build / ci`。
- 分支模型 `main + release-xxx + dev + test + feature + hotfix`：只有 `feature` / `hotfix` 允许直接提交，`main / release / dev / test` 只经合并流入。
- `main` 推送、部署标记与正式版本 Tag 相互独立；正式版本支持可选的第四段 REVISION，部署期连续修复不会挤占 PATCH。
- 多仓库各自独立 git；提交前扫敏感项，不提交 `.env` / 密钥。

---

## 安装

Claude Code 技能放在 `~/.claude/skills/<skill-name>/SKILL.md`（个人级，所有项目可见）或项目的 `.claude/skills/<skill-name>/SKILL.md`（仅该项目）。

### 方式一（推荐）：把链接发给 Claude，直接装

把下面的仓库链接发给任意 Claude Code 会话，让 Claude 自己克隆并安装：

```text
https://github.com/yunhao-dev/git-workflow.git
```

可直接粘贴这段指令给 Claude：

```text
请安装技能「git-workflow」：
克隆 https://github.com/yunhao-dev/git-workflow.git 到临时目录，
把其中的 SKILL.md 复制到用户级技能目录
~/.claude/skills/git-workflow/SKILL.md
（Windows 为 C:\Users\<用户名>\.claude\skills\git-workflow\SKILL.md）。
装好后告诉我，重启 Claude Code 即生效。
```

等价做法：把单文件地址发给 Claude，让它抓取内容并写入上述路径：

```text
https://raw.githubusercontent.com/yunhao-dev/git-workflow/main/SKILL.md
```

### 方式二：一键安装脚本

克隆仓库后在仓库根目录执行脚本（幂等，可重复执行）：

```bash
# macOS / Linux / WSL
bash install.sh

# Windows PowerShell
powershell -ExecutionPolicy Bypass -File install.ps1
```

### 方式三：手动复制

把仓库根目录的 `SKILL.md` 复制到：

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
5. 合并按 flow：`feature → dev → test → release-xxx → main`；正式版本 Tag 只在明确发布新版本时创建，部署重试或部署期修复不自动递增版本号；push 只推 feature/hotfix 或用户明确的合并请求；不直接改 `main / release / dev / test`，绝不用 `--force`。
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
| `main`（线上稳定） | ❌ 禁止；由 release-xxx 验收后合并，是否打版本 Tag 单独判断 |
| `release-xxx`（预发布） | ❌ 禁止 |
| `dev`（开发） / `test`（测试） | ❌ 禁止 |
| `feature` / `hotfix`（基于 main 切出） | ✅ 允许 |

**开发流程**：`feature/00001`（基于 main）→ 合 `dev`（开发环境）→ 合 `test`（提测，bug 在 feature 上修并反复合并）→ 基于 main 建 `release-xxx` 合入待上线 feature → 上线验收 → 合 `main` → 仅在明确形成新版本时打 Tag → 删 `release-xxx` 与 `feature` 分支。hotfix 同 feature。

### Tag 规则

- 正式版本可选标准三段 `vMAJOR.MINOR.PATCH`，或四段修订版 `vMAJOR.MINOR.PATCH.REVISION`；例如 `v2.4.1.12` 的第四段表示同一功能版本下第 12 次对外修订。
- 四段格式不是标准 SemVer，使用前需确认工具链支持；只接受 SemVer 的项目可使用 `v2.4.1-rev.12`。
- 项目一旦选定三段或四段模式应保持一致。由三段迁移时，将已有 `vX.Y.Z` 视作 `vX.Y.Z.0`，下一个修订使用 `vX.Y.Z.1`，不移动旧 Tag。
- 普通 main 推送、部署重试和未交付的修复默认不打 Tag，也不改版本号；四段模式仅在确实交付新修订产物时递增 REVISION。
- 同一次部署中连续修复多个问题时，先反复部署提交进行验证，稳定后只在最终提交上打一次正式版本 Tag。
- 如果部署平台必须依赖 Tag 触发，可使用 `deploy/prod/20260904-01` 这类部署标记；它不参与版本计算。
- 已推送的 Tag 不移动、不覆盖。正式版本发布后的行为修复如需再次对外发布，三段模式递增 PATCH，四段模式优先递增 REVISION。
