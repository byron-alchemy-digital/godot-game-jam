# Godot 3D Game Development Project

## Project Overview

This is a **Godot 4.5 3D game project** following object-oriented design principles and component-based architecture. The project is designed for game jam development with scalable patterns.

## Tech Stack

- **Engine:** Godot 4.5 (Forward+ Renderer)
- **Language:** GDScript (primary), with C# optional for performance-critical systems
- **Rendering:** Forward+ 3D rendering pipeline
- **Physics:** Godot Physics 3D (Jolt optional for complex simulations)

## Project Structure

```
/
├── .claude/                    # Claude Code configuration
│   ├── skills/                 # Development skills and commands
│   └── settings.json           # Claude settings
├── assets/                     # Game assets
│   ├── models/                 # 3D models (.glb, .gltf, .obj)
│   ├── textures/               # Textures and materials
│   ├── audio/                  # Sound effects and music
│   ├── fonts/                  # Custom fonts
│   └── shaders/                # Custom shader files (.gdshader)
├── scenes/                     # Godot scene files (.tscn)
│   ├── main/                   # Main game scenes
│   ├── entities/               # Entity scenes (player, enemies, NPCs)
│   ├── environments/           # Level and environment scenes
│   ├── ui/                     # UI scenes
│   └── prefabs/                # Reusable prefab scenes
├── scripts/                    # GDScript code (.gd)
│   ├── autoload/               # Singleton/autoload scripts
│   ├── entities/               # Entity scripts
│   ├── components/             # Reusable component scripts
│   ├── systems/                # Game systems (inventory, dialogue, etc.)
│   ├── ui/                     # UI controller scripts
│   └── utils/                  # Utility classes and helpers
├── resources/                  # Godot resources (.tres, .res)
│   ├── data/                   # Game data resources
│   └── materials/              # Material resources
├── exports/                    # Build outputs (gitignored)
├── docs/                       # Documentation
│   └── DESIGN.md               # Design document
├── project.godot               # Godot project configuration
└── CLAUDE.md                   # This file
```

## Architecture Principles

### 1. Component-Based Design
- Entities are built from composable components
- Components are self-contained and reusable
- Prefer composition over inheritance
- Use signals for loose coupling between components

### 2. Object-Oriented Patterns
- **Single Responsibility:** Each class has one clear purpose
- **Open/Closed:** Classes are open for extension, closed for modification
- **Liskov Substitution:** Derived classes are substitutable for base classes
- **Interface Segregation:** Small, focused interfaces over large monolithic ones
- **Dependency Inversion:** Depend on abstractions, not concretions

### 3. Godot-Specific Patterns
- **Autoloads** for global state and services (GameManager, AudioManager, etc.)
- **Scenes as Classes** - treat scene files as reusable class instances
- **Signal-driven communication** between decoupled systems
- **Resource-based data** for game configuration and save data
- **Node composition** for building complex behaviors

## GDScript Conventions

### Naming Conventions
```gdscript
# Classes: PascalCase
class_name PlayerController

# Constants: SCREAMING_SNAKE_CASE
const MAX_SPEED := 10.0
const JUMP_FORCE := 15.0

# Variables: snake_case
var current_health: int = 100
var is_jumping: bool = false

# Private variables: prefix with underscore
var _internal_state: Dictionary = {}

# Signals: past tense, snake_case
signal health_changed(new_health: int)
signal died()

# Functions: snake_case, verb-first
func take_damage(amount: int) -> void:
    pass

# Private functions: prefix with underscore
func _calculate_knockback() -> Vector3:
    pass
```

### Type Hints (Required)
Always use static typing for better performance and code clarity:
```gdscript
var speed: float = 5.0
var player: CharacterBody3D = null
var enemies: Array[Enemy] = []

func get_health() -> int:
    return _health

func set_position(pos: Vector3) -> void:
    global_position = pos
```

### Documentation Standards
```gdscript
## Brief description of the class purpose.
##
## Extended description if needed. Explain the responsibility
## and how it fits into the larger system.
class_name EntityHealth
extends Node

## Emitted when health value changes.
signal health_changed(new_value: int, max_value: int)

## Maximum health points for this entity.
@export var max_health: int = 100

## Current health points.
var current_health: int:
    get:
        return _health
    set(value):
        _health = clampi(value, 0, max_health)
        health_changed.emit(_health, max_health)

var _health: int = 100


## Apply damage to this entity.
## Returns the actual damage dealt after modifiers.
func take_damage(amount: int, damage_type: String = "physical") -> int:
    var actual_damage := _calculate_damage(amount, damage_type)
    current_health -= actual_damage
    return actual_damage
```

## 3D Development Guidelines

### Node Hierarchy for 3D Entities
```
Entity (Node3D or CharacterBody3D)
├── Visual (Node3D) - Contains all visual elements
│   ├── Model (MeshInstance3D or imported scene)
│   └── Effects (GPUParticles3D, etc.)
├── Collision (CollisionShape3D)
├── Components (Node) - Component container
│   ├── HealthComponent
│   ├── MovementComponent
│   └── ...
├── Audio (AudioStreamPlayer3D)
└── UI (Node3D) - World-space UI elements
```

### Physics Layers (3D)
| Layer | Name          | Purpose                          |
|-------|---------------|----------------------------------|
| 1     | player        | Player character                 |
| 2     | enemies       | Enemy characters                 |
| 3     | environment   | Static world geometry            |
| 4     | interactables | Doors, switches, pickups         |
| 5     | projectiles   | Bullets, spells, thrown objects  |
| 6     | triggers      | Area triggers, detection zones   |
| 7     | navigation    | Navigation mesh obstacles        |
| 8     | ragdoll       | Ragdoll physics bodies           |

### Camera System
- Use a dedicated CameraController script
- Implement smooth follow with configurable parameters
- Support multiple camera modes (third-person, first-person, cinematic)
- Handle camera collision with environment

### Input Handling
- Define all inputs in project.godot Input Map
- Use Input.get_vector() for movement axes
- Handle input in _unhandled_input() for game actions
- Use _input() for UI interactions

## Common Commands

```bash
# Run project in editor
godot --path . --editor

# Run project
godot --path .

# Export for Windows
godot --headless --export-release "Windows Desktop" exports/game.exe

# Export for Linux
godot --headless --export-release "Linux/X11" exports/game.x86_64

# Export for Web
godot --headless --export-release "Web" exports/index.html
```

## Testing Guidelines

- Create test scenes in `scenes/test/` for isolated testing
- Use print_debug() for development logging
- Implement debug visualizations behind a DEBUG constant
- Test physics interactions in isolation before integration

## Performance Considerations

### 3D Optimization
- Use LOD (Level of Detail) for complex models
- Implement occlusion culling for indoor environments
- Batch static geometry where possible
- Use visibility notifiers to disable off-screen processing
- Pool frequently spawned objects (projectiles, particles)

### GDScript Performance
- Cache node references in _ready()
- Avoid get_node() in _process() or _physics_process()
- Use static typing everywhere
- Prefer built-in types over custom classes for hot paths

## Git Workflow

- Commit frequently with descriptive messages
- Use conventional commit format: `type(scope): description`
- Types: feat, fix, refactor, docs, style, test, chore
- Keep scenes and scripts in sync when committing

## Resources

- [Godot 4 Documentation](https://docs.godotengine.org/en/stable/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [3D Tutorial Series](https://docs.godotengine.org/en/stable/tutorials/3d/index.html)
