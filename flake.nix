{
  description = "Examples of building a Unison program with Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    unison-nix.url = "github:ceedubs/unison-nix";
    unison-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, unison-nix }:
    flake-utils.lib.eachSystem flake-utils.lib.defaultSystems
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ unison-nix.overlay ];
          };
        in
        rec {
          packages = rec {

            # A simple example: create an executable from a Unison Share project
            hello-server = pkgs.buildUnisonShareProject {
              pname = "hello-server";
              version = "3.0.2";
              userHandle = "unison";
              projectName = "httpserver";
              # The compiledHash is the hash of the compiled Unison code. This
              # is needed because Nix builds restrict network access unless the
              # output hash is known ahead of time (which helps with
              # reproducibility and caching). You won't know it until you run
              # the derivation for the first time. You can just set this to
              # `pkgs.lib.fakeHash` and do a `nix build` or `nix run` and copy
              # the hash labeled "got: `.
              compiledHash = "sha256-RyhyK36dYx2tla1aTq6VsyBdQWJJFaUNhnP0Kzz6Mf0=";
              executables = { "hello-server" = "example.main"; };
            };

            # A lower-level example: create executables from a Unison transcript
            hello-world = pkgs.buildUnisonFromTranscript rec {
              pname = "hello-world";
              version = "0.0.1";

              src = builtins.toFile "pull-and-compile-${pname}-${version}.md" ''
                ```ucm
                .> project.create-empty hello-world
                hello-world/main> pull @unison/base/releases/2.10.0 lib.base_2_10_0
                ```

                ```unison
                main = do
                  printLine "Hello, world!"

                greet = do
                  printLine "What is your name?"
                  name = !readLine
                  printLine ("Hello, " ++ name ++ "!")
                ```

                ```ucm
                hello-world/main> add
                hello-world/main> compile main hello-world
                hello-world/main> compile greet greet
                ```
              '';

              compiledHash = "sha256-LomYouMzvhjtUNPzmucgr0talrC9YdAGFy0aCdnyW6w="; 
            };
          };

          apps = rec {
            hello-server = flake-utils.lib.mkApp { drv = packages.hello-server; };

            hello-world = flake-utils.lib.mkApp { drv = packages.hello-world; };

            greet = flake-utils.lib.mkApp {
              drv = packages.hello-world;
              name = "greet";
            };

            default = greet;
          };
        }
      );
}

