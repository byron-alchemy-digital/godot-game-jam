# Skill: Create 3D Controller

Creates player or AI character controllers with proper 3D movement and physics.

## Usage
```
/create-3d-controller <ControllerType> [--perspective=<first-person|third-person>]
```

## Controller Types

### First-Person Controller
```gdscript
## First-person player controller with mouselook and movement.
class_name FirstPersonController
extends CharacterBody3D

# Movement
@export_group("Movement")
@export var move_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 10.0
@export var air_control: float = 0.3

# Mouse Look
@export_group("Mouse Look")
@export var mouse_sensitivity: float = 0.002
@export var max_look_angle: float = 89.0

# References
@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D

# State
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _is_sprinting: bool = false


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _handle_mouse_look(event)

    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
    _apply_gravity(delta)
    _handle_jump()
    _handle_movement(delta)
    move_and_slide()


func _handle_mouse_look(event: InputEventMouseMotion) -> void:
    rotate_y(-event.relative.x * mouse_sensitivity)
    _head.rotate_x(-event.relative.y * mouse_sensitivity)
    _head.rotation.x = clampf(
        _head.rotation.x,
        deg_to_rad(-max_look_angle),
        deg_to_rad(max_look_angle)
    )


func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= _gravity * delta


func _handle_jump() -> void:
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity


func _handle_movement(delta: float) -> void:
    var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    _is_sprinting = Input.is_action_pressed("sprint") and is_on_floor()
    var target_speed := sprint_speed if _is_sprinting else move_speed
    var accel := acceleration if is_on_floor() else acceleration * air_control

    if direction:
        velocity.x = move_toward(velocity.x, direction.x * target_speed, accel * delta)
        velocity.z = move_toward(velocity.z, direction.z * target_speed, accel * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, accel * delta)
        velocity.z = move_toward(velocity.z, 0, accel * delta)
```

### Third-Person Controller
```gdscript
## Third-person player controller with camera orbit.
class_name ThirdPersonController
extends CharacterBody3D

# Movement
@export_group("Movement")
@export var move_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var rotation_speed: float = 10.0
@export var jump_velocity: float = 4.5

# Camera
@export_group("Camera")
@export var camera_distance: float = 4.0
@export var camera_height: float = 2.0
@export var mouse_sensitivity: float = 0.003

# References
@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _camera_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var _model: Node3D = $Model

# State
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _camera_rotation: Vector2 = Vector2.ZERO


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _camera_arm.spring_length = camera_distance
    _camera_pivot.position.y = camera_height


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _camera_rotation.x -= event.relative.y * mouse_sensitivity
        _camera_rotation.y -= event.relative.x * mouse_sensitivity
        _camera_rotation.x = clampf(_camera_rotation.x, deg_to_rad(-80), deg_to_rad(80))


func _physics_process(delta: float) -> void:
    _update_camera()
    _apply_gravity(delta)
    _handle_jump()
    _handle_movement(delta)
    move_and_slide()


func _update_camera() -> void:
    _camera_pivot.rotation.x = _camera_rotation.x
    _camera_pivot.rotation.y = _camera_rotation.y


func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= _gravity * delta


func _handle_jump() -> void:
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity


func _handle_movement(delta: float) -> void:
    var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

    # Get camera-relative direction
    var cam_basis := _camera_pivot.global_transform.basis
    var direction := (cam_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    direction.y = 0

    if direction:
        # Rotate model to face movement direction
        var target_rotation := atan2(direction.x, direction.z)
        _model.rotation.y = lerp_angle(_model.rotation.y, target_rotation, rotation_speed * delta)

        var speed := sprint_speed if Input.is_action_pressed("sprint") else move_speed
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, move_speed)
        velocity.z = move_toward(velocity.z, 0, move_speed)
```

## Scene Structures

### First-Person Scene
```
Player (CharacterBody3D)
├── CollisionShape3D (CapsuleShape3D)
├── Head (Node3D) - Rotates for look up/down
│   └── Camera3D
├── Components (Node)
│   ├── HealthComponent
│   └── InteractionRaycast (RayCast3D)
└── AudioListener3D
```

### Third-Person Scene
```
Player (CharacterBody3D)
├── CollisionShape3D (CapsuleShape3D)
├── Model (Node3D) - Rotates to face movement
│   └── CharacterModel (imported scene)
├── CameraPivot (Node3D) - Orbits around player
│   └── SpringArm3D - Handles camera collision
│       └── Camera3D
├── Components (Node)
│   ├── HealthComponent
│   └── InteractionArea (Area3D)
└── AnimationTree
```

## Required Input Actions

Add to project.godot:
```ini
[input]
move_left={...key=A/Left}
move_right={...key=D/Right}
move_up={...key=W/Up}
move_down={...key=S/Down}
jump={...key=Space}
sprint={...key=Shift}
interact={...key=E}
```

## Camera Collision (SpringArm3D)

The SpringArm3D automatically handles camera collision:
```gdscript
# Configuration
_camera_arm.spring_length = 4.0  # Default distance
_camera_arm.margin = 0.2         # Collision margin
_camera_arm.collision_mask = 4   # Environment layer only
```

## Animation Integration

```gdscript
# In _physics_process after movement
var anim_tree: AnimationTree = $AnimationTree
var state_machine: AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]

if is_on_floor():
    if velocity.length() > 0.1:
        state_machine.travel("Run" if _is_sprinting else "Walk")
    else:
        state_machine.travel("Idle")
else:
    state_machine.travel("Jump" if velocity.y > 0 else "Fall")
```
