# WezTerm / tmux / Neovim 集成设计

2026-09-07。用户已授权重新设计，不要求兼容此前逐项决定。本文根据日常开发、SSH、应用按键兼容性和维护成本重新取舍；旧配置与此前讨论仅作为参考。本文是已实施的设计基线。具体文件、检查结果和未实测范围见 validation.md；已有进程是否加载新配置取决于各自重载机制。

## 0. 设计出发点

让三个软件分别提供稳定的连接入口、可返回的工作现场、完整的编辑环境。深度集成集中在按键传递、剪贴板、目录、终端能力和视觉一致性，不要求三者实时互相控制。

- 一个标签页通常代表一个连接入口；一个 session 代表一组需要一起返回的工作；一个 window 代表一种活动；一个 pane 代表一个并排运行的程序。session 不强制等于仓库、worktree 或项目。
- 分屏是有明确层级的：文件之间使用 Neovim 编辑分屏，独立进程之间使用 tmux pane。用前缀表达跨进程操作，比所有程序都争夺 Ctrl+hjkl 更可预测。
- 默认配置服务于频繁操作；低频功能通过原生命令面板、树形选择器和帮助访问。
- 可以检查当前应用、操作系统、工具是否存在，但不建立项目管理框架或自动安装链路。
- 先保证断线继续工作；机器重启恢复作为未来独立功能，不与基本会话混合。

## 1. 使用模型

- WezTerm 启动普通登录 shell，不自动创建、附着或恢复 tmux。
- 本地：WezTerm → 本地 tmux → shell / Neovim / 任务。
- 远程：WezTerm → 系统 OpenSSH → 远程 tmux → shell / Neovim / 任务。
- 默认避免本地、远程两层 tmux 嵌套，偶尔嵌套通过发送前缀操作内层。
- SSH 主机、端口、密钥、跳板机统一留在 ~/.ssh/config；不复制进三款软件的共享配置。
- tmux 仅管理已有会话及手动创建的会话，不扫描项目、识别 worktree、收藏目录或自动运行项目任务。
- 需要断线后继续运行的程序必须放在其执行机器上的 tmux 中。普通 shell 不提供这一保证。
- 不增加机器重启恢复、任务自动重启、布局存档插件。

## 2. 职责和对象

| 软件 | 负责的对象 | 日常职责 |
| --- | --- | --- |
| WezTerm | 图形窗口、标签页 | 连接入口、字体、输入法、系统剪贴板、链接 |
| tmux | session、window、pane | 会话切换、进程布局、历史输出、断开重连 |
| Neovim | buffer、编辑窗口 | 文件编辑、搜索、LSP、诊断、编辑器内终端 |

WezTerm 不提供另一套日常业务分屏快捷键。Neovim 内置终端保留给短时命令、REPL 或临时 Git 操作；持续服务和重要任务放在 tmux pane。

## 3. 按键原则

- tmux 前缀 Ctrl+a，保留可见的前缀状态提示；不额外强加前缀超时。
- 连按两次 Ctrl+a 发送原始 Ctrl+a；前缀 a 切换到上一个使用过的 window。这次重新选择让原始按键通过重复自身获得，最近窗口使用同手操作。
- 不全局占用 Ctrl+hjkl、Ctrl+方向键、Alt+字母或裸 F1–F12。
- tmux 普通操作只消费一次前缀后的按键，不让后续输入意外留在重复操作状态。
- 仅连续缩放模式允许 hjkl 持续执行；状态栏持续提示模式。
- 按方向移动到最外侧时停止，不从另一侧绕回。tmux 需要显式边界条件，不能仅依赖 select-pane 默认行为。
- 放大 tmux pane 后，方向导航不隐式取消放大；先 z 还原再跨 pane。
- 不改变 shell 按键绑定，不在终端层发送自造字符替代组合键。

## 4. tmux 目标快捷键

