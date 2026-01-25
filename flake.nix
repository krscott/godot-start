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

      in
      {
        # packages = {
        # };

        devShells = {
          default = devPkgs.mkShellNoCC {
            buildInputs = with devPkgs; [
              (callPackage ./scripts/install-export-templates.nix { })
              godot_4
              aseprite
              python3
              steam-run-free
              zip
            ];

            shellHook = ''
              PATH="$PATH:$PWD/scripts"
            '';
          };
        };

        formatter = pkgs.nixfmt;
      }
    );
}
