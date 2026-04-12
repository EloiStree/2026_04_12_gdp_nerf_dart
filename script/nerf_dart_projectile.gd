extends CharacterBody3D
class_name NerfDart

# =============================================================================
# Nerf Dart – Realistic quadratic-drag physics
# Uses CharacterBody3D + manual integration (time-based from launch)
# =============================================================================

@export var drag_coefficient := 0.8          # 0.67–1.6 (papers recommend ~0.8 for good feel)
@export var dart_radius := 0.006             # meters
@export var air_density := 1.225
@export var gravity := 9.81
@export var lifetime := 4.0

var _drag_k := 0.0

func _ready() -> void:
	var mass := 0.001                        # 1 gram
	var area := PI * dart_radius * dart_radius
	_drag_k = (air_density * drag_coefficient * area) / (2.0 * mass)
	
	top_level = true
	
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	if velocity.length_squared() < 0.01:
		return
	
	# Quadratic drag
	var speed := velocity.length()
	var drag_accel := Vector3.ZERO
	if speed > 0.1:
		drag_accel = -_drag_k * speed * velocity
	
	# Total acceleration
	var total_accel := Vector3.DOWN * gravity + drag_accel
	
	# Integrate velocity
	velocity += total_accel * delta
	
	# Move with collision
	move_and_slide()
	
	# Rotate to face movement direction (visual only)
	if velocity.length_squared() > 0.1:
		look_at(global_position + velocity, Vector3.UP)


# =============================================================================
# Fire function
# =============================================================================
func fire(muzzle_node: Node3D, muzzle_speed: float = 30.0, spread_deg: float = 1.5) -> void:
	# Set starting position and orientation
	global_transform = muzzle_node.global_transform
	
	# Direction
	var direction := -muzzle_node.global_basis.z.normalized()
	
	# Apply spread
	if spread_deg > 0.0:
		var spread_rad := deg_to_rad(spread_deg)
		var random_euler := Vector3(
			randf_range(-spread_rad, spread_rad),
			randf_range(-spread_rad, spread_rad),
			0.0
		)
		direction = (Basis.from_euler(random_euler) * direction).normalized()
	
	# Initial velocity at t=0
	velocity = direction * muzzle_speed
	
	# REMOVED: angular_velocity (CharacterBody3D does not have it)
	# If you want dart spin/wobble → switch to RigidBody3D instead
