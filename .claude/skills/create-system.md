# Skill: Create System (Autoload)

Creates a new autoload/singleton system for global game functionality.

## Usage
```
/create-system <SystemName>
```

## Process

1. **Create script** at `scripts/autoload/<SystemName>.gd`
2. **Register as autoload** in project.godot
3. **Document public API**

## System Template

```gdscript
## Global system for managing [specific functionality].
##
## Access via: SystemName.method_name()
##
## Responsibilities:
## - List main responsibilities
## - Keep it focused
extends Node

# Signals for other systems to react to
signal system_event(data)

# Configuration
const SAVE_PATH := "user://system_data.save"

# State
var _initialized: bool = false
var _data: Dictionary = {}


func _ready() -> void:
    _load_data()
    _initialized = true


func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        _save_data()


## Public API method with documentation.
func public_method(param: String) -> bool:
    if not _initialized:
        push_warning("SystemName not initialized")
        return false
    # Implementation
    return true


## Get some value.
func get_value(key: String) -> Variant:
    return _data.get(key)


## Set some value.
func set_value(key: String, value: Variant) -> void:
    _data[key] = value
    system_event.emit({"key": key, "value": value})


# Persistence
func _save_data() -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_var(_data)


func _load_data() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
        if file:
            _data = file.get_var()
```

## Common Systems

### GameManager (State Machine)
```gdscript
extends Node

signal state_changed(new_state: GameState)
signal game_paused(is_paused: bool)

enum GameState { MENU, LOADING, PLAYING, PAUSED, GAME_OVER }

var current_state: GameState = GameState.MENU:
    set(value):
        if current_state != value:
            current_state = value
            state_changed.emit(value)

var is_paused: bool:
    get: return current_state == GameState.PAUSED


func start_game() -> void:
    current_state = GameState.PLAYING


func pause() -> void:
    if current_state == GameState.PLAYING:
        current_state = GameState.PAUSED
        get_tree().paused = true
        game_paused.emit(true)


func resume() -> void:
    if current_state == GameState.PAUSED:
        current_state = GameState.PLAYING
        get_tree().paused = false
        game_paused.emit(false)


func game_over() -> void:
    current_state = GameState.GAME_OVER
```

### AudioManager
```gdscript
extends Node

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

var _music_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _pool_size: int = 8


func _ready() -> void:
    _setup_music_player()
    _setup_sfx_pool()


func play_music(stream: AudioStream, fade_time: float = 1.0) -> void:
    # Implementation with crossfade


func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
    var player := _get_available_player()
    if player:
        player.stream = stream
        player.volume_db = volume_db
        player.play()


func set_music_volume(linear: float) -> void:
    AudioServer.set_bus_volume_db(
        AudioServer.get_bus_index(MUSIC_BUS),
        linear_to_db(linear)
    )


func _get_available_player() -> AudioStreamPlayer:
    for player in _sfx_pool:
        if not player.playing:
            return player
    return _sfx_pool[0]  # Fallback to first
```

### SceneManager
```gdscript
extends Node

signal scene_loading_started(scene_path: String)
signal scene_loading_progress(progress: float)
signal scene_loaded(scene: Node)

var _loader: ResourceLoader
var _loading_scene: String = ""


func change_scene(scene_path: String, transition: bool = true) -> void:
    scene_loading_started.emit(scene_path)

    if transition:
        await _fade_out()

    get_tree().change_scene_to_file(scene_path)

    if transition:
        await _fade_in()

    scene_loaded.emit(get_tree().current_scene)


func reload_current_scene() -> void:
    get_tree().reload_current_scene()


func _fade_out() -> void:
    # Implement fade transition


func _fade_in() -> void:
    # Implement fade transition
```

## Registering Autoload

Add to project.godot under [autoload]:
```ini
[autoload]
GameManager="*res://scripts/autoload/GameManager.gd"
AudioManager="*res://scripts/autoload/AudioManager.gd"
SceneManager="*res://scripts/autoload/SceneManager.gd"
```

Or via Editor: Project > Project Settings > Autoload

## Best Practices

1. **Minimal State**: Only store truly global state
2. **Clear API**: Well-documented public methods
3. **Signal-Based**: Emit signals for state changes
4. **Lazy Initialization**: Don't assume other autoloads exist in _ready()
5. **Save on Exit**: Handle NOTIFICATION_WM_CLOSE_REQUEST
