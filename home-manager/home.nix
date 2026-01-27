# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # Desktop environment modules (i3, kitty, rofi, etc.)
    ./modules/all.nix
  ];

  # nixpkgs.config is inherited from NixOS via home-manager.useGlobalPkgs
  # allowUnfree is set in hosts/alice/default.nix

  home = {
    username = "sasha";
    homeDirectory = "/home/sasha";

    # User packages managed by home-manager
    packages = with pkgs; [
      # File manager
      lf

      # Secrets management
      sops
      age
      ssh-to-age

      # Development tools
      python3
      shellcheck
      bats

      nixfmt
      statix
      jq
      yq
      tree

      # Terminal & Shell
      kitty

      tmux

      # Modern CLI replacements
      eza # ls replacement
      bat # cat replacement
      fzf # fuzzy finder
      ripgrep # grep replacement
      zoxide # cd replacement
      btop # htop replacement
      fastfetch # system info

      # Browsers
      tor-browser

      # Media
      vlc
      obs-studio

      # Office
      libreoffice-qt6-fresh
      obsidian
      zathura
      xournalpp
      anki

      # Communication
      discord

      # Development
      vscodium-fhs

      # Neovim dependencies
      imagemagick
    ];
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    signing = {
      key = "/home/sasha/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      user.name = "monaciello";
      user.email = "tahgijones@gmail.com";
      gpg.format = "ssh";
    };
  };

  # Starship removed - using xonsh prompt instead
  # programs.starship = {
  #   enable = true;
  #   enableBashIntegration = true;
  # };

  # Tmux configuration - enhanced with vim keybinds
  # Tmux - fully declarative, no manual TPM required
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    shortcut = "Space";
    terminal = "screen-256color";

    # Declarative plugins (replaces manual TPM)
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      # Custom plugin not in nixpkgs - declared from GitHub
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
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip"
      bind P paste-buffer
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip"

      # Minimal tmux status theme settings
      set -g @minimal-tmux-bg "#ccffff"
      set -g status-left-length 15
      set -g @minimal-tmux-indicator-str "$USER"
      set -g @minimal-tmux-status "bottom"
      set -g @minimal-tmux-justify "centre"
      bind-key b set-option status
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  # Must match home-manager release version
  home.stateVersion = "24.11";
}
