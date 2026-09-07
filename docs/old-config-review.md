# 旧配置分析与借鉴建议

分析日期：2026-09-07。

实际分析目录：`/home/eg/Downloads/dotfiles-main`。用户消息中的路径重复了一遍，重复后的路径不存在。

结论：旧配置的主要价值在 tmux 操作细节和 WezTerm 外观交互。应选择性提取，不能整体覆盖当前配置。Neovim 与当前模板几乎相同。

## 范围与验证边界

- 阅读 WezTerm 全部 Lua 配置、事件、辅助模块、README、开发工具配置及 LICENSE；清点 16 张背景图片（约 19 MB），未逐张进行视觉评价。
- 阅读完整 tmux.conf、README 和 .gitignore。
- 对新旧 Neovim 目录做递归差异比较：共同文件内容全部相同；旧版仅多 astrotheme.lua，当前版仅多 lazy-lock.json。当前共同文件已在此前调研逐项阅读。
- 静态检查键位、加载关系、平台分支、参数作用域与外部依赖。
- 在不加载个人配置的 Neovim 中实际复现 opts-validator 的两个问题：重复字段被接受；table 字段传入数字会抛异常。
- 未加载旧 tmux 配置、未安装旧插件、未连接远程主机、未进行 GUI/SSH/剪贴板端到端测试。本文的兼容性建议不等于实机验证通过。
- 本轮仅新增本文，没有修改三款软件的运行配置。

## 当前讨论已确定的边界

- 本地与远程分别使用所在机器的 tmux，默认直接 SSH 到远程 tmux，偶尔允许嵌套。
- WezTerm 本地入口先进入普通 shell。
- tmux 管会话和进程，不加入项目扫描、worktree 发现或目录收藏。
- 只要求断开后保持会话，不加入机器重启恢复。
- 前缀 Ctrl+a；前缀后 a 发送原始 Ctrl+a；前缀后 hjkl 切换 tmux pane。
- 不全局截获 Ctrl+hjkl 或 Ctrl+方向键；Neovim 普通模式保留内部导航，到边界停止。
- 新 pane 继承当前目录；新 window 使用 session 创建时的起始目录，不将它解释为自动识别的项目根目录。
- Neovim 内部寄存器与系统剪贴板分离；显式跨软件复制；tmux 复制同步本机剪贴板。
- tmux vi 复制模式，鼠标辅助。
- WezTerm 连接信息、tmux 会话/窗口信息、Neovim 编辑信息分层展示。

## 加载与依赖结构

### WezTerm

`wezterm.lua` 先扫描背景并随机选择，再注册五组事件，最后依次合并 appearance、bindings、domains、fonts、general、launch。

| 模块 | 作用 | 建议 |
| --- | --- | --- |
| config/init.lua | 自建 Config 对象，遇到重复配置保留先出现的值并警告 | 换为原生 config_builder 和明确的覆盖顺序 |
| config/appearance.lua | 渲染、背景、光标、标签栏、窗口布局 | 保留必要外观设置；硬件参数单独评估 |
| config/bindings.lua | GUI、分屏、滚动、背景、key table | 按新职责重新选键，不整体迁入 |
| config/domains.lua | Windows 的示例 SSH/WSL 域 | 删除个人示例；Linux/macOS 分支没有已配置远程主机 |
| config/fonts.lua | ComicShannsMono Nerd Font Medium、18pt | 作为用户偏好候选，另查实际字体和中文回退 |
| config/general.lua | 键盘协议、历史、链接、退出行为 | 保留意图，调整历史上限并验证键盘协商 |
| config/launch.lua | 按系统选择 shell 和启动菜单 | 普通 shell 启动符合当前决定；移除不存在的命令/路径 |
| events/gui-startup.lua | 在启动事件中创建窗口并最大化 | 生命周期位置合理；最大化是否默认仍待决定 |
| events/left-status.lua | 显示 WezTerm leader/key table | 可提取模式提示思想，精简显示 |
| events/right-status.lua | 时间、电池 | 不符合已选精简状态栏，暂不迁入 |
| events/new-tab-button.lua | 右键加号打开模糊启动菜单 | 可选；没有项目扫描，适合 shell/连接入口 |
| events/tab-title.lua | 进程、标题、锁定标题、未读输出、进度 | 提取手动标题、宽度处理；不整体迁入 615 行实现 |
| utils/backdrops.lua | 背景扫描、切换、选择、纯色模式 | 外观候选，需要修正状态与 overrides 处理 |
| utils/cells.lua | 可嵌套的格式片段抽象 | 当前精简 UI 无需这套 302 行框架 |
| utils/opts-validator.lua | 自建配置 schema 校验 | 不迁入，已有可复现缺陷 |
| utils/gpu-adapter.lua | 枚举显卡并按自定分数选 GPU | 不作为默认基础设施 |
| utils/platform.lua | Windows/Linux/macOS 检测 | 有跨平台需求时保留简版 |
| utils/math.lua、str.lua | 四个数学/字符串辅助函数 | 仅在迁入的功能实际需要时保留 |
| colors/custom.lua | 修改版 Mocha 外观与独立 ANSI 色表 | 不是完整统一主题，需要重新选择色板 |

