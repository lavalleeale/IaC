{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pywal-nix = {
      url = "github:Fuwn/pywal.nix";
      inputs.nixpkgs.follows = "nixpkgs"; # Recommended
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser-flake = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gorg-flake = {
      url = "github:lavalleeale/gorg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wl-paste-flake = {
      url = "github:lavalleeale/wl-paste-cpp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/hyprland/v0.49.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.49.0-fix";
      inputs.hyprland.follows = "hyprland";
    };
    authentik-nix = {
      url = "github:nix-community/authentik-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      sharedConfig = { allowUnfree = true; };
      overlay = final: prev: {
        gorg = inputs.gorg-flake.packages.${system}.default;
        wl-paste = inputs.wl-paste-flake.packages.${system}.default;
        zen-browser = inputs.zen-browser-flake.packages.${system}.default;
      };
      pkgs = import nixpkgs {
        inherit system;
        config = sharedConfig;
        overlays = [ overlay ];
      };
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config = sharedConfig;
      };
      hyprland-plugins = inputs.hyprland-plugins;
      homeModule = import ./home.nix;
      homeManagerSharedModules =
        [ inputs.pywal-nix.homeManagerModules.${system}.default ];
      homeManagerExtraSpecialArgs = { inherit hyprland-plugins pkgs-unstable; };
    in {
      homeConfigurations = {
        alex = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = homeManagerExtraSpecialArgs;
          modules = homeManagerSharedModules ++ [ homeModule ];
        };
      };

      nixosConfigurations = {
        server = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit pkgs-unstable; };
          modules = [
            ({ ... }: {
              nixpkgs = {
                config = sharedConfig;
                overlays = [ overlay ];
              };
            })
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.alex = homeModule;
                backupFileExtension = "backup";
                sharedModules = homeManagerSharedModules;
                extraSpecialArgs = homeManagerExtraSpecialArgs;
              };
              users.users.root.initialPassword = "changeme";
            }
            inputs.sops-nix.nixosModules.sops
            inputs.home-manager.nixosModules.home-manager
            inputs.authentik-nix.nixosModules.default
            ./configuration.nix
            ./server.nix
            ./laptop-hardware-configuration.nix
            ({ ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
          ];
        };
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit pkgs-unstable; };
          modules = [
            ({ ... }: {
              nixpkgs = {
                config = sharedConfig;
                overlays = [ overlay ];
              };
            })
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.impermanence.nixosModules.impermanence
            inputs.nixos-hardware.nixosModules.framework-13-7040-amd
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.alex = homeModule;
                backupFileExtension = "backup";
                sharedModules = homeManagerSharedModules;
                extraSpecialArgs = homeManagerExtraSpecialArgs;
              };
            }
            inputs.sops-nix.nixosModules.sops
            inputs.home-manager.nixosModules.home-manager
            ./laptop.nix
            ./laptop-hardware-configuration.nix
            ./configuration.nix
            ({ ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
          ];
        };
      };
    };
}
