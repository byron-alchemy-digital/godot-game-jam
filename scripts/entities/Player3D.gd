## 3D Player character with WASD movement.
##
## A simple third-person character controller that moves
## on the XZ plane using WASD input.
class_name Player3D
extends CharacterBody3D

## Movement speed in units per second.
@export var move_speed: float = 5.0

## Acceleration rate for smooth movement.
@export var acceleration: float = 10.0

## Gravity strength.
@export var gravity: float = 20.0

# Cached gravity from project settings (fallback)
var _project_gravity: float


func _ready() -> void:
	_project_gravity = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement(delta)
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func _handle_movement(delta: float) -> void:
	# Get input direction from WASD
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Convert to 3D direction (XZ plane)
	var direction := Vector3(input_dir.x, 0.0, input_dir.y).normalized()

	# Apply movement with acceleration for smoothness
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)
	else:
		# Decelerate when no input
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