下表“前缀”均为 Ctrl+a。

| 按键 | 行为 |
| --- | --- |
| 前缀 Ctrl+a | 发送原始 Ctrl+a |
| 前缀 a | 上一个使用过的 window |
| 前缀 d | detach，保留会话和任务 |
| 前缀 s | 选择已有 session |
| 前缀 w | 显示窗口/会话树 |
| 前缀 S | 输入名字，创建新 session，起始目录取当前 pane 目录 |
| 前缀 $ | 重命名 session |
| 前缀 c | 从当前 pane 目录创建 window |
| 前缀 , | 重命名 window |
| 前缀 n / p | 下一/上一 window |
| 前缀 Tab | 上一个使用过的 window |
| 前缀 1–9 | 按编号选择 window |
| 前缀 \| | 左右分屏，继承当前 pane 目录 |
| 前缀 - | 上下分屏，继承当前 pane 目录 |
| 前缀 h/j/k/l | 左/下/上/右相邻 pane |
| 前缀 z | 放大/还原 pane |
| 前缀 r | 进入连续缩放模式 |
| 缩放模式 h/j/k/l | 按方向调整，每次 2 格 |
| 缩放模式 q/Esc | 退出；其他非缩放键退出且不执行破坏性操作 |
| 前缀 x | 确认后关闭 pane，提示目标编号及程序 |
| 前缀 & | 确认后关闭 window，提示窗口名 |
| 前缀 [ | 进入 vi 复制模式 |
| 前缀 / | 进入复制模式并向历史上方增量搜索 |
| 前缀 ] | 粘贴 tmux buffer，使用 bracketed paste 能力 |
| 前缀 = | 选择 tmux buffer |
| 前缀 ? | 查看按键帮助 |
| 前缀 R | 重载配置并反馈成功/错误 |
| 前缀 g | 若安装了 lazygit，在当前目录打开 Git 弹窗；缺少工具则提示，不自动安装 |

不新增一键杀整个 session 的绑定。显式退出程序仍使用程序本身的退出方式。

窗口与 pane 从 1 编号。关闭 window 后不自动重编号，避免熟悉的编号随关闭其他窗口变化。支持手动整理布局，默认不强制创建 edit/run/logs 等窗口。

新 window 与新 pane 都继承当前 pane 目录，这是重新评估后的统一规则：在哪里发起操作，就从哪里继续。Neovim 当前文件目录不隐式更改外部 shell 目录，不自动推断 Git 根目录。要从另一目录开始，先在 shell 中 cd 或显式指定 -c。

## 5. Neovim 导航及剪贴板

- 保留 AstroNvim 普通模式 Ctrl+hjkl 内部分屏导航及 Ctrl+方向键缩放。
- smart-splits 关闭 multiplexer 集成，最外侧停止，不跨出到 tmux。
- 插入模式与终端输入模式不增加全局方向抢占；内置终端可通过原生 Ctrl+\\、Ctrl+n 返回普通模式。
- 保留空格 Leader 和逗号 LocalLeader，沿用现有 AstroNvim 搜索、LSP、诊断、终端操作。
- 清空 clipboard 的 unnamedplus 联动。y/d/c 使用内部寄存器；系统剪贴板由显式寄存器操作访问。
- 正常/可视模式均使用原生 "+y 复制到系统剪贴板，避免再新增可能冲突的 Leader 快捷键。
- 系统粘贴主要使用 WezTerm Ctrl+Shift+v。在普通模式准备插入文本时先进入插入模式，落实时验证 bracketed paste 的实际行为。
- 本地优先使用已可用的系统 clipboard provider；远程显式提供 OSC 52 复制路径，不能仅依赖 tmux 内自动检测。
- 不把远端 OSC 52 读剪贴板当作必须能力；未验证时不承诺远程 "+p 可读到本机剪贴板。复制成功与读取成功分别检查。
- 保留现有 lazy-lock.json 和 AstroNvim 架构。不整体启用模板示例，不新增会话自动恢复逻辑；现有 resession 保存行为保持原状。

