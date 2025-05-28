{ config, lib, pkgs, ... }: {
  imports = [ ./configuration.nix ./desktop-hardware-configuration.nix ];
  services.openssh.enable = true;
}
