{ inputs, pkgs, config, ... }:
let
  colors = import ./colors.nix;
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "Cascadia Code 12";
    terminal = "${pkgs.kitty}/bin/kitty";

    extraConfig = {
      modi = "window,run,drun";
      show-icons = true;
      display-drun = "Applications:";
      display-window = "Windows:";
      drun-display-format = "{name}";
    };

    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        "*" = {
          bg = mkLiteral "#0f1c21";
          bg-alt = mkLiteral "#2E3440";
          bg-selected = mkLiteral "#88C0D0";
          fg = mkLiteral "#ECEFF4";
          fg-alt = mkLiteral "#8FBCBB";
          border = 1;
          margin = 0;
          padding = 0;
          spacing = 0;
        };

        "window" = {
          width = mkLiteral "40%";
          background-color = mkLiteral "@bg";
          border-color = mkLiteral "@fg-alt";
        };

        "element" = {
          padding = mkLiteral "8 12";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@fg-alt";
        };

        "element selected" = {
          text-color = mkLiteral "@bg";
          background-color = mkLiteral "@bg-selected";
        };

        "element-text" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
        };

        "element-icon" = {
          size = mkLiteral "14";
          padding = mkLiteral "0 10 0 0";
          background-color = mkLiteral "transparent";
        };

        "entry" = {
          padding = 12;
          background-color = mkLiteral "@bg-alt";
          text-color = mkLiteral "@fg";
        };

        "inputbar" = {
          children = map mkLiteral [
            "prompt"
            "entry"
          ];
          background-color = mkLiteral "@bg";
        };

        "prompt" = {
          enabled = true;
          padding = mkLiteral "12 0 0 12";
          background-color = mkLiteral "@bg-alt";
          text-color = mkLiteral "@fg";
        };

        "listview" = {
          background-color = mkLiteral "@bg";
          columns = 1;
          lines = 10;
        };

        "mainbox" = {
          children = map mkLiteral [
            "inputbar"
            "listview"
          ];
          background-color = mkLiteral "@bg";
        };
      };
  };
}
