{pkgs, ...}: {
  home.file.".config/nvim/init.lua".text = builtins.readFile ./dotfiles/init.lua;

  programs.neovim = {
    enable = true;
    extraLuaPackages = ps: [ps.magick];
    extraPackages = with pkgs; [
      # Image support
      imagemagick

      # LSP servers (declarative via Nix)
      nixd          # Nix language server
      pyright       # Python language server
    ];
  };
}
