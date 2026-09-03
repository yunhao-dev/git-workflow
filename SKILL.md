---
name: git-workflow
description: "通用 Git 提交、分支与发布约定（Claude Code 技能）：commit 前缀按 Commit 规范标注类型；分支模型为 main/release-xxx/dev/test/feature/hotfix；区分 main 推送、部署标记和正式版本 Tag，避免部署修复造成版本号膨胀。多仓库场景各自独立 git、禁止混合提交。使用时：准备 git commit、切分支、合并、push、打 Tag 或发布时遵循此 skill。"
---

# Git 工作流（Commit 规范 + 分支模型）

## 适用范围（多仓库时各自独立维护）

- 可套用于**任意项目**；项目含多仓库（如「后端 + 前端」拆分、或控制面 + 站点）时尤其适用。
- **每个仓库各自独立 git，提交/推送分开进行、禁止混合提交**：一条跨仓库的 feature 可能在多个仓库落改动，但每个仓库单独提交、单独推送。
- 动手前先 `git status` / `git branch --show-current` 确认是在哪个仓库、哪个分支。

## 一、Commit 提交规范

提交信息以固定前缀标识本次提交属性，`<前缀>: <中文说明>`，说明聚焦“为什么”。

| 前缀 | 含义 |
| --- | --- |
| `feat:` | 新功能（feature） |
| `fix:` | 修补 bug |
| `docs:` | 文档（documentation） |
| `style:` | 格式（不影响代码运行的变动） |
| `refactor:` | 重构（既非新增功能、也非修 bug 的代码变动） |
| `chore:` | 构建过程或辅助工具的变动 |
| `revert:` | 撤销，版本回退 |
| `perf:` | 性能优化 |
| `test:` | 测试 |
| `improvement:` | 改进 |
| `build:` | 打包 |
| `ci:` | 持续集成 |

## 二、分支模型

| 分支 | 用途 | 是否允许直接改/提交 |
| --- | --- | --- |
| **main** | 线上最稳定、理论可上线 | **禁止**直接修改提交 |
| **release**（release-xxx） | 上线前预发布环境 | **禁止**直接修改提交；验收通过后合并到 main，是否打版本 Tag 另行判断 |
| **dev** | 开发环境 | **禁止**直接修改提交 |
| **test** | 测试环境 | **禁止**直接修改提交 |
| **feature**（feature/00001） | 基于 main checkout，开发新功能 | **允许**直接修改提交 |
| **hotfix** | 基于 main 创建，修复线上 bug | **允许**直接修改提交（流程同 feature） |

## 三、开发流程

1. **收需求**：基于 `main` checkout 新分支 → `feature/00001`。
2. **开发阶段**：在 feature 分支上开发、**允许直接提交**；开发完成后合并到 `dev`，发布 dev 环境。
3. **提测阶段**：将 feature 分支合并到 `test`；测试反馈的 bug 继续在该 feature 分支修改，改完再合并到 `dev` 和 `test`，发布 test 环境。
4. **预发布阶段**：基于 main checkout 新 `release-xxx`；把要上线的 feature 分支合并进 `release-xxx`；bug 修改继续在 feature 分支进行并重复合并到 `dev`、`test`、`release-xxx`；发布预发布环境。
5. **上线发布**：发布 `release-xxx`；验收通过后将 `release-xxx` 合并到 `main`。只有明确形成一个正式版本时才打版本 Tag；普通 main 推送、部署重试或部署期修复不自动打版本 Tag。删除已完成的 `release-xxx`、`feature/00001`。
6. **hotfix**：从 main 建分支修复线上 bug，流程同 feature。

要点：**只有 feature 与 hotfix 分支允许直接提交**；main/release/dev/test 一律通过合并流入，不直接改。**main 有新提交不等于产品版本发生变化。**

## 四、版本 Tag 与部署标记

