# Standalone MCP flake — mcp-nixos + Serena, supply-chain locked, sandboxed.
# Own flake.lock: run `nix flake update` here when you bump `nixpkgs` in the parent Desktop flake.
# mcp-nixos: nix run .#mcp-nixos-sandboxed
# Serena:    nix run .#serena-sandboxed -- start-mcp-server
{
  description = "MCP servers — supply-chain locked, sandboxed";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mcp-nixos = {
      url = "github:utensils/mcp-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    serena = {
      url = "github:oraios/serena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      mcp-nixos,
      serena,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          mcp = mcp-nixos.packages.${system}.mcp-nixos;
          serenaPkg = serena.packages.${system}.serena;
        in
        {
          mcp-nixos = mcp;

          # bwrap: blocks ~/.ssh, ~/.config/sops; read-only $HOME/Projects
          mcp-nixos-sandboxed = pkgs.writeShellScriptBin "mcp-nixos-sandboxed" ''
            exec ${pkgs.bubblewrap}/bin/bwrap \
              --ro-bind /nix /nix \
              --ro-bind /etc /etc \
              --ro-bind "$HOME/Projects" "$HOME/Projects" \
              --tmpfs /tmp \
              --tmpfs "$HOME/.ssh" \
              --tmpfs "$HOME/.config/sops" \
              --tmpfs /run \
              --dev /dev \
              --proc /proc \
              --new-session \
              --die-with-parent \
              -- ${mcp}/bin/mcp-nixos "$@"
          '';

          serena = serenaPkg;

          # Serena: rw Projects (for .serena cache); blocks ~/.ssh, ~/.config/sops
          serena-sandboxed = pkgs.writeShellScriptBin "serena-sandboxed" ''
            exec ${pkgs.bubblewrap}/bin/bwrap \
              --ro-bind /nix /nix \
              --ro-bind /etc /etc \
              --bind "$HOME/Projects" "$HOME/Projects" \
              --tmpfs /tmp \
              --tmpfs "$HOME/.ssh" \
              --tmpfs "$HOME/.config/sops" \
              --tmpfs /run \
              --dev /dev \
              --proc /proc \
              --new-session \
              --die-with-parent \
              -- ${serenaPkg}/bin/serena "$@"
          '';
        }
      );
    };
}
