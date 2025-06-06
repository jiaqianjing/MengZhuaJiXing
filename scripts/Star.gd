extends RigidBody2D

# Normal star script
# Handles star falling, collection and disappearance

# Signal definitions
signal star_missed

# Star properties
@export var fall_speed: float = 150.0
@export var points_value: int = 10
@export var rotation_speed: float = 2.0

# State variables
var collected: bool = false

func _ready():
	"""Initialize star"""
	# Set falling speed
	linear_velocity = Vector2(0, fall_speed)

	# Add some random horizontal velocity
	linear_velocity.x = randf_range(-30, 30)

	print("Normal star spawned, value: ", points_value, " points")

func _physics_process(delta):
	"""Physics update - handle rotation animation"""
	if not collected:
		rotation += rotation_speed * delta

func collect() -> int:
	"""Called when star is collected"""
	if collected:
		return 0

	collected = true

	# Play collection animation (simple scaling effect)
	create_tween().tween_property(self, "scale", Vector2.ZERO, 0.2)

	# Delayed deletion (doesn't block return value)
	get_tree().create_timer(0.2).timeout.connect(queue_free)

	return points_value

func _on_visibility_notifier_2d_screen_exited():
	"""When star leaves screen"""
	if not collected:
		print("Star missed!")
		star_missed.emit()

	queue_free()
