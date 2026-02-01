# godot-start

My rather opinionated Godot project template.

To start a project with this template, run:
```
./init-template.sh new_project_name
```

## Features

Batteries included. Delete what you don't want.

- Cross-platform nix build
- Quicksave/Quickload
- Player input replay
- Pause menu

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
