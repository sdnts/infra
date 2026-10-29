# Nix is many things, but in the context of flakes (and this repository), Nix is a generic build system that can
# download, compile, install and manage dependencies for any arbitrary software. It is akin to `make` (in that it isn't
# tied to a specific programming language or ecosystem), but it is a lot more opinionated and pedantic. Nix itself
# doesn't build / compile anything, but you can use it to define a workflow that invokes other tools (like `cargo`, `gcc`
# or anything else) in a way that guarantees reproducibility. It does so by pinning exact versions of dependencies,
# dependencies of dependencies, and so on all the way to the bottom. This way, a specific version of `cargo` is always
# building a specific version of an app's code, using very specific versions of `gcc`, `glibc` etc. You end up with
# identical artifacts every time, which everyone in the Nix ecosystem is very obsessed with.
#
# A flake is a standardized way to define the build graph (aka what to build, how to build it, what it depends on, what
# the dependencies depend on etc.) for the Nix build system. Flakes are a relatively recent feature in the Nix world,
# and while they are still considered experimental, they are fairly stable and MUCH more modern and approacahable.
#
# You can use flakes to describe (declaratively, reproducibly) how to build your app, libraries, shell environments, or
# even entire "systems" (much more on this later). Flakes are written in the Nix programming language, which can feel
# esoteric if you haven't written a functional programming language before, but you can get started with very little.
#
# Flakes have a fixed schema. They're expected to be an attribute set with exactly 3 attributes: `description` (optional),
# `inputs`, and `outputs`.
{
  # `inputs` declare any other flakes that this flake needs to build its outputs. This flake configures a few NixOS
  # and macOS systems, that each run useful services for my home lab, so it has quite a few inputs.
  # `inputs` is expected to be an attribute set. Each attribute defines how to fetch that input (ususally a GitHub repo,
  # but it doesn't have to be). When you first build this flake, Nix will download the contents of this repo, calculate
  # a hash, and generate a `flake.lock` file that pins the input to a specific commit.
  inputs = {
    # `nixpkgs.url = "something"` is shorthard for `nixpkgs = { url = "something"; };`
    # The `github:nixos/nixpkgs/nixos-stable` string is also shorthand for the full Github URL:
    # 1. `github:` says the URL is a Github repo
    # 2. `nixos/nixpkgs` is the repo name
    # 3. `nixos-unstable` is the branch name. If you omit this, Nix downloads the default branch (usually main / master)
    #
    # This input asks the build system to fetch this GitHub repo, evaluate it (parse it as Nix data structures) and
    # assign the result of the eval to a variable called `nixpkgs`. We'll be able to use this variable in our `outputs`
    # later.
    #
    # `nixpkgs` is probably the most common input you'll see. It is a ginormous flake with just about every package
    # under the sun. You can search through them all here: https://search.nixos.org/packages
    # nixpkgs is constantly updated. New packages are added, existing ones are updated, and they've got a test suite that
    # runs continuously. The `master` branch is the absolute bleeding edge of all packages. You generally don't want to
    # depend on it though because broken packages end up there all the time. The `nixos-unstable` branch is the latest,
    # tested branch. It can lag behind the `master` branch by a few days. Twice a year, a "stable" branch is cut from
    # the `nixos-unstable` branch, named `nixos-26.05` (20256, May) or `nixos-25.11` (2025, November) or such. These
    # branches contain battle-tested versions of packages.
    # Most hobbyists tend to use the `nixos-unstable` branch to get the latest versions of packages. More serious
    # production use-cases might warrant using the "stable" channel instead.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Some packages decide to not publish to nixpkgs, or maintain their own flake that builds absolute latest version.
    # The size and centralization of the nixpkgs repo makes this option attractive.
    agenix.url = "github:ryantm/agenix";
    copyparty.url = "github:9001/copyparty";
    darwin = {
      # This input is a little more special. In addition to the `url`, it also says that this flake should not bring in
      # its own version of `nixpkgs`, but should instead use the version from the `nixpkgs` input in OUR flake. This can
      # be a little unstable at times because `nix-darwin` was likely tested against a specific version of nixpkgs that
      # does not match our version, but in practice it is mostly fine.
      # Doing this helps with performance because Nix doesn't have to build multiple versions of common packages.
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy.url = "github:serokell/deploy-rs";
    disko.url = "github:nix-community/disko";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    pi.url = "github:earendil-works/pi/stable";
    rex.url = "https://pkgs.superlogical.com/rex/nix/snapshot.tar.gz";
  };

  # `outputs` declare what this flake builds. It is a Nix function that gets all inputs as arguments, and it is expected
  # to return an attribute set. Each attribute in this set is an output. You'll also see outputs called "derivations".
  outputs =
    inputs@{
      self,
      nixpkgs,
      deploy,
      darwin,
      ...
    }:
    {
      # In our case, the only output is a derivation called `deploy` that the deploy-rs CLI uses to push configuration
      # to our NixOS and macOS machines over SSH. `deploy-rs` is one of many tools you can use to remotely manage and
      # deploy configuration and services to all your machines. I use it over Colmena mostly because it allows me to
      # manage darwin (macOS) systems.
      deploy = {
        # This tells deploy-rs to build this configuration on the remote machine instead of locally. It's useful to
        # realize that if you can build a binary with the right versions of all dependencies, "installing" that binary
        # really only just means copying it to some location. This location might be your own machine, or some other
        # machine on the other side of the planet (assuming it has the same processor architecture). So for example, you
        # can build the Zig compiler on your own MacBook, then copy it over to some other macOS machine, and it'll jsut
        # work (assuming any dynamically linked libraries exist in the right locations). If you describe this build
        # correctly in a flake (meaning you tell Nix that you depend on libraries X, Y and Z), Nix can make sure the
        # right versions of those libraries exist at the right locations. This was a real unlock for me. "Local builds"
        # are not magic!
        remoteBuild = true;
        # deploy-rs calls machines "nodes". Inside the `nodes` attr set, I'm describing what I want the configuration of
        # each machine to look like
        nodes = {
          # MacBook Air
          hq = {
            # The hostname deploy-rs will SSH into to deploy this configuration. All my nodes run Tailscale, so I have
            # these pretty hostnames instead of IP addresses.
            hostname = "hq";
            # The user deploy-rs will SSH as
            sshUser = "sdnts";
            # Disabling remoteBuild for this specific node because I use my MacBook to deploy to every other node.
            # Remote is the same as local here.
            remoteBuild = false;
            # Required workaround for https://github.com/serokell/deploy-rs/pull/404
            magicRollback = false;
            # Profiles are a collection of packages that are symlinked from the Nix store. You can use profiles to
            # install a set of packages with specific versions all in one command. The act of doing so is called
            # "activating" a profile. In my case I only have a single profile that defines my entire system. It installs
            # the right packages, sets up my home directory, my shell, secrets, everything.
            profiles.system = {
              # Profiles can be activated by specific users. When you do that, the packages in that profile are only
              # available to that user. In my case because I'm using this profile to configure the entire system, I need
              # to activate it as root so I have the right priveleges.
              user = "root";
              interactiveSudo = true;
              # This is the fun stuff. I'm calling a function called `deploy.lib.aarch64-darwin.activate.darwin` that
              # activates a profile. I'm in turn building that profile by calling the `darwin.lib.darwinSystem` function.
              # The configuration of the system is in the `./nodes/hq/default.nix` file, and `inputs` are forcefully
              # injected into the hq module.
              path = deploy.lib.aarch64-darwin.activate.darwin (
                darwin.lib.darwinSystem {
                  system = "aarch64-darwin";
                  modules = [ ./nodes/hq ];
                  specialArgs = { inherit inputs; };
                }
              );
            };
          };

          # The remaining nodes are very similar. Some are macOS, others are NixOS.

          # Mac mini
          mainframe = {
            hostname = "mainframe";
            sshUser = "root";
            magicRollback = false;
            profiles.system.path = deploy.lib.aarch64-darwin.activate.darwin (
              darwin.lib.darwinSystem {
                system = "aarch64-darwin";
                modules = [ ./nodes/mainframe ];
                specialArgs = { inherit inputs; };
              }
            );
          };

          # VPS (Mythic Beasts)
          bastion = {
            hostname = "bastion";
            sshUser = "root";
            profiles.system.path = deploy.lib.x86_64-linux.activate.nixos (
              nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ ./nodes/bastion ];
                specialArgs = { inherit inputs; };
              }
            );
          };

          # NAS (Zima Board)
          vault = {
            hostname = "vault";
            sshUser = "root";
            profiles.system.path = deploy.lib.x86_64-linux.activate.nixos (
              nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ ./nodes/vault ];
                specialArgs = { inherit inputs; };
              }
            );
          };

          # VPS (Hetzner)
          sentry = {
            hostname = "sentry";
            sshUser = "root";
            profiles.system.path = deploy.lib.x86_64-linux.activate.nixos (
              nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ ./nodes/sentry ];
                specialArgs = { inherit inputs; };
              }
            );
          };
        };
      };
    };
}
