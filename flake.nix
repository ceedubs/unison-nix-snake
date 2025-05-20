{
  description = "Examples of building a Unison program with Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
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
        pkgs = import nixpkgs {
          inherit system;
          overlays = [unison-nix.overlay];
        };
      in rec {
        packages = {
          # A simple example: create an executable from a Unison Share project
          snake = pkgs.buildUnisonShareProject {
            pname = "snake";
            version = "0.0.1";
            userHandle = "runarorama";
            projectName = "terminus";

            # The compiledHash is the hash of the compiled Unison code. This
            # is needed because Nix builds restrict network access unless the
            # output hash is known ahead of time (which helps with
            # reproducibility and caching). You won't know it until you run
            # the derivation for the first time. You can just set this to
            # `pkgs.lib.fakeHash` and do a `nix build` or `nix run` and copy
            # the hash labeled `got: `.
            compiledHash = "sha256-xRjeGswzLLKxPoxHu0hsQzqr7y+1YK0YSXHJSYLb1mo=";

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
