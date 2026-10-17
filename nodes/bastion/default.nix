{ ... }:
{
  imports = [
    ../../lib
    ../../lib/nixos.nix

    ./hardware-configuration.nix
    ./configuration.nix

    ./services/nginx.nix
  ];

  infra.roles = [ "server" ];
}
