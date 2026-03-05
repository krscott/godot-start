# godot-start Codebase Summary

An opinionated Godot 4.5 project template with batteries included: cross-platform Nix builds, quicksave/quickload, input replay, and a pause menu system.

---

## Project Structure Overview

```
godot-start/
├── project/           # Godot game source
├── nix/               # Nix build helpers
├── scripts/           # Build & utility scripts
├── assets/            # Color palettes
├── flake.nix          # Nix flake entry point
├── default.nix        # Main derivation
├── overlay.nix        # Nixpkgs overlay
└── init-template.sh   # Template initialization script
```

---

## Major Components

### 1. Nix Build System

The project uses Nix flakes for reproducible, cross-platform builds.

| File | Purpose |
|------|---------|
| `flake.nix` | Defines inputs (nixpkgs, flake-utils), dev shells, and export packages for Linux, macOS, Windows, and Web |
| `default.nix` | Main derivation that invokes the `bld` script with Godot headless export |
| `overlay.nix` | Adds `godot-start` package to nixpkgs, auto-detecting platform preset |
| `nix/install-export-templates.nix` | Helper script to symlink Godot export templates into the expected location |

**Build Targets:**
- `nix build` — Default platform (Linux/macOS based on host)
- `nix build .#web` / `.#windows` — Cross-platform exports
- `nix build .#linux-archive` / `.#web-archive` — Zipped archives

**Dev Shells:**
- `default` — Godot, Python, steam-run, zip
- `full` — Adds Aseprite (requires unfree)

---

### 2. Game State & Save System

**`project/scenes/game_state.gd`** — Central autoload singleton managing:

- **Quicksave/Quickload** — Press `[` to save, `]` to load. State is serialized via `GdSerde`.
- **Replay System** — Records and plays back player input frames.
- **Pause Menu** — Escape opens menu; handles continue, load replay, quit.
- **State Synchronization** — Objects register with `sync_state(key, obj)` to participate in save/load.

**Signals:**
- `savedata_saving` — Emitted before serialization
- `savedata_loaded` — Emitted after deserialization

---

### 3. Serialization (`GdSerde`)

**`project/scripts/gdserde.gd`** — Custom serialization framework for Godot objects.

**How it works:**
1. Objects declare `gdserde_class` (cache key) and `gdserde_props` (list of property names to serialize)
2. `serialize_object(obj)` → Dictionary
3. `deserialize_object(obj, dict)` → Restores state

**Example usage:**
```gdscript
class_name FreeCam
const gdserde_class := &"FreeCam"
const gdserde_props := [&"transform"]
```

Objects can also implement custom `gdserde_serialize()` / `gdserde_deserialize()` methods.

---

### 4. Input & Replay System

| Script | Role |
|--------|------|
| `player_input.gd` | Captures WASD movement, mouse look, sprint/crouch/jump. Serializable for replay. |
| `replay.gd` | Records frames during gameplay, saves/loads `.dat` files, plays back input. |

**Replay Flow:**
1. During play, `request_frame` signal triggers `PlayerInput` serialization
2. On replay, `load_frame` signal deserializes each frame back into `PlayerInput`
3. CLI: Pass replay file as argument to auto-play on launch

---

### 5. Pause System

**`project/scripts/pausing.gd`** — Simple pause controller that sets `get_tree().paused`.

- Uses `PROCESS_MODE_ALWAYS` to keep running while paused
- Syncs internal `paused` flag with scene tree each physics frame

---

### 6. Menu System

**`project/scenes/ui/menu.gd`** — Declarative menu builder.

```gdscript
menu.build([
    Menu.btn("Continue", _unpause, "ui_cancel"),
    Menu.btn("Load Replay", _replay_open_dialog),
    Menu.btn("Quit", _save_replay_and_quit),
])
```

- Buttons are created from templates defined in the scene
- Supports keyboard shortcuts via action bindings

---

### 7. Free Camera

**`project/scripts/free_cam.gd`** — Debug/spectator camera.

- Reads from `PlayerInput` for movement and look
- Supports base speed and sprint speed
- Serializable transform for save/load

---

### 8. Utility Scripts

**`project/scripts/util.gd`** — Static helper functions:
- `set_mouse_captured()` / `is_mouse_captured()`
- `aok(err)` — Assert on error
- `has_member(obj, name)` — Check if object has property
- `try_as_dict()` / `try_as_obj()` — Safe casting

**`project/scripts/system_dialog.gd`** — Native file dialog wrapper using async/await.

---

### 9. Shader System

**`project/shaders/palette-post.gdshader`** — Post-processing shader that quantizes colors to a fixed palette.

**`scripts/palette-shader`** — Generates the shader from a `.hex` palette file (one hex color per line).

**Included palettes** (`assets/palette/`):
- `midnight-ablaze.hex`
- `noire-truth.hex`

---

### 10. Build Scripts

| Script | Purpose |
|--------|---------|
| `scripts/bld` | Main build script. Exports Godot project with options for debug, wrapped (steam-run), and zip modes. |
| `scripts/fmt` | Formats all `.nix` files using `nix fmt` |
| `scripts/palette-shader` | Generates palette post-processing shader from hex file |

**`bld` usage:**
```bash
./scripts/bld [preset]           # Linux, macOS, Windows, Web
./scripts/bld -d Linux           # Debug build
./scripts/bld -z Web             # Create zip archive
./scripts/bld -w Linux           # Wrapped with steam-run
```

---

### 11. Template Initialization

**`init-template.sh`** — Renames the project throughout the codebase:

1. Replaces `godot-start` / `godot_start` / `godotstart` / `GODOTSTART` with new name
2. Removes the init script and LICENSE
3. Commits the changes

**Usage:**
```bash
./init-template.sh my_new_game
```

---

## Input Mappings

| Action | Default Key |
|--------|-------------|
| `move_forward` | W |
| `move_backward` | S |
| `move_left` | A |
| `move_right` | D |
| `jump` | Space |
| `crouch` | Ctrl |
| `sprint` | Shift |
| `quick_save` | `[` |
| `quick_load` | `]` |
| `quit` | `` ` `` (backtick) |

---

## Export Presets

Configured in `project/export_presets.cfg`:

| Preset | Platform | Architecture |
|--------|----------|--------------|
| Linux | Linux | x86_64 |
| macOS | macOS | Universal |
| Windows | Windows Desktop | x86_64 |
| Web | Web (HTML5) | — |

---

## Key Design Decisions

1. **Nix-first** — Reproducible builds across Linux, macOS, Windows, and Web
2. **Serialization by convention** — Objects opt-in via `gdserde_class` / `gdserde_props`
3. **Input replay** — Deterministic replay by recording `PlayerInput` state each physics frame
4. **Autoload pattern** — `GameState` is a global singleton managing all cross-cutting concerns
5. **Declarative menus** — Menu items defined as data, not scene nodes
