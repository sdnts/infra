# This is my custom framework to help maintain all my machines. I'd like to be able to set up common configuration once,
# but still allow each machine to have individuality.
# Really calling this a "framework" is overselling it. A firm understanding of how Nix merges attribute sets spread
# across multiple modules is would make this "framework" trivial. Read the comments in `home.nix` for details.
{ lib, ... }:
{
  imports = [ ./home.nix ];

  options = {
    # I organize my servers based on roles. Roles decide what (common) packages get installed, how dotfiles are
    # symlinked, and how common services are configured.
    # So far I've only got two roles but I want to create more as I add more nodes to my fleet.
    #
    # The `server` role sets up a node as server.
    #   - A minimal set of packages are installed to keep the node lean.
    #   - Packages useful for debugging servers are installed.
    #   - Dotfiles are symlinked to the nix store, which means changing them requires a redeployment. This makes sure
    #     all nodes feel exactly the same, and stuff like "accidentally breaking the shell" isn't possible.
    # The `tty` role sets up a node as a machine I interact with regularly.
    #   - QoL packages are installed to make the node feel nicer.
    # The `hq` role sets up a node as an administrative machine.
    #   - QoL packages are installed to make the node feel nicer.
    #   - Dotfiles are symlinked to this repository (outside the nix store), so I can edit them without redeploying
    #     constantly
    infra.roles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Options: server, tty, hq";
    };
  };
}
