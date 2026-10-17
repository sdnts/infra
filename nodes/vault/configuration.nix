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

  zramSwap.enable = true;
  networking.hostId = "280f1a04";
  time.timeZone = "America/New_York";

  home-manager.users.sdnts.home = {
    stateVersion = "26.05";
    packages = [ ];
  };
}
