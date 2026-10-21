{ inputs, pkgs, ... }:
{
  system.stateVersion = "25.11";

  boot = {
    kernelPackages = pkgs.linuxPackages;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "vault";
    hostId = "280f1a04";
  };
  time.timeZone = "America/New_York";
  zramSwap.enable = true;

  home-manager.users.sdnts.home = {
    stateVersion = "26.05";
    packages = [ ];
  };
}
