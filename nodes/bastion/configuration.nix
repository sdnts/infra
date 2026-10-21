{ ... }:
{
  system.stateVersion = "26.05";

  networking.hostName = "bastion";
  networking.hostId = "dd3b3b75";
  time.timeZone = "Europe/London";

  home-manager.users.sdnts.home = {
    stateVersion = "26.05";
    packages = [ ];
  };
}
