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

  age.secrets = {
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
  users.users.root.openssh.authorizedKeys.keys = lib.mkForce [
    identity.hq.ssh.users.sdnts.publicKey
  ];
  users.users.sdnts = {
    home = lib.mkForce "/Users/sdnts";
    shell = lib.mkForce pkgs.fish;
    openssh.authorizedKeys.keys = lib.mkForce [
      identity.hq.ssh.users.sdnts.publicKey
    ];
  };

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
    openssh = {
      enable = lib.mkForce true;
      extraConfig = lib.mkForce ''
        PubkeyAuthentication yes
        PasswordAuthentication no
        KbdInteractiveAuthentication no
        PermitRootLogin prohibit-password
      '';
    };
    tailscale.enable = lib.mkDefault true;
    prometheus.exporters.node.enable = lib.mkDefault true;
  };
}
