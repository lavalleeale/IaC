{ config, lib, pkgs, ... }: {
  imports = [
    ./configuration.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];
  services.getty.autologinUser = lib.mkForce "alex";
  users.users.alex.password = "";
}
