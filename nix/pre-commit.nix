let
  sources = import ./sources.nix;
  nix-pre-commit-hooks = import sources."pre-commit-hooks.nix";
  gitignoreSource = ./gitignore.nix;
in
nix-pre-commit-hooks.run {
  src = gitignoreSource ./.;
  excludes = [ "^nix/sources\.nix$" ];
  hooks = {
    ormolu.enable = true;
    hlint.enable = true;
    hpack.enable = true;
    nixpkgs-fmt.enable = true;
    nix-linter.enable = true;
    shellcheck.enable = true;
  };
}
