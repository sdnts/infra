{ ... }:
{
  system.stateVersion = 7;

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
    prometheus.exporters.node.enable = false;
  };
}
