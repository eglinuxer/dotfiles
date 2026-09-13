# 背景图片

将自己的 PNG、JPG、JPEG、GIF 或 BMP 图片放在本目录（也可软链接）。图片默认不提交到 Git；不递归扫描子目录。

在 WezTerm 按 `Ctrl+Shift+p`，搜索 `Background`，选择 `Select wallpaper / 选择壁纸`。每次打开选择器都会重新扫描，无需重启。也可以在 `../background.lua` 的 `settings.wallpaper` 填写本机图片的绝对路径。

macOS 快捷键：`Cmd+,` 上一张、`Cmd+.` 下一张、`Cmd+/` 随机、`Cmd+Ctrl+/` 搜索选图、`Cmd+b` 切换专注／恢复。Linux / Windows 用 `Ctrl+Shift` 代替 Cmd，搜索选图为 `Ctrl+Shift+Alt+/`。

默认使用壁纸背景（按文件名排序的第一张）。壁纸模式没有可读取图片时回退到纯色；选图时按 Esc 不改变当前背景。支持格式不代表损坏的图片能解码，请使用有效图片。

模式作用于当前 WezTerm 窗口及其所有标签，关闭该窗口后不保存；新窗口使用 `settings.default_mode`。运行中已选的模式通过窗口覆盖保留，修改强度参数并重载后重新选一次模式即可应用新参数。

本机已按用户要求下载 [KevinSilvester/wezterm-config 的 16 张壁纸](https://github.com/KevinSilvester/wezterm-config/tree/master/backdrops)，保留原文件名；来源、Git blob 哈希和 SHA-256 见 `sources.json`。图片文件是本机资源，不随配置 Git 提交；新机器需自行下载或放入自己的图片。
