# WezTerm · tmux · Neovim

日常入口用 WezTerm，工作现场用 tmux，文件编辑用 AstroNvim。配置不扫描项目、不自动附着会话；Neovim 启动时自动安装缺失的插件管理器和插件。

## 开始使用

本机三个配置目录已软链接到本仓库。WezTerm 自动重载；新启动的 tmux server 和 Neovim 使用新配置。已有 tmux server 可执行 `tmux source-file ~/.config/tmux/tmux.conf`，但之前加载的其他绑定不会因此自动清除；不要为应用配置杀掉正在运行任务的 server。

保留原有圆角主题：tmux 恢复应用／会话圆弧模块；WezTerm 标签采用同样的圆弧分段，紫色编号块连接深灰名称块。标签通常等宽 24 列，空间不足时收缩，长名称显示省略号。标签栏保持常显。macOS 保留独立的原生窗口标题栏和红黄绿按钮。窗口装饰变更若未随自动重载生效，请保存工作后重新启动 WezTerm。

```sh
# 本地：在需要的目录创建工作现场
cd /path/to/work
tmux new -s work
# 随时重新连接
tmux attach -t work
# 查看已有会话
tmux ls
```

远程先执行 `ssh 主机别名`，然后在远程执行同样的 tmux 命令。SSH 设置放在 `~/.ssh/config`。重要任务应在其执行机器的 tmux 内启动；关闭普通 shell 不等于保留任务。

`Ctrl+a` 后按 `d` 离开并保留现场。机器重启或 tmux server 被结束后不会自动恢复。

tmux 使用 [模块化配置](tmux/README.md)，外观采用随项目保存的 Catppuccin Mocha 主题，保留原有圆弧状态模块，并提供上游正式版检查／更新命令。

## 字体与外观

英文字体保留 **ComicShannsMono Nerd Font Mono**，中文回退使用 **Xiaolai Mono（小赖等宽）**。正文 18pt、行高 1.05，左右留白 12px、上下 8px。macOS 新机器安装字体（已有字体跳过对应命令）：

```sh
brew install --cask font-comic-shanns-mono-nerd-font
brew install --cask font-xiaolai-mono
```

WezTerm、tmux 和 Neovim 统一 Catppuccin Mocha。Neovim 沿用已有插件，精简状态栏，搜索／补全／输入框采用统一浮窗配色和圆角边框。文件搜索在小于 140 列时优先展示结果列表，`Alt+p` 切换预览；宽窗口默认并排预览。专用选择器可保留自身布局。

配置位置、色板与调节说明见 [视觉设计](docs/visual-design.md)。

## 按键速查

“前缀”是 `Ctrl+a`。**连按两次 Ctrl+a** 将原始 Ctrl+a 发给 shell；偶尔嵌套时，再接操作键即可操作内层 tmux。

| 操作 | tmux 按键 |
| --- | --- |
| 分屏：左右 / 上下 | 前缀 `\|` / `-` |
| 移动到相邻 pane | 前缀 `h/j/k/l` |
| 放大 / 还原 pane | 前缀 `z` |
| 连续缩放 | 前缀 `r`，再按 `hjkl`；`q/Esc` 退出 |
| 新建 window | 前缀 `c` |
| 前 / 后一个 window | 前缀 `p` / `n` |
| 最近使用的 window | 前缀 `a` 或 `Tab` |
| 按编号选择 window | 前缀 `1–9` |
| session / window 选择树 | 前缀 `s` / `w` |
| 新建 / 重命名 session | 前缀 `S` / `$` |
| 重命名 window | 前缀 `,` |
| 确认关闭 pane / window | 前缀 `x` / `&` |
| 历史 / 向上搜索 | 前缀 `[` / `/` |
| 粘贴 / 选择 tmux buffer | 前缀 `]` / `=` |
| lazygit 弹窗（需已安装） | 前缀 `g` |
| 帮助 / 重载配置 | 前缀 `?` / `R` |

新 pane 和 window 都继承发起操作的位置。窗口编号从 1 开始，关闭其他窗口不会导致重新编号。最外侧导航停止；放大 pane 时先还原，再切换到其他 pane。缩放模式的未知按键只退出模式，不发送给程序。

| GUI 操作 | WezTerm 按键 |
| --- | --- |
| 新标签 / 新窗口 | Ctrl+Shift+t / n |
| 请求关闭标签 | Ctrl+Shift+w |
| 第 1～9 个标签 | Alt+1～9 |
| 系统复制 / 粘贴 | Ctrl+Shift+c / v |
| GUI 搜索 / 命令面板 | Ctrl+Shift+f / p |
| 重载 | Ctrl+Shift+r |
| 字号增加 / 减少 / 恢复 | Ctrl+Shift+= / - / 0 |

通过命令面板的 **Rename connection tab** 命名连接或任务标签，空名称恢复固定的 `local`。标签和原生窗口标题不跟随当前程序变化；`local` 是默认标签名，不代表连接状态检测，SSH 连接请手动改为主机别名。标签不会根据 ssh 进程名称猜测主机；tmux 状态栏左侧保持原有窗口标签，右侧恢复应用和会话圆弧模块，前缀状态由会话模块变红提示。全屏和 GUI 复制模式也在命令面板中。

