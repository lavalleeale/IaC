{ lib, config, pkgs, ... }: {
  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "radeonsi";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      MOZ_ENABLE_WAYLAND = "1";
      VDPAU_DRIVER = "radeonsi";
    };
    systemPackages = with pkgs; [ libva-utils vdpauinfo ];
    pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

    persistence."/nix/persist" = {
      directories = [
        "/etc/ssh"
        "/etc/nixos"
        "/etc/secureboot"
        "/var/log"
        "/var/lib/docker"
        "/var/lib/nixos"
        "/var/lib/fprint"
        "/var/lib/bluetooth"
        {
          directory = "/var/lib/private";
          mode = "u=rwx,g=,o=";
        }
        "/var/lib/tailscale"
        "/etc/NetworkManager/system-connections"
        "/root"
      ];
      files = [
        "/etc/machine-id"
        {
          file = "/etc/nix/id_rsa";
          parentDirectory = { mode = "u=rwx,g=rw,o=rw"; };
        }
      ];
    };
  };
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
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
    usbmuxd.enable = true;
    udisks2.enable = true;
    udev = {
      packages = [ pkgs.platformio-core.udev ];
      extraRules = ''
        KERNEL=="uinput", GROUP="input", TAG+="uaccess"
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
    };
    fprintd.enable = true;
    geoclue2.enable = true;
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    pcscd.enable = true;
    printing.enable = true;
    logind.settings.Login.HandlePowerKey = "suspend";
    snapper = {
      configs = {
        "programming" = {
          SUBVOLUME = "/home/alex/Documents/Programming";
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 5;
          TIMELINE_LIMIT_DAILY = 7;
        };
      };
    };
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
  };
  users.users = {
    alex.hashedPasswordFile = "/nix/persist/passwords/alex";
    root.hashedPasswordFile = "/nix/persist/passwords/root";
  };
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
  services.hardware.bolt.enable = true;
  hardware = {
    bluetooth.enable = true; # enables support for Bluetooth
    bluetooth.powerOnBoot = true;
    graphics.enable = true;
    graphics.enable32Bit = true;
    graphics.extraPackages = with pkgs; [ mesa ];
    uinput.enable = true;
    ledger.enable = true;
  };
  programs = {
    adb.enable = true;
    fuse.userAllowOther = true;
    steam.enable = true;
  };
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
}
