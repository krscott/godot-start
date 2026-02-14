# godot-start

My rather opinionated Godot project template.

To start a project with this template, run:
```
./init-template.sh new_project_name
```

## AI Use

This template does not contain the output of Generative AI.

This project is tagged `no-ai`, following the
[itch.io AI disclosure guidelines](https://itch.io/docs/creators/quality-guidelines#ai-disclosure)

This is to allow derivative projects to publish under a no-AI policy.
If AI is used in derivative projects, this section must be removed.

## Features

Batteries included. Delete what you don't want.

- Safe serialization/deserialization framework
- Quicksave (hotkey `[`) and Quickload (hotkey `]`)
- Player input replay system
- Pause menu
- Palette and dither screen shaders
- Cross-platform nix build

## Development

A nix env is provided, but purely optional.

Update dependencies
```
nix flake update
```

Start nix dev shell
```
nix develop
```

## Improvements

- Fix home-manager setup / support nixGL
  (see [1](https://github.com/NixOS/nixpkgs/issues/336400), [2](https://github.com/nix-community/home-manager/issues/3968))
