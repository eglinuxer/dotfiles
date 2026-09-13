# 视觉设计 · 2026-09-13

以 ComicShannsMono 的手写感为主，搭配小赖等宽中文；用一致的 Mocha 背景、低饱和界面和清楚的选中状态组织 WezTerm、tmux 与 Neovim。

## 字体

- WezTerm 主字体：`ComicShannsMono Nerd Font Mono`；保留本机已有字体。
- 中文回退：`Xiaolai Mono`，通过 Homebrew `font-xiaolai-mono` 安装 v3.126。
- 不用中文字体覆盖英文字形；缺失字继续使用 WezTerm 的系统回退。
- 18pt、行高 1.05、左右留白 12px、上下留白 8px。在终端里的 tmux 和 Neovim 都继承该字体，无需各自配置 GUI 字体。
- 原生 CoreText 解析确认：英文 1 格，小赖中文与全角标点 2 格。此结果验证字体选择和终端单元宽度，不等于穷举所有汉字。

## 共同样式

圆角／圆弧是用户明确要求保留的主题特征。外观优化沿用原有圆弧分段，不改成平面下划线标签。

| 用途 | Mocha 色值 |
| --- | --- |
| 正文背景 base | `#1e1e2e` |
| WezTerm 标签栏／Neovim 状态栏及浮窗 mantle | `#181825` |
| 正文 text | `#cdd6f4` |
| 次要文字 subtext0 | `#a6adc8` |
| 标签名称底 surface0／surface1 | `#313244`／`#45475a` |
| 标签选中编号 mauve | `#cba6f7` |
| 文本选区 surface1 | `#45475a` |
| 浮窗边框 surface2 | `#585b70` |
| 交互强调 lavender | `#b4befe` |

正文画布使用 WezTerm 的统一背景。默认壁纸加 94% Mocha 遮罩；命令面板可切换毛玻璃（88% 不透明、macOS 模糊 20）或不透明纯色专注。tmux 正文与状态栏空白使用默认背景，Neovim 的 Normal、非活动窗口、分隔线和侧栏清除 RGB / 256 色背景；Heirline 空白区和非活动 buffer 标签也继承终端。WezTerm 标签圆弧外侧使用默认背景，标签栏空白透明，编号／名称色块继续保留。

浮窗正文、边框底色与标题底色透明，边框前景为 `#585b70`；tmux popup、Snacks 搜索与输入、Blink 补全／文档继承统一背景，Which-key、Lazy、Mason 通过 NormalFloat 继承。禁用 Mason / Lazy 的遮罩，不叠加全屏压暗层。Neo-tree 自行生成的非活动页签和标题条底色也清除。选中项、diff、光标行及模式圆弧保留语义底色，模式块文字显式固定为 `#11111b`。原生 macOS 标题栏继续独立绘制；WezTerm 原生分屏关闭非活动区域的额外降亮，保持与 tmux / Neovim 分屏一致。

WezTerm 使用方案 A 的自定义圆弧标签（`use_fancy_tab_bar = false`，由标题事件绘制 `` / ``）：编号块与名称块分色，当前编号为 mauve、名称底为 surface1，呼应 tmux 原有 Catppuccin 圆弧模块。标签栏保持常显，通常等宽 24 列，空间不足时服从实际分配宽度；长名称按终端列数裁切并加省略号，同时预留圆弧和间距。名称优先使用手动设置值，默认为固定的 `local`，不跟随 pane 的程序标题变化；SSH 连接需手动命名，默认名称不作为连接状态指示。macOS 原生窗口标题使用同一名称，最多保留 48 列再附加 ` — WezTerm`；原生窗口按钮独立保留。

tmux 恢复改动前的主题配置：Mocha、左侧 basic 窗口标签、右侧 application / session 圆弧模块、跟随终端的状态栏背景。前缀状态通过会话模块变红显示。圆弧来自右侧状态模块；保留这个原始布局，不将窗口标签擅自替换成另一种上游预设。原版 vendor 文件保持原样，主题选项位于 `tmux/conf.d/30-theme.conf`。

## Neovim

- 使用 Neovim 0.12 自带的 `catppuccin`，`background=dark` 选择 Mocha；没有新增主题插件或修改锁文件。
- AstroUI 统一浮窗、输入框、选择项以及 Heirline 配色；模式、分支、文件信息与位置区域保留圆弧分段。
- 状态栏保留模式、Git 分支／差异、文件类型、诊断、搜索／宏提示和位置；移除重复的末端模式块与常驻 LSP／解析器／虚拟环境标签。原有功能仍可通过对应工具访问。
- Snacks 文件搜索：小于 140 列时使用大列表，默认隐藏预览；`Alt+p` 可切换上下预览。至少 140 列时使用并排预览。布局在打开时选择；工具自己的专用布局优先。
- Blink 补全菜单、文档与签名框使用圆角边框。文档自动显示延迟 200ms，减少快速移动候选项时闪动。
- 沿用原有搜索、补全和缓冲区操作键位。

## 调整与生效

| 调整内容 | 文件 |
| --- | --- |
| 字体、字号、留白、窗口色板 | `wezterm/appearance.lua` |
| 壁纸／毛玻璃／专注、透明强度、图片路径 | `wezterm/background.lua` |
| WezTerm 标签圆弧、分段颜色与文字 | `wezterm/events.lua` |
| tmux 状态栏与弹窗 | `tmux/conf.d/30-theme.conf` |
| Neovim 主题与高亮 | `nvim/lua/plugins/astroui.lua` |
| 搜索布局、补全与状态栏组件 | `nvim/lua/plugins/ui.lua` |

WezTerm 自动重载配置；已有 tmux server 用 `tmux source-file ~/.config/tmux/tmux.conf` 重载；Neovim 在下次启动时加载全部插件选项。无需重建会话或结束进程。字体文件安装在 macOS 用户字体目录，未加入仓库；新机器需要显式安装字体。

来源见 [主题来源](theme-source.md)，实际检查与边界见 [验证记录](validation.md)。
