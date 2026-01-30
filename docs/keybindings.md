# Keybindings Reference

Programs with configurable keybindings in this config.

## Config Locations

| Program | Config File | Manages |
|---------|-------------|---------|
| i3 | `home-manager/modules/i3.nix` | Window management |
| kitty | `home-manager/modules/kitty.nix` | Terminal |
| tmux | `home-manager/programs/tmux.nix` | Multiplexer |
| neovim | `home-manager/modules/dotfiles/init.lua` | Editor |
| rofi | `home-manager/modules/rofi.nix` | Launcher |

## i3 Window Manager

**Mod key:** `Alt`

| Binding | Action |
|---------|--------|
| `Mod+Return` | Terminal (kitty) |
| `Mod+s` | Launcher (rofi) |
| `Mod+h/j/k/l` | Focus left/down/up/right |
| `Mod+Shift+h/j/k/l` | Move window |
| `Mod+Shift+q` | Kill window |
| `Mod+1-0` | Switch workspace |
| `Mod+Shift+1-0` | Move to workspace |
| `Mod+f` | Fullscreen |
| `Mod+v` | Split vertical |
| `Mod+b` | Split horizontal |
| `Mod+r` | Resize mode |
| `Mod+Shift+r` | Restart i3 |
| `Mod+Shift+e` | Exit i3 |

**Super key shortcuts:**

| Binding | Action |
|---------|--------|
| `Super+v` | Firefox |
| `Super+o` | Obsidian |
| `Super+l` | lf (file manager) |

## tmux

**Prefix:** `Ctrl+Space`

| Binding | Action |
|---------|--------|
| `prefix+c` | New window |
| `prefix+%` | Split horizontal |
| `prefix+"` | Split vertical |
| `prefix+h/j/k/l` | Navigate panes |
| `prefix+H/J/K/L` | Resize panes |
| `prefix+n/p` | Next/previous window |
| `prefix+[` | Copy mode |
| `prefix+]` | Paste |
| `prefix+d` | Detach |
| `prefix+z` | Zoom pane |
| `prefix+x` | Kill pane |
| `prefix+&` | Kill window |

## Neovim

**Leader:** `Space`

| Binding | Action |
|---------|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>e` | File explorer |
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover docs |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename |
| `[d` / `]d` | Prev/next diagnostic |
| `<C-h/j/k/l>` | Navigate splits |

## Kitty

| Binding | Action |
|---------|--------|
| `Ctrl+Shift+c` | Copy |
| `Ctrl+Shift+v` | Paste |
| `Ctrl+Shift+t` | New tab |
| `Ctrl+Shift+q` | Close tab |
| `Ctrl+Shift+Right/Left` | Next/prev tab |
| `Ctrl+Shift+Enter` | New window |
| `Ctrl+Shift+]` / `[` | Next/prev window |
| `Ctrl+Shift+f` | Move window forward |
| `Ctrl+Shift+b` | Move window backward |
| `Ctrl+Shift+Equal` | Increase font |
| `Ctrl+Shift+Minus` | Decrease font |

## Rofi

| Binding | Action |
|---------|--------|
| `Tab` | Next entry |
| `Shift+Tab` | Previous entry |
| `Enter` | Accept |
| `Escape` | Cancel |
| `Ctrl+v` | Paste |
