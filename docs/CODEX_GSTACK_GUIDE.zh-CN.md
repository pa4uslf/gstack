# gstack 在 Codex 里的使用说明

这份文档面向两类读者：

- 你自己：想知道在什么场景该不该用 gstack、应该怎么用
- Agent：进入仓库后，需要快速判断优先使用项目内 gstack 还是全局 gstack，以及该调用哪些 skill

## 一句话结论

gstack 不是“任何事都要先跑一遍”的框架，而是一组在**规划、审查、调试、浏览器验证、QA、发版**这些高杠杆节点上使用的专家 skill。

最常见的用法不是“先开 gstack 再工作”，而是：

1. 正常描述任务
2. 在需要更强约束或更强流程时，明确点名某个 `gstack-*` skill
3. 做完后回到普通编码流程

## 什么时候应该使用 gstack

适合用 gstack 的场景：

- 需求还不清楚，需要先拆清楚问题和范围
- 准备开始一个新功能，想先做产品/工程评审
- 改动已经写完，需要更严格的 review
- 遇到 bug，但不想直接盲修，想先做系统化调查
- 需要真实浏览器验证，而不是只靠代码推断
- 需要登录态测试、交互测试、端到端 QA
- 需要发版、部署检查、发布后验证

不一定需要 gstack 的场景：

- 很小的单点改动，例如改一个文案、改一个常量、修一个明显拼写错误
- 单纯查一个 API 或修一个局部类型错误
- 你已经非常明确要改哪一行代码，而且不需要额外流程

简单原则：

- **问题越模糊、风险越高、跨文件越多、越涉及浏览器或交互，越值得用 gstack**
- **问题越小、越局部、越确定，越可以直接改**

## 在其他目录工作时，应该用哪个 gstack

你现在同时有两种安装方式：

- repo-local 安装：某个项目里有 `.agents/skills/gstack`
- 全局安装：`~/gstack` 已执行过 `./setup --host codex`

优先级规则：

1. 如果当前项目里存在 `.agents/skills/gstack`，优先使用**项目内 gstack**
2. 如果当前项目没有 repo-local gstack，再回退到**全局 gstack**

为什么这样做：

- 项目内 gstack 更贴近当前仓库的版本和约定
- 全局 gstack 适合作为“任何目录都能用”的兜底版本

## 在 Codex 里怎么触发 gstack

在 Codex 里，优先按 `gstack-*` 技能名使用，不要假设 Claude 风格的短名 slash command 一定可用。

常用名字：

- `gstack-office-hours`
- `gstack-plan-ceo-review`
- `gstack-plan-eng-review`
- `gstack-review`
- `gstack-investigate`
- `gstack-browse`
- `gstack-connect-chrome`
- `gstack-setup-browser-cookies`
- `gstack-qa`
- `gstack-qa-only`
- `gstack-document-release`
- `gstack-upgrade`

典型说法：

- “先用 `gstack-plan-eng-review` 看一下这个功能方案”
- “这段改动写完了，跑一次 `gstack-review`”
- “这个 bug 不要直接修，先走 `gstack-investigate`”
- “这个页面要真实点点看，用 `gstack-qa`”
- “这个站点要登录后测试，先 `gstack-setup-browser-cookies`”

## 最常用的工作流

### 1. 新功能

适合：需求不够清楚，或者改动会跨多个文件/模块

推荐流程：

1. `gstack-office-hours`
2. `gstack-plan-eng-review`
3. 实现代码
4. `gstack-review`
5. `gstack-qa`

### 2. 明确功能，但风险较高

适合：需求已明确，但你担心架构、边界条件、测试遗漏

推荐流程：

1. `gstack-plan-eng-review`
2. 实现代码
3. `gstack-review`

### 3. 排查 bug

适合：问题原因不明、涉及多层数据流、已经试过一次两次还没修好

推荐流程：

1. `gstack-investigate`
2. 根据调查结果修复
3. `gstack-review`
4. 如果是前端或交互问题，再补 `gstack-qa`

### 4. 浏览器验证

适合：页面跳转、表单、登录态、截图、真实交互

推荐流程：

- 无登录态：`gstack-browse` 或 `gstack-qa`
- 有登录态：先 `gstack-setup-browser-cookies`
- 想看见浏览器过程：`gstack-connect-chrome`

### 5. 发版前收尾

适合：代码已经差不多完成，要做最后检查

推荐流程：

1. `gstack-review`
2. `gstack-qa`
3. `gstack-document-release`
4. 再执行你自己的提交、推送、发版流程

## 浏览器相关怎么选

如果任务重点是“真实网页交互验证”，优先考虑 gstack 的浏览器能力：

- `gstack-browse`：快速浏览器自动化
- `gstack-qa`：测试并验证页面流程
- `gstack-connect-chrome`：可视化 Chrome 协作
- `gstack-setup-browser-cookies`：导入登录态

如果任务重点是“读取真实 Chrome 登录态、站点 adapter、把浏览器当 API 调用”，仍按你本机 `~/.codex/BROWSER.md` 的规则选工具，不要机械地把所有浏览器任务都丢给 gstack。

## 如何维护 gstack

### 全局安装维护

如果你在任意目录都想能用 gstack，全局仓库 `~/gstack` 是主入口。

更新方法：

```bash
cd ~/gstack
git pull --ff-only fork main
./setup --host codex
```

### 项目内安装维护

如果某个项目里使用 repo-local gstack：

```bash
cd "$(readlink -f .agents/skills/gstack)"
git pull --ff-only fork main
./setup --host codex
```

## 现在你的推荐实践

结合你当前的环境，推荐你这样用：

- 在带有 `.agents/skills/gstack` 的项目里：优先用项目内 gstack
- 在普通目录、临时目录、没有 repo-local gstack 的仓库里：用 `~/gstack` 提供的全局 gstack
- 在 Codex 中统一按 `gstack-*` 技能名触发
- 小改动直接做；高风险节点再引入 gstack

## 最短速查

### 我现在在一个新项目里，先干什么？

- 如果需求还模糊：`gstack-office-hours`
- 如果需求清楚但改动大：`gstack-plan-eng-review`

### 我代码写完了，接下来？

- `gstack-review`

### 我怀疑页面行为有问题？

- `gstack-qa`

### 我需要登录后测试？

- `gstack-setup-browser-cookies`

### 我不在带 `.agents/skills/gstack` 的项目里，还能用吗？

- 可以，用全局安装的 `~/gstack`

### 我应该每次都先用 gstack 吗？

- 不应该。只在高杠杆节点用。
