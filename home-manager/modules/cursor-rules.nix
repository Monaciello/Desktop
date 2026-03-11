{ ... }:
{
  # Global rules — deployed to ~/.cursor/rules/ via Home Manager
  # Numbering = priority (lower = higher priority, evaluated first)

  # 000: Always-on fundamentals
  home.file.".cursor/rules/000-codebase-first.mdc".source =
    ./dotfiles/cursor-rules/000-codebase-first.mdc;

  # 100: Python strictness (glob-triggered on *.py, inert in non-Python projects)
  home.file.".cursor/rules/100-strict-architect.mdc".source =
    ./dotfiles/cursor-rules/100-strict-architect.mdc;

  # 150: Python testing (glob-triggered on test files)
  home.file.".cursor/rules/150-python-testing.mdc".source =
    ./dotfiles/cursor-rules/150-python-testing.mdc;

  # 200: Rust mentor (glob-triggered on *.py, *.rs)
  home.file.".cursor/rules/200-rust-mentor.mdc".source =
    ./dotfiles/cursor-rules/200-rust-mentor.mdc;

  # 300: Nix orchestration (always-on for *.nix, flake.lock, secrets)
  home.file.".cursor/rules/300-nix-orchestrator.mdc".source =
    ./dotfiles/cursor-rules/300-nix-orchestrator.mdc;

  # 350: Python + Nix integration (glob-triggered on flake/shell nix files)
  home.file.".cursor/rules/350-python-nix.mdc".source =
    ./dotfiles/cursor-rules/350-python-nix.mdc;

  # 400: Nix style guide (on-demand)
  home.file.".cursor/rules/400-nix-guide.mdc".source = ./dotfiles/cursor-rules/400-nix-guide.mdc;

  # 500: Spec-driven workflow (on-demand)
  home.file.".cursor/rules/500-spec-driven.mdc".source = ./dotfiles/cursor-rules/500-spec-driven.mdc;
}
