{
  description = "NixOS configuration for alice";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Skarabox framework
    selfhostblocks.url = "github:ibizaman/selfhostblocks";
    skarabox.url = "github:ibizaman/skarabox";

    # Installation and deployment tools
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    # Flake framework
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Deployment tools (optional - comment out if not needed)
    # deploy-rs.url = "github:serokell/deploy-rs";
    # colmena.url = "github:zhaofengli/colmena";

    # Secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    flake-parts,
    ...
  } @ inputs: let
    systems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Custom packages accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    # Formatter for nix files, available through 'nix fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

    # Development shells, available through 'nix develop' or 'nix develop .#<name>'
    # Shells: default (bootstrap), fhs (FHS env), xonsh (xonsh dev)
    devShells = forAllSystems (system: import ./shells {pkgs = nixpkgs.legacyPackages.${system};});

    # Custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # Reusable NixOS modules you might want to export
    nixosModules = import ./modules/nixos;

    # Reusable home-manager modules you might want to export
    homeModules = import ./modules/home-manager;

    # NixOS system configurations
    # Available through 'nixos-rebuild --flake .#alice'
    nixosConfigurations = {
      alice = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          # Apply overlays to nixpkgs
          {
            nixpkgs.overlays = [
              self.overlays.additions
              self.overlays.modifications
              self.overlays.unstable
	    ];
          }
          # Sops-nix for secrets management
          inputs.sops-nix.nixosModules.default
          # Home-manager as NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {inherit inputs;};
            home-manager.users.sasha = import ./home-manager/home.nix;
          }
          # Main host configuration
          ./hosts/alice
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#sasha@alice'
    homeConfigurations = {
      "sasha@alice" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs;};
        modules = [
          {
            nixpkgs.overlays = [
              self.overlays.additions
              self.overlays.modifications
              self.overlays.unstable
            ];
            # Allow unfree packages (obsidian, etc)
            nixpkgs.config.allowUnfree = true;
          }
          ./home-manager/home.nix
        ];
      };
    };

    # Optional: Skarabox integration structure (for future use)
    # apps.x86_64-linux = {
    #   deploy = {
    #     type = "app";
    #     program = "${inputs.deploy-rs.packages.x86_64-linux.deploy-rs}/bin/deploy-rs";
    #   };
    # };
  };
}
