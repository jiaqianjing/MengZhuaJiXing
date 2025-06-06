extends RigidBody2D

# Special star script
# Inherits from normal star, but with higher value and special effects

# Signal definitions
signal star_missed

# Special star properties
@export var fall_speed: float = 120.0  # Slightly slower
@export var points_value: int = 50     # Higher value
@export var rotation_speed: float = 4.0  # Faster rotation
@export var pulse_speed: float = 3.0   # Pulse effect speed

# State variables
var collected: bool = false
var time_passed: float = 0.0

func _ready():
	"""Initialize special star"""
	# Set falling speed
	linear_velocity = Vector2(0, fall_speed)

	# Add some random horizontal velocity
	linear_velocity.x = randf_range(-20, 20)

	print("Special star spawned, value: ", points_value, " points")

func _physics_process(delta):
	"""Physics update - handle rotation and pulse animation"""
	if not collected:
		time_passed += delta

		# Rotation animation
		rotation += rotation_speed * delta

		# Pulse effect - make star size change periodically
		var pulse_scale = 1.0 + sin(time_passed * pulse_speed) * 0.2
		scale = Vector2(pulse_scale * 2, pulse_scale * 2)

func collect() -> int:
	"""Called when special star is collected"""
	if collected:
		return 0

	collected = true

	# Play special collection animation (flashing effect)
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(self, "modulate", Color.YELLOW, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

	# Scale to disappear
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)

	# Delayed deletion (doesn't block return value)
	tween.finished.connect(queue_free)

	return points_value

func _on_visibility_notifier_2d_screen_exited():
	"""When special star leaves screen"""
	if not collected:
		print("Special star missed! Lost ", points_value, " points")
		star_missed.emit()

	queue_free()
