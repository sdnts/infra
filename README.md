# infra

These are my personal configurations for all my macOS & NixOS machines. While this flake is likely not re-usable as-is,
the comments in it might be educational to fellow Nix nerds.

## Modules

- The `lib` module contains common, overridable configuration for [NixOS](./lib/nixos.nix) and [macOS](./lib/darwin.nix)
  hosts. It also sets up [home-manager](https://github.com/nix-community/home-manager) to manage my dotfiles and user
  packages. It groups common configurations using "roles".
- The `nodes` module contains configurations for each machine. These import `lib`, and only define overrides or
  additional configuration.
- `dots` is not a Nix module. It is a stash for my (opinionated) dotfiles. Depending on a node's role, these dotfiles
  are either copied over into the Nix store and symlinked from there, or directly from a checkout of this repository.
- `secrets` is not a NixOS module. It is a stash for all (age-encrypted) secrets. These are decrypted and expanded into
  my shell when [deploy-rs](https://github.com/serokell/deploy-rs) activates the `system` profile.

## Deployment

The `deploy-rs` CLI is installed on all nodes with the `hq` role. From such a node, running `deploy .` deploys all
profiles across all nodes. Use `deploy .#<name>` to deploy all profiles to a specific node only (for example: `deploy .#bastion`)

## dotfiles

This directory has configurations for various tools I use. These are symlinked to the right location during profile
activation. On nodes with the `hq` roles, these are symlinked directly to a local checkout of this repository to allow
quick changes without constant re-reployment. On all other nodes, these are copied to the nix store and symlinked out of
there.

## Secrets Management

All secrets are encrypted with [age](https://github.com/FiloSottile/age) and managed using [agenix](https://github.com/ryantm/agenix).

`age` / `agenix` use SSH keys to encrypt and decrypt secrets. SSH keys for all nodes is defined in an [Identities file](./identity.nix).
These identities are set up to be copied to the right nodes. They control who can encrypt and / or read secrets. In 
general, HQ is always included, since I create secrets using HQ's SSH key. Nodes that receive these secrets are also
included so they can read the secret during deploy-rs' profile activation. For example, I run nginx in the Bastion node,
so the `nginx.age` secret is encrypted with both HQ and Bastion's keys.

### Creating new secrets

The `agenix` CLI is installed on all nodes with the `hq` role. As such, only these nodes are able to create secrets:
1. Define what (SSH) public keys should be used for this secret. In [agenix-rules.nix](./agenix-rules.nix), add an
   attribute for this secret.
2. Run `agenix -e secrets/<name>.age` to open up an editor where you can set this secret's value.
3. Define this secret in the node that wants to use it, using the `age.secrets` option in NixOS / `nix-darwin`. Ideally
   put this definition next to the service that wants to use it (for example, the `nginx.age` secret is defined in
   [nginx's service module](./nodes/bastion/services/nginx.nix))

### Updating existing secrets

Run `agenix -e secrets/<name>.nix` from a node whose SSH public key is allowed to decrypt / encrypt it. Ideally do this
from an `hq` node.
