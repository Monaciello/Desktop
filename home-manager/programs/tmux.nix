# Tmux configuration
# Prefix: Space (C-Space)
# Mode: vi
# Pane nav: Space+h/j/k/l
# Pane resize: Ctrl+Alt+h/j/k/l (no prefix)
{ pkgs, lib, ... }:
let
  clipboardCmd = if pkgs.stdenv.hostPlatform.isDarwin then "pbcopy" else "wl-copy";
in
{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    shortcut = "Space";
    terminal = "screen-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      (pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "minimal-tmux-status";
        version = "unstable-2024-01-01";
        src = pkgs.fetchFromGitHub {
          owner = "niksingh710";
          repo = "minimal-tmux-status";
          rev = "67e2f5205de1b46f99af1d92013fb38fec5b05d9";
          sha256 = "sha256-T5eoG861JJdGj6swp4+icjzwtSB5TY4efy5FeYbgHeg=";
        };
        rtpFilePath = "minimal.tmux";
      })
    ];

    extraConfig = ''
      # Refresh binding
      unbind r
      bind r source-file ~/.tmux.conf

      # Navigation (vim-style)
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R
      bind-key -n C-M-h resize-pane -L 3
      bind-key -n C-M-j resize-pane -D 3
      bind-key -n C-M-k resize-pane -U 3
      bind-key -n C-M-l resize-pane -R 3

      # Keep current working directory across panes
      bind c new-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      # Options
      set -g mouse on
      setw -g mode-keys vi
      set-option -g status-position top
      set-option -g allow-passthrough on
      set -g pane-active-border-style fg=#FFFFFF

      # Copy mode (vim keybinds)
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${clipboardCmd}"
      bind P paste-buffer
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "${clipboardCmd}"

      # Minimal tmux status theme settings
      set -g @minimal-tmux-bg "#ccffff"
      set -g status-left-length 15
      set -g @minimal-tmux-indicator-str "$USER"
      set -g @minimal-tmux-status "bottom"
      set -g @minimal-tmux-justify "centre"
      bind-key b set-option status
    '';
  };
}
