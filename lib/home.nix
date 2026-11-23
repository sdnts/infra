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

  homeDirectoryBehaviour = config.infra.home;
in
{
  age.secrets = {
  };

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
      ]
      ++ lib.optionals isServer [ ]
      ++ lib.optionals isTTY [
        pkgs.cargo
        pkgs.hexyl
        pkgs.git
        pkgs.jujutsu
        pkgs.nodejs
        pkgs.zig
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
        pkgs.zls
        # Formatters
        pkgs.nixfmt
        pkgs.stylua
        # Neovim Support
        pkgs.tree-sitter
        pkgs.ripgrep

        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.deploy.packages.${pkgs.stdenv.hostPlatform.system}.default

        pkgs.nodejs
        pkgs.pnpm
        inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      home.file =
        lib.genAttrs
          [
            ".config/fish/config.fish"
            ".config/git/config"
            ".config/hunk/config.toml"
            ".config/jj/config.toml"
            ".config/nvim"
            ".config/posting/config.yaml"
            ".config/rex"
            ".config/ssh/config"

            ".pi/agent/extensions/draw"
            ".pi/agent/extensions/keys"
            ".pi/agent/extensions/omlx"
            ".pi/agent/extensions/prompt"
            ".pi/agent/extensions/webshot"
            ".pi/agent/skills"
            ".pi/agent/APPEND_SYSTEM.md"
            ".pi/agent/keybindings.json"
            ".pi/agent/mcp.json"
            ".pi/agent/models.json"
            ".pi/agent/settings.json"

            ".clickhouse-cli.rc"
            ".npmrc"
          ]
          (path: {
            source = lib.mkDefault (
              # If requested, symlink dotfiles directly to a local checkout of this repo.
              # This allows me to make changes and have them reflect instantly, without having to redeploy.
              if homeDirectoryBehaviour == "symlink" then
                config.lib.file.mkOutOfStoreSymlink "/Users/sdnts/Code/infra/home/${path}"
              else
                # Otherwise, copy the dotfiles to the Nix store and symlink from there. This protects me from
                # accidentally breaking things.
                ../home + "/${path}"
            );
            recursive = lib.mkForce true;
          });
    };
  };
}
