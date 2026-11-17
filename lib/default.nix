# This is my custom framework to help maintain all my machines. I'd like to be able to set up common configuration once,
# but still allow each machine to have individuality.
# Really calling this a "framework" is overselling it. A firm understanding of how Nix merges attribute sets spread
# across multiple modules is would make this "framework" trivial. Read the comments in `home.nix` for details.
{ lib, ... }:
{
  imports = [ ./home.nix ];

  options = {
    # Machines are organized by "roles". This option defines a default set of baseline packages that are installed and
    # services that are enabled.
    # The `server` role sets up a machine as server.
    #   - A minimal set of packages are installed to keep the machine lean.
    #   - Packages useful for debugging servers are installed.
    # The `tty` role sets up a machine I interact with regularly. QoL packages are installed to make the node feel nicer.
    infra.roles = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "server"
          "tty"
        ]
      );
    };

    # This option defines how dotfiles are managed on machines.
    # `copy` copies them to the nix store , which means changing them requires a redeployment. This makes sure all
    #   machines feel exactly the same, and stuff like "accidentally breaking the shell" isn't possible.
    # `symlink` symlinks the home directory to this repository (outside the nix store), so I can edit them without
    #   redeploying constantly
    infra.home = lib.mkOption {
      type = lib.types.enum [
        "copy"
        "symlink"
      ];
      default = "copy";
    };
  };
}
