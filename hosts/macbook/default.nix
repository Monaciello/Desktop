# nix-darwin configuration for macbook
#
# Bootstrap:
#   nix run nix-darwin -- switch --flake ~/Projects/Desktop#macbook
#
# Rebuild:
#   darwin-rebuild switch --flake ~/Projects/Desktop#macbook
{ pkgs, ... }:
{
  imports = [
    ../common
    ./homebrew.nix
  ];

  networking.hostName = "macbook";

  system.primaryUser = "sasha";

  users.users.sasha = {
    home = "/Users/sasha";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
        minimize-to-application = true;
        show-recents = false;
        tilesize = 48;
      };

      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        FXEnableExtensionChangeWarning = false;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleInterfaceStyle = "Dark";
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    stateVersion = 6;
  };

  nix.gc.interval = {
    Weekday = 0;
    Hour = 2;
  };
}
