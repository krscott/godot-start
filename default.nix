{
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  name = "godot-start";
  src = lib.cleanSource ./.;
}
