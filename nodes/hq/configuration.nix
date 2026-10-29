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
    # On HQ, I'm forced to use the Tailscale app since it makes using Exit Nodes simple / possible
    # This does mean that I cannot use Tailscale SSH, since the macOS GUI app does not yet support
    # logging in as root (and deploy-rs needs that to deploy the `system` profile)
    # So, for now, disable the Tailscale daemon and fall back to using OpenSSH instead.
    #
    # Another side effect of using the Tailscale app is that Tailscale Funnel isn't allowed to
    # forward packets to Unix sockets yet (https://github.com/tailscale/tailscale/issues/21900), so
    # Rex shows up as its own device on the Tailscale console.
    tailscale.enable = false;
    openssh.enable = true;

    prometheus.exporters.node.enable = false;
  };
}
