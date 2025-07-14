{
  description = "QML widget shell helper.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    quickshell,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({config, ...}: {
      systems = ["x86_64-linux"];

      perSystem = {
        config,
        inputs',
        system,
        ...
      }: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        devShells.default = pkgs.mkShell rec {
          packages = [
            inputs'.quickshell.packages.default
            pkgs.kdePackages.qtdeclarative
            pkgs.nushell
          ];

          QMLLS_BUILD_DIRS = "${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml/:${inputs'.quickshell.packages.default}/lib/qt-6/qml/";
          QML2_IMPORT_PATH = QMLLS_BUILD_DIRS;

          SHELL = "${pkgs.nushell}/bin/nu";
          shellHook = ''
            #! /usr/bin/env nu
          '';
        };
      };
    });
}
