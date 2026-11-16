let
  identity = import ./identity.nix;
in
{
  "secrets/exa.age".publicKeys = with identity; [
    operators.sdnts.ssh.publicKey
    machines.hopper.ssh.publicKey
    machines.lovelace.ssh.publicKey
    machines.cloudflare.ssh.publicKey
    machines.turing.ssh.publicKey
    machines.lamport.ssh.publicKey
    machines.lee.ssh.publicKey
  ];
  "secrets/nginx.age".publicKeys = with identity; [
    operators.sdnts.ssh.publicKey
    machines.lamport.ssh.publicKey
  ];
  "secrets/grafana.age".publicKeys = with identity; [
    operators.sdnts.ssh.publicKey
    machines.lamport.ssh.publicKey
  ];
}
