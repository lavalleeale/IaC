{
  imports = [ ./configuration.nix ./laptop-hardware-configuration.nix ];
  services.snapper = {
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
}
