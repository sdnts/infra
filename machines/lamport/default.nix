{ ... }:
{
  imports = [
    ../../lib
    ../../lib/nixos.nix

    ./hardware-configuration.nix
    ./configuration.nix

    ./services/grafana.nix
    ./services/nginx.nix
    ./services/prometheus.nix
  ];

  infra.roles = [ "server" ];
}