### tmux

顺序为终端能力、核心选项、按键、sesh、复制模式、弹窗、嵌套模式、Catppuccin 配置、插件声明、TPM 自动安装与加载、最终透明覆盖。

外部依赖不止 tmux：git、TPM、sesh、zoxide、fzf/fzf-tmux、fd、lazygit；插件另有自己的依赖。README 安装命令未覆盖全部配置调用，例如 fd。

| 插件/工具 | 旧用途 | 当前建议 |
| --- | --- | --- |
| Catppuccin tmux v2.3.0 | 状态栏主题 | 颜色可借鉴；简单状态栏可原生实现 |
| extrakto | 模糊提取输出中的路径、URL、词 | 可选增强，先确认是否高频使用 |
| tmux-floax | 浮动终端 | 暂不默认加入，与编辑器终端/普通 pane 的职责待比较 |
| tmux-menus | 分级操作菜单 | 可选；基础功能先用 tmux 原生命令和帮助 |
| tmux-resurrect | 手动保存恢复 | 不迁入，用户当前明确不需要重启恢复 |
| sesh + zoxide + fzf | 混合会话、目录历史和项目选择 | 不迁入当前 tmux 基础配置 |
| lazygit popup | 当前目录打开 Git TUI | 可选；不要求 tmux 扫描或管理项目 |
| TPM | 自动克隆并安装插件 | 当前基础范围无需引入；以后安装动作与运行配置分开 |

### Neovim

旧版新增的 `nvim/lua/plugins/astrotheme.lua` 是唯一额外的用户功能配置：开启透明背景，设置 inactive/float/neotree 样式，并覆盖补全菜单和终端背景。

其他 astrocore、astrolsp、mason、treesitter、none-ls、astroui、user、community、polish 文件与当前完全相同，仍提前返回。示例中的语言服务器、debugpy、格式化器不是旧版已启用的个人工具链。

旧版没有 lazy-lock.json，无法仅根据该目录还原当时安装的精确插件组合。当前锁文件应保留，不能由旧目录替换删除。

## 最值得提取的交互

