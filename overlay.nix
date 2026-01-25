final: prev: {
  godot-start = prev.callPackage ./. {
    inherit (prev.stdenv.hostPlatform) system;
  };
}
