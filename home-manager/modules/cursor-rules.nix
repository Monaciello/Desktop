{ ... }:
{
  # Global rules — Nix-first, apply to all projects
  home.file.".cursor/rules/300-nix-orchestrator.mdc".source =
    ./dotfiles/cursor-rules/300-nix-orchestrator.mdc;
  home.file.".cursor/rules/350-python-nix.mdc".source =
    ./dotfiles/cursor-rules/350-python-nix.mdc;
  home.file.".cursor/rules/400-nix-guide.mdc".source = ./dotfiles/cursor-rules/400-nix-guide.mdc;
  home.file.".cursor/rules/500-spec-driven.mdc".source = ./dotfiles/cursor-rules/500-spec-driven.mdc;

  # Language-specific rules (000, 100, 150, 200) live in project repos:
  #   InclusiveBlocks/.cursor/rules/000-archeologist.mdc
  #   InclusiveBlocks/.cursor/rules/100-strict-architect.mdc
  #   InclusiveBlocks/.cursor/rules/150-python-testing.mdc
  #   InclusiveBlocks/.cursor/rules/200-rust-mentor.mdc
}
