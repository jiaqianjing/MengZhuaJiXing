extends Control

# Tutorial system script

# UI node references
@onready var step_label = $TutorialPanel/VBoxContainer/StepLabel
@onready var instruction_label = $TutorialPanel/VBoxContainer/InstructionLabel
@onready var hint_label = $TutorialPanel/VBoxContainer/HintLabel
@onready var prev_button = $TutorialPanel/VBoxContainer/ButtonContainer/PrevButton
@onready var next_button = $TutorialPanel/VBoxContainer/ButtonContainer/NextButton
@onready var start_button = $TutorialPanel/VBoxContainer/ButtonContainer/StartButton
@onready var touch_indicator = $TouchIndicator
@onready var left_area = $TouchIndicator/LeftArea
@onready var right_area = $TouchIndicator/RightArea

# Animation related
var pulse_tween: Tween
var guide_style: StyleBoxFlat

# Tutorial steps
var current_step = 0
var tutorial_steps = []

# Whether entering tutorial from game (for showing return button)
var from_game = false

func _ready():
	"""Initialize tutorial"""
	# Check if entering tutorial from game
	from_game = has_played_before()

	if from_game:
		print("Entering tutorial from game")
	else:
		print("First time playing, showing full tutorial")

	setup_tutorial_steps()
	setup_touch_guide_style()
	show_current_step()

func setup_tutorial_steps():
	"""Setup tutorial steps"""
	tutorial_steps = [
		{
			"title": "Welcome to Star Catcher!",
			"instruction": "This is a simple and fun star collection game\n\nCollect falling stars to earn points\nGolden special stars are worth more\nDon't miss stars or you'll lose lives",
			"hint": "Ready to start learning the game controls?",
			"show_touch": false
		},
		{
			"title": "Movement Controls",
			"instruction": "Elegant touch controls:\n\nTap left side of screen to move left\nTap right side of screen to move right\n\nKeyboard controls:\n• A key or Left arrow to move left\n• D key or Right arrow to move right",
			"hint": "Try tapping the semi-transparent areas below to feel the smooth controls!",
			"show_touch": true
		},
		{
			"title": "Game Objective",
			"instruction": "Game Goal:\n• Collect as many stars as possible\n• Get higher scores\n• Avoid missing stars to prevent losing lives\n\nGame Time: 60 seconds\nLives: 3 points",
			"hint": "Game ends when lives reach zero or time runs out",
			"show_touch": false
		},
		{
			"title": "Star Types",
			"instruction": "Normal Stars: 10 points\nSpecial Stars: 50 points\n\nSpecial stars glow and are larger,\ncollect them to quickly boost your score!",
			"hint": "Special stars appear less frequently, seize the opportunity!",
			"show_touch": false
		},
		{
			"title": "Ready to Start",
			"instruction": "Now you understand the basic game controls!\n\nRemember:\n• Move left and right to collect stars\n• Don't miss any stars\n• Special stars are worth more\n• Get the highest score before time runs out",
			"hint": "Click the \"Start Game\" button to begin your star collection journey!",
			"show_touch": false
		}
	]

func setup_touch_guide_style():
	"""Setup elegant style for touch guide"""
	# Create glass effect style
	guide_style = StyleBoxFlat.new()

	# Background color - semi-transparent blue
	guide_style.bg_color = Color(0.2, 0.4, 0.8, 0.15)

	# Border - light blue glow effect
	guide_style.border_width_left = 2
	guide_style.border_width_top = 2
	guide_style.border_width_right = 2
	guide_style.border_width_bottom = 2
	guide_style.border_color = Color(0.4, 0.6, 1, 0.4)

	# Rounded corners
	guide_style.corner_radius_top_left = 20
	guide_style.corner_radius_top_right = 20
	guide_style.corner_radius_bottom_right = 20
	guide_style.corner_radius_bottom_left = 20

	# Shadow effect
	guide_style.shadow_color = Color(0, 0, 0, 0.1)
	guide_style.shadow_size = 5
	guide_style.shadow_offset = Vector2(0, 2)

	# Apply style to touch areas
	if left_area:
		left_area.add_theme_stylebox_override("panel", guide_style)
	if right_area:
		right_area.add_theme_stylebox_override("panel", guide_style)

