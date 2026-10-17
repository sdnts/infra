{ ... }:
{
  system.stateVersion = "26.05";

  networking.hostId = "47488af9";
  time.timeZone = "Europe/Berlin";

  home-manager.users.sdnts.home = {
    stateVersion = "26.05";
    packages = [ ];
  };
}
