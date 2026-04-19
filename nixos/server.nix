{ config, pkgs, ... }: {
  virtualisation.vmVariant = {
    virtualisation.memorySize = 8096;
    virtualisation.forwardPorts = [
      {
        host.port = 9000;
        guest.port = 9000;
        from = "host";
      }
      {
        host.port = 2222;
        guest.port = 22;
        from = "host";
      }
      {
        host.port = 8443;
        guest.port = 8443;
        from = "host";
      }
      {
        host.port = 2283;
        guest.port = 2283;
        from = "host";
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [ 8443 9000 2222 2283 ];
  services = {
    immich = { enable = true; };
    authentik = {
      enable = true;
      # The environmentFile needs to be on the target host!
      # Best use something like sops-nix or agenix to manage it
      environmentFile = config.sops.secrets.authentik-env.path;
      settings = {
        email = {
          host = "smtp.example.com";
          port = 587;
          username = "authentik@example.com";
          use_tls = true;
          use_ssl = false;
          from = "authentik@example.com";
        };
        disable_startup_analytics = true;
        avatars = "initials";
      };
    };
    authentik-proxy = {
      enable = true;
      environmentFile = config.sops.secrets.authentik-env.path;
    };
    caddy = {
      enable = true;
      configFile = ./caddy/Caddyfile;
    };
    unifi = {
      enable = true;
      openFirewall = true;
    };
  };
  sops = {
    defaultSopsFile = ./secrets/example.yaml;
    # This will automatically import SSH keys as age keys
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # This is using an age key that is expected to already be in the filesystem
    # This is the actual specification of the secrets.
    secrets.authentik-env = { };
  };
}
