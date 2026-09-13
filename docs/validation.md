# 实施与验证记录

## 2026-09-13 · 透明遗漏排查与强度微调

在实际打开 Neo-tree 和 Snacks 选择器后导出高亮及每个窗口的 `winhighlight`，定位到以下非语义背景：默认 StatusLine/StatusLineNC、TabLine/TabLineFill、TitleBar、Neo-tree 自行生成的 `#141414` 非活动页签与实色标题、Heirline 的非活动 buffer 背景，以及上一版刻意保留的 NormalFloat / Pmenu 浮层。

上述区域已改为终端默认背景，浮窗标题和边框也透明；通过继承关系覆盖 Snacks、Blink、Which-key、Lazy 和 Mason。Mason 的额外 backdrop 设置为 100。保留当前项、光标行、搜索、diff、圆弧模块等语义强调，并显式设置 mode_fg，避免状态栏透明后模式块文字跟随 NONE。

壁纸遮罩由 0.96 调至 0.94，毛玻璃不透明度由 0.90 调至 0.88；tmux popup 同步使用默认背景。已有窗口若有背景 overrides，需要重新选一次模式或用 Cmd+. 切图来应用新强度；已有 Neovim 进程需重新启动加载新插件配置。

`tests/nvim.lua` 增加背景覆盖与模式文字对比度检查；`tests/nvim-surfaces.lua` 实际打开 Neo-tree、120 列紧凑选择器及预览、160 列宽选择器，检查窗口的正文／边框／标题／分隔线背景，重载主题后再次检查。异步关闭选择器后先等待其清理，再触发下一次尺寸变化。剩余带底色的高亮均归于选中状态、diff、光标／列指示、调试提示、圆弧模块或未启用的阴影／遮罩。

顺带修正 doctor 对物理按键导出大小写的假设：本机 `show-keys` 可能输出 `phys:c` 或 `phys:C`，不能据此误报配置加载失败。GUI 截图验收仍受前文所述工具限制。

## 2026-09-13 · 三层背景继承与背景模式

实际版本：WezTerm `20260912-133823-2afb8364`、tmux `3.7c`、Neovim `0.12.5`。

- WezTerm 新增独立背景模块。默认壁纸 + 96% Mocha 遮罩；命令面板提供壁纸、毛玻璃、纯色专注和选图。切换清除旧模式的背景层／透明度／模糊，保留其他窗口 overrides，并按窗口记住所选图片。空图片目录、空文件、已删除图片均有安全回退。
- 标签栏空白及圆弧外侧继承画布，圆弧色块保留。tmux 正文／状态栏默认背景；popup 覆盖为与 Neovim 一致的浮层底色。Neovim 正文、侧栏与分隔线清除背景，Heirline 空白区使用 NONE；Snacks 与 Blink 浮窗保留底色。
- 原生 `tests/wezterm.lua` 通过：原有按键／标签测试，以及模式切换、窗口隔离、选图记忆、其他 overrides 保留、图片筛选与缺失回退；实际 WezTerm 配置解析通过。
- `tests/nvim.lua` 通过：原有导航／剪贴板行为，结构背景透明、浮窗／选中项底色与 Heirline 圆弧配色，连续两次主题重载。
- 额外用完整 Neovim 配置实例化 Snacks 宽布局的输入、结果与预览窗口，读取实际窗口高亮映射，确认三者均为 `#181825` 且 `winblend=0`。
- `tests/tmux.py` 通过：真实 PTY 的原有导航／复制／会话行为，新增透明正文和浮窗背景检查。测试使用独立 socket，只清理自己的 server。
- `tests/doctor.py` 通过。参考仓库的 16 张图片共 19,390,659 字节，逐一核对上游 Git blob 哈希、记录 SHA-256，并使用 macOS `sips` 验证图片可解码。图片保存在本机被 Git 忽略的背景目录；来源清单可由 Git 跟踪。
- 最后复核发现 `show-keys` 在 Lua 断言失败后可能以退出码 0 输出默认键位。新增 `tests/wezterm.py` 要求原生 Lua 成功完成后输出测试标记；修正了新测试中的圆弧背景索引。doctor 也检测意外回退默认键位，避免将退出码 0 误报为通过。

验证边界：电脑控制工具以安全限制拒绝访问 WezTerm 应用，因此本次没有完成真实 GUI 截图验收；未用其他截图工具绕过该限制。已验证原生配置、终端集成、图片解码和 Neovim 实际浮窗配置，壁纸的最终对比度、毛玻璃合成与原生标题栏观感仍需用户在 GUI 中观察。

## 2026-09-12 · macOS 视觉方案验证