1. **连续缩放模式**（tmux.conf:89）：前缀 r 进入，hjkl 连续调整，q/Esc 退出。避免占用 shell Ctrl+方向键，最契合当前选择。新实现应显示 RESIZE 状态并验证其他键的退出/转发行为。
2. **鼠标复制后停留原位**（:161）：拖选后复制而不跳到底部，适合逐段查看日志。与键盘 y 复制退出可并存。
3. **历史增量搜索**（:165）：输入时即时匹配；前缀 / 可以直接向历史上方搜索。保留前缀 [ 作为常规复制入口。
4. **分屏继承目录**（:71）：直接使用 pane_current_path。仅新 pane 沿用；旧 new-window 同样继承当前目录的规则需要更改。
5. **显式重载与反馈**（:65）：前缀 R 重载并提示。应注意被删掉的旧绑定不会仅因 source-file 自动消失，迁移验证使用干净隔离 server。
6. **窗口从 1 编号**（:46）：数字快捷键顺手；自动重编号属于偏好，关闭窗口后号码会变化，需要单独确定。
7. **GUI 字体调整模式与手动标签名**：适合连接入口管理；无需同时保留 WezTerm 的另一套业务分屏导航。
8. **能力分层注释**（:18）：正确区分外层 TERM 与内层 tmux-256color。这个解释值得保留，能力声明需缩窄。

## 与新方案的直接冲突

| 旧行为 | 原位置 | 处理 |
| --- | --- | --- |
| 无前缀 Ctrl+hjkl 被 tmux 截获 | tmux.conf:102 | 删除，保留各应用原行为 |
| 前缀 a 切最近 window；前缀 Ctrl+a 才转发 | :63、:87 | 使用已讨论的前缀 a 转发；最近窗口另选键 |
| 前缀 [ / ] 切 window | :125 | 恢复复制/粘贴入口或另行明确，不直接覆盖已选前缀 [ |
| 前缀 w/W 直接杀 pane/window | :77 | 不迁入无确认关闭 |
| 新 window 继承当前 pane 路径 | :123 | 改为 session 起始目录 |
| 项目/目录发现集成在 sesh popup | :137 | 移出基础配置 |
| F6 全局切换本地捕获 | :183 | 偶尔嵌套优先发送前缀，避免再占一个应用功能键 |
| 重启恢复及 pane 内容存档 | :215、:223 | 不迁入 |
| WezTerm 原生分屏及 workspace 入口 | bindings.lua:175、:25 | 不作为日常业务层入口 |
| 时间、电池、进程与会话重复展示 | right-status.lua、tab-title.lua、tmux.conf:203 | 根据已定信息分工精简 |

## 技术问题与迁移时应修正的假设

### 1. Linux 下“GUI 按键零冲突”不成立

bindings.lua:12 将 SUPER 定义为 ALT，故 Alt+f、Alt+b、Alt+d、Alt+t 等先被 WezTerm 消费。它们与常见 shell 的单词移动/删除等操作重叠。Ctrl+Shift+n/s 还被转换成特殊字符；F1–F5/F11/F12 也被截获。不能因为 macOS 用 Cmd，就把整套修饰键映射当作跨平台等价。

### 2. 关闭 GUI 不总是安全 detach

appearance.lua:53 的 NeverPrompt，以及 bindings.lua:68、:190 的 confirm=false，会绕过确认。tmux 内进程可以在 client 断开后继续，但普通 shell 中的任务不具有同样保证。现在明确先开普通 shell，更不能将关闭窗口一概解释为 detach。

### 3. 两层近十亿行历史不合适

general.lua:15 和 tmux.conf:42 都设为 999999999。它是容量上限，不是立即预分配同等内存，但持续日志会累积显著内存。两层无需保持相同数值；tmux 按 pane 保存历史，WezTerm 保存自身终端内容，不能把 GUI 滚动视作每个 tmux pane 的完整历史。

建议后续分别选择有限上限；长期日志另存文件。数值属于尚未决定的参数。

### 4. 能力声明过宽，键盘协议不能靠注释保证

tmux.conf:21 给所有 xterm-256color 声明 RGB、下划线、剪贴板、扩展键、链接等能力，:26–27 更对所有 TERM 声明下划线转义支持。换终端登录远程同一 server 时，这些假设未必成立。

保留 tmux-256color 的方向，但在远程确认 terminfo 已安装。优先实际能力检测，补丁按已确认终端和版本添加。extended-keys always 会向未请求的应用也发送扩展序列，不能作为通用无代价开关。先采用协商方式，确有具体应用需求再测试 always。参见 [tmux 手册](https://man.openbsd.org/tmux.1) 与 [WezTerm kitty keyboard](https://wezterm.org/config/lua/config/enable_kitty_keyboard.html)。

### 5. 剪贴板与鼠标文档有误导

“远端只能靠 tmux buffer 粘贴”不正确：本地 WezTerm 可把本机剪贴板内容通过 SSH 输入流发送到远端。tmux buffer 是另一条有用路径，但不是唯一途径。OSC 52 复制与读取剪贴板也要分别验证。

旧代码 Ctrl+点击打开链接；应用开启鼠标上报后，默认需要 Shift 绕过。若使用这条 Ctrl 绑定，应考虑 Ctrl+Shift+点击，不能只用一句“Shift 点击”概括所有绑定路径。可显式配置鼠标上报场景并测试。参见 [WezTerm 鼠标绕过规则](https://wezterm.org/config/lua/config/bypass_mouse_reporting_modifiers.html)。

### 6. 动态外观覆盖丢弃其他 overrides

backdrops.lua:122 和 tab-title.lua:597 每次传入只有背景、标签栏字段的新覆盖表。以后加入的字体、颜色等窗口覆盖可能被清除。应先 get_config_overrides，再只更新自己的字段。[官方推荐用法](https://wezterm.org/config/lua/window/set_config_overrides.html)。

背景开关 no_img 与图片切换操作也没有保持状态一致；入口每次求值都重新随机选图，容易造成重载前后状态不稳定。set_img 的判断允许索引 0；空图片目录亦缺乏明确的选择/切换保护。纯色回退应成为正常路径。

### 7. 标签栏有可见边界缺陷

- tab-title.lua:77 把 circle 写成 cirlce；选择 circle 模式时取不到图标。当前入口使用 numbered_box，因此该问题不是当前默认路径。
- :192 使用 floor(pct*8/100)，0–12% 返回索引 0，而帧表从 1 开始，进度图标缺失。
- :378 用 count > limit 而不是限制到 10；达到 11 个未读 pane 时查找不存在的编号图标。
- 进度循环同样用 > limit，允许超出设定数量一个。
- 进度状态以可变化的 tab_index/pane_index 标识，而非稳定 ID；调整顺序时可能把陈旧状态关联到别的 pane。
- 30 秒进度值不变就隐藏，并不等同于任务结束。
- WezTerm 看到的是自己的 pane；该图标统计不能直接解释为内部 tmux pane 的任务/未读统计。

### 8. 自建工具增加维护成本

opts-validator 的 schema 验证初始化 field_names 却未加入字段名，重复校验失效；字段类型错误后仍调用 ipairs(value)，会抛异常而不是返回默认值。以上两项已实际复现。

cells.lua 的 fg 校验误检查 bg，格式序列遍历多用 pairs，不宜依赖其顺序。GPU 选择仅根据类型/后端打分，并非性能测试；未知枚举值缺乏保护。原生 config_builder 和简单 wezterm.format 足以满足当前范围。

### 9. 嵌套模式影响范围比提示更广

tmux.conf:183 修改 prefix/key-table 时未使用 client 专属状态，它改变 session 选项；同 session 的其他客户端可能一起受影响。对当前“默认不嵌套”的需求没有必要引入这套模式。

### 10. 可复现性与仓库清洁

TPM 只固定了主题标签，其他插件未锁定；启动配置会联网安装；目录存在但安装不完整时没有完整修复路径。按需引入插件后应显式安装、记录版本，不把首次启动作为安装脚本。

旧 wezterm README 仍有上游内容，字体名称、滚动键和部分顺序与实际代码不一致；其中图片引用的 .github 目录不在提供的目录内。nvim.log 是运行日志，不是配置。背景资源按需保留；复用上游实质代码时保留已有 MIT 版权声明。

WezTerm .luarc.json / StyLua 指向 Lua 5.4，而 .luacheckrc 的 std = luajit 既未写成字符串，又与使用的 Lua 5.4 位运算语法不一致。开发工具声明应各自匹配 WezTerm Lua 5.4 与 Neovim LuaJIT，不能机械统一运行时。

## 候选迁入顺序（未视为用户已同意新增功能）

1. 连续缩放、历史增量搜索、鼠标复制后保持位置。
2. 基础能力：真彩色、焦点事件、剪贴板、有限历史与扩展键验证。
3. 外观选择：字体、色板、背景或纯色、启动最大化；与功能层分开决定。
4. 只有明确高频需求后再考虑 lazygit popup、文本提取、浮动终端等增强。

实施验证应覆盖普通 shell、tmux shell、Neovim 普通/插入/终端输入模式、本地与 SSH；重点检查 Ctrl/Alt/F 键传递、中文宽度、复制粘贴、鼠标与断开重连。先使用隔离配置或独立 tmux socket，再应用到日常会话。
