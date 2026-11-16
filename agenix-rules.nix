let
  identity = import ./identity.nix;
in
{
  "secrets/exa.age".publicKeys = with identity; [
    hopper.ssh.users.sdnts.publicKey
    hopper.ssh.host.publicKey
    lovelace.ssh.host.publicKey
    cloudflare.ssh.host.publicKey
    turing.ssh.host.publicKey
    lamport.ssh.host.publicKey
    lee.ssh.host.publicKey
  ];
  "secrets/nginx.age".publicKeys = with identity; [
    hopper.ssh.users.sdnts.publicKey
    lamport.ssh.host.publicKey
  ];
  "secrets/grafana.age".publicKeys = with identity; [
    hopper.ssh.users.sdnts.publicKey
    lamport.ssh.host.publicKey
  ];
}
