# Skill: Godot 3D Patterns Reference

Common patterns and solutions for 3D game development in Godot.

## Object Pooling

```gdscript
## Generic object pool for frequently spawned objects.
class_name ObjectPool
extends Node

@export var scene: PackedScene
@export var initial_size: int = 20

var _pool: Array[Node] = []
var _active: Array[Node] = []


func _ready() -> void:
    for i in initial_size:
        _create_instance()


func get_instance() -> Node:
    var instance: Node
    if _pool.is_empty():
        instance = _create_instance()
    else:
        instance = _pool.pop_back()

    _active.append(instance)
    instance.show()
    instance.set_process(true)
    instance.set_physics_process(true)
    return instance


func release(instance: Node) -> void:
    if instance in _active:
        _active.erase(instance)
        _pool.append(instance)
        instance.hide()
        instance.set_process(false)
        instance.set_physics_process(false)


func _create_instance() -> Node:
    var instance := scene.instantiate()
    add_child(instance)
    instance.hide()
    instance.set_process(false)
    instance.set_physics_process(false)
    _pool.append(instance)
    return instance
```

## State Machine

```gdscript
## Base state for state machine pattern.
class_name State
extends Node

var state_machine: StateMachine


func enter() -> void:
    pass


func exit() -> void:
    pass


func update(delta: float) -> void:
    pass


func physics_update(delta: float) -> void:
    pass


func handle_input(event: InputEvent) -> void:
    pass
```

```gdscript
## Finite state machine for entity behavior.
class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}


func _ready() -> void:
    for child in get_children():
        if child is State:
            states[child.name.to_lower()] = child
            child.state_machine = self

    if initial_state:
        current_state = initial_state
        current_state.enter()


func _unhandled_input(event: InputEvent) -> void:
    current_state.handle_input(event)


func _process(delta: float) -> void:
    current_state.update(delta)


func _physics_process(delta: float) -> void:
    current_state.physics_update(delta)


func transition_to(state_name: String) -> void:
    var new_state: State = states.get(state_name.to_lower())
    if new_state and new_state != current_state:
        current_state.exit()
        current_state = new_state
        current_state.enter()
```

## Hitbox/Hurtbox System

```gdscript
## Hitbox for dealing damage (attacker side).
class_name Hitbox3D
extends Area3D

signal hit(hurtbox: Hurtbox3D)

@export var damage: int = 10
@export var knockback_force: float = 5.0

var owner_entity: Node3D


func _ready() -> void:
    area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
    if area is Hurtbox3D and area.owner_entity != owner_entity:
        var hurtbox := area as Hurtbox3D
        var knockback_dir := (hurtbox.global_position - global_position).normalized()
        hurtbox.take_hit(damage, knockback_dir * knockback_force, owner_entity)
        hit.emit(hurtbox)
```

```gdscript
## Hurtbox for receiving damage (defender side).
class_name Hurtbox3D
extends Area3D

signal hurt(damage: int, knockback: Vector3, attacker: Node3D)

var owner_entity: Node3D
var is_invincible: bool = false


func take_hit(damage: int, knockback: Vector3, attacker: Node3D) -> void:
    if is_invincible:
        return
    hurt.emit(damage, knockback, attacker)
```

## Interaction System

```gdscript
## Interactable object base class.
class_name Interactable3D
extends Area3D

signal interacted(interactor: Node3D)
signal focus_entered()
signal focus_exited()

@export var interaction_prompt: String = "Interact"
@export var one_shot: bool = false

var _has_been_used: bool = false


func can_interact() -> bool:
    return not (one_shot and _has_been_used)


func interact(interactor: Node3D) -> void:
    if can_interact():
        _has_been_used = true
        interacted.emit(interactor)
        _on_interact(interactor)


func _on_interact(interactor: Node3D) -> void:
    pass  # Override in derived classes


func _on_focus() -> void:
    focus_entered.emit()


func _on_unfocus() -> void:
    focus_exited.emit()
```

