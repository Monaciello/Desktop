# Homebrew casks for GUI apps that aren't well-supported in nixpkgs on macOS
{ ... }:
{
  nix-homebrew = {
    enable = true;
    user = "sasha";
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };

    casks = [
      "1password"
      "firefox"
      "discord"
      "obsidian"
      "vlc"
      "anki"
      "telegram"
      "cursor"
    ];
  };
}
