{pkgs, inputs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Core plugins - declaratively managed
    plugins = with pkgs.vimPlugins; [
      # UI enhancements
      vim-airline
      vim-airline-themes
      alpha-nvim
      nvim-web-devicons

      # Treesitter for syntax
      nvim-treesitter
      nvim-treesitter-refactor

      # Fuzzy finder
      telescope-nvim
      telescope-fzf-native-nvim

      # LSP
      nvim-lspconfig
      lsp-zero-nvim
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      nvim-cmp
      luasnip
      cmp_luasnip

      # Git integration
      vim-fugitive
      gitsigns-nvim

      # File management
      mini-nvim
      oil-nvim

      # Markdown
      bullets-vim
      vim-table-mode

      # Theming
      nord-nvim

      # Notifications
      nvim-notify

      # Notes
      obsidian-nvim
      plenary-nvim

      # Image preview
      image-nvim

      # Vim improvements
      vim-tmux-navigator
      vim-surround
      vim-commentary
    ];

    # LSP servers (declaratively provided)
    extraPackages = with pkgs; [
      nixd              # Nix language server
      pyright           # Python language server
      imagemagick       # For image.nvim
    ];

    extraLuaPackages = ps: [ps.magick];

    # Keybindings and settings
    extraConfig = ''
      ${builtins.readFile ./dotfiles/init.lua}
    '';
  };
}
