{ ... }:
{
  system.stateVersion = 7;

  networking = {
    hostName = "lovelace";
    localHostName = "lovelace";
    computerName = "Lovelace";
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
