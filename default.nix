# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  spektrafilm-python = import ./pkgs/spektrafilm/python-runtime.nix;
  spektrafilm-pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/25.05.tar.gz";
  }) {
    config.allowBroken = true;
    overlays = [
      (final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            colour-science = import ./pkgs/spektrafilm/colour-science.nix { pkgs = final; };
            pyfftw = import ./pkgs/spektrafilm/pyfftw.nix { pkgs = final; };
            openimageio = import ./pkgs/spektrafilm/openimageio.nix { pkgs = final; };
            spektrafilm = import ./pkgs/spektrafilm/spektrafilm.nix { pkgs = final; };
          })
        ];
      })
    ];
  };
in
{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  spektrafilm = spektrafilm-pkgs.python3Packages.spektrafilm;
  # example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
