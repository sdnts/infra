{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  isServer = builtins.elem "server" config.infra.roles;
  isTTY = builtins.elem "tty" config.infra.roles;
  isHQ = builtins.elem "hq" config.infra.roles;
in
{
  age.secrets = {
    exa = {
      file = ../secrets/exa.age;
      owner = "sdnts";
    };
  };

  programs.fish.shellInit = ''
    if status is-interactive; and test "$USER" = sdnts
      if test -r ${config.age.secrets.exa.path}
        source ${config.age.secrets.exa.path}
      end
    end
  '';

  home-manager = {
    useGlobalPkgs = lib.mkDefault true;
    useUserPackages = lib.mkDefault true;

    backupFileExtension = lib.mkForce "hm-backup";
    users.sdnts = { config, ... }: {
      home.packages = [
        pkgs.btop
        pkgs.curl
        pkgs.dig
        pkgs.eza
        pkgs.vim

        pkgs.nodejs
        pkgs.pnpm
        inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.default
      ]
      ++ lib.optionals isServer [ ]
      ++ lib.optionals isTTY [
        pkgs.cargo
        pkgs.hexyl
        pkgs.git
        pkgs.jujutsu
        pkgs.mosh
        pkgs.nodejs
        pkgs.nushell
        pkgs.zoxide

        pkgs.neovim
        # Language Servers
        pkgs.astro-language-server
        pkgs.fish-lsp
        pkgs.gopls
        pkgs.lua-language-server
        pkgs.nixd
        pkgs.pyright
        pkgs.tailwindcss-language-server
        pkgs.taplo
        pkgs.typescript
        pkgs.vscode-langservers-extracted
        pkgs.yaml-language-server
        # Formatters
        pkgs.nixfmt
        pkgs.nufmt
        pkgs.stylua
        # Neovim Support
        pkgs.tree-sitter
        pkgs.ripgrep
      ]
      ++ lib.optionals isHQ [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.deploy.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      xdg.configFile =
        lib.genAttrs
          [
            "fish"
            "git"
            "hunk"
            "jj"
            "nvim"
            "posting"
            "rex"
            "ssh"
          ]
          (path: {
            source = lib.mkDefault (
              if isHQ then
                # For nodes with the `hq` role, I want to symlink dotfiles directly to a local checkout of this repo.
                # This allows me to make changes and have them reflect instantly, without having to redeploy.
                config.lib.file.mkOutOfStoreSymlink "/Users/sdnts/Code/infra/dots/${path}"
              else
                # On all other nodes, I want to copy the dotfiles to the Nix store and symlink from there. This protects
                # me from accidentally breaking things.
                ../dots + "/${path}"
            );
            recursive = lib.mkForce true;
          });

      home.file.".clickhouse-cli.rc".source = lib.mkDefault (
        if isHQ then
          # Same here, symlink to a local checkout of this repo, if this is a node with the `hq` role.
          config.lib.file.mkOutOfStoreSymlink "/Users/sdnts/Code/infra/dots/clickhouse-cli/.clickhouse-cli.rc"
        else
          # Otherwise symlink from the Nix store.
          ../dots/clickhouse-cli/.clickhouse-cli.rc
      );
      home.file.".npmrc".source = lib.mkDefault (
        if isHQ then
          config.lib.file.mkOutOfStoreSymlink "/Users/sdnts/Code/infra/dots/npm/.npmrc"
        else
          ../dots/npm/.npmrc
      );
      home.file.".pi" = {
        source = lib.mkDefault (
          if isHQ then
            config.lib.file.mkOutOfStoreSymlink "/Users/sdnts/Code/infra/dots/pi"
          else
            pkgs.lib.cleanSourceWith {
              src = ../dots/pi;
              filter = path: type: baseNameOf path != "node_modules";
            }
        );
        recursive = lib.mkForce true;
      };
    };
  };
}
