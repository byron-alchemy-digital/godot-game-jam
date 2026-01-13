# Game Jam Project - Godot 4.x Template

A ready-to-use Godot 4.x project template optimized for game jams. Features a clean folder structure, player controller with multiple movement styles, game state management, and placeholder code for common game jam features.

## Quick Start

1. Open Godot 4.2+ and import this project
2. Open `scenes/Main.tscn` (already set as main scene)
3. Press F5 to run
4. Start building your game!

## Folder Structure

```
godot-game-jam/
├── assets/
│   ├── sprites/      # Character sprites, tilesets, UI elements
│   ├── audio/        # Sound effects (.wav, .ogg) and music (.ogg, .mp3)
│   ├── fonts/        # Custom fonts (.ttf, .otf)
│   └── textures/     # Materials, backgrounds, particles
├── scenes/           # All .tscn scene files
│   ├── Main.tscn     # Main game scene
│   └── Player.tscn   # Player character scene
├── scripts/          # All .gd GDScript files
│   ├── Main.gd       # Main scene controller
│   ├── Player.gd     # Player controller (top-down & platformer)
│   └── GameManager.gd # Global game state (autoload)
├── resources/        # Godot resources (.tres, .res)
├── exports/          # Build outputs (ignored by git)
├── project.godot     # Godot project configuration
├── icon.svg          # Game icon
├── .gitignore        # Git ignore rules
└── README.md         # This file
```

## Controls

| Action | Key(s) |
|--------|--------|
| Move | WASD / Arrow Keys |
| Jump | Space |
| Action/Interact | E |
| Pause | Escape |

All controls are defined in `project.godot` under `[input]` and can be modified in:
**Project > Project Settings > Input Map**

## Core Systems

### Player Controller (`scripts/Player.gd`)

The player supports two movement styles (change via `MOVEMENT_STYLE` export):

**Top-Down Movement:**
- 8-directional movement
- Smooth acceleration and friction
- Great for: RPGs, shooters, puzzle games

**Platformer Movement:**
- Side-scrolling with gravity
- Coyote time (jump after leaving platform)
- Jump buffering (jump input remembered before landing)
- Variable jump height (release early for short jump)
- Great for: Platformers, action games

**Configurable exports:**
```gdscript
@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0
@export var MAX_HEALTH: int = 3
# ... and more
```

### Game Manager (`scripts/GameManager.gd`)

Global singleton (autoload) for managing:
- Score tracking with signals
- Lives system
- Game states (menu, playing, paused, game over)
- Save/load high scores
- Scene management helpers

**Usage:**
```gdscript
GameManager.add_score(100)
GameManager.lose_life()
GameManager.trigger_game_over()
```

### Main Scene (`scripts/Main.gd`)

Controls game flow:
- Player spawning
- UI updates (score, pause menu, game over)
- Pause functionality
- Helper functions for enemies, collectibles, screen effects

## Collision Layers

Configured in `project.godot`:

| Layer | Name | Use For |
|-------|------|---------|
| 1 | player | Player character |
| 2 | enemies | Enemy characters |
| 3 | environment | Walls, platforms, obstacles |
| 4 | collectibles | Coins, powerups, pickups |
| 5 | projectiles | Bullets, arrows, thrown items |

## Adding New Features

### Adding an Enemy

1. Create `scenes/Enemy.tscn` with CharacterBody2D
2. Create `scripts/Enemy.gd`
3. Set collision layer to 2 (enemies), mask to 1,3 (player, environment)
4. Add enemy spawning in `Main.gd`

### Adding a Collectible

1. Create `scenes/Collectible.tscn` with Area2D
2. Create `scripts/Collectible.gd`
3. Connect `body_entered` signal
4. Call `player.collect("coin", 10)` when collected

### Adding Audio

1. Place audio files in `assets/audio/`
2. Use AudioStreamPlayer for music, AudioStreamPlayer2D for SFX
3. Load and play:
```gdscript
$AudioStreamPlayer2D.stream = preload("res://assets/audio/jump.wav")
$AudioStreamPlayer2D.play()
```

### Adding Animations

1. Select your Sprite2D node
2. Open AnimationPlayer
3. Create animations: "idle", "run", "jump", "fall", "hurt", "death"
4. Uncomment animation code in `Player.gd`

## Game Jam Tips

### Time Management
- **Hour 1-2:** Brainstorm, plan core mechanic
- **Hour 3-6:** Implement core gameplay loop
- **Hour 7-10:** Add content (levels, enemies)
- **Hour 11-12:** Polish, juice, bug fixes
- **Final 30 min:** Build and submit!

### Scope Control
- Start with ONE core mechanic
- Get it playable ASAP
- Add features only if time permits
- Cut features ruthlessly

### Quick Wins for "Juice"
- [ ] Screen shake on hits
- [ ] Particle effects
- [ ] Sound effects for EVERYTHING
- [ ] Smooth camera follow
- [ ] Tweened UI animations
- [ ] Slow motion on big events

### Common Pitfalls
- Don't start with menus - build gameplay first
- Don't over-scope - one polished mechanic beats five broken ones
- Test early and often - export and test on target platform
- Save frequently - use git commits as checkpoints

### Performance Tips
- Use object pooling for bullets/enemies
- Disable physics on off-screen objects
- Use `call_deferred()` for spawning
- Profile with Godot's built-in profiler

## Building for Export

1. **Project > Export...**
2. Add your target platform(s)
3. Configure settings
4. Export to `exports/` folder

### Common Platforms
- **Web (HTML5):** Great for itch.io, easy sharing
- **Windows:** Most game jams accept this
- **Linux:** Good to include if time permits

## Useful Resources

- [Godot Documentation](https://docs.godotengine.org/)
- [GDQuest Tutorials](https://www.gdquest.com/)
- [KidsCanCode](https://kidscancode.org/godot_recipes/)
- [Godot Asset Library](https://godotengine.org/asset-library)

## License

This template is provided as-is for game jam use. Modify freely!

---

**Good luck with your game jam!**
