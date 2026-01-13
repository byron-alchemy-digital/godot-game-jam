extends Node
## GameManager - Global singleton for managing game state
##
## This autoload script handles:
## - Score tracking
## - Lives system
## - Game state (playing, paused, game over)
## - High score persistence
## - Level progression

# =============================================================================
# SIGNALS
# =============================================================================

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal game_over
signal level_completed
signal game_started

# =============================================================================
# GAME STATE
# =============================================================================

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER, LEVEL_COMPLETE }

var current_state: GameState = GameState.MENU

# =============================================================================
# SCORE & PROGRESSION
# =============================================================================

var score: int = 0
var high_score: int = 0
var lives: int = 3
var current_level: int = 1

# =============================================================================
# SETTINGS - Adjust for your game!
# =============================================================================

const STARTING_LIVES: int = 3
const MAX_LIVES: int = 5
const SAVE_FILE_PATH: String = "user://savegame.save"

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready() -> void:
	# Load saved data
	_load_game()

	# Don't pause this node when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	# Global input handling
	# TODO: Add global hotkeys if needed
	pass


# =============================================================================
# SCORE MANAGEMENT
# =============================================================================

func add_score(points: int) -> void:
	## Adds points to the current score
	score += points
	score_changed.emit(score)

	# Check for high score
	if score > high_score:
		high_score = score
		# TODO: Trigger high score celebration


func get_score() -> int:
	return score


func reset_score() -> void:
	## Resets score to zero
	score = 0
	score_changed.emit(score)


# =============================================================================
# LIVES MANAGEMENT
# =============================================================================

func add_life() -> void:
	## Adds a life (up to max)
	if lives < MAX_LIVES:
		lives += 1
		lives_changed.emit(lives)

		# TODO: Play 1-up sound


func lose_life() -> void:
	## Removes a life and checks for game over
	lives -= 1
	lives_changed.emit(lives)

	if lives <= 0:
		trigger_game_over()


func get_lives() -> int:
	return lives


# =============================================================================
# GAME STATE MANAGEMENT
# =============================================================================

func start_game() -> void:
	## Starts a new game
	current_state = GameState.PLAYING
	reset_game()
	game_started.emit()

	# TODO: Load first level
	# get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")


func reset_game() -> void:
	## Resets all game state for a new game
	score = 0
	lives = STARTING_LIVES
	current_level = 1

	score_changed.emit(score)
	lives_changed.emit(lives)


func trigger_game_over() -> void:
	## Triggers game over state
	current_state = GameState.GAME_OVER
	game_over.emit()

	# Save high score
	_save_game()

	# TODO: Play game over sound
	# TODO: Show game over screen


func complete_level() -> void:
	## Called when a level is completed
	current_state = GameState.LEVEL_COMPLETE
	current_level += 1
	level_completed.emit()

	# TODO: Calculate level bonus
	# TODO: Show level complete screen
	# TODO: Load next level


func pause_game() -> void:
	## Pauses the game
	current_state = GameState.PAUSED
	get_tree().paused = true


func resume_game() -> void:
	## Resumes the game
	current_state = GameState.PLAYING
	get_tree().paused = false


# =============================================================================
# SAVE/LOAD SYSTEM
# =============================================================================

func _save_game() -> void:
	## Saves game data to file
	var save_data = {
		"high_score": high_score,
		# TODO: Add more save data
		# "unlocked_levels": unlocked_levels,
		# "settings": settings,
	}

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()


func _load_game() -> void:
	## Loads game data from file
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()

		if error == OK:
			var data = json.data
			high_score = data.get("high_score", 0)
			# TODO: Load more data


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func is_playing() -> bool:
	return current_state == GameState.PLAYING


func is_paused() -> bool:
	return current_state == GameState.PAUSED


func is_game_over() -> bool:
	return current_state == GameState.GAME_OVER


# =============================================================================
# SCENE MANAGEMENT HELPERS
# =============================================================================

func change_scene(scene_path: String) -> void:
	## Changes to a new scene with optional transition
	# TODO: Add transition effect

	get_tree().change_scene_to_file(scene_path)


func reload_current_scene() -> void:
	## Reloads the current scene
	get_tree().reload_current_scene()


func quit_game() -> void:
	## Saves and quits the game
	_save_game()
	get_tree().quit()


# =============================================================================
# DEBUG HELPERS (Remove in production!)
# =============================================================================

func _input(event: InputEvent) -> void:
	# Debug shortcuts - remove these for release!
	if OS.is_debug_build():
		if event.is_action_pressed("ui_home"):  # Home key
			add_score(100)
			print("[DEBUG] Added 100 score")
		elif event.is_action_pressed("ui_end"):  # End key
			add_life()
			print("[DEBUG] Added life")
