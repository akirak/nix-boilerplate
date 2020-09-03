{ pkgs ? import <nixpkgs> {} }:
let
  gitignoreFilter = (
    import (import ./nix/sources.nix)."gitignore.nix" {
      inherit (pkgs) lib;
    }
  ).gitignoreFilter;
  ignoredDirectories = [
    ".recipes"
    ".github/workflows"
  ];
  ignoredFiles = [
    "default.nix"
    "nix-boilerplate.el"
    "README.md"
    "test.bash"
  ];
  regexpQuotePath = builtins.replaceStrings [ "." ] [ "\\." ];
  inDirectory = path: dir:
    let
      pathRegexp = ".+/" + (regexpQuotePath dir) + "(/..+)?";
    in
      builtins.match pathRegexp (builtins.toString path) != null;
  toBeCopied = path: type:
    (gitignoreFilter ./. path type)
    && ! (pkgs.lib.any (inDirectory path) ignoredDirectories)
    && ! builtins.elem (baseNameOf path) ignoredFiles;
in
pkgs.srcOnly {
  name = "nix-boilerplate";
  src = builtins.filterSource toBeCopied ./.;
}
