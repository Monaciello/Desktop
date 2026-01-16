# Plan to Address GEMINI.md

This plan outlines the steps to address the questions and action items in `GEMINI.md`.

## NixOS Configuration

1.  **Fallback DE**:
    *   **Task**: Add a lightweight Desktop Environment as a fallback.
    *   **Action**: Propose adding `pkgs.xfce4` to `environment.systemPackages` in `hosts/alice/default.nix`.

2.  **autorandr**:
    *   **Task**: Verify if `autorandr` is installed.
    *   **Action**: Search for `autorandr` in the NixOS configuration. If it is not installed, add `pkgs.autorandr` to `environment.systemPackages` in `hosts/alice/default.nix`.

## Xonsh Configuration

3.  **uv venv**:
    *   **Task**: Test `uv` virtual environment creation and prompt integration.
    *   **Action**: Create a test virtual environment using `uvox` and verify that the prompt displays the venv name.

4.  **Git aliases**:
    *   **Task**: Explain the risks of the `gup` alias and propose safer alternatives.
    *   **Action**: Add a section to `GEMINI.md` explaining the `gup` alias and proposing a set of standard, safe git aliases (`gst` for status, `gco` for checkout, `gcm` for commit, `gd` for diff).

5.  **webup alias**:
    *   **Task**: Explain the `webup` alias functionality.
    *   **Action**: Examine the `xonshrc` file to find the `webup` alias definition and explain what it does.

6.  **command_output() function**:
    *   **Task**: Investigate the `command_output()` function in `xonshrc`.
    *   **Action**: Examine the `xonshrc` file for the `command_output()` function, determine its purpose, and if it's unused, recommend its removal.

## Neovim Configuration

7.  **LSP**:
    *   **Task**: Add `nixd` and a Python LSP to the Neovim configuration.
    *   **Action**: Modify `home-manager/modules/neovim.nix` to add `pkgs.nixd` and a Python LSP package (e.g., `pkgs.pyright`) to `extraPackages`.

8.  **Obsidian Vault**:
    *   **Task**: Update the Obsidian vault path.
    *   **Action**: Modify the Neovim configuration in `home-manager/modules/dotfiles/init.lua` to change the Obsidian vault path to `~/DOCUMENTS/obsidian`.

9.  **Image.nvim**:
    *   **Task**: Test `image.nvim`.
    *   **Action**: Find the `solarized-girl.jpg` file and attempt to open it in Neovim to verify `image.nvim` is working.

10. **Keymaps**:
    *   **Task**: Allow the user to define custom keymaps.
    *   **Action**: Add a new section to `GEMINI.md` for the user to specify their desired keymaps, and then update the Neovim configuration accordingly.

## Documentation

11. **Update GEMINI.md**:
    *   **Task**: Update `GEMINI.md` to reflect the changes and decisions made.
    *   **Action**: Create a new version of `GEMINI.md` that removes resolved questions and includes the new sections for git aliases and keymaps.
