# Unison Nix Snake

This repository demonstrates using [unison-nix](https://github.com/ceedubs/unison-nix/) to easily package an app written in Unison.

[![asciicast](https://asciinema.org/a/6QgQOL7Wtw8hUAkNjt7RuEy2k.svg)](https://asciinema.org/a/6QgQOL7Wtw8hUAkNjt7RuEy2k)

## Running the app

```sh
nix run github:ceedubs/unison-nix-snake
```

If you are on an ARM-based Mac (M1, etc) you may need to run the following (since Unison doesn't yet release ARM builds):

```sh
nix run --system x86_64-darwin github:ceedubs/unison-nix-snake
```

The first time that you run this, it will take a while to pull the project from Share. But Nix will cache the result and subsequent runs should be nearly instantaneous.

## Packaging your own Unison app with Nix

Copy [flake.nix](flake.nix) and change the fields passed to `buildUnisonShareProject` as needed.

To start, set `compiledHash = pkgs.lib.fakeHash`. When you do a `nix run`, Nix will complain about the compiled hash not matching and will tell you the actual hash that you should use instead.
