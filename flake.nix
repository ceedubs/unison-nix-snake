{
  description = "Examples of building a Unison program with Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    unison-nix.url = "github:ceedubs/unison-nix";
    unison-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    unison-nix,
  }:
    flake-utils.lib.eachSystem flake-utils.lib.defaultSystems
    (
      system: let
        pkgs = nixpkgs.legacyPackages.${system}.appendOverlays [
          unison-nix.overlays.default
        ];
      in rec {
        packages = {
          # A simple example: create an executable from a Unison Share project
          snake = pkgs.unison.lib.buildShareProject {
            pname = "snake";
            version = "0.0.4";
            userHandle = "runarorama";
            projectName = "terminus";

            # The compiledHash is the hash of the compiled Unison code. This
            # is needed because Nix builds restrict network access unless the
            # output hash is known ahead of time (which helps with
            # reproducibility and caching). You won't know it until you run
            # the derivation for the first time. You can just set this to
            # `pkgs.lib.fakeHash` and do a `nix build` or `nix run` and copy
            # the hash labeled `got: `.
            compiledHash = "sha256-6EnFUI5+9Zmyt7kDUjIvYR6q0Q4Ps5lNENZhghYuJJ0=";

            # A mapping of executable names to Unison functions.
            executables = {"snake" = "examples.snake.main";};
          };
        };

        apps = rec {
          # If your executable name isn't the same as your `pname`, you should also supply `name` argument below.
          snake = flake-utils.lib.mkApp {drv = packages.snake;};

          default = snake;
        };

        formatter = pkgs.alejandra;
      }
    );
}
