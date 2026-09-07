# 实施与验证记录

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
