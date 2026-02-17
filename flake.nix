{
  description = "Desktop — NixOS configuration for alice";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

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

        homeConfigurations = {
          "sasha@alice" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = { inherit inputs; };
            modules = [
              {
                nixpkgs.overlays = [
                  self.overlays.additions
                  self.overlays.modifications
                  self.overlays.unstable
                ];
              }
              ./home-manager/home.nix
            ];
          };
        };

        nixosConfigurations = {
          alice = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              {
                nixpkgs.overlays = [
                  self.overlays.additions
                  self.overlays.modifications
                  self.overlays.unstable
                ];
              }
              inputs.sops-nix.nixosModules.default
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "backup";
                home-manager.extraSpecialArgs = { inherit inputs; };
                home-manager.users.sasha = import ./home-manager/home.nix;
              }
              ./hosts/alice
            ];
          };
        };
      };
    };
}
