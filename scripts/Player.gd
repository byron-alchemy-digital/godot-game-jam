extends CharacterBody2D
class_name Player
## Player character controller with movement, jumping, and basic interactions
##
## Supports both top-down and platformer movement styles.
## Change MOVEMENT_STYLE to switch between them.

# =============================================================================
# SIGNALS
# =============================================================================

signal died
signal health_changed(new_health: int)
signal collected_item(item_type: String)

# =============================================================================
# ENUMS
# =============================================================================

enum MovementStyle { TOP_DOWN, PLATFORMER }
enum State { IDLE, RUNNING, JUMPING, FALLING, HURT, DEAD }

# =============================================================================
# EXPORTS - Tweak these in the Inspector!
# =============================================================================

@export_group("Movement")
@export var MOVEMENT_STYLE: MovementStyle = MovementStyle.TOP_DOWN
@export var SPEED: float = 300.0
@export var ACCELERATION: float = 2000.0
@export var FRICTION: float = 1500.0

@export_group("Platformer Settings")
@export var JUMP_VELOCITY: float = -400.0
@export var GRAVITY_SCALE: float = 1.0
@export var COYOTE_TIME: float = 0.1
@export var JUMP_BUFFER_TIME: float = 0.1

@export_group("Combat")
@export var MAX_HEALTH: int = 3
@export var INVINCIBILITY_TIME: float = 1.0
@export var KNOCKBACK_FORCE: float = 200.0

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt_timer: Timer = $HurtTimer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# =============================================================================
# STATE VARIABLES
# =============================================================================

var current_state: State = State.IDLE
var health: int = MAX_HEALTH
var is_invincible: bool = false

# Platformer-specific
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false

# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	# TODO: Initialize player
	# TODO: Set up collision shape (use RectangleShape2D or CircleShape2D)
	# TODO: Load player sprite
	# TODO: Set up animations

	health = MAX_HEALTH
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)

	# Create a default collision shape if none exists
	if collision_shape.shape == null:
		var shape = CircleShape2D.new()
		shape.radius = 16.0
		collision_shape.shape = shape


func _physics_process(delta: float) -> void:
	match MOVEMENT_STYLE:
		MovementStyle.TOP_DOWN:
			_process_top_down_movement(delta)
		MovementStyle.PLATFORMER:
			_process_platformer_movement(delta)

	_update_animation()
	move_and_slide()

	# Check for collisions after movement
	_handle_collisions()


# =============================================================================
# TOP-DOWN MOVEMENT
# =============================================================================

func _process_top_down_movement(delta: float) -> void:
	## Handles 8-directional top-down movement

	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_dir != Vector2.ZERO:
		# Accelerate towards target velocity
		velocity = velocity.move_toward(input_dir * SPEED, ACCELERATION * delta)
		current_state = State.RUNNING

		# TODO: Flip sprite based on direction
		# if input_dir.x != 0:
		#     sprite.flip_h = input_dir.x < 0
	else:
		# Apply friction
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		current_state = State.IDLE


# =============================================================================
# PLATFORMER MOVEMENT
# =============================================================================

func _process_platformer_movement(delta: float) -> void:
	## Handles side-scrolling platformer movement with jump

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * GRAVITY_SCALE * delta

	# Coyote time - allows jumping shortly after leaving platform
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	elif coyote_timer > 0:
		coyote_timer -= delta

	# Jump buffer - remembers jump input before landing
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	elif jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# Handle jump
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0
		current_state = State.JUMPING

		# TODO: Play jump sound
		# _play_sound(jump_sound)

	# Variable jump height - release jump early for shorter jump
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	# Horizontal movement
	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)

		# Flip sprite
		if sprite:
			sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Update state
	if is_on_floor():
		current_state = State.RUNNING if abs(velocity.x) > 10 else State.IDLE
	else:
		current_state = State.JUMPING if velocity.y < 0 else State.FALLING


# =============================================================================
# COMBAT & HEALTH
# =============================================================================

func take_damage(amount: int = 1, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	## Called when player takes damage
	if is_invincible or current_state == State.DEAD:
		return

	health -= amount
	health_changed.emit(health)
	current_state = State.HURT

	# Apply knockback
	if knockback_dir != Vector2.ZERO:
		velocity = knockback_dir.normalized() * KNOCKBACK_FORCE

	# Start invincibility
	is_invincible = true
	hurt_timer.start(INVINCIBILITY_TIME)

	# TODO: Flash sprite during invincibility
	# TODO: Play hurt sound
	# TODO: Screen shake

	if health <= 0:
		_die()


func heal(amount: int = 1) -> void:
	## Restores health
	health = min(health + amount, MAX_HEALTH)
	health_changed.emit(health)

	# TODO: Play heal sound
	# TODO: Heal visual effect


func _die() -> void:
	## Called when player health reaches 0
	current_state = State.DEAD
	died.emit()

	# TODO: Play death animation
	# TODO: Play death sound
	# TODO: Disable collision

	# Optional: Remove player after delay
	# await get_tree().create_timer(1.0).timeout
	# queue_free()


func _on_hurt_timer_timeout() -> void:
	## Called when invincibility ends
	is_invincible = false

	# TODO: Stop flashing effect


# =============================================================================
# COLLISIONS & INTERACTIONS
# =============================================================================

func _handle_collisions() -> void:
	## Process collisions after movement
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		# TODO: Handle different collision types
		# if collider is Enemy:
		#     take_damage(1, collision.get_normal())
		# elif collider is Collectible:
		#     collider.collect()


func collect(item_type: String, value: int = 1) -> void:
	## Called when collecting an item
	collected_item.emit(item_type)

	match item_type:
		"coin":
			GameManager.add_score(value)
		"health":
			heal(value)
		"powerup":
			# TODO: Apply powerup
			pass

	# TODO: Play collect sound
	# TODO: Collect visual effect


# =============================================================================
# ANIMATION
# =============================================================================

func _update_animation() -> void:
	## Updates player animation based on current state
	# TODO: Add actual animations

	if not animation_player:
		return

	match current_state:
		State.IDLE:
			pass  # animation_player.play("idle")
		State.RUNNING:
			pass  # animation_player.play("run")
		State.JUMPING:
			pass  # animation_player.play("jump")
		State.FALLING:
			pass  # animation_player.play("fall")
		State.HURT:
			pass  # animation_player.play("hurt")
		State.DEAD:
			pass  # animation_player.play("death")


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func _play_sound(sound: AudioStream) -> void:
	## Plays a sound effect
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.play()


func reset() -> void:
	## Resets player to initial state
	health = MAX_HEALTH
	current_state = State.IDLE
	is_invincible = false
	velocity = Vector2.ZERO
	health_changed.emit(health)
