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
    taps = [
      {
        name = "jundot/omlx";
        clone_target = "https://github.com/jundot/omlx";
      }
    ];
    brews = [
      {
        name = "jundot/omlx/omlx";
        args = [ "with-custom-kernel" ];
        start_service = true;
        restart_service = "changed";
      }
      "incoai/tap/splash"
    ];
    casks = [ ];
  };

  home-manager.users.sdnts.home = {
    stateVersion = "26.05";
    packages = [ ];
  };
}
