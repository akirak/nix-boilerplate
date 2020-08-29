{ pkgs ? import <nixpkgs> {} }:
let
  # gitignoreSource = import ./nix/gitignore.nix;
  gitignoreFilter = (
    import (import ./nix/sources.nix)."gitignore.nix" {
      inherit (pkgs) lib;
    }
  ).gitignoreFilter;
  f = path: type:
    (gitignoreFilter ./. path type)
    && (builtins.match ".+/\.recipes(/..+)?" (builtins.toString path) == null)
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
