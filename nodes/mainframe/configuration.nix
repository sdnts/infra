{ ... }:
{
  system.stateVersion = 7;

  networking = {
    hostName = "mainframe";
    localHostName = "mainframe";
    computerName = "mainframe";
  };

  power = {
    sleep.computer = "never";
    restartAfterPowerFailure = true;
    restartAfterFreeze = true;
  };

  home-manager.users.sdnts.home = {
    stateVersion = "26.05";
    packages = [ ];
  };
}
