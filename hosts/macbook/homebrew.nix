# Homebrew casks for GUI apps that aren't well-supported in nixpkgs on macOS
{ ... }:
{
  nix-homebrew = {
    enable = true;
    user = "sasha";
  };

  homebrew = {
    enable = true;
    # Opinion: declarative flake rebuilds are the source of truth — avoid implicit brew updates.
    # Use `brew update && brew upgrade` when you want latest casks. Cleanup is non-zap to avoid wiping unmanaged taps.
    onActivation = {
      autoUpdate = false;
      cleanup = true;
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
