# Kitty terminal configuration
{ ... }:
let
  colors = import ./colors.nix;
in
{
  programs.kitty = {
    enable = true;

    font = {
      name = "Cascadia Code";
      size = 12.0;
    };

    settings = {
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      disable_ligatures = "never";
      clipboard_control = "write-clipboard write-primary no-append";

      shell = "tmux";
      editor = "nvim";
      enable_audio_bell = false;
      allow_remote_control = true;

      foreground = colors.text;
      background = colors.crust;

      color0 = colors.surface1;
      color1 = colors.red;
      color2 = colors.green;
      color3 = colors.yellow;
      color4 = colors.blue;
      color5 = colors.pink;
      color6 = colors.teal;
      color7 = colors.subtext1;

      color8 = colors.surface2;
      color9 = colors.red;
      color10 = colors.green;
      color11 = colors.yellow;
      color12 = colors.blue;
      color13 = colors.pink;
      color14 = colors.teal;
      color15 = colors.subtext0;
    };

    keybindings = {
      "ctrl+shift+l" = "send_text all clear\\n";
    };
  };
}