- 正式版本 Tag 使用 `vMAJOR.MINOR.PATCH`（例如 `v2.4.1`），只表示对外可识别、需要长期追溯的产品版本。
- 合并或推送到 `main` 时默认**不创建 Tag、不递增版本号**。只有用户明确要求“发布新版本”并确认版本号后，才创建正式版本 Tag。
- 同一次上线窗口中发现多个问题时，继续在对应 feature/hotfix 分支修复并逐次部署验证；待该版本稳定后，只在最终确认的提交上创建一次正式版本 Tag，避免每修一个问题就增加一个版本号。
- 若部署系统必须由 Tag 触发，使用不参与语义化版本计算的部署标记，例如 `deploy/prod/20260903-01`；版本计算、Release Note 和包发布流程只识别 `v[0-9]+.[0-9]+.[0-9]+` 格式的正式版本 Tag。
- 部署标记也应保持不可变；需要再次部署时创建新的部署标记，禁止移动或覆盖已经推送的 Tag。若平台支持，优先用 commit SHA 或 Deployment 记录部署，不额外创建 Tag。
- 若正式版本 Tag 已经发布，之后的修复改变了对外产物或行为，再发布时通常应递增 patch；不要修改或复用已有正式版本 Tag。

## 五、执行步骤（准备 commit / 切分支 / 合并 / 发布时）

1. 明确当前仓库与分支：`git status` + `git branch --show-current`。
2. 若是新功能/修复 → 基于 main 建 `feature/<编号>` 或 `hotfix/<编号>` 分支，在其上提交。
3. 归类提交：按上表选对前缀；一个逻辑单元一个提交；无关改动不混入（慎用 `git add -A`，按文件分组提交）。
4. 合并流：feature → dev（开发）→ test（提测）→ release-xxx（预发布）→ main（上线验收）；Tag 按“版本 Tag 与部署标记”规则单独处理。
5. push 只推 feature/hotfix 分支（或用户明确的合并请求）；**不直接 push/提交到 main/release/dev/test**；绝不用 `--force`。
6. 涉及 `main` / `release` 的合并或上线前，先与用户确认要推的分支；除非用户明确要求发布新版本，否则不建议版本号、不创建正式版本 Tag。
7. 用户要求打 Tag 时，先确认用途：正式版本使用 `vMAJOR.MINOR.PATCH`，仅触发/记录部署则使用部署标记；创建前检查远程同名 Tag 是否已存在。

## 六、正式版本 Tag 与发布说明

仅当用户明确确认发布新版本时执行：

1. **确认版本号**：Tag 与项目版本号一致（如 `package.json` version、构建产物 `AgentBell-0.1.0-…` → Tag `v0.1.0`）。版本规则沿用语义化版本，先与用户确认此次是否发布版本以及使用哪个版本号。
2. **查看上一个正式版本 Tag**：只在 `vMAJOR.MINOR.PATCH` 格式的 Tag 中选择上一版本，并记录其哈希；忽略 `deploy/...` 部署标记。
3. **打注释 Tag**：`git tag -a v<版本> -m "<版本>：<一句话发布主题>"`（记录打 Tag 人、时间与说明，不用轻量 Tag）。
4. **按用户指引推送**：main 尚未推送时分别执行 `git push origin main` 和 `git push origin v<版本>`；main 已在远程时只推新 Tag。绝不 `--force`。
5. **写“与上一正式版本 Tag 之间”的发布说明**：
   - 区间：`git log --oneline <上一tag>..v<新tag>`（feature 合并进来的全部提交）；**没有上一 tag 时为首个 tag**，说明从仓库起点（或最近一次既定的产品基线）起的全量内容。
   - 组织：按 commit 前缀归类（`feat:`/`fix:`/`docs:`/`refactor:`/`chore:` 等），每条说明「改了什么、为什么、影响或验证」。
   - 必须包含：关键产品/行为决策（如默认值反转、支付渠道、试用策略）、数据库/配置迁移、需要部署方配合的变更（如 NexusCore 配套迁移）、验证结果（测试数量/构建/smoke 结论）。
   - 多仓库：每个仓库各自的 tag 与发布说明分开写；先写主仓库，再注明配套仓库的 tag 与说明位置。

## 七、安全

- 绝不提交 `.env`、密钥、令牌（凭据进 gitignore 的 `.env`，不入库）。
- 提交前对 diff 做敏感项扫描（`AKID`、`sk-`、`secret`/`password`、`BEGIN PRIVATE` 等）。
- 其他会话/协作者产出的改动按「他人产出」对待：保留现状、可代为提交但归入对应 feature 提交，不擅自改动内容方向。