实际版本：tmux 3.7b、Neovim 0.12.4、WezTerm 20260714-220616-d96ba571。当前视觉方案见 [视觉设计](visual-design.md)；下文 2026-09-07 的 Linux 记录保留为历史证据。

| 检查 | 本次结果 |
| --- | --- |
| 前置条件与 WezTerm 原生配置解析 | `python3 tests/doctor.py` 通过；最低 Neovim 要求更新为 0.12 |
| WezTerm 按键、标签名称与中文截断 | 原生运行 `tests/wezterm.lua` 通过；圆弧标签保留自动／手动命名，1～30 列宽检查包含圆弧和间距 |
| 字体安装 | ComicShannsMono 已存在，未覆盖；Homebrew 安装 Xiaolai Mono 3.126 成功 |
| 下载完整性 | 初次下载 TLS 中断；重试官方 URL 成功，SHA-256 与 Homebrew cask 一致，复用已验证缓存完成安装 |
| 实际 CoreText 字体解析 | `wezterm ls-fonts --text 'ABC中文路径注释检查，。'` 确认英文 ComicShannsMono，中文及全角标点 Xiaolai Mono；分别 1 格与 2 格；弧形块由 WezTerm 内置绘制 |
| 完整 AstroNvim 配置 | `tests/nvim.lua` 通过，包括 Mocha 背景、显式安装、按键、内部导航、剪贴板隔离 |
| Neovim 实际窗口冒烟检查 | 完整配置打开文件并渲染 Heirline；80／120 列下列表不溢出、预览可打开，180 列下默认并排预览；重载主题后浮窗高亮仍生效；Blink 合并选项正确 |
| 剪贴板 provider | `tests/clipboard.lua` 通过；本地 provider 与远程显式复制／缓存粘贴行为保持原样 |
| tmux PTY 集成 | `tests/tmux.py` 检查原版 application / session 圆弧模块、原始按键传递、目录继承、分屏、粘贴、OSC 52、断开重连及重载幂等性 |
| 主题更新器 | 使用当前 vendor 运行 `validate()` 隔离加载通过；未更新上游版本或文件 |
| 差异检查 | `git diff --check` 通过；无字体二进制、额外插件或锁文件变更 |

根据用户明确要求恢复圆角：tmux 主题配置与更新器恢复到本轮改动前版本；WezTerm 改用圆弧分段标签、取消下划线并恢复标签栏常显；Neovim 恢复圆弧状态栏分段，实际渲染包含左右圆弧。字体与 Mocha 配色保留。

保留测试在 macOS 上正确比较 `/var` 与 `/private/var` 工作目录的兼容修复。

字体验证必须能访问 macOS 字体服务：受限沙箱中的 `ls-fonts` 曾把已有用户字体误报为缺失，本次以完整系统环境的 CoreText 解析为准。

生效状态：配置目录已链接到仓库，WezTerm 配置启用自动重载；没有运行中的默认 tmux server，下次新建会话生效。已有 Neovim 实例未被强制关闭或修改，下次启动加载完整配置。

验证边界：本轮没有对真实 WezTerm GUI 做截图验收，也未在 macOS 上运行仅支持 Linux GTK 的 `tests/gui.py`；窗口外观最终观感与所有罕见字的覆盖情况未穷举。字体解析、原生配置、Neovim 实际浮窗几何及 tmux PTY 行为已验证。

## 2026-09-07 · 历史集成验证

2026-09-07。本机 Linux / Wayland；tmux 3.7c、Neovim 0.12.5、WezTerm 20260906-101927-d2f3f05b。

## 实施内容

- WezTerm：原生 Lua 配置、物理 Ctrl+Shift GUI 快捷键、中文宽度感知的连接标签、命令面板重命名、Astrodark 静态配色、14pt 内置字体、普通 shell 入口。
- tmux：无插件配置、前缀 Ctrl+a、目录继承、边界停止、放大保护、连续缩放、vi 历史和增量搜索、鼠标复制后保留位置、OSC 52、稳定窗口编号、模式状态栏、确认关闭和可选 lazygit 弹窗。
- Neovim：沿用 AstroNvim 与原锁文件；关闭 smart-splits 外部导航，释放终端模式 Ctrl+hjkl；显式剪贴板；远端 OSC 52 写入和非阻塞缓存粘贴。
- 启动时不克隆 lazy.nvim，不自动安装缺失插件、工具或解析器，不自动刷新 Mason 注册表。保留显式安装更新入口。
- 保持原有 resession 行为，没有增加自动恢复或项目/worktree 管理。
- 新增 README、doctor、原生配置检查及集成测试；没有修改 shell 或 SSH 配置，没有安装额外软件。

## 已执行的检查

