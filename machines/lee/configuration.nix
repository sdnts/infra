{ ... }:
{
  system.stateVersion = "26.05";

  networking = {
    hostName = "lee";
    hostId = "7464c390";
  };
  time.timeZone = "Europe/Amsterdam";

  home-manager.users.sdnts.home = {
    stateVersion = "26.05";
    packages = [ ];
  };

  services.tailscale.extraUpFlags = [
    "--advertise-tags=tag:service"
  ];
}