## 6. 历史、鼠标和复制

- WezTerm 历史上限 10,000 行；tmux 每 pane 50,000 行，作为第一版可调默认值。
- tmux 内历史以 tmux 复制模式为准；GUI 搜索主要用于普通 shell。
- 复制模式：hjkl 移动，v 选择，Ctrl+v 矩形选择，y 复制并退出，q/Esc 取消退出。
- / 向下、? 向上增量搜索；n/N 下一个/上一个匹配。
- 鼠标开启：点击选 pane，拖边框调整；不启用鼠标悬停自动切焦点。
- 拖选结束立即复制，保留选区和滚动位置；q/Esc 回实时输出。
- Neovim 有自己的鼠标模式，滚轮优先交给 Neovim，不能强制当成 tmux 历史滚动。
- Shift 拖选为 WezTerm 直接选取的备用入口，正常情况用 tmux pane 内复制。
- Ctrl+Shift+点击打开 URL，显式适配鼠标上报场景；沿用原生链接规则，不手写一套宽泛正则。
- tmux 复制通过 OSC 52 写入本机剪贴板。选择 set-clipboard on 以允许内部应用的 OSC 52 复制路径；与 Neovim 内部寄存器分离是两个不同层面。
- 不为了 OSC 52 一概开启所有 passthrough；图片及其他转义透传在有明确用途时再处理。

## 7. WezTerm 操作和外观

| 按键 | 行为 |
| --- | --- |
| Ctrl+Shift+t | 新标签，普通 shell |
| Ctrl+Shift+n | 新图形窗口，普通 shell |
| Ctrl+Shift+w | 请求关闭当前标签，有运行程序时确认 |
| Alt+1～9 | 切换到第 1～9 个 GUI 标签 |
| Ctrl+Shift+c/v | 系统复制/粘贴 |
| Ctrl+Shift+f | GUI 内容搜索，作为普通 shell 的搜索入口 |
| Ctrl+Shift+p | 命令面板，用于低频 GUI 操作 |
| Ctrl+Shift+r | 重载 WezTerm 配置 |
| Ctrl+Shift+= / - / 0 | 字体放大/缩小/恢复 |

GUI 仅保留明确列出的快捷键及必要复制模式表，审计默认绑定，尤其 Ctrl+Tab、Alt+数字、功能键。使用 Physical 键位匹配，避免 Shift+= 变成 +、Shift+0 变成 ) 后匹配丢失；已通过原生解析器检查。

- 使用 Astrodark 作为三端视觉基线。Neovim 保留 AstroTheme；WezTerm 与 tmux 取同一主题的静态色值，记录来源，不在运行时读取 Neovim 插件目录。
- 默认纯色、不透明、不使用背景图片，不自动随机换背景。浮窗与补全菜单保留可读的背景层次。
- 默认使用 WezTerm 自带 JetBrains Mono，初始 14pt，减少跨机字体依赖；旧 ComicShannsMono 留作可替换外观偏好，不因旧配置使用就默认继承。保持 GUI 窗口大小不随字号调整。
- 保留 WezTerm 内置 fallback；额外中文字体只选实际安装并验证过的字体。本机实际中文回退为 Droid Sans Fallback，已通过 WezTerm ls-fonts 验证中文占两格；符号使用内置 Symbols Nerd Font Mono。
- 默认 120 列、36 行，保留窗口管理器的放置习惯，不强制最大化。
- 不强制独显、不自建 GPU 打分器，不将 120 FPS 作为通用要求；使用默认渲染策略及适度刷新。
- 关闭声音提示；错误退出显示退出状态。有前台任务时关闭确认，普通 shell 正常 exit 无多余确认。

## 8. 信息显示

