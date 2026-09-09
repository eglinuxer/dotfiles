# 主题来源

静态色板来自 AstroNvim/astrotheme 的 Astrodark：commit `744e520fcb300980a4e5ea32c508128c790ecc73`，对应现有 `nvim/lazy-lock.json`。

来源文件为 `extras/wezterm/astrodark.toml`，上游作者标识为 AstroNvim。WezTerm 色板转为 Lua 并调整标签对比度。运行时不依赖 Neovim 的插件目录。

上游许可证副本：[GNU GPL v3](licenses/astrotheme-GPL-3.0.txt)。颜色适配保留该来源和许可证信息。

## tmux

tmux 使用 [Catppuccin tmux v2.3.0](https://github.com/catppuccin/tmux/tree/v2.3.0) 原版主题配置，选项与 Downloads/dotfiles-main 中的参考配置一致：Mocha、basic 窗口、终端背景及 application/session 状态模块。上游文件存于 `tmux/vendor/catppuccin/`，保留 [MIT 许可证](../tmux/vendor/catppuccin/LICENSE)；启动时通过 source-file 同步加载，无需 TPM。

上游版本和下载校验值记录于 `tmux/vendor/catppuccin/upstream.json`；运行 `python3 tmux/scripts/update-theme.py --check` 检查正式版更新，去掉 `--check` 执行下载和隔离加载验证。
