{ config, ... }:
{
  age.secrets = {
    netrc = {
      file = ../../secrets/netrc.age;
      # Credentials in the netrc file are going to be used when deploying to nodes. This happens as my user, which is
      # why this file must belong to me.
      owner = "sdnts";
    };
  };

  system.stateVersion = 7;

  # Rex's flake requires a secret that's supplied via /etc/netrc
  nix.settings.netrc-file = config.age.secrets.netrc.path;

  networking = {
    hostName = "hq";
    localHostName = "hq";
    computerName = "hq";
  };

  homebrew = {
    brews = [ "ampcode/tap/ampcode" ];
    casks = [ ];
  };

  home-manager.users.sdnts = {
    home.stateVersion = "26.05";
    home.packages = [ ];
  };

  services = {
    tailscale.enable = false; # We'll use the Tailscale app instead
    prometheus.exporters.node.enable = false;
  };
}
