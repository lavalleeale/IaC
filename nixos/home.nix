{ ... }: {
  imports = [
    ./home/packages.nix
    ./home/zshell.nix
    ./home/git.nix
    ./home/desktop.nix
    ./home/hyprland.nix
    ./home/hyprland-ui.nix
  ];

  home = {
    username = "alex";
    homeDirectory = "/home/alex";
    stateVersion = "25.05";
  };
}
