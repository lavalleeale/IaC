{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pywal-nix = {
      url = "github:lavalleeale-forks/pywal.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
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
      url = "github:hyprwm/hyprland/v0.53.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.53.0";
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

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      sharedConfig = {
        allowUnfree = true;
      };
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

      homeBaseModule = import ./home.nix;
      homeDesktopModule = {
        imports = [
          ./home/desktop.nix
          ./home/hyprland.nix
          ./home/hyprland-ui.nix
        ];
      };
      homeManagerSharedModules = [ inputs.pywal-nix.homeManagerModules.${system}.default ];

      commonSpecialArgs = { inherit pkgs-unstable; };

      commonHomeSpecialArgs = commonSpecialArgs // {
        hyprland-plugins = inputs.hyprland-plugins;
      };

      nixpkgsModule = {
        nixpkgs = {
          config = sharedConfig;
          overlays = [ overlay ];
        };
      };

      registryModule = {
        nix.registry.nixpkgs.flake = nixpkgs;
      };

      mkUiSettings =
        {
          graphical ? false,
          batteryPath ? null,
          temperaturePath ? null,
          networkInterface ? null,
          hyprlockWallpaper ? null,
          hyprlockProfileImage ? null,
          hyprlandMonitors ? [ ",preferred,auto,auto" ],
        }:
        {
          inherit
            graphical
            batteryPath
            temperaturePath
            networkInterface
            hyprlockWallpaper
            hyprlockProfileImage
            hyprlandMonitors
            ;
        };

      mkHomeModule =
        { graphical, ... }:
        {
          imports = [ homeBaseModule ] ++ lib.optionals graphical [ homeDesktopModule ];
        };

      mkHomeManagerModule =
        { graphical, uiSettings }:
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.alex = mkHomeModule { inherit graphical uiSettings; };
            backupFileExtension = "backup";
            sharedModules = homeManagerSharedModules;
            extraSpecialArgs = commonHomeSpecialArgs // {
              inherit uiSettings;
            };
          };
        };

      mkHost =
        {
          graphical ? false,
          uiSettings ? mkUiSettings { inherit graphical; },
          modules,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = commonSpecialArgs;
          modules = [
            nixpkgsModule
            (mkHomeManagerModule { inherit graphical uiSettings; })
            inputs.home-manager.nixosModules.home-manager
          ]
          ++ modules
          ++ [ registryModule ];
        };

      laptopUiSettings = mkUiSettings {
        graphical = true;
        batteryPath = "/sys/class/power_supply/BAT1/capacity";
        temperaturePath = "/sys/class/hwmon/hwmon5/temp1_input";
        networkInterface = "wlp*";
        hyprlockWallpaper = "/home/alex/Pictures/wallpapers/current";
        hyprlockProfileImage = "/home/alex/Pictures/profile.png";
        hyprlandMonitors = [
          ",preferred,auto,auto"
          "eDP-1,2256x1504@60,0x0,1.175"
        ];
      };

      desktopUiSettings = mkUiSettings { graphical = true; };
    in
    {
      homeConfigurations = {
        alex = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = commonHomeSpecialArgs // {
            uiSettings = laptopUiSettings;
          };
          modules = homeManagerSharedModules ++ [
            (mkHomeModule {
              graphical = true;
              uiSettings = laptopUiSettings;
            })
          ];
        };
      };

      nixosConfigurations = {
        laptop = mkHost {
          graphical = true;
          uiSettings = laptopUiSettings;
          modules = [
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.impermanence.nixosModules.impermanence
            inputs.nixos-hardware.nixosModules.framework-13-7040-amd
            inputs.sops-nix.nixosModules.sops
            ./configuration.nix
            ./laptop.nix
            ./laptop-hardware-configuration.nix
          ];
        };

        desktop = mkHost {
          graphical = true;
          uiSettings = desktopUiSettings;
          modules = [
            ./configuration.nix
            ./desktop.nix
            ./desktop-hardware-configuration.nix
          ];
        };

        server = mkHost {
          modules = [
            inputs.sops-nix.nixosModules.sops
            inputs.authentik-nix.nixosModules.default
            ./configuration.nix
            ./server.nix
          ];
        };
      };
    };
}
