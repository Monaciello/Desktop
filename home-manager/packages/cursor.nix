# Cursor AI IDE configuration
#
# Cursor is an AI-powered code editor built on VSCode
# - AI-native coding with GPT-4, Claude, and custom models
# - Composer: multi-file editing agent
# - Plan mode: design before coding
# - Cursor Blame: AI attribution tracking
#
# Current: Using nixpkgs version (2.2.44)
# Latest upstream: 2.4.37+
# See docs/cursor-packaging-guide.md for updating to latest version via overlay
#
# https://changelog.cursor.sh/

{
  config,
  pkgs,
  ...
}:

{
  # Install Cursor AI from nixpkgs (stable but slightly outdated)
  home.packages = [
    pkgs.code-cursor-fhs # FHS version for better compatibility

    # LSP servers and dev tools that Cursor can use
    pkgs.nixd
    pkgs.shellcheck
    pkgs.ruff
    pkgs.python313
    pkgs.black
  ];

  # Note: Cursor is installed as a standalone application
  # Configuration and extensions are managed through Cursor's UI
  # Settings are stored in ~/.config/Cursor/User/settings.json
  #
  # To access Cursor: Run `cursor` from terminal or app launcher
  #
  # To update to latest version:
  # See docs/cursor-packaging-guide.md for overlay implementation
}
