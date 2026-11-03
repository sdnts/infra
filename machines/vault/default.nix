{ ... }:
{
  imports = [
    ../../lib
    ../../lib/nixos.nix

    ./hardware-configuration.nix
    ./configuration.nix

    ./services/copyparty.nix
    ./services/immich.nix
    ./services/jellyfin.nix
    ./services/mealie.nix
    ./services/zfs.nix
  ];

  infra.roles = [ "server" ];
}
