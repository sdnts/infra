{ ... }:
{
  imports = [
    ../../lib
    ../../lib/nixos.nix

    ./hardware-configuration.nix
    ./configuration.nix

    ./services/prometheus.nix
    ./services/grafana.nix
  ];

  infra.roles = [ "server" ];
}
