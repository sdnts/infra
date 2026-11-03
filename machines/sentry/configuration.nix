{ ... }:
{
  system.stateVersion = "26.05";

  networking = {
    hostName = "sentry";
    hostId = "47488af9";
  };
  time.timeZone = "Europe/Berlin";

  home-manager.users.sdnts.home = {
    stateVersion = "26.05";
    packages = [ ];
  };

  services.tailscale.extraUpFlags = [
    "--advertise-tags=tag:service,tag:monitoring"
  ];
}