```gdscript
## Player interaction detector using raycast.
class_name InteractionRaycast
extends RayCast3D

signal interactable_changed(interactable: Interactable3D)

var current_interactable: Interactable3D


func _physics_process(_delta: float) -> void:
    var new_interactable: Interactable3D = null

    if is_colliding():
        var collider := get_collider()
        if collider is Interactable3D:
            new_interactable = collider

    if new_interactable != current_interactable:
        if current_interactable:
            current_interactable._on_unfocus()
        current_interactable = new_interactable
        if current_interactable:
            current_interactable._on_focus()
        interactable_changed.emit(current_interactable)


func try_interact(interactor: Node3D) -> bool:
    if current_interactable and current_interactable.can_interact():
        current_interactable.interact(interactor)
        return true
    return false
```

## Camera Shake

```gdscript
## Camera shake effect.
class_name CameraShake
extends Node

@export var decay_rate: float = 5.0
@export var max_offset: Vector2 = Vector2(0.5, 0.5)
@export var max_rotation: float = 5.0

var _trauma: float = 0.0
var _camera: Camera3D


func _ready() -> void:
    _camera = get_parent() as Camera3D


func _process(delta: float) -> void:
    if _trauma > 0:
        _trauma = maxf(_trauma - decay_rate * delta, 0)
        _apply_shake()


func add_trauma(amount: float) -> void:
    _trauma = minf(_trauma + amount, 1.0)


func _apply_shake() -> void:
    var shake_amount := _trauma * _trauma  # Quadratic falloff

    var offset := Vector3(
        randf_range(-max_offset.x, max_offset.x) * shake_amount,
        randf_range(-max_offset.y, max_offset.y) * shake_amount,
        0
    )
    _camera.h_offset = offset.x
    _camera.v_offset = offset.y

    var rotation_amount := deg_to_rad(max_rotation) * shake_amount
    _camera.rotation.z = randf_range(-rotation_amount, rotation_amount)
```

## Resource-Based Data

```gdscript
## Base class for game data resources.
class_name GameData
extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D
```

```gdscript
## Item data resource.
class_name ItemData
extends GameData

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM }

@export var item_type: ItemType
@export var stack_size: int = 1
@export var value: int = 0

# For consumables
@export_group("Consumable")
@export var heal_amount: int = 0
@export var effect_script: Script

# For equipment
@export_group("Equipment")
@export var damage_bonus: int = 0
@export var defense_bonus: int = 0
```

## Spawner Pattern

```gdscript
## Spawns entities at intervals or on demand.
class_name Spawner3D
extends Node3D

signal entity_spawned(entity: Node3D)

@export var entity_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var max_entities: int = 10
@export var auto_start: bool = false

var _spawned_entities: Array[Node3D] = []
var _timer: Timer


func _ready() -> void:
    _timer = Timer.new()
    _timer.wait_time = spawn_interval
    _timer.timeout.connect(_on_timer_timeout)
    add_child(_timer)

    if auto_start:
        start()


func start() -> void:
    _timer.start()


func stop() -> void:
    _timer.stop()


func spawn() -> Node3D:
    if _spawned_entities.size() >= max_entities:
        return null

    var entity := entity_scene.instantiate() as Node3D
    entity.global_position = global_position
    get_tree().current_scene.add_child(entity)

    _spawned_entities.append(entity)
    entity.tree_exited.connect(_on_entity_removed.bind(entity))

    entity_spawned.emit(entity)
    return entity


func _on_timer_timeout() -> void:
    spawn()


func _on_entity_removed(entity: Node3D) -> void:
    _spawned_entities.erase(entity)
```

## Tween Utilities

```gdscript
## Common tween animations.
class_name TweenUtils

static func bounce_scale(node: Node3D, duration: float = 0.3) -> Tween:
    var tween := node.create_tween()
    tween.tween_property(node, "scale", Vector3.ONE * 1.2, duration * 0.3)
    tween.tween_property(node, "scale", Vector3.ONE, duration * 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
    return tween


static func fade_in(node: Node3D, duration: float = 0.5) -> Tween:
    var tween := node.create_tween()
    # Assumes node has a material with albedo_color
    tween.tween_property(node, "modulate:a", 1.0, duration).from(0.0)
    return tween


static func punch_position(node: Node3D, direction: Vector3, strength: float = 0.5) -> Tween:
    var original_pos := node.position
    var tween := node.create_tween()
    tween.tween_property(node, "position", original_pos + direction * strength, 0.1)
    tween.tween_property(node, "position", original_pos, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
    return tween
```
