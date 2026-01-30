# Kitty terminal configuration
{ ... }:
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

      foreground = "#CDD6F4";
      background = "#0f1c21";

      color0 = "#2E3440";
      color1 = "#BF616A";
      color2 = "#94E2D5";
      color3 = "#EBCB8B";
      color4 = "#81A1C1";
      color5 = "#B48EAD";
      color6 = "#88C0D0";
      color7 = "#E5E9F0";

      color8 = "#4C566A";
      color9 = "#BF616A";
      color10 = "#94E2D5";
      color11 = "#EBCB8B";
      color12 = "#81A1C1";
      color13 = "#B48EAD";
      color14 = "#8FBCBB";
      color15 = "#ECEFF4";
    };

    keybindings = {
      "ctrl+shift+l" = "send_text all clear\\n";
    };
  };
}
