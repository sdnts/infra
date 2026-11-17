let
  identity = import ./identity.nix;
in
{
  "secrets/nginx.age".publicKeys = with identity; [
    operators.sdnts.ssh.publicKey
    machines.lamport.ssh.publicKey
  ];
  "secrets/grafana.age".publicKeys = with identity; [
    operators.sdnts.ssh.publicKey
    machines.lamport.ssh.publicKey
  ];
}