- 顶部 WezTerm 标签：连接名称；本地显示 local，可手动命名远程入口。
- 系统 ssh 启动的连接仍属于本地 WezTerm domain，不能仅凭 domain 推断远端主机。首版以手动标签名作为可靠退路；如自动显示主机，再用明确的启动元数据或轻量 shell 通知，不猜进程参数。
- 底部 tmux：左侧主机/session，中央 window 名称及编号，右侧 PREFIX / COPY / RESIZE / ZOOM 状态。
- tmux 即使换终端接入，也保留主机标识，远程操作始终能确认目标机器。
- Neovim：保留文件、分支、诊断、光标位置等编辑信息。
- 不显示电池、时间、CPU、内存等额外模块，不复制旧版 615 行标签渲染框架。
- 重要模式用文字与颜色共同提示，不能只依赖 Nerd Font 图标。

## 9. 终端兼容性

- 外层使用 WezTerm 实际 TERM；tmux 内层使用 tmux-256color；逐台远程检查 terminfo。
- 启用焦点事件、真彩色支持和必要的键盘协商；extended-keys 以 on 为默认，不强制 always。
- 不向所有 xterm-256color 或所有 TERM 宣称未经验证的高级能力。
- 本机 tmux 3.7c / Neovim 0.12.5 / WezTerm 20260906 作为本地验证基线，远端版本在部署时检测。
- 远端缺少某项高级能力时降级该能力，保留会话、按键、复制模式基础；不在启动时自行升级或联网安装软件。

参考：[tmux 手册](https://man.openbsd.org/tmux.1)、[WezTerm 字体及 fallback](https://wezterm.org/config/fonts.html)、[原生链接规则](https://wezterm.org/hyperlinks.html)。

## 10. 文件与维护

```text
dotfiles/
├── docs/
│   ├── integration-design.md
│   └── old-config-review.md
├── wezterm/
│   ├── wezterm.lua
│   ├── appearance.lua
│   ├── keys.lua
│   └── events.lua
├── tmux/
│   └── tmux.conf
└── nvim/
    ├── lazy-lock.json
    └── lua/plugins/
        ├── astrocore.lua
        └── smart-splits.lua
```

核心结构已实施；另增加 clipboard_setup.lua、tool-installation.lua、验证脚本及使用说明。其余模板文件保持禁用，未整体启用示例。

- 三款软件各自原生配置，无跨进程共享 Lua、配置生成器或项目数据库。
- 初版不新增 tmux/WezTerm 外部插件，不更换 Neovim 插件体系。lazygit 是检测后调用的可选外部程序，缺失不影响基础配置。
- 配置加载不联网、不安装、不自动创建任务。
- 本机差异仅在实际需要时加被 Git 忽略的覆盖文件；不提前搭建多层平台框架。
- 旧文件仅提取必要逻辑，实质复制上游代码时保留原有版权声明。

## 11. 实施与验收

1. 先实现 tmux 核心、WezTerm GUI 层和 Neovim 最小覆盖，不安装可选增强。
2. 使用独立 tmux socket 验证，避免重载污染正在使用的会话；GUI 配置先隔离检查。
3. 验证普通 shell、Neovim 普通/插入/终端模式下的 Ctrl/Alt/F 键不被意外截获。
4. 验证新 pane 与 window 都继承当前目录，以及关闭其他窗口后编号稳定。
5. 验证边界停止、放大模式、连续缩放退出、模式标记和确认关闭。
6. 验证中文/图标宽度、链接点击、鼠标选择、增量搜索、复制后保持位置。
7. 验证本地系统剪贴板、Neovim 内部删除不覆盖剪贴板、多行粘贴。
8. 有可用远程主机后验证 SSH 中 OSC 52、按键协商、断线后任务存活与重新附着；未执行前明确标注远程未验证。
9. 完成后提供精简按键速查与变更说明，不用跑通 GUI 启动来冒充端到端验证。