func show_current_step():
	"""Show current step"""
	if current_step >= 0 and current_step < tutorial_steps.size():
		var step = tutorial_steps[current_step]

		# Update UI
		step_label.text = "Step %d / %d" % [current_step + 1, tutorial_steps.size()]
		instruction_label.text = step.instruction
		hint_label.text = step.hint

		# Show/hide touch indicator
		touch_indicator.visible = step.show_touch

		# If showing touch indicator, start pulse animation
		if step.show_touch:
			start_pulse_animation()
		else:
			stop_pulse_animation()

		# Update button states
		prev_button.visible = current_step > 0
		next_button.visible = current_step < tutorial_steps.size() - 1
		start_button.visible = current_step == tutorial_steps.size() - 1

		# If entering from game, modify last step button text
		if from_game and current_step == tutorial_steps.size() - 1:
			start_button.text = "Return to Game"

		print("Showing tutorial step: ", current_step + 1)

func _on_prev_button_pressed():
	"""Previous button"""
	if current_step > 0:
		current_step -= 1
		show_current_step()

func _on_next_button_pressed():
	"""Next button"""
	if current_step < tutorial_steps.size() - 1:
		current_step += 1
		show_current_step()

func _on_start_button_pressed():
	"""Start game button"""
	print("Starting game")
	stop_pulse_animation()  # Clean up animation
	mark_tutorial_completed()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func has_played_before() -> bool:
	"""Check if played before"""
	var save_file = "user://tutorial_completed.save"
	return FileAccess.file_exists(save_file)

func mark_tutorial_completed():
	"""Mark tutorial as completed"""
	var save_file = FileAccess.open("user://tutorial_completed.save", FileAccess.WRITE)
	if save_file:
		save_file.store_string("completed")
		save_file.close()
	print("Tutorial completed and saved")

func _input(event):
	"""Handle input events"""
	# Allow players to test touch controls in tutorial
	if touch_indicator.visible and event is InputEventScreenTouch:
		if event.pressed:
			test_touch_control(event.position)
	elif touch_indicator.visible and event is InputEventMouseButton:
		if event.pressed:
			test_touch_control(event.position)

func _unhandled_input(event):
	"""Handle input events not processed by UI"""
	# Ensure clicks outside touch areas can also be handled
	if touch_indicator.visible and (event is InputEventScreenTouch or event is InputEventMouseButton):
		if event.pressed:
			test_touch_control(event.position)

func test_touch_control(pos: Vector2):
	"""Test touch control"""
	var screen_size = get_viewport().get_visible_rect().size
	var screen_center = screen_size.x / 2

	# Check if click is within touch guide area (bottom 65%-95% of screen)
	var touch_area_top = screen_size.y * 0.65
	var touch_area_bottom = screen_size.y * 0.95

	if pos.y >= touch_area_top and pos.y <= touch_area_bottom:
		if pos.x < screen_center:
			print("Test: Move left")
			flash_area(left_area)
		else:
			print("Test: Move right")
			flash_area(right_area)

func start_pulse_animation():
	"""Start elegant pulse animation"""
	stop_pulse_animation()  # Stop previous animation first

	# Simplified pulse animation - two areas pulse synchronously
	pulse_tween = create_tween()
	pulse_tween.set_loops()

	# Pulse animation for both areas simultaneously
	pulse_tween.tween_method(_update_pulse_alpha, 0.3, 0.8, 1.5)
	pulse_tween.tween_method(_update_pulse_alpha, 0.8, 0.3, 1.5)

func _update_pulse_alpha(alpha: float):
	"""Update pulse transparency"""
	if left_area:
		left_area.modulate.a = alpha
	if right_area:
		right_area.modulate.a = alpha * 0.9  # Right side slightly darker for layered effect

func stop_pulse_animation():
	"""Stop pulse animation"""
	if pulse_tween:
		pulse_tween.kill()
		pulse_tween = null

	# Reset transparency
	if left_area:
		left_area.modulate.a = 0.8
	if right_area:
		right_area.modulate.a = 0.8

func flash_area(area: Panel):
	"""Elegant touch feedback effect"""
	if not area:
		return

	# Create touch feedback animation
	var feedback_tween = create_tween()

	# Quick scale up and brighten
	feedback_tween.parallel().tween_property(area, "scale", Vector2(1.05, 1.05), 0.1)
	feedback_tween.parallel().tween_property(area, "modulate", Color(1.2, 1.2, 1.5, 1.0), 0.1)

	# Return to original state
	feedback_tween.parallel().tween_property(area, "scale", Vector2(1.0, 1.0), 0.2)
	feedback_tween.parallel().tween_property(area, "modulate", Color(1, 1, 1, 0.8), 0.2)
