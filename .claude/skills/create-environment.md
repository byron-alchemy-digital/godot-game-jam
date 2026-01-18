# Skill: Create 3D Environment

Creates environment scenes with proper lighting, atmosphere, and world setup.

## Usage
```
/create-environment <EnvironmentName> [--type=<indoor|outdoor|stylized>]
```

## Process

1. **Create scene** at `scenes/environments/<EnvironmentName>.tscn`
2. **Set up WorldEnvironment** with appropriate settings
3. **Configure lighting** based on environment type
4. **Add navigation mesh** if needed

## Environment Template

### Outdoor Environment
```
World (Node3D)
├── WorldEnvironment
│   └── Environment resource
├── DirectionalLight3D (Sun)
├── Terrain (Node3D)
│   ├── Ground (StaticBody3D)
│   │   ├── MeshInstance3D
│   │   └── CollisionShape3D
│   └── Props (Node3D)
├── Navigation (NavigationRegion3D)
│   └── NavigationMesh
├── Spawns (Node3D)
│   ├── PlayerSpawn (Marker3D)
│   └── EnemySpawns (Node3D)
└── Triggers (Node3D)
```

### Indoor Environment
```
Level (Node3D)
├── WorldEnvironment
├── Lighting (Node3D)
│   ├── OmniLight3D (multiple)
│   └── SpotLight3D (multiple)
├── Geometry (Node3D)
│   ├── Walls (StaticBody3D)
│   ├── Floor (StaticBody3D)
│   └── Ceiling (StaticBody3D)
├── Props (Node3D)
├── Interactables (Node3D)
├── Navigation (NavigationRegion3D)
└── Spawns (Node3D)
```

## WorldEnvironment Setup

### Outdoor Sky
```gdscript
# In editor or via code
var env := Environment.new()

# Sky
var sky := Sky.new()
sky.sky_material = ProceduralSkyMaterial.new()
env.sky = sky
env.background_mode = Environment.BG_SKY

# Ambient Light
env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
env.ambient_light_energy = 0.5

# Tonemap
env.tonemap_mode = Environment.TONE_MAPPER_ACES

# SSAO
env.ssao_enabled = true
env.ssao_radius = 1.0
env.ssao_intensity = 2.0

# SDFGI (Global Illumination)
env.sdfgi_enabled = true  # For large outdoor scenes

# Fog
env.fog_enabled = true
env.fog_light_color = Color(0.8, 0.9, 1.0)
env.fog_density = 0.001
```

### Indoor/Stylized
```gdscript
var env := Environment.new()

# Solid color or gradient background
env.background_mode = Environment.BG_COLOR
env.background_color = Color(0.1, 0.1, 0.15)

# Ambient Light (no sky)
env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
env.ambient_light_color = Color(0.3, 0.3, 0.4)
env.ambient_light_energy = 0.3

# Glow for stylized look
env.glow_enabled = true
env.glow_intensity = 0.5
env.glow_bloom = 0.1

# VolumetricFog for atmosphere
env.volumetric_fog_enabled = true
env.volumetric_fog_density = 0.02
```

## Lighting Setup

### Sun Light (Outdoor)
```gdscript
var sun := DirectionalLight3D.new()
sun.rotation_degrees = Vector3(-45, -45, 0)
sun.light_color = Color(1.0, 0.95, 0.9)
sun.light_energy = 1.0
sun.shadow_enabled = true
sun.shadow_bias = 0.02
sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
```

### Point Lights (Indoor)
```gdscript
var light := OmniLight3D.new()
light.light_color = Color(1.0, 0.9, 0.8)
light.light_energy = 2.0
light.omni_range = 5.0
light.omni_attenuation = 1.0
light.shadow_enabled = true  # Use sparingly
```

### Spot Lights (Focused)
```gdscript
var spot := SpotLight3D.new()
spot.light_color = Color(1.0, 1.0, 0.9)
spot.light_energy = 3.0
spot.spot_range = 10.0
spot.spot_angle = 30.0
spot.shadow_enabled = true
```

## Navigation Setup

```gdscript
# NavigationRegion3D setup
var nav_region := NavigationRegion3D.new()
var nav_mesh := NavigationMesh.new()

# Configure for character size
nav_mesh.agent_radius = 0.5
nav_mesh.agent_height = 2.0
nav_mesh.agent_max_climb = 0.5
nav_mesh.agent_max_slope = 45.0

# Cell size affects precision vs performance
nav_mesh.cell_size = 0.25
nav_mesh.cell_height = 0.25

nav_region.navigation_mesh = nav_mesh
# Bake in editor or call nav_region.bake_navigation_mesh()
```

## Performance Tips

### LOD Groups
```gdscript
# Set up LOD for distant objects
var lod := LODGroup.new()
lod.lod_bias = 1.0
# Add meshes with different detail levels
```

### Occlusion Culling
- Enable in Project Settings > Rendering > Occlusion Culling
- Add OccluderInstance3D nodes for large occluders (walls, terrain)

### Light Baking
```gdscript
# For static lights, use baked lightmaps
var lightmap_gi := LightmapGI.new()
# Configure and bake in editor
```

### Distance Fade
```gdscript
# On MeshInstance3D for distant objects
mesh_instance.visibility_range_begin = 50.0
mesh_instance.visibility_range_end = 100.0
mesh_instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
```

## Common Environment Scripts

### Day/Night Cycle
```gdscript
class_name DayNightCycle
extends Node

@export var day_length_seconds: float = 120.0
@export var sun: DirectionalLight3D
@export var environment: WorldEnvironment

var time_of_day: float = 0.5  # 0-1, 0.5 = noon


func _process(delta: float) -> void:
    time_of_day = fmod(time_of_day + delta / day_length_seconds, 1.0)
    _update_sun()
    _update_environment()


func _update_sun() -> void:
    var angle := (time_of_day - 0.25) * TAU
    sun.rotation.x = angle
    sun.light_energy = maxf(0, sin(angle))
```

### Weather System (Basic)
```gdscript
class_name WeatherSystem
extends Node3D

@export var rain_particles: GPUParticles3D
@export var environment: WorldEnvironment

enum Weather { CLEAR, CLOUDY, RAINY }
var current_weather: Weather = Weather.CLEAR


func set_weather(weather: Weather) -> void:
    current_weather = weather
    match weather:
        Weather.CLEAR:
            rain_particles.emitting = false
            environment.environment.fog_density = 0.001
        Weather.RAINY:
            rain_particles.emitting = true
            environment.environment.fog_density = 0.01
```
