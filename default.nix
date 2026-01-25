{
  preset ? "Linux",
  archive ? false,

  callPackage,
  lib,
  stdenvNoCC,

  fontconfig,
  godot_4,
  steam-run-free,
}:
let
  strIf = b: flag: if b then flag else "";
  arrIf = b: arr: if b then arr else [ ];

  # NixOS and Web builds require wrapper
  wrapper = (preset == "Linux" || preset == "Web") && !archive;
in
stdenvNoCC.mkDerivation {
  name = "godot-start";
  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    godot_4
    (callPackage ./scripts/install-export-templates.nix { })
  ];

  buildInputs = arrIf wrapper [ steam-run-free ];

  buildPhase = ''
    TMPDIR="''${TMPDIR:-/tmp}"
    export HOME="$TMPDIR/home"
    export FONTCONFIG_FILE=${fontconfig.out}/etc/fonts/fonts.conf
    export FONTCONFIG_PATH=${fontconfig.out}/etc/fonts/
    install-export-templates
    ./scripts/bld ${preset} ${strIf archive "-a"} ${strIf wrapper "-w"}
  '';

  installPhase =
    if archive then
      ''
        mkdir -p $out/share
        mv build/* $out/share
      ''
    else
      ''
        mkdir -p $out/bin
        mv build/* $out/bin
      '';

  meta = {
    mainProgram = "godot-start";
    # description = "A short description of my application";
    # homepage = "https://github.com";
    # license = lib.licenses.mit;
  };
}
