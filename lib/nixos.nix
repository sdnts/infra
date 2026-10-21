# This module is used to configure NixOS machines. NixOS and macOS are differnet enough that I'd like to keep these
# configurations separate, even if I have to repeat myself a bit.
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
    inputs.agenix.nixosModules.default
    inputs.copyparty.nixosModules.default
    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.default
    inputs.nixos-facter-modules.nixosModules.facter
  ];

  nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

  nix = {
    optimise.automatic = lib.mkDefault true;
    settings = {
      download-buffer-size = lib.mkDefault 536870912;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = lib.mkDefault false;
    };
    gc = {
      options = lib.mkDefault "--delete-older-than 14d";
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
    };
  };

  boot.tmp.cleanOnBoot = lib.mkDefault true;
  programs.fish.enable = lib.mkForce true;
  programs.mosh.enable = lib.mkDefault true;
  virtualisation.oci-containers.backend = lib.mkDefault "docker";

  networking = {
    networkmanager.enable = lib.mkDefault true;
    firewall = {
      allowedUDPPorts = [ ];
      allowedTCPPorts = [ ];
    };
    firewall.trustedInterfaces = [ "docker0" ];
  };

  users.users.root = {
    shell = lib.mkForce pkgs.fish;
    openssh.authorizedKeys.keys = lib.mkForce [
      identity.hq.ssh.users.sdnts.publicKey
    ];
  };
  users.users.sdnts = {
    shell = lib.mkForce pkgs.fish;
    isNormalUser = lib.mkForce true;
    extraGroups = lib.mkForce [ "wheel" ];
    openssh.authorizedKeys.keys = lib.mkForce [
      identity.hq.ssh.users.sdnts.publicKey
    ];
  };

  # `home.nix` already installs a bunch of packages, so list packages here that are nixos-specific.
  home-manager.users.sdnts.home.packages = [

  ]
  ++ lib.optionals isServer [ pkgs.nethogs ]
  ++ lib.optionals isTTY [ ]
  ++ lib.optionals isHQ [ ];

  services = {
    openssh = {
      enable = lib.mkForce true;
      settings.PasswordAuthentication = lib.mkForce false;
      settings.PermitRootLogin = lib.mkForce "prohibit-password";
    };
    journald.settings.Journal = {
      SystemMaxUse = lib.mkDefault "500M";
      MaxRetentionSec = lib.mkDefault "7day";
    };
    tailscale.enable = lib.mkForce true;
    prometheus.exporters.node.enable = lib.mkForce true;
  };
}
