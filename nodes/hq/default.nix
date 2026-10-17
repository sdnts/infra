# This module returns a function. It gets a few arguments, but we don't need any of them, hence the `...`.
{ ... }:
{
  imports = [
    ../../lib
    ../../lib/darwin.nix

    ./hardware-configuration.nix
    ./configuration.nix
  ];

  # The `lib` module exposes a `infra.roles` option that nodes use to receive common configuration. They're free to
  # override any of it, but I don't have to repeat all of it across similar nodes.
  # This isn't standard NixOS. More details about my "framework" in `lib/default.nix`.
  infra.roles = [
    "tty"
    "hq"
  ];
}
