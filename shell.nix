let
  pkgs = import ./nix/pinned-pkgs.nix;
  pre-commit = import ./nix/pre-commit.nix;
in
pkgs.mkShell {
  shellHook = pre-commit.shellHook;
}
