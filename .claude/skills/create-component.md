# Skill: Create Component

Creates a reusable component following the component-based architecture pattern.

## Usage
```
/create-component <ComponentName>
```

## Process

1. **Create script** at `scripts/components/<ComponentName>.gd`
2. **Follow component design principles**
3. **Document signals and public API**

## Component Template

```gdscript
## Brief description of what this component does.
##
## Extended description explaining how to use this component,
## what signals it emits, and any dependencies it has.
class_name ComponentName
extends Node

# Signals - communicate state changes to parent/siblings
signal state_changed(new_state)

# Configuration - exposed in inspector
@export_group("Configuration")
@export var some_value: float = 1.0
@export var is_enabled: bool = true

# Dependencies - optional references to sibling components
var _parent_entity: Node3D

# Internal state
var _initialized: bool = false


func _ready() -> void:
    _cache_references()
    _initialized = true


func _cache_references() -> void:
    _parent_entity = get_parent() as Node3D
    if not _parent_entity:
        push_warning("%s: Parent is not a Node3D" % name)


## Public method description.
## Explain parameters and return value.
func public_method(param: int) -> bool:
    if not is_enabled:
        return false
    # Implementation
    return true


## Another public method.
func another_method() -> void:
    state_changed.emit("new_state")


# Private helper methods
func _internal_helper() -> void:
    pass
```

## Common Component Types

### HealthComponent
```gdscript
class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died()
signal damage_taken(amount: int, source: Node)

@export var max_health: int = 100
@export var invincibility_time: float = 0.0

var current_health: int:
    get: return _health
var is_alive: bool:
    get: return _health > 0

var _health: int
var _invincible: bool = false


func _ready() -> void:
    _health = max_health


func take_damage(amount: int, source: Node = null) -> int:
    if _invincible or not is_alive:
        return 0

    var actual := mini(amount, _health)
    _health -= actual
    health_changed.emit(_health, max_health)
    damage_taken.emit(actual, source)

    if _health <= 0:
        died.emit()
    elif invincibility_time > 0:
        _start_invincibility()

    return actual


func heal(amount: int) -> int:
    var actual := mini(amount, max_health - _health)
    _health += actual
    health_changed.emit(_health, max_health)
    return actual


func _start_invincibility() -> void:
    _invincible = true
    await get_tree().create_timer(invincibility_time).timeout
    _invincible = false
```

### MovementComponent (3D)
```gdscript
class_name MovementComponent3D
extends Node

signal movement_started()
signal movement_stopped()

@export var move_speed: float = 5.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0
@export var gravity_scale: float = 1.0

var velocity: Vector3 = Vector3.ZERO
var is_moving: bool:
    get: return velocity.length_squared() > 0.01

var _body: CharacterBody3D
var _gravity: float


func _ready() -> void:
    _body = get_parent() as CharacterBody3D
    _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func apply_movement(direction: Vector3, delta: float) -> void:
    var target_velocity := direction.normalized() * move_speed
    velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
    velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)


func apply_gravity(delta: float) -> void:
    if not _body.is_on_floor():
        velocity.y -= _gravity * gravity_scale * delta


func apply_friction(delta: float) -> void:
    velocity.x = move_toward(velocity.x, 0, friction * delta)
    velocity.z = move_toward(velocity.z, 0, friction * delta)


func move() -> void:
    if _body:
        _body.velocity = velocity
        _body.move_and_slide()
        velocity = _body.velocity
```

## Best Practices

1. **Single Responsibility**: One component = one job
2. **No Hard Dependencies**: Use signals for communication
3. **Self-Contained**: Component works without knowing parent details
4. **Configurable**: Expose important values via @export
5. **Documented**: Always add class documentation
