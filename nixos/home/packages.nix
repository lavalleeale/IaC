{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs;
    let
      mediaTools = [ imagemagick plasma5Packages.kdeconnect-kde ];

      scienceTools = [ mars-mips texlive-custom ];
      texlive-custom = texlive.combine {
        inherit (pkgs.texlive)
          scheme-medium titlesec fontawesome changepage enumitem;
      };

      editors = [
        android-studio
        jetbrains.clion
        jetbrains.phpstorm
        pkgs-unstable.neovim
        vim
        pkgs-unstable.vscode
      ];

      securityTools =
        [ openssl sbctl tpm2-tools yubikey-manager bitwarden-cli ];

      virtTools = [
        (vagrant.override { withLibvirt = false; })
        dnsmasq
        packer
        virt-manager
      ];

      desktopApps = [
        catppuccin-papirus-folders
        alacritty
        kdePackages.dolphin
        dunst
        google-chrome
        firefox
        zen-browser
        kitty
        obsidian
        parsec-bin
        ledger-live-desktop
        postman
        prismlauncher
        tetrio-desktop
        tor-browser-bundle-bin
        vesktop
        vlc
      ];

      waylandTools = [
        brightnessctl
        hyprshot
        hyprsunset
        pamixer
        rofi-wayland
        wayvnc
        wl-clipboard
      ];

      otherUtils = [
        borgbackup
        code-cursor
        dmenu
        eza
        flintlock
        gorg
        wl-paste
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

      devUtils = [
        act
        atuin
        cachix
        cypress
        gemini-cli
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
    in devUtils ++ mediaTools ++ scienceTools ++ securityTools ++ virtTools
    ++ desktopApps ++ waylandTools ++ otherUtils ++ editors;
}
