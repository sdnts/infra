# This module is used to configure darwin (macOS) machines. NixOS and macOS are differnet enough that I'd like to keep
# these configurations separate, even if I have to repeat myself a bit.
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  identity = import ../identity.nix;

  isServer = builtins.elem "server" config.infra.roles;
  isTTY = builtins.elem "tty" config.infra.roles;
  isHQ = builtins.elem "hq" config.infra.roles;
in
{
  imports = [
    inputs.agenix.darwinModules.default
    inputs.home-manager.darwinModules.default
  ];

  age = {
    # Ask age to use the host's SSH key as its identity. This is used when decrypting secrets after profile deployment
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = { };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      download-buffer-size = lib.mkDefault 536870912;
      warn-dirty = lib.mkDefault false;
    };
    optimise.automatic = lib.mkDefault true;
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 14d";
      interval = [
        {
          Weekday = lib.mkDefault 3;
          Hour = lib.mkDefault 2;
          Minute = lib.mkDefault 10;
        }
      ];
    };
  };

  programs.fish.enable = lib.mkForce true;

  system.primaryUser = lib.mkForce "sdnts";
  users.users.sdnts = {
    home = lib.mkForce "/Users/sdnts";
    shell = lib.mkForce pkgs.fish;
    # SSH is controlled by Tailscale policies, so no `authorizedKeys` here!
  };
  users.users.root.openssh.authorizedKeys.keys = lib.mkForce [
    identity.hq.ssh.users.sdnts.publicKey
  ];

  homebrew = {
    enable = lib.mkDefault true;

    brews = [

    ]
    ++ lib.optionals isServer [ ]
    ++ lib.optionals isTTY [ ]
    ++ lib.optionals isHQ [ ];

    casks = [

    ]
    ++ lib.optionals isServer [ ]
    ++ lib.optionals isTTY [ ]
    ++ lib.optionals isHQ [ ];
  };

  # `home.nix` already installs a bunch of packages, so list packages here that are darwin-specific.
  home-manager.users.sdnts.home.packages = [

  ]
  ++ lib.optionals isServer [ ]
  ++ lib.optionals isTTY [ ]
  ++ lib.optionals isHQ [ ];

  services = {
    tailscale.enable = lib.mkDefault true;

    # I'd like to not have OpenSSH / Remote Login turned on for macOS hosts, but relying solely on Tailscale SSH is not
    # practical yet. Apparently, nix-darwin activations tell deploy-rs to unload, load new plist, then load launchctl
    # services (like Tailscale). Unlike NixOS, this is controlled by the deploy-rs script and not launchctl itself
    # (AKA, unlike systemd, you cannot tell launctl to "restart" a service, you must stop and start it yourself). This
    # means that if Tailscale is ever upgraded, deploy-rs + nix-darwin kill the SSH daemon, but cannot copy over the new
    # plist or restart Tailscale. When this happens, we drop the SSH connection and leave the remote host stranded.
    # It disappears from the tailnet and the new profile never gets activated.
    # This sucks. But we can enable OpenSSH so that deploy-rs always has a way to reach remote darwin hosts.
    openssh = {
      enable = lib.mkForce true;
      extraConfig = lib.mkForce ''
        PubkeyAuthentication yes
        PasswordAuthentication no
        KbdInteractiveAuthentication no
        PermitRootLogin prohibit-password
      '';
    };

    prometheus.exporters.node.enable = lib.mkDefault true;
  };
}
