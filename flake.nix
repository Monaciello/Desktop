{
  description = "Desktop — NixOS + nix-darwin configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Cursor IDE (desktop) — pinned tag, auto-updated 3x/week by upstream CI
    code-cursor-nix.url = "github:jacopone/code-cursor-nix/v2.6.18";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      nix-homebrew,
      flake-parts,
      ...
    }@inputs:
    let
      darwinPkgs = import inputs.nixpkgs-darwin {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };

      commonOverlays = [
        self.overlays.additions
        self.overlays.modifications
        self.overlays.unstable
      ];

      linuxOverlays = commonOverlays ++ [
        self.overlays.code-cursor
        self.overlays.cursor-xorg-fix
      ];
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        {
          packages = import ./pkgs nixpkgs.legacyPackages.${system};
          formatter = nixpkgs.legacyPackages.${system}.nixfmt;
          devShells = import ./shells { pkgs = nixpkgs.legacyPackages.${system}; };
        };

      flake = {
        overlays = import ./overlays { inherit inputs; };

        nixosModules = import ./modules/nixos;
        homeModules = import ./modules/home-manager;
        darwinModules = import ./modules/darwin;

        # --- NixOS (Linux) ---

        homeConfigurations = {
          "sasha@alice" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = { inherit inputs; };
            modules = [
              {
                nixpkgs.config.allowUnfree = true;
                nixpkgs.overlays = linuxOverlays;
              }
              ./home-manager/home.nix
              ./home-manager/linux.nix
            ];
          };
        };

        nixosConfigurations = {
          alice = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              { nixpkgs.overlays = linuxOverlays; }
              inputs.sops-nix.nixosModules.default
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "backup";
                home-manager.extraSpecialArgs = { inherit inputs; };
                home-manager.users.sasha = {
                  imports = [
                    ./home-manager/home.nix
                    ./home-manager/linux.nix
                  ];
                };
              }
              ./hosts/alice
            ];
          };
        };

        # --- nix-darwin (macOS) ---

        darwinConfigurations = {
          macbook = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = { inherit inputs; };
            modules = [
              { nixpkgs.overlays = commonOverlays; }
              nix-homebrew.darwinModules.nix-homebrew
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "backup";
                home-manager.extraSpecialArgs = { inherit inputs; };
                home-manager.users.sasha = {
                  imports = [
                    ./home-manager/home.nix
                    ./home-manager/darwin.nix
                  ];
                };
              }
              ./hosts/macbook
            ];
          };
        };
      };
    };
}