## 编辑、复制和鼠标

- Neovim 普通模式：Ctrl+hjkl 切内部编辑分屏，Ctrl+方向键调整大小，到边界停止。
- Neovim 终端输入模式：Ctrl+hjkl 交给程序；按 Ctrl+反斜杠，再 Ctrl+n，回到终端普通模式。
- 普通 `y/d/c` 不覆盖系统剪贴板。`"+y` 显式复制（例如 `"+yy` 复制整行）。
- 系统粘贴用 Ctrl+Shift+v；编辑文本时先进入插入模式。
- 远程使用 OSC 52 写入本机剪贴板。远程 `"+p` 只返回该 Neovim 最后显式复制的内容，不读取你电脑最新的剪贴板，也不会等待终端查询超时。
- tmux 复制模式：`v` 选择，Ctrl+v 矩形选择，`y` 复制并退出，`q/Esc` 退出，`/` / `?` 搜索，`n/N` 切匹配。
- 鼠标点击选 pane，拖边框缩放；拖选完成即复制，但保留选区及滚动位置。
- Shift 拖选可绕过应用使用 GUI 选择；Ctrl+Shift+点击打开 URL。
- tmux 内回看输出使用 tmux 历史，而非 GUI 历史。上限分别为每 pane 50,000 行与 GUI 10,000 行。

## 新机器安装（手动）

基础目标：tmux 3.2+、Neovim 0.12+（使用内置 Catppuccin）、WezTerm。2026-09-12 已验证本机 macOS 版本为 tmux 3.7b、Neovim 0.12.4、WezTerm 20260714-220616-d96ba571。其他版本先执行检查，再部署；Neovim 远程 OSC52 provider 需要对应内置 API。

将仓库放在 `~/.config/dotfiles`；仅当目标配置路径尚不存在时创建软链接，不覆盖已有文件：

```sh
ln -s ~/.config/dotfiles/wezterm ~/.config/wezterm
ln -s ~/.config/dotfiles/tmux ~/.config/tmux
ln -s ~/.config/dotfiles/nvim ~/.config/nvim
```

远端只需要 tmux 与 Neovim；无需安装 WezTerm 或 GUI 字体。执行 `infocmp tmux-256color` 检查 terminfo，缺失时通过目标系统的软件包或 terminfo 工具显式安装。不要在 shell 中全局强制设置 TERM。

Neovim 首次启动会自动下载 lazy.nvim，并安装缺失插件；需要 Git 和网络连接：

```sh
nvim
```

后续启动也会自动补齐缺失插件。需要恢复仓库锁定版本时使用 `:Lazy restore`；更新插件使用 `:Lazy update`，审阅并保存 `lazy-lock.json`。lazy.nvim 下载失败时会显示错误信息。

工具、注册表和解析器安装是显式动作：`:MasonUpdate`、`:Mason`、`:TSInstall`。不自动安装语言服务器或 tree-sitter CLI。安装后沿用 AstroNvim 对已安装工具的集成；具体语言工具按开发需求另行选择。

## 验证与维护

```sh
python3 tests/doctor.py
wezterm --config-file "$PWD/tests/wezterm.lua" show-keys --lua > /tmp/dotfiles-wezterm-keys.lua
python3 tests/tmux.py
NVIM_LOG_FILE=/tmp/dotfiles-nvim.log XDG_STATE_HOME=/tmp/dotfiles-nvim-state XDG_CACHE_HOME=/tmp/dotfiles-nvim-cache nvim --headless -i NONE -c "lua local ok,err=pcall(dofile,'tests/nvim.lua'); if not ok then print(err); vim.cmd('cquit') end"
NVIM_LOG_FILE=/tmp/dotfiles-nvim.log nvim --clean --headless -i NONE -c "lua local ok,err=pcall(dofile,'tests/clipboard.lua'); if not ok then print(err); vim.cmd('cquit') end"
```

远端可使用 `python3 tests/doctor.py --remote`，跳过 GUI 检查。

`tmux.py` 使用真实 PTY 与独立临时 socket，会清理自己的 server，不碰日常会话。需要系统允许创建 PTY 和 Unix socket。

真实 GUI 验证（Linux，需系统 Python 的 GTK3 绑定，运行前关闭其他剪贴板写入操作）：

```sh
wezterm --config-file "$PWD/wezterm/wezterm.lua" start --always-new-process -- /usr/bin/python3 "$PWD/tests/gui.py" /tmp/dotfiles-gui-result.txt
cat /tmp/dotfiles-gui-result.txt
```

该测试会临时复制测试文字，再恢复原文本剪贴板；遇到非文本剪贴板会停止，不覆盖它。只记录结果，不记录原剪贴板内容。

详见 [视觉设计](docs/visual-design.md)、[集成设计](docs/integration-design.md)、[旧配置分析](docs/old-config-review.md)、[验证记录](docs/validation.md)、[主题来源](docs/theme-source.md)。
