{ pkgs ? import <nixpkgs> {} }:
let
  # gitignoreSource = import ./nix/gitignore.nix;
  gitignoreFilter = (
    import (import ./nix/sources.nix)."gitignore.nix" {
      inherit (pkgs) lib;
    }
  ).gitignoreFilter;
  ignoredDirectories = [
    ".recipes"
    ".github/workflows"
  ];
  inDirectory = path: dir:
    (
      builtins.match
        (
          pkgs.lib.concatStringsSep
            ""
            [ ".+/" (builtins.replaceStrings [ "." ] [ "\\." ] dir) "(/..+)?" ]
        )
        (builtins.toString path) != null
    );
  f = path: type:
    (gitignoreFilter ./. path type)
    && ! (pkgs.lib.any (inDirectory path) ignoredDirectories)
    && ! builtins.elem (baseNameOf path)
      [
        "default.nix"
        "nix-boilerplate.el"
        "README.md"
      ];
in
pkgs.srcOnly {
  name = "nix-boilerplate";
  src = builtins.filterSource f ./.;
}