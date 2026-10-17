let
  identity = import ./identity.nix;
in
{
  "secrets/exa.age".publicKeys = with identity; [
    hq.ssh.users.sdnts.publicKey
    hq.ssh.host.publicKey
    mainframe.ssh.host.publicKey
    cloudflare.ssh.host.publicKey
    bastion.ssh.host.publicKey
    vault.ssh.host.publicKey
    sentry.ssh.host.publicKey
  ];
  "secrets/nginx.age".publicKeys = with identity; [
    hq.ssh.users.sdnts.publicKey
    bastion.ssh.host.publicKey
  ];
  "secrets/grafana.age".publicKeys = with identity; [
    hq.ssh.users.sdnts.publicKey
    sentry.ssh.host.publicKey
  ];
}
