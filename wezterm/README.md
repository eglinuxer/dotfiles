# WezTerm 专业配置框架

一个模块化、跨平台的 WezTerm 配置框架，支持 macOS、Windows 和 Linux。

## 特性

- 🎨 **主题支持**: Tokyo Night 和 Nord 主题，支持快速切换
- ⌨️ **键位映射**: 与 tmux 和 AstroNvim 兼容的键位设计
- 🖼️ **背景图片**: 支持背景图片轮换
- 🔒 **SSH 管理**: 内置 SSH 连接管理
- 💾 **会话恢复**: 支持会话保存和恢复
- 🖥️ **跨平台**: 智能检测并适配不同操作系统
- 📦 **模块化**: 清晰的模块结构，易于维护和扩展

## 目录结构

```
~/.config/wezterm/
├── wezterm.lua          # 主入口文件
├── config/              # 配置模块
│   ├── appearance.lua   # 外观设置（主题、透明度、背景）
│   ├── fonts.lua        # 字体配置
│   ├── keybindings.lua  # 键位映射
│   ├── platform.lua     # 平台特定设置
│   ├── sessions.lua     # 会话管理
│   └── ssh.lua          # SSH 域配置
├── utils/               # 工具函数
│   └── platform.lua     # 平台检测工具
├── events/              # 事件处理
│   └── init.lua         # 事件监听器
├── backgrounds/         # 背景图片目录
└── README.md           # 本文档
```

## 快捷键

### Leader 键
- **Leader**: `Ctrl-e` (避免与 tmux 的 `Ctrl-b` 冲突)

### 面板管理（Pane）
- `Leader + |`: 垂直分屏
- `Leader + -`: 水平分屏
- `Leader + h/j/k/l`: 切换面板（vim 风格）
- `Leader + H/J/K/L`: 调整面板大小
- `Leader + z`: 面板缩放（全屏/恢复）
- `Leader + x`: 关闭当前面板

### 标签页管理（Tab）
- `Leader + c`: 新建标签页
- `Leader + 1-9`: 切换到指定标签页
- `Leader + n/p`: 下一个/上一个标签页
- `Leader + ,`: 重命名标签页

### 工作区管理（Workspace）
- `Leader + w`: 切换工作区
- `Leader + W`: 创建新工作区

### 其他功能
- `Leader + s`: SSH 连接管理
- `Leader + [`: 进入复制模式（vim 风格）
- `Leader + /`: 搜索
- `Leader + :`: 命令面板
- `Leader + t`: 切换主题
- `Leader + b`: 切换背景图片
- `Leader + r`: 重载配置
- `Leader + d`: 显示调试信息

### 快速操作
- `Cmd/Ctrl+Shift + +/-/0`: 调整字体大小
- `Alt + Enter`: 全屏切换
- `Cmd + k`: 清屏（macOS）

## 自定义配置

### 添加 SSH 连接

编辑 `config/ssh.lua`：

```lua
config.ssh_domains = {
    {
        name = "my-server",
        remote_address = "192.168.1.100",
        username = "user",
    },
}
```

### 添加背景图片

将图片文件放入 `backgrounds/` 目录，支持格式：jpg, jpeg, png, gif, bmp

### 修改主题

编辑 `config/appearance.lua` 中的 `M.current_theme`：

```lua
M.current_theme = "tokyo-night"  -- 或 "nord"
```

### 平台特定配置

各平台的特定配置位于 `config/platform.lua`，包括：
- macOS: 原生全屏、模糊效果、Option 键映射
- Windows: PowerShell 集成、Acrylic 效果
- Linux: Wayland 支持、IME 设置

## 依赖

- WezTerm（最新版本）
- 0xProto Nerd Font Mono（或其他 Nerd Font）
- zsh（macOS/Linux）或 PowerShell（Windows）

## 故障排除

1. **配置不生效**: 使用 `Leader + r` 重载配置
2. **快捷键冲突**: 检查是否与 tmux/neovim 键位冲突
3. **背景图片不显示**: 确保图片在 `backgrounds/` 目录
4. **字体问题**: 确保已安装 Nerd Font

## 更新日志

- 初始版本：完整的模块化配置框架
- 支持 Tokyo Night 和 Nord 主题
- tmux/AstroNvim 兼容键位
- 跨平台智能适配