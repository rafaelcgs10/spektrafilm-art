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
  # Import nixpkgs with our overlay that adds custom Python packages
  spektrafilm-pkgs = import pkgs.path {
    inherit (pkgs) system;
    config = { allowBroken = true; };
    overlays = [
      (final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            colour-science = python-final.callPackage ./pkgs/spektrafilm/colour-science.nix { };
            pyfftw = python-final.callPackage ./pkgs/spektrafilm/pyfftw.nix {
              inherit (final) fftw;
            };
            openimageio = python-final.callPackage ./pkgs/spektrafilm/openimageio.nix {
              inherit (final)
                fftw zlib imath openexr libjpeg libtiff libpng
                openimageio freetype opencolorio opencv libraw libheif
                mesa libgbm libglvnd giflib ffmpeg openjph libwebp robin-map
                cmake ninja;
              inherit (final) qt6;
            };
            spektrafilm = python-final.callPackage ./pkgs/spektrafilm/spektrafilm.nix {
              inherit (final) makeWrapper;
              qt5 = final.libsForQt5.qt5;
            };
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
  overlays = import ./overlays; # nixpkgs overlays

  spektrafilm = spektrafilm-pkgs.python3Packages.spektrafilm;
}
