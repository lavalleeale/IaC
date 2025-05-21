# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  unstableTarball = fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-unstable.tar.gz";
in {
  imports = [ ./hardware-configuration.nix ];
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import unstableTarball { config = config.nixpkgs.config; };
    };
    permittedInsecurePackages =
      [ "dotnet-sdk-wrapped-7.0.410" "dotnet-sdk-7.0.410" ];
  };
  networking = {
    firewall = {
      enable = true;
      extraCommands = ''
        # Allow traffic from virbr0
        iptables -A FORWARD -i virbr0 -j ACCEPT
        iptables -A FORWARD -o virbr0 -j ACCEPT
        iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -o wlp1s0 -j MASQUERADE
      '';
    };
  };

  time.timeZone = "America/New_York";

  security = {
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
    };
    sudo = {
      enable = true;
      extraRules = [{
        commands = [
          {
            command = "${pkgs.fw-ectool}/bin/ectool fanduty *";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.fw-ectool}/bin/ectool autofanctrl";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }];
    };
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };
    containerd.enable = true;
    vmVariant = {
      # following configuration is added only when building VM with build-vm
      virtualisation = {
        memorySize = 8192;
        cores = 4;
        qemu.options = [ "-device" "virtio-vga" ];
      };
    };
    docker.enable = true;
    virtualbox.host.enable = true;
  };
  services = {
    udev.extraRules = ''
      ACTION != "add", GOTO="solaar_end"
      SUBSYSTEM != "hidraw", GOTO="solaar_end"

      # USB-connected Logitech receivers and devices
      ATTRS{idVendor}=="046d", GOTO="solaar_apply"

      # Lenovo nano receiver
      ATTRS{idVendor}=="17ef", ATTRS{idProduct}=="6042", GOTO="solaar_apply"

      # Bluetooth-connected Logitech devices
      KERNELS == "0005:046D:*", GOTO="solaar_apply"

      GOTO="solaar_end"

      LABEL="solaar_apply"

      # Allow any seated user to access the receiver.
      # uaccess: modern ACL-enabled udev
      TAG+="uaccess"

      # Grant members of the "plugdev" group access to receiver (useful for SSH users)
      #MODE="0660", GROUP="plugdev"

      LABEL="solaar_end"
    '';
    printing.enable = true;
    open-webui.enable = true;
    ollama.enable = true;
    pcscd.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };
    fwupd.enable = true;
    tor = {
      enable = false;
      enableGeoIP = false;
      relay.onionServices = {
        myOnion = {
          version = 3;
          map = [{
            port = 80;
            target = {
              addr = "[::1]";
              port = 8080;
            };
          }];
        };
      };
      settings = {
        ClientUseIPv4 = false;
        ClientUseIPv6 = true;
        ClientPreferIPv6ORPort = true;
      };
    };
    tailscale.enable = true;
    nixseparatedebuginfod.enable = true;
    gnome.gnome-keyring.enable = true;
    geoclue2.enable = true;
    hardware = { bolt.enable = true; };
    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';
    devmon.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    fprintd.enable = true;
    usbmuxd.enable = true;
  };
  programs = {
    steam.enable = true;
    adb.enable = true;
    fuse.userAllowOther = true;
    zsh = {
      enable = true;
      shellAliases = {
        dotfiles = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";
      };
    };
    direnv.enable = true;
    hyprland.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
  };
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      alex = {
        createHome = true;
        isNormalUser = true;
        hashedPasswordFile = "/nix/persist/passwords/alex";
        extraGroups = [
          "libvirtd"
          "docker"
          "wheel"
          "vboxusers"
          "adbusers"
          "tss"
        ]; # Enable ‘sudo’ for the user.
        packages = with pkgs; [ firefox tree ];
      };
      root.hashedPasswordFile = "/nix/persist/passwords/root";
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters =
        [ "https://lavalleeale.cachix.org" "https://cache.nixos.org/" ];
      trusted-public-keys = [
        "lavalleeale.cachix.org-1:durM7fu7UhmWkgUoc/3lUQF30Z+rEVNmFb0lRrhIO7Y="
      ];
    };
  };

  networking.networkmanager.enable = true;

  hardware = {
    bluetooth.enable = true; # enables support for Bluetooth
    bluetooth.powerOnBoot = true;
    graphics.enable = true;
  };

  environment.systemPackages = with pkgs;
    let
      rstudio-custom = rstudioWrapper.override {
        packages = with rPackages; [ ggplot2 dplyr tidyverse ];
      };
      launcher = (builtins.getFlake
        "github:lavalleeale/gorg").packages.${pkgs.system}.default;
      python3-custom = python3.withPackages (ps:
        with ps; [
          aiohttp
          argparse
          beautifulsoup4
          black
          datadog
          jupyter
          lxml
          matplotlib
          nltk
          notebook
          numpy
          pandas
          ps
          pylint
          requests
          tqdm
          websockets
        ]);
      texlive-custom = texlive.combine {
        inherit (pkgs.texlive)
          scheme-medium titlesec fontawesome changepage enumitem;
      };

      # Development tools
      devTools = [
        cmake
        fw-ectool
        gcc
        git
        gnumake
        go
        lua-language-server
        nodejs_22
        php
        pkg-config
        postgresql_14
        python3-custom
        rustfmt
        ruby
        sqlite
        usbutils
        yarn
        jre_minimal
        file
        slurp
      ];

      # IDEs and editors
      editors = [
        android-studio
        jetbrains.clion
        jetbrains.phpstorm
        unstable.neovim
        vim
        unstable.vscode
      ];

      # System utilities
      sysUtils = [
        bc
        btop
        dig
        fd
        htop
        inotify-tools
        iproute2
        killall
        lm_sensors
        lsof
        ncdu
        ripgrep
        wget
        solaar
        clipman
      ];

      # Security and encryption
      securityTools =
        [ openssl sbctl tpm2-tools yubikey-manager yubikey-manager-qt ];

      # Virtualization and containers
      virtTools = [
        (vagrant.override { withLibvirt = false; })
        dnsmasq
        packer
        virt-manager
      ];

      # Desktop and GUI applications
      desktopApps = [
        alacritty
        dolphin
        dunst
        google-chrome
        kitty
        obsidian
        parsec-bin
        postman
        prismlauncher
        tetrio-desktop
        tor-browser-bundle-bin
        vesktop
        vlc
      ];

      # Wayland-specific tools
      waylandTools = [
        brightnessctl
        hypridle
        hyprlock
        hyprpaper
        hyprshot
        hyprsunset
        pamixer
        rofi-wayland
        waybar
        wayvnc
        wl-clipboard
        wofi
      ];

      # Development utilities
      devUtils = [
        act
        atuin
        cachix
        cypress
        gh
        jq
        niv
        nix-output-monitor
        nixfmt-classic
        nixpkgs-fmt
        starship
        thefuck
        zoxide
      ];

      # Multimedia and graphics
      mediaTools = [ imagemagick plasma5Packages.kdeconnect-kde ];

      # Science and education
      scienceTools = [ mars-mips rstudio-custom texlive-custom ];

      # Other utilities
      otherUtils = [
        borgbackup
        code-cursor
        dmenu
        eza
        flintlock
        launcher
        libimobiledevice
        libisoburn
        linuxKernel.packages.linux_zen.perf
        mangohud
        monero-cli
        monero-gui
        power-profiles-daemon
        pywal
        samba
        unzip
        valgrind
        xdg-utils
      ];
    in devTools ++ editors ++ sysUtils ++ securityTools ++ virtTools
    ++ desktopApps ++ waylandTools ++ devUtils ++ mediaTools ++ scienceTools
    ++ otherUtils;

  fonts.packages = with pkgs; [
    font-awesome
    powerline-fonts
    powerline-symbols
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  specialisation = {
    vpn.configuration = {
      services.openvpn.servers = {
        upVPN = {
          config = "config /nix/persist/ovpn/up.ovpn ";
          updateResolvConf = true;
          autoStart = true;
        };
      };
    };
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}

