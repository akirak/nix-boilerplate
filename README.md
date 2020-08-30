This is a repository boilerplate for Nix projects.

![CI](https://github.com/akirak/nix-boilerplate/workflows/CI/badge.svg)

## Features

It initializes a project structure with the following setup:

- [niv](https://github.com/nmattia/niv)
- [gitignore.nix](https://github.com/hercules-ci/gitignore.nix)
- [pre-commit-hooks.nix](https://github.com/cachix/pre-commit-hooks.nix)

## Usage

- You can use `nix-build` to create a store which contains a minimal set of configuration files.
- You can use `nix-boilerplate.el` in this repository to copy files from the store to a directory.

## Resources

Inspired by Damien Cassou's [nix-hello-world](https://github.com/DamienCassou/nix-hello-world).
