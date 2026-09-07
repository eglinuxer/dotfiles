# WezTerm · tmux · Neovim

日常入口用 WezTerm，工作现场用 tmux，文件编辑用 AstroNvim。配置不扫描项目、不自动附着会话、不在启动时安装软件。

## 开始使用

本机三个配置目录已软链接到本仓库。WezTerm 自动重载；新启动的 tmux server 和 Neovim 使用新配置。已有 tmux server 可执行 `tmux source-file ~/.config/tmux/tmux.conf`，但之前加载的其他绑定不会因此自动清除；不要为应用配置杀掉正在运行任务的 server。

WezTerm 顶部标签标题栏右侧提供最小化、最大化／还原和关闭按钮；双击标签栏空白处可最大化／还原窗口。窗口装饰变更若未随自动重载生效，请保存工作后重新启动 WezTerm。

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
| 前 / 后标签 | Ctrl+Shift+PageUp / PageDown |
| 系统复制 / 粘贴 | Ctrl+Shift+c / v |
| GUI 搜索 / 命令面板 | Ctrl+Shift+f / p |
| 重载 | Ctrl+Shift+r |
| 字号增加 / 减少 / 恢复 | Ctrl+Shift+= / - / 0 |

通过命令面板的 **Rename connection tab** 命名远程连接标签，空名称恢复 `local`。标签不会根据 ssh 进程名称猜测主机；tmux 状态栏始终另显示实际主机。全屏和 GUI 复制模式也在命令面板中。

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

基础目标：tmux 3.2+、满足 AstroNvim v6 要求的 Neovim、WezTerm。已验证本机版本为 tmux 3.7c、Neovim 0.12.5、WezTerm 20260906。其他版本先执行检查，再部署；Neovim 远程 OSC52 provider 需要对应内置 API。

将仓库放在 `~/.config/dotfiles`；仅当目标配置路径尚不存在时创建软链接，不覆盖已有文件：

```sh
ln -s ~/.config/dotfiles/wezterm ~/.config/wezterm
ln -s ~/.config/dotfiles/tmux ~/.config/tmux
ln -s ~/.config/dotfiles/nvim ~/.config/nvim
```

远端只需要 tmux 与 Neovim；无需安装 WezTerm 或 GUI 字体。执行 `infocmp tmux-256color` 检查 terminfo，缺失时通过目标系统的软件包或 terminfo 工具显式安装。不要在 shell 中全局强制设置 TERM。

Neovim 首次安装 lazy.nvim（已有安装则跳过）：

```sh
git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
```

启动 Neovim 后显式执行 `:Lazy install`，需要恢复仓库锁定版本时使用 `:Lazy restore`。缺少 lazy.nvim 时只提示，不联网、不等待按键。更新插件使用 `:Lazy update`，审阅并保存 `lazy-lock.json`。

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

详见 [设计](docs/integration-design.md)、[旧配置分析](docs/old-config-review.md)、[验证记录](docs/validation.md)、[主题来源](docs/theme-source.md)。
