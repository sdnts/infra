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
    inputs.rex.nixosModules.default
  ];

  nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

  age.secrets = {
    netrc.file = ../secrets/netrc.age;
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Rex's Linux server requires a secret that's supplied via /etc/netrc
      netrc-file = lib.mkDefault config.age.secrets.netrc.path;
      download-buffer-size = lib.mkDefault 536870912;
      warn-dirty = lib.mkDefault false;
    };
    optimise.automatic = lib.mkDefault true;
    gc = {
      options = lib.mkDefault "--delete-older-than 14d";
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
    };
  };

  boot.tmp.cleanOnBoot = lib.mkDefault true;
  programs.fish.enable = lib.mkForce true;
  virtualisation.oci-containers.backend = lib.mkDefault "docker";

  networking = {
    networkmanager.enable = lib.mkDefault true;
    firewall = {
      allowedUDPPorts = [ ];
      allowedTCPPorts = [ ];
    };
    firewall.trustedInterfaces = [ "docker0" ];
  };

  users.users.sdnts = {
    shell = lib.mkForce pkgs.fish;
    isNormalUser = lib.mkForce true;
    extraGroups = lib.mkForce [ "wheel" ];
    # SSH is controlled by Tailscale policies, so no `authorizedKeys` here!
  };

  # `home.nix` already installs a bunch of packages, so list packages here that are nixos-specific.
  home-manager.users.sdnts.home.packages = [

  ]
  ++ lib.optionals isServer [ pkgs.nethogs ]
  ++ lib.optionals isTTY [ ]
  ++ lib.optionals isHQ [ ];

  services = {
    # SSH access is controlled by Tailscale, but age requires sshd running
    openssh = {
      enable = lib.mkForce true;
      settings.PasswordAuthentication = lib.mkForce false;
      settings.PermitRootLogin = lib.mkForce "prohibit-password";
    };
    journald.settings.Journal = {
      SystemMaxUse = lib.mkDefault "500M";
      MaxRetentionSec = lib.mkDefault "7day";
    };
    rex.loginServer = {
      enable = true;
      tailscaleServe.enable = true;
      accounts.sdnts.principals = [ "tailscale:sdnts@github" ];
    };
    tailscale.enable = lib.mkForce true;
    prometheus.exporters.node.enable = lib.mkForce true;
  };
}
