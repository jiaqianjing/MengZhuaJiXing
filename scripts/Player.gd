extends CharacterBody2D

# Player control script
# Handles player movement and collision detection

# Signal definitions - for communication with main scene
signal star_collected(points: int)
signal life_lost

# Movement parameters
@export var speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# Player state enumeration
enum PlayerState {
	STILL,    # Still state
	RUNNING,  # Moving state
	CATCHING  # Catching star state
}

# State related variables
var current_state: PlayerState = PlayerState.STILL
var catch_animation_timer: float = 0.0
var catch_animation_duration: float = 0.3  # Catch animation duration

# Movement direction
var last_movement_direction: float = 1.0  # 1.0 = right, -1.0 = left

# Display settings
@export var player_display_size: float = 60.0  # Player display size (pixels)

# Texture resources
@export var still_texture: Texture2D
@export var run_texture: Texture2D
@export var catch_texture: Texture2D

# Screen boundaries
var screen_size: Vector2

# Touch control
var touch_input_direction: float = 0.0

# Node references
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	"""Initialize player"""
	screen_size = get_viewport_rect().size

	# Ensure sprite node is visible
	if sprite:
		sprite.visible = true

	# Load texture resources
	load_textures()

	# Set initial state (this will immediately show still texture)
	change_state(PlayerState.STILL)

	# Ensure texture is applied immediately
	if sprite and sprite.texture:
		adjust_sprite_scale(sprite.texture)

	print("Player initialization complete, current texture: ", sprite.texture)

func load_textures():
	"""Load texture resources for all states"""
	still_texture = load("res://assets/images/image_still.png")
	run_texture = load("res://assets/images/image_run.png")
	catch_texture = load("res://assets/images/image_catch.png")

	if not still_texture or not run_texture or not catch_texture:
		print("Error: Player texture loading failed! Please check resource files")
		# If texture loading fails, use default white square
		var default_texture = ImageTexture.new()
		var image = Image.create(64, 64, false, Image.FORMAT_RGB8)
		image.fill(Color.WHITE)
		default_texture.set_image(image)

		if not still_texture:
			still_texture = default_texture
		if not run_texture:
			run_texture = default_texture
		if not catch_texture:
			catch_texture = default_texture
	else:
		print("All player state textures loaded successfully")

func change_state(new_state: PlayerState):
	"""Change player state and update texture"""
	if current_state == new_state:
		return

	current_state = new_state

	# Update texture and scale based on state
	match current_state:
		PlayerState.STILL:
			sprite.texture = still_texture
			adjust_sprite_scale(still_texture)
			print("Switched to still state")
		PlayerState.RUNNING:
			sprite.texture = run_texture
			adjust_sprite_scale(run_texture)
			# Set mirroring based on movement direction
			update_sprite_direction()
			print("Switched to moving state, direction: ", last_movement_direction)
		PlayerState.CATCHING:
			sprite.texture = catch_texture
			adjust_sprite_scale(catch_texture)
			catch_animation_timer = catch_animation_duration
			print("Switched to catching state")

func update_sprite_direction():
	"""Update sprite mirroring based on movement direction"""
	# Your sprite is running left, so need to mirror when moving right
	if last_movement_direction > 0:  # Moving right
		sprite.scale.x = abs(sprite.scale.x) * -1  # Mirror flip (negative scale)
	else:  # Moving left
		sprite.scale.x = abs(sprite.scale.x)  # Keep original direction (positive scale)

func adjust_sprite_scale(texture: Texture2D):
	"""Adjust sprite scale based on texture size, maintain appropriate display size"""
	if not texture:
		return

	# Calculate scale ratio using adjustable display size
	var texture_size = texture.get_size()
	var scale_ratio = player_display_size / max(texture_size.x, texture_size.y)

	# Maintain current direction (positive/negative value)
	var current_x_direction = 1.0 if sprite.scale.x >= 0 else -1.0

	# Apply uniform scaling, maintain aspect ratio and direction
	sprite.scale = Vector2(scale_ratio * current_x_direction, scale_ratio)

	print("Texture size: %s, target size: %s pixels, applied scale: %s" % [texture_size, player_display_size, scale_ratio])

func _physics_process(delta):
	"""Physics update - handle player movement"""
	handle_input(delta)
	move_and_slide()
	clamp_to_screen()
	update_state(delta)

func update_state(delta):
	"""Update player state"""
	# Handle catch animation timer
	if current_state == PlayerState.CATCHING:
		catch_animation_timer -= delta
		if catch_animation_timer <= 0:
			# Catch animation ended, switch based on current movement state
			if abs(velocity.x) > 10:  # If still moving
				change_state(PlayerState.RUNNING)
			else:
				change_state(PlayerState.STILL)
		return  # Don't change other states during catch state

	# Update state based on movement speed
	if abs(velocity.x) > 10:  # Movement threshold
		if current_state != PlayerState.RUNNING:
			change_state(PlayerState.RUNNING)
	else:
		if current_state != PlayerState.STILL:
			change_state(PlayerState.STILL)

func handle_input(delta):
	"""Handle input control - supports keyboard and touch"""
	var input_direction = 0

	# Detect keyboard left/right movement input
	if Input.is_action_pressed("move_left"):
		input_direction -= 1
	if Input.is_action_pressed("move_right"):
		input_direction += 1

	# Detect touch input
	var touch_input = get_touch_input()
	if touch_input != 0:
		input_direction = touch_input

	# Record movement direction (for mirroring)
	if input_direction != 0:
		last_movement_direction = input_direction

	# Apply movement logic
	if input_direction != 0:
		# Accelerate when there's input
		velocity.x = move_toward(velocity.x, input_direction * speed, acceleration * delta)
	else:
		# Decelerate when no input
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func get_touch_input() -> float:
	"""Get touch input direction"""
	# Use touch control variable
	return touch_input_direction

func _input(event):
	"""Handle touch and mouse input"""
	# Handle touch events
	if event is InputEventScreenTouch:
		handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		handle_screen_drag(event)
	# Handle mouse events (for desktop testing)
	elif event is InputEventMouseButton:
		if event.pressed:
			handle_mouse_input(event.position)
		else:
			touch_input_direction = 0.0

func handle_screen_touch(event: InputEventScreenTouch):
	"""Handle touch screen touch events"""
	if event.pressed:
		handle_touch_position(event.position)
	else:
		touch_input_direction = 0.0

func handle_screen_drag(event: InputEventScreenDrag):
	"""Handle touch screen drag events"""
	handle_touch_position(event.position)

func handle_mouse_input(mouse_pos: Vector2):
	"""Handle mouse input (for desktop testing)"""
	handle_touch_position(mouse_pos)

func handle_touch_position(touch_pos: Vector2):
	"""Determine movement direction based on touch position"""
	var screen_center = screen_size.x / 2

	if touch_pos.x < screen_center:
		touch_input_direction = -1.0  # Move left
		print("Touch: Move left")
	else:
		touch_input_direction = 1.0   # Move right
		print("Touch: Move right")

func clamp_to_screen():
	"""Limit player within screen bounds"""
	var half_width = 40  # Half width of player sprite
	position.x = clamp(position.x, half_width, screen_size.x - half_width)

func _on_area_2d_area_entered(area):
	"""Area entered detected - handle star collection"""
	var star = area.get_parent()

	if star.has_method("collect"):
		var points = star.collect()
		star_collected.emit(points)

		# Trigger catch state animation
		change_state(PlayerState.CATCHING)

		print("Player collected star, earned ", points, " points!")
