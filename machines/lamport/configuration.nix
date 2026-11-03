{ ... }:
{
  system.stateVersion = "26.05";

  networking = {
    hostName = "lamport";
    hostId = "2a18b4a9";
  };
  time.timeZone = "Europe/Amsterdam";

  home-manager.users.sdnts.home = {
    stateVersion = "26.05";
    packages = [ ];
  };

  services.tailscale.extraUpFlags = [
    "--advertise-tags=tag:ingress,tag:service,tag:monitoring"
  ];
}
