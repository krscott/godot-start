{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (
      system:
      let
        localOverlay = import ./overlay.nix;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ localOverlay ];
        };

        devPkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # required for aseprite
        };

        baseDevShell = devPkgs.mkShellNoCC {
          buildInputs = with devPkgs; [
            (callPackage ./nix/install-export-templates.nix { })
            godot_4
            python3
            steam-run-free
            zip
          ];

          shellHook = ''
            PATH="$PATH:$PWD/scripts"
          '';
        };

        mkArchive =
          preset:
          pkgs.godot-start.override {
            inherit preset;
            archive = true;
          };

      in
      {
        packages = {
          inherit (pkgs) godot-start;
          default = pkgs.godot-start;
          web = pkgs.godot-start.override { preset = "Web"; };
          debug = pkgs.godot-start.override { debug = true; };

          linux-archive = mkArchive "Linux";
          macos-archive = mkArchive "macOS";
          windows-archive = mkArchive "Windows Desktop";
          web-archive = mkArchive "Web";
        };

        devShells = {
          default = baseDevShell;

          full = baseDevShell.overrideAttrs (oldAttrs: {
            buildInputs =
              oldAttrs.buildInputs
              ++ (with devPkgs; [
                aseprite # Requires large local build
              ]);
          });
        };

        formatter = pkgs.nixfmt;
      }
    );
}
