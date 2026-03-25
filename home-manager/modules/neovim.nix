{ pkgs, ... }:
{
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
      (nvim-treesitter.withPlugins (p: [
        p.nix
        p.python
        p.markdown
        p.bash
        p.json
        p.toml
        p.yaml
      ]))

      # Fuzzy finder
      telescope-nvim
      telescope-fzf-native-nvim

      # LSP
      nvim-lspconfig
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

    # LSP servers + runtime dependencies
    extraPackages = with pkgs; [
      nixd
      pyright
      imagemagick
    ];

    extraLuaPackages = ps: [ ps.magick ];

    # Wire nvim-lspconfig to nixd + pyright (extraPackages above)
    initLua = ''
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          local lspconfig = require("lspconfig")
          local caps = require("cmp_nvim_lsp").default_capabilities()
          lspconfig.nixd.setup({ capabilities = caps })
          lspconfig.pyright.setup({ capabilities = caps })
        end,
      })
    '';
  };
}
