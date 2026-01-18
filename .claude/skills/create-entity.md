# Skill: Create 3D Entity

Creates a new 3D entity with proper component-based architecture.

## Usage
```
/create-entity <EntityName> [--type=<character|static|interactable|projectile>]
```

## Process

1. **Create the scene file** at `scenes/entities/<EntityName>.tscn`
2. **Create the script file** at `scripts/entities/<EntityName>.gd`
3. **Set up node hierarchy** based on entity type

## Entity Templates

### Character Entity (CharacterBody3D)
```gdscript
## Description of the entity.
class_name EntityName
extends CharacterBody3D

# Signals
signal died()

# Exports
@export var move_speed: float = 5.0

# Node references
@onready var _visual: Node3D = $Visual
@onready var _collision: CollisionShape3D = $CollisionShape3D

# State
var _is_active: bool = true


func _ready() -> void:
    _setup()


func _physics_process(delta: float) -> void:
    if not _is_active:
        return
    _process_movement(delta)


func _setup() -> void:
    pass


func _process_movement(delta: float) -> void:
    move_and_slide()
```

### Scene Structure (Character)
```
EntityName (CharacterBody3D)
├── Visual (Node3D)
│   └── MeshInstance3D
├── CollisionShape3D
├── Components (Node)
└── AudioStreamPlayer3D
```

### Static Entity (StaticBody3D)
For non-moving world objects with collision.

### Interactable Entity (Area3D)
For pickups, triggers, and interactive objects.

### Projectile Entity (CharacterBody3D or RigidBody3D)
For bullets, spells, and thrown objects with pooling support.

## Component Integration

After creating entity, consider adding components:
- HealthComponent for damageable entities
- MovementComponent for complex movement
- HitboxComponent for combat
- InteractionComponent for player interaction

## Collision Layer Assignment

Set appropriate collision layers based on entity type:
- Player: Layer 1, Mask 2,3,4,5,6
- Enemy: Layer 2, Mask 1,3,5,6
- Environment: Layer 3
- Interactable: Layer 4, Mask 1
- Projectile: Layer 5, Mask 1,2,3
