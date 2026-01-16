## NixOS Configuration Decisions

### Desktop Environment
1. **Fallback DE**: what can we put in place of a cinnamon DE?

### Xonsh & xontrib-uvox Configuration

#### Global Behavior
2. **Tracebacks**: `$XONSH_SHOW_TRACEBACK = True` — Keep for debugging? keep
3. **Wallpaper dir**: `~/Pictures/wallpapers` exists? yes it exists 

#### Prompt
4. **Show nix shell name**: `{nix_shell_name}` — Keep? YES 
5. **Show venv name**: `{env_name_cust}` — Keep? we haven't used uv to create venv yes
6. **Prompt colors**: BLACK/CYAN/WHITE/#CCFFFF — Adjust? this works

#### Desktop Functions
7. **set_wallpaper**: Assumes i3 — Correct WM? correct
8. **set_display**: Uses autorandr — Installed? check and verify
9. **Multiple displays**: Need autorandr profiles? check and verify

#### Git Workflow
10. **gup (git_sync)**: Dangerous (git add ., auto-push) — Keep/Remove/Replace? is this a safe git workflow ?
11. **Add safe git aliases**: gst, gco, gd, gc? gst (git status) , gco (git commit), gd, gc?

#### PATH
12. **~/.local/bin in PATH**: Keep? how does this affect home.nix?

#### xontrib-uvox
13. **Virtualenv location**: Default `~/.virtualenvs`? home or hosts level? 
14. **mkvenv behavior**: `uvox new venv` in project dir? mkvenv uvox venv is default I believe what are other options?

#### Aliases Audit
15. **code → codium**: Correct? codium is equal to code with code being the default for our vscodium ide()
16. **neo → fastfetch**: Keep? keep
17. **webup**: HTTP server on 8080 — Keep? what is being served at 8080?
18. **tkill**: Kills ALL tmux sessions — Keep? tkill
19. **untar**: Only .tar.xz, make generic? that works

#### Zoxide
20. **cd replacement**: Comfortable with zoxide as cd? yes so we can cd to any relative path

#### Dependencies Check
21. **Installed**: eza, bat, zoxide, fastfetch, xclip, autorandr? this works

#### Home Manager
22. **xonshrc via home.file**: Keep this approach? this interfaces well with xonshrc
23. **Auto-create dirs**: ~/Pictures/wallpapers, ~/.local/bin? that works

#### Dead Code
24. **command_output()**: Unused function — Remove? what would go here regarding command_output().

### Neovim Questions
25. **LSP languages**: Add/remove from Mason? we would love nixd and a modern python lsp. and not mason
26. **Obsidian vault**: Path ~/obsidian correct? obsidian no DOCUMENTS/obsidian
27. **Image.nvim**: Using Kitty terminal? solarized girl.jpg
28. **Keymaps**: Modify any shortcuts? yes we have to modify to make our own
