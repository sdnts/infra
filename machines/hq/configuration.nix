{ config, ... }:
{
  system.stateVersion = 7;

  networking = {
    hostName = "hq";
    localHostName = "hq";
    computerName = "HQ";
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

    prometheus.exporters.node.enable = false;
  };
}