| 范围 | 证据 |
| --- | --- |
| WezTerm 原生解析、GUI 按键白名单 | `tests/doctor.py`、`tests/wezterm.lua` 经真实 wezterm show-keys 执行通过 |
| 标签默认名称、中文截断、命令面板注册 | `tests/wezterm.lua` 调用事件处理函数并使用原生 column_width 校验 |
| 实际 GUI 配置加载 | 独立 GUI 窗口读取 effective_config，确认 14pt、#1a1d23、默认键绑定禁用 |
| 中文与图标字体 | 原生 ls-fonts：中文 Droid Sans Fallback，2 格；图标内置 Symbols Nerd Font Mono，1 格 |
| Neovim 实际合并后的设置与主题 | `tests/nvim.lua` 用完整配置启动；clipboard、smart-splits、terminal maps、Astrodark 均通过 |
| Neovim 内部导航与边界 | 创建实际编辑分屏，调用导航，验证边界停止与相邻窗口切换 |
| 普通删除与显式复制 | 注入可计数 clipboard provider，实际执行 dd / "+yy，确认分别 0 次/1 次写入 |
| 本地/SSH provider 分支 | `tests/clipboard.lua` 检查本地不覆盖默认 provider、SSH 两个寄存器各自复制和缓存 |
| tmux 键盘传递 | `tests/tmux.py` 用真实 PTY attached client 发 Ctrl+hjkl、Alt+b/f、F1、Ctrl+Left，原始程序逐字节核对 |
| tmux 前缀、目录、布局 | 实际按键创建 pane/window，检查目录；外边界、放大保护、稳定编号和连续缩放通过 |
| 缩放退出和关闭保护 | q、Esc、未知键退出；关闭 pane 的确认取消后程序仍存活 |
| tmux 历史与粘贴 | 真实复制模式选取、保留选区、键盘 y 退出、增量搜索；paste-buffer 的括号边界和换行规范通过 |
| tmux OSC 52 | 程序输出的 OSC 52 到达外层 client，tmux buffer 内容正确 |
| 断开重连 | 前缀 d 断开后原 pane PID 不变，重新 attach 仍为同一进程 |
| 重载 | 相同文件再次 source 后全局选项不累加、不漂移 |
| 真实系统剪贴板链路 | `tests/gui.py` 在独立 WezTerm 窗口执行 Neovim SSH provider → tmux → WezTerm；GTK 读取系统剪贴板确认中文内容，结束后恢复原文本 |
| GUI 多行粘贴 | 真实 WezTerm cli send-text 与 raw 程序核对 bracketed paste framing |

可复跑命令见 README；GUI 检查需要 Linux GTK3 绑定及桌面连接。测试日志不记录原剪贴板内容。

## 验证中发现并处理的问题

- AstroNvim 默认在终端模式绑定 Ctrl+hjkl：用户覆盖明确移除，否则仅改 tmux 不足以保留程序按键。
- AstroNvim 工具注册表刷新与解析器自动安装：通过官方插件选项关闭自动动作，并在 AstroCore 选项合并后清空 ensure_installed，避免继承列表触发安装；保留手动安装。
- Ctrl+Shift+= / 0 的 Shift 字符转换：明确 Physical 键位，原生解析结果为 Equal / 0 对应物理键。
- WezTerm 没有响应本次 OSC 52 读取请求：不放宽读取权限；验证使用 GTK 系统接口，远端配置保留非阻塞缓存粘贴。
- tmux paste-buffer 默认把行分隔转为 CR：集成测试按实际终端协议验证，不误认为字节必须保持 LF。
- Escape 和交互搜索提示有输入处理时序：测试分开按键并等待终端处理，避免一次写入串模拟出非人工时序。

- Neovim GUI 复制测试在事件循环启动后通过 defer_fn 执行，避免启动期连续 `-c sleep / setreg / qa` 尚未完成界面刷新而误报。

## 明确的验证边界

- 没有连接用户的真实 SSH 主机。SSH provider 分支和同样的 OSC 52 终端链路已在本机验证；真实网络断线、远端软件版本、远端 terminfo 和主机策略仍需部署时验证。
- 未穷举其他系统、键盘布局、桌面全局快捷键或输入法组合；本机配置解析、字体布局、GUI 启动和实际终端链路已验证。
- 关闭确认和模式行为的自动测试主要覆盖 tmux；GUI 关闭采用 WezTerm 原生确认动作，没有自动关闭用户已有窗口来测试。
- 不声称支持跨系统重启恢复；方案本身未包含该功能。

## 启用方式

本机三个配置软链接已存在。WezTerm 监听配置变化；新开的 Neovim 与新 tmux server 使用当前配置。对已有 tmux server，可显式 source 配置，但不清除未知的旧自定义键；不以 kill-server 强制刷新工作现场。所有验证 server 都使用临时专用 socket，完成时清理。
