# WezTerm / tmux / Neovim 背景一致性分析

检查日期：2026-09-13。下文保留实施前的诊断与方案，所述“当前配置”为分析时的快照。用户批准后已实施三层背景继承与三种模式；使用方法见 [README](../README.md#背景模式)，实施验证见 [验证记录](validation.md)。本机也已下载参考仓库的 16 张壁纸。

结论：当前配置可以支持参考仓库的壁纸效果，也能支持 macOS 桌面毛玻璃。让 WezTerm 统一绘制背景，让 tmux 和 Neovim 的正文区域使用终端默认背景；保留圆弧模块、选区和浮窗的可读性。现有 Catppuccin Mocha、字体、按键与会话结构可以继续使用。

## 参考仓库实际做了什么

[KevinSilvester 的背景模块](https://github.com/KevinSilvester/wezterm-config/blob/master/utils/backdrops.lua) 在底层放图片，上方叠加不透明度 `0.96` 的主题底色。遮罩宽高为 `120%`，偏移为 `-10%`，覆盖范围超出窗口；图片居中。对完全不透明的图片，这相当于约 96% 遮罩色与 4% 图片颜色的混合，整体仍然不透明。

专注模式把上述两层换成不透明度 `1` 的纯色层。随机、轮换和选择图片通过窗口配置覆盖实现。[入口](https://github.com/KevinSilvester/wezterm-config/blob/master/wezterm.lua) 启动时扫描图片并随机选择。

所以参考仓库默认的核心是“低对比度壁纸”，不能把遮罩的 `0.96` 解释为整个窗口有 4% 的桌面透视。[外观配置](https://github.com/KevinSilvester/wezterm-config/blob/master/config/appearance.lua) 也没有设置桌面透明度或 macOS 模糊。

它的[色板](https://github.com/KevinSilvester/wezterm-config/blob/master/colors/custom.lua) 使用修改后的 Mocha，正文基色是 `#1f1f28`，标签栏底色为带 alpha 的黑色。你的基色是标准 Mocha `#1e1e2e`。移植背景机制即可，不需要替换整套色板。

## 三种“透明”必须区分

| 设置 | 作用对象 | 能看到什么 |
| --- | --- | --- |
| WezTerm `window_background_opacity` | 窗口背景 | 桌面或后面的窗口 |
| WezTerm `background` 中各层的 `opacity` | 图片、色块等背景层 | 下方的背景层；能否透桌面取决于整个背景的合成 |
| Neovim `bg = "NONE"` / tmux `bg=default` | 终端单元格的默认背景 | WezTerm 绘制的共同背景 |

WezTerm 的 `text_background_opacity` 控制非默认单元格背景，默认 `1.0`。它不是文字前景透明度。全局降低它会同时削弱状态模块、搜索结果、diff 等色块。[官方说明](https://wezterm.org/config/appearance.html#text-background-opacity)

本机版本对应的[渲染源码](https://github.com/wezterm/wezterm/blob/2afb8364/wezterm-gui/src/termwindow/render/screen_line.rs#L202) 用 `ColorAttribute::Default` 判断默认背景，而非仅比较 RGB。因此，显式的 `#1e1e2e` 与终端默认背景并不等价。适配应清除正文底色，而不能只要求三套主题颜色一样。

Neovim 的 `winblend`、`pumblend` 是其内部浮窗／菜单的伪透明，会混合编辑器底层内容，不负责 macOS 桌面透视。当前两者均为 `0`，建议继续保持；依据本机 `:help winblend` 和 `:help pumblend`。

## 当前配置的具体情况

三个 `~/.config/` 配置目录均软链接到本仓库。实测版本为 WezTerm `20260912-133823-2afb8364`、tmux `3.7c`、Neovim `0.12.5`，高于仓库 README 原来的验证版本。

| 部位 | 当前状态 | 适配动作 |
| --- | --- | --- |
| WezTerm 正文背景 | `window_background_opacity = 1`，无图片层 | 增加壁纸模式或桌面透明模式 |
| WezTerm 标签栏 | 底色 `#181825` | 若要标签空白区域也融入背景，需要单独调整 |
| WezTerm 圆弧外侧 | `events.lua` 再次写入 `#181825` | 与标签栏底色一起处理，避免圆弧外侧出现实色矩形 |
| tmux 正文 | `window-style`、`window-active-style` 均为 `default` | 已具备继承条件 |
| tmux 状态栏空白 | `status-style = bg=default` | 已具备继承条件 |
| tmux 分隔线 | 仅设置前景色 | 已具备继承条件 |
| tmux popup | 主题加载后为 `bg=#1e1e2e` | 建议作为有底色的浮层保留 |
| Neovim `Normal` | RGB 背景 `#1e1e2e`，256 色背景 `233` | 同时清除 `bg`、`ctermbg` |
| Neovim `WinSeparator` | 显式背景 `#1e1e2e` | 保留前景，清除背景 |
| Neovim 行号、符号列、文件末尾 | 查询到的高亮无显式背景 | 随正文继承；可用明确规则防止以后被覆盖 |
| Neovim 状态栏与 buffer 栏 | AstroUI 配色表写死多个底色 | 区分空白底色和圆弧模块底色 |
| Neovim 浮窗、输入与补全 | `NormalFloat`、`Pmenu` 等使用 `#181825` | 建议保留，保证阅读与层次 |

配置位置：`wezterm/appearance.lua`、`wezterm/events.lua`、`tmux/conf.d/30-theme.conf`、`nvim/lua/plugins/astroui.lua`、`nvim/lua/plugins/ui.lua`。

## 推荐的视觉规则

- 正文、普通分屏、行号区、侧栏和状态栏空白区域共享同一背景。
- 紫色模式块、圆弧标签、当前 buffer、搜索选中项及 diff 保留底色。
- Snacks 搜索／输入框、Blink 文档与补全、tmux popup 使用统一 Mocha 浮层底色。它们打开时是清晰的面板，不让后面的代码穿过来。
- macOS 原生标题栏保留原生窗口按钮。原生标题栏、WezTerm 标签栏和终端正文属于不同绘制区域，不承诺仅改正文透明度就能获得完全相同的效果。

这里的一致性是正文继承与浮层层次一致。若希望所有浮窗也透出壁纸，可以追加清除对应高亮背景；应明确设置各插件的 Normal／Border／Title，不能靠 `winblend` 或全局降低文字背景透明度替代。

## WezTerm 的两条落地路径

### 路径 A：接近参考仓库的壁纸模式

采用一个图片层和一个 Mocha 遮罩层；遮罩初始不透明度取 `0.96`，再按图片亮度尝试 `0.92–0.96`。这是建议调节范围，尚未进行本机视觉调参。

使用 `config.background` 管理这些层。官方说明旧背景选项会隐式增加底层，因此实现时应集中管理背景，避免混用后某个不透明底层使桌面透明失效。[背景层文档](https://wezterm.org/config/lua/config/background.html)

增加单一背景模块负责：图片路径校验、空目录回退、遮罩强度、专注模式、当前窗口状态。参考模块直接调用随机选择，空图片目录时存在 `math.random(0)` 问题；窗口覆盖也应先读取并合并已有 overrides，保留其他运行时调整。功能借鉴需要适配这些边界。

背景图存于本机 WezTerm 配置可访问的位置即可。SSH 到远端后，tmux 和 Neovim 仍在同一终端画布中绘制，不需要向远端复制图片。

### 路径 B：macOS 桌面毛玻璃

在没有图片背景层的情况下，最小入口为：

```lua
config.window_background_opacity = 0.90
config.text_background_opacity = 1.0
if wezterm.target_triple:find('apple', 1, true) then
  config.macos_window_background_blur = 20
end
```

`0.90` 表示背景 90% 不透明；`20` 是模糊参数，不是百分比。这是起始建议，最终强度需要在真实桌面上观察。相关参数已经通过本机 WezTerm 的配置解析。[窗口透明度与模糊说明](https://wezterm.org/config/lua/config/window_background_opacity.html)

不同时叠加一张完全不透明的壁纸，否则该区域无法透出桌面。可将“壁纸／毛玻璃／纯色专注”做成互斥模式。

建议通过已有 `Ctrl+Shift+p` 命令面板切换模式，复用 `events.lua` 的命令面板扩展；无需占用 tmux 与 Neovim 的按键。所有终端内容都继承默认背景后，切换只发生在 WezTerm，同一窗口内不需要给每个 tmux pane 或 Neovim 进程同步透明度。

## Neovim 如何接入现有 AstroUI

当前使用 Neovim runtime 自带 `colors/catppuccin.vim`，不是 `catppuccin/nvim` 插件。网上常见的 `require("catppuccin").setup { transparent_background = true }` 不适用于本配置。

应在 `nvim/lua/plugins/astroui.lua` 的 `opts.highlights.catppuccin` 增加／替换结构区域高亮，例如：

```lua
Normal = { fg = "#cdd6f4", bg = "NONE", ctermbg = "NONE" },
NormalNC = { link = "Normal" },
WinSeparator = { fg = "#45475a", bg = "NONE", ctermbg = "NONE" },
NeoTreeNormal = { link = "Normal" },
NeoTreeNormalNC = { link = "NormalNC" },
```

行号、符号列和文件末尾可通过读取并保留原高亮前景、仅清除背景来加固。不要批量清空所有包含 `bg` 的高亮，那样会丢失选中项、diff 和诊断的重要视觉提示。

AstroUI 已有 `ColorScheme` 自动命令，会重新应用这些配置，之后发出 `AstroColorScheme` 事件刷新 Heirline。因此无需在停用的 `polish.lua` 里另加一组启动后补丁。

还需把 `opts.status.colors.bg` 和 `tabline_bg` 改成 `"NONE"`，让状态栏和 buffer 栏的空白区透出背景；`git_branch_bg`、`file_info_bg`、`nav_bg`、`buffer_active_bg` 等模块背景保留。只改 `StatusLine` 高亮不充分，因为 Heirline 会使用自己的配色表和生成高亮。

Snacks 已配置 `backdrop = false`，没有额外全屏压暗层。浮窗细节需要在真实打开搜索、预览、输入和补全后检查；仅启动 Neovim 时，部分懒加载插件高亮尚不存在，空高亮表不能当作完整视觉验证。

## tmux 如何接入

已有 `@catppuccin_status_background 'none'` 和主题加载后的 `status-style bg=default`，正文的两个 window style 也已为默认，无需安装透明插件。

若要让配置重载主动清除旧的正文底色，可以在本地 `30-theme.conf` 的 vendor 加载后显式设置：

```tmux
set -g window-style 'default'
set -g window-active-style 'default'
set -g status-style 'bg=default'
```

对日常 server 单独给某个 window 设置过的局部样式，这些全局设置不会自动清除，需要有针对性地检查。当前检查是独立 server 的配置结果。

popup 底色目前由 vendor 最后设置。若以后要覆盖 popup，应在 vendor 加载后调整本地配置；无需修改 vendor 文件。透明效果本身不依赖 tmux `allow-passthrough`。继续使用 `tmux-256color`；RGB 支持负责颜色准确，默认背景负责背景继承，是两件事。

## 验证结果与实施验收

已完成：

1. 核对配置软链接、三个程序实际版本和主题来源。
2. 用实际 WezTerm 加载当前配置，并临时覆盖透明度、文字背景透明度与模糊参数；`show-keys --lua` 成功。
3. 用独立临时 socket 加载 tmux，读取正文、状态栏、分隔线和 popup 的最终样式；只清理测试 server。
4. 启动实际 Neovim 配置，查询当前高亮；在内存里清除结构背景，调整 Heirline 配色，并连续两次重载 Catppuccin。结构背景维持无底色，Heirline 的两项颜色为 `NONE`，浮窗仍为 `#181825`，补全选中项仍为 `#45475a`。

以上验证的是配置解析和高亮行为，未验证实际 GUI 合成画面，也未修改日常窗口外观。正式实施后应检查：普通 shell → tmux 双 pane → Neovim 双分屏与侧栏 → 搜索／预览／补全 → 专注模式来回切换；分别在浅色、深色桌面背景下检查文字、圆弧外侧和选中项。

如实施透明正文，现有 `tests/nvim.lua` 中要求 `Normal.bg == 0x1e1e2e` 的断言也必须更新，并验证主题重载后的透明背景与浮窗保留底色。

推荐顺序：先建立 tmux / Neovim 的统一背景继承，再接入壁纸模式与专注切换；桌面毛玻璃作为另一个可选模式。这样最接近参考仓库的效果，也能保持日常编辑的稳定观感。
