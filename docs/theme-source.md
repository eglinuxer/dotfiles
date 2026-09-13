# 主题与字体来源

## 当前视觉方案

三个工具统一使用 [Catppuccin Mocha 色板](https://catppuccin.com/palette/)。WezTerm 的静态 Lua 色板与 tmux 状态栏定制位于本仓库，不依赖 Neovim 插件目录。

Neovim 使用 0.12 自带的 `colors/catppuccin.vim`：深色背景为 Mocha，浅色为 Latte；本项目固定深色，并通过 AstroUI 适配浮窗和状态栏。上游源见 [Neovim runtime](https://github.com/neovim/neovim/blob/master/runtime/colors/catppuccin.vim)。

tmux 使用 [Catppuccin tmux v2.3.0](https://github.com/catppuccin/tmux/tree/v2.3.0) 的原版运行文件，存于 `tmux/vendor/catppuccin/`，保留 [MIT 许可证](../tmux/vendor/catppuccin/LICENSE)。在 `conf.d/30-theme.conf` 保留原有 basic 窗口与 application / session 圆弧状态模块，不改 vendor 文件。

上游版本和下载校验值记录于 `tmux/vendor/catppuccin/upstream.json`；运行 `python3 tmux/scripts/update-theme.py --check` 检查正式版更新，去掉 `--check` 执行下载和隔离加载验证。

## 字体

- [Comic Shanns](https://github.com/shannpersand/comic-shanns)：原始设计来源；本机使用 [Nerd Fonts ComicShannsMono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/ComicShannsMono) 的 Mono 变体。字体已经存在，本轮未覆盖。
- [小赖字体](https://github.com/lxgw/kose-font)：选择等宽版 `Xiaolai Mono`。本次安装 [v3.126 官方文件](https://github.com/lxgw/kose-font/releases/download/v3.126/XiaolaiMono-Regular.ttf)，由 [Homebrew cask](https://formulae.brew.sh/cask/font-xiaolai-mono) 管理。
- 安装文件 SHA-256：`802b658db492e02ae5b659f5b56d7d4ef8f77609515bdcc82f462ae912888c33`，与官方 cask 一致。

字体文件及其许可证随上游分发，不将字体二进制打包进本仓库。

## 历史来源

此前 WezTerm 使用 AstroNvim/astrotheme Astrodark 的 `extras/wezterm/astrodark.toml`，commit `744e520fcb300980a4e5ea32c508128c790ecc73`。当前已替换色板；保留历史来源和 [GNU GPL v3 副本](licenses/astrotheme-GPL-3.0.txt)。
