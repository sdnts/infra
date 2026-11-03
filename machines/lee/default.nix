{ ... }:
{
  imports = [
    ../../lib
    ../../lib/nixos.nix

    ./hardware-configuration.nix
    ./configuration.nix
  ];

  infra.roles = [ "server" ];
}
