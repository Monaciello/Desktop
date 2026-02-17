# 1Password configuration
#
# Provides: GUI app, CLI tool, browser integration, system authentication,
#           SSH/Git agent integration, and SOPS compatibility via age-plugin-1p
#
# References:
# - https://wiki.nixos.org/wiki/1Password
# - https://mynixos.com/nixpkgs/options/programs._1password-gui
# - https://github.com/natrontech/sops-age-op (SOPS integration)

{
  pkgs,
  config,
  lib,
  ...
}:
{
  # Allow unfree packages (1Password is proprietary)
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password-gui"
      "1password-cli"
    ];

  # Enable 1Password GUI with system integration
  programs._1password-gui = {
    enable = true;

    # Package selection (stable vs beta)
    # package = pkgs._1password-gui;      # Stable: 8.11.18
    # package = pkgs._1password-gui-beta; # Beta: 8.11.18-34.BETA

    # Users who can integrate 1Password with polkit authentication
    # Required for: fingerprint unlock, system auth, CLI integration
    polkitPolicyOwners = [ "sasha" ];
  };

  # 1Password CLI (renamed from _1password to _1password-cli)
  # Installed automatically via GUI module, but can be added explicitly
  environment.systemPackages = with pkgs; [
    _1password-cli # op command (v2.32.0)

    # age-plugin-1p: Use 1Password-stored keys with age/SOPS
    # Allows encrypting secrets with age keys stored in 1Password
    # Usage: age -r "age1password://<vault>/<item>" -e secret.txt
    age-plugin-1p
  ];

  # Browser integration (automatic for Firefox, Chrome, Brave)
  # For other Chromium browsers (Vivaldi, etc.), add custom allowed browsers:
  # environment.etc."1password/custom_allowed_browsers" = {
  #   text = ''
  #     vivaldi-bin
  #   '';
  #   mode = "0755";
  # };

  # SSH/Git Integration
  # After enabling "SSH Agent" in 1Password settings, configure in home-manager:
  #
  # programs.ssh.extraConfig = ''
  #   Host *
  #     IdentityAgent ~/.1password/agent.sock
  # '';
  #
  # programs.git.extraConfig = {
  #   gpg.format = "ssh";
  #   gpg."ssh".program = "${pkgs._1password-gui}/bin/op-ssh-sign";
  # };

  # Note: For fingerprint unlock, ensure polkit agent is running
  # i3 users: start polkit agent in i3 config or via systemd user service
  # systemd.user.services.polkit-gnome = {
  #   description = "PolicyKit Authentication Agent";
  #   wantedBy = [ "graphical-session.target" ];
  #   wants = [ "graphical-session.target" ];
  #   after = [ "graphical-session.target" ];
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  #     Restart = "on-failure";
  #     RestartSec = 1;
  #     TimeoutStopSec = 10;
  #   };
  # };
}
