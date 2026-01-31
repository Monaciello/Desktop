# ZSA Keyboard Configuration
# Orchestrates keyboard layers for Ergodox EZ or similar ZSA devices
#
# Layer Design:
# - Layer 0: BASE - Standard QWERTY typing
# - Layer 1: NAVIGATION - Vim-style movement (Space-hold)
# - Layer 2: DEV/EDITOR - Nixvim + clipboard workflow (Enter-hold)
# - Layer 3: WINDOW MANAGER - i3 + tmux control (Hyper-hold)
# - Layer 4: APP LAUNCHER - App shortcuts + media (Meh-hold)
# - Layer 5: INTEGRATION - Context-aware automation (via kontroll)
#
# Keyboard layout files (.kbd) are created via keymapp GUI and stored in layouts/
# See docs/keyboard/layer-reference.md for detailed mappings

{ config, pkgs, ... }:
{
  # Optional: Symlink kbd layouts when they exist
  # home.file.".config/zsa".source = ./layouts;
}
