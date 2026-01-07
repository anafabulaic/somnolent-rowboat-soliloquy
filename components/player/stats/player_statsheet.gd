extends Resource
class_name PlayerStatSheet

#region Exported Properties
@export_group("General")
@export var gravity: Vector3 = Vector3(0, -15.0, 0)
@export var speed_cap: float = 200.0

@export var character_height: float = 1.8
@export var character_radius: float = 0.6
@export var camera_height: float = 1.524

@export var max_walk_slope: float = 45.573

@export var physshadow_mass: float = 40.0

@export_group("Speed")
@export var base_speed: float = 200.0
@export var walk_speed: float = 200.0
@export var crouch_speed: float = 100.0

@export_group("Ground Movement")
@export var ground_accel: float = 0.25
@export var ground_decel: float = 0.25
@export var ground_friction: float = 8.0

@export var crouch_translate: float = 0.7
@export var crouch_jump_add: float = 0.7
@export var crouching_speed: float = 5.0

@export_group("Ladders")
@export var climbing_speed: float = 300.0

@export_group("Stairs")
@export var max_step_height: float = 0.3

@export_group("Air Movement")
@export var air_accel: float = 5.0
@export var air_control_cap: float = 1.0
@export var air_speed_limit: float = 200.0

@export_group("Jumping")
@export var jump_force: float = 6.0

#endregion

#region Runtime Properties
var has_spawned: bool = false

var velocity: Vector3 = Vector3.ZERO

var physics_active: bool = false
var touching_physics: bool = false
var was_touching_physics: bool = false

var is_in_water: bool = false
var water_level: float = 0.0

var current_water: MapWaterVolume
var current_ladder: Ladder

var can_move_and_slide: bool = true
var can_land: bool = true

# Input
var wants_jump: bool = false
var wants_crouch: bool = false
var wants_slowmove: bool = false

var is_crouched: bool = false

var mouse_input: Vector2 = Vector2.ZERO
var input_dir: Vector2 = Vector2.ZERO
var wish_dir: Vector3 = Vector3.ZERO
var wish_speed: float = base_speed

# Camera
var desired_camera_height: float = 1.524
var step_time: float = 0.0

var is_holding: bool = false
var held_object: PhysicsProp3D

# Trinkets
var equipped_trinket: TrinketReference

# Modifiers
var gravity_modifier: float = 1.0
#endregion
