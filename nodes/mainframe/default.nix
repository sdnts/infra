{ ... }:
{
  imports = [
    ../../lib
    ../../lib/darwin.nix

    ./hardware-configuration.nix
    ./configuration.nix
  ];

  infra.roles = [ "tty" ];
}
