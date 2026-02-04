# lf file manager with preview and dragon-drop
{ pkgs, ... }:
{
  programs.lf = {
    enable = true;

    settings = {
      preview = true;
      hidden = true;
      drawbox = true;
      icons = true;
    };

    keybindings = {
      # Unmap defaults
      "\"" = "";
      o = "";
      c = "";

      # Core
      "." = "set hidden!";
      "<enter>" = "open";
      ee = "$$EDITOR \"\$f\"";
      dd = "cut";
      y = "copy";
      p = "paste";
      D = "delete";
      a = "rename";

      # Dragon
      do = "dragon-out";

      # Nav
      gh = "cd";
      gc = "cd ~/.config";
    };

    commands = {
      open = ''
        case $(${pkgs.file}/bin/file --mime-type "$f" -bL) in
          text/*) $EDITOR "$f" ;;
          image/*) sxiv "$f" ;;
          video/*) mpv "$f" ;;
          application/pdf) zathura "$f" ;;
          *) xdg-open "$f" ;;
        esac
      '';

      dragon-out = "%${pkgs.dragon-drop}/bin/dragon-drop -a -x \"\$fx\"";
    };

    extraConfig =
      let
        previewer = pkgs.writeShellScriptBin "lf-preview" ''
          #!/bin/sh
          case "''${1##*.}" in
            pdf) ${pkgs."poppler-utils"}/bin/pdftotext "$1" - | head -20 ;;
            md) ${pkgs.glow}/bin/glow -s dark "$1" ;;
            json) ${pkgs.jq}/bin/jq . "$1" ;;
            *) ${pkgs.bat}/bin/bat --color=always "$1" 2>/dev/null || cat "$1" ;;
          esac
        '';

        cleaner = pkgs.writeShellScriptBin "lf-cleaner" ''
          #!/bin/sh
          :
        '';
      in
      ''
        set previewer ${previewer}/bin/lf-preview
        set cleaner ${cleaner}/bin/lf-cleaner
      '';
  };

  home.packages = with pkgs; [
    dragon-drop
    bat
    glow
    jq
  ];
}
