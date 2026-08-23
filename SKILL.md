---
name: git-workflow
description: "两个独立 git 仓库（NexusCore 后端 / Snipix 前端）的提交与分支约定：提交信息按 Commit 规范标注类型；分支模型为 main/release/dev/test/feature/hotfix，只有 feature 与 hotfix 可直接提交，其余分支禁止直接改。使用时：准备 git commit / 切分支 / 合并 / push 时遵循此 skill。"
---

# Git 工作流（双仓库 · Commit 规范 + 分支模型）

## 适用仓库（各自独立 git，分开提交与推送，禁止混合）

| 仓库 | 路径 | 角色 |
| --- | --- | --- |
| **NexusCore** | `E:\Coding\NexusCore` | Payload 各类 SaaS 后端 / 控制平面（auth、billing、media/COS、配额、API） |
| **Snipix** | `E:\Coding\Snipix` | 前端 web + Chrome 扩展（workspace 编辑器、媒体面板、定价/个人中心等） |

- 前端（Snipix）经 BFF/Platform API 调后端（NexusCore）；同一条 feature 可能横跨两仓，但**提交/推送**必须分仓库各自进行。
- 每个 repo 先 `git status` / `git branch --show-current` 看清是哪个仓库、在哪个分支，再动手。

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
| **release**(release-xxx) | 上线前预发布环境 | **禁止**直接修改提交；验收通过后合并到 main 并打 tag |
| **dev** | 开发环境 | **禁止**直接修改提交 |
| **test** | 测试环境 | **禁止**直接修改提交 |
| **feature**（feature/00001） | 基于 main checkout，开发新功能 | **允许**直接修改提交 |
| **hotfix** | 基于 main 创建，修复线上 bug | **允许**直接修改提交（流程同 feature） |

## 三、开发流程

1. **收需求**：基于 `main` checkout 新分支 → `feature/00001`。
2. **开发阶段**：在 feature 分支上开发、**允许直接提交**；开发完成后合并到 `dev`，发布 dev 环境。
3. **提测阶段**：将 feature 分支合并到 `test`；测试反馈的 bug 继续在该 feature 分支修改，改完再合并到 `dev` 和 `test`，发布 test 环境。
4. **预发布阶段**：基于 main checkout 新 `release-xxx`；把要上线的 feature 分支合并进 `release-xxx`；bug 修改继续在 feature 分支进行并重复合并到 `dev`、`test`、`release-xxx`；发布预发布环境。
5. **上线发布**：发布 `release-xxx`；验收通过后将 `release-xxx` 合并到 `main`，**打版本 tag**；删除 `release-xxx`、`feature/00001`。
6. **hotfix**：从 main 建分支修复线上 bug，流程同 feature。

要点：**只有 feature 与 hotfix 分支允许直接提交**；main/release/dev/test 一律通过合并流入，不直接改。

## 四、执行步骤（准备 commit / 切分支 / 合并时）

1. 明确当前仓库与分支：`git status` + `git branch --show-current`。
2. 若是新功能/修复 → 基于 main 建 `feature/<编号>` 或 `hotfix/<编号>` 分支，在其上提交。
3. 归类提交：按上表选对前缀；一个逻辑单元一个提交；无关改动不混入（`git add -A` 慎用，按文件分组提交）。
4. 合并流：feature → dev（开发）→ test（提测）→ release-xxx（预发布）→ main + tag（上线验收）。
5. push 只推 feature/hotfix 分支（或用户明确的合并请求）；**不直接 push/提交到 main/release/dev/test**；绝不用 `--force`。
6. 涉及 `main` / `release` 的合并或上线前，先与用户确认要推的分支与 tag 版本。

## 五、安全

- 绝不提交 `.env`、密钥、令牌（凭据进 gitignore 的 `.env`，不入库）。
- 提交前对 diff 做敏感项扫描（`AKID`、`sk-`、`secret`/`password`、`BEGIN PRIVATE` 等）。
- 其他会话/用户产出的改动按「用户产出」对待：保留现状、可代为提交但归入对应 feature 提交，不擅自改动内容方向。