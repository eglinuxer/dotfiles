# tmux 配置

入口为 `tmux.conf`，按顺序加载 `conf.d/`，所有路径相对配置文件解析：

- `00-options.conf`：终端能力、历史、会话默认值。
- `10-keys.conf`：前缀、窗口、分屏、缩放和工具快捷键。
- `20-copy-mode.conf`：选择、复制、粘贴和搜索。
- `30-theme.conf`：主题选项、状态栏布局和原版主题加载。
- `vendor/catppuccin/`：Catppuccin tmux v2.3.0 原版配置及 MIT 许可证。

外观移植自 `/home/eg/Downloads/dotfiles-main/tmux/tmux.conf`：Mocha 色板、底部状态栏、左侧 basic 窗口标签、右侧应用 `` 和会话 `` 模块、圆弧分隔符、跟随终端的状态栏背景。参考文件明确使用 basic 窗口样式，圆弧来自右侧状态模块。弹窗使用圆角边框，最终颜色由原版主题决定。

外观由原版主题渲染，快捷键和会话行为沿用本项目。前缀状态通过会话模块变红显示；右侧不再添加此前自定义的 COPY / RESIZE / ZOOM 文案或主机名。背景图仍由终端配置决定。

主题已随项目保存，启动无需下载或安装插件。WezTerm 内置图标字体可显示所需符号。修改外观请编辑 `conf.d/30-theme.conf`，保留 `vendor/` 上游文件原样。

重载：按 `Ctrl+a` 再按 `Shift+r`，或执行：

```sh
tmux source-file ~/.config/tmux/tmux.conf
```

## 跟踪上游更新

截至 2026-09-09，上游最新正式版为 **v2.3.0**（2026-04-08 发布）。本项目跟踪正式 release，不跟随 main 的未发布变更。

在仓库根目录执行：

```sh
# 查询最新正式版，与本地记录比较；不修改配置
python3 tmux/scripts/update-theme.py --check

# 下载最新正式版，验证后替换 vendor/catppuccin
python3 tmux/scripts/update-theme.py

# 必要时回退到指定版本
python3 tmux/scripts/update-theme.py --version v2.3.0
```

更新器通过 GitHub 官方 release API 查询版本，从官方源下载，仅保存主题运行文件与许可证。`vendor/catppuccin/upstream.json` 记录版本、下载地址和归档 SHA-256。更新前在独立临时 tmux 服务中验证本项目的主题配置和应用／会话模块；失败则保留当前版本。更新后审阅差异，运行 `python3 tests/tmux.py`，再按前缀 `R` 重载。

更新为显式操作，不在启动时联网，也没有后台定时更新。需要 Python 3、tmux、网络连接，以及创建临时 Unix socket 的权限。
