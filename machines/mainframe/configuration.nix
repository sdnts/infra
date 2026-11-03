{ ... }:
{
  system.stateVersion = 7;

  networking = {
    hostName = "mainframe";
    localHostName = "mainframe";
    computerName = "Mainframe";
  };

  power = {
    sleep.computer = "never";
    restartAfterPowerFailure = true;
    restartAfterFreeze = true;
  };

  homebrew = {
    brews = [ ];
    casks = [ ];
  };

  home-manager.users.sdnts.home = {
    stateVersion = "26.05";
    packages = [ ];
  };
}
