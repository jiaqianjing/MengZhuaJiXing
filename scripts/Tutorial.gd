extends Control

# 教程系统脚本

# UI节点引用
@onready var step_label = $TutorialPanel/VBoxContainer/StepLabel
@onready var instruction_label = $TutorialPanel/VBoxContainer/InstructionLabel
@onready var hint_label = $TutorialPanel/VBoxContainer/HintLabel
@onready var prev_button = $TutorialPanel/VBoxContainer/ButtonContainer/PrevButton
@onready var next_button = $TutorialPanel/VBoxContainer/ButtonContainer/NextButton
@onready var start_button = $TutorialPanel/VBoxContainer/ButtonContainer/StartButton
@onready var touch_indicator = $TouchIndicator
@onready var left_area = $TouchIndicator/LeftArea
@onready var right_area = $TouchIndicator/RightArea

# 动画相关
var pulse_tween: Tween
var guide_style: StyleBoxFlat

# 教程步骤
var current_step = 0
var tutorial_steps = []

# 是否从游戏中进入教程（用于显示返回按钮）
var from_game = false

func _ready():
	"""初始化教程"""
	# 检查是否从游戏中进入教程
	from_game = has_played_before()

	if from_game:
		print("从游戏中进入教程")
	else:
		print("首次游戏，显示完整教程")

	setup_tutorial_steps()
	setup_touch_guide_style()
	show_current_step()

func setup_tutorial_steps():
	"""设置教程步骤"""
	tutorial_steps = [
		{
			"title": "欢迎来到萌爪集星！",
			"instruction": "这是一个简单有趣的星星收集游戏\n\n🌟 收集掉落的星星获得分数\n⭐ 金色特殊星星价值更高\n❤️ 不要漏接星星，会失去生命",
			"hint": "准备好开始学习游戏操作了吗？",
			"show_touch": false
		},
		{
			"title": "移动控制",
			"instruction": "✨ 优雅的触屏控制：\n\n👈 轻触屏幕左侧 → 向左移动\n👉 轻触屏幕右侧 → 向右移动\n\n⌨️ 键盘控制：\n• A键或←键 → 向左移动\n• D键或→键 → 向右移动",
			"hint": "试试轻触下方的半透明区域，感受流畅的操作体验！",
			"show_touch": true
		},
		{
			"title": "游戏目标",
			"instruction": "🎯 游戏目标：\n• 收集尽可能多的星星\n• 获得更高的分数\n• 避免漏接星星失去生命\n\n⏰ 游戏时间：60秒\n❤️ 生命值：3点",
			"hint": "当生命值归零或时间结束时游戏结束",
			"show_touch": false
		},
		{
			"title": "星星类型",
			"instruction": "🌟 普通星星：10分\n⭐ 特殊星星：50分\n\n特殊星星会发光并且更大，\n收集它们可以快速提高分数！",
			"hint": "特殊星星出现频率较低，要抓住机会！",
			"show_touch": false
		},
		{
			"title": "准备开始",
			"instruction": "🎮 现在您已经了解了游戏的基本操作！\n\n记住：\n• 左右移动收集星星\n• 不要漏接星星\n• 特殊星星价值更高\n• 在时间结束前获得最高分数",
			"hint": "点击\"开始游戏\"按钮开始您的星星收集之旅！",
			"show_touch": false
		}
	]

func setup_touch_guide_style():
	"""设置触屏引导的优雅样式"""
	# 创建毛玻璃效果样式
	guide_style = StyleBoxFlat.new()

	# 背景色 - 半透明蓝色
	guide_style.bg_color = Color(0.2, 0.4, 0.8, 0.15)

	# 边框 - 淡蓝色发光效果
	guide_style.border_width_left = 2
	guide_style.border_width_top = 2
	guide_style.border_width_right = 2
	guide_style.border_width_bottom = 2
	guide_style.border_color = Color(0.4, 0.6, 1, 0.4)

	# 圆角
	guide_style.corner_radius_top_left = 20
	guide_style.corner_radius_top_right = 20
	guide_style.corner_radius_bottom_right = 20
	guide_style.corner_radius_bottom_left = 20

	# 阴影效果
	guide_style.shadow_color = Color(0, 0, 0, 0.1)
	guide_style.shadow_size = 5
	guide_style.shadow_offset = Vector2(0, 2)

	# 应用样式到触屏区域
	if left_area:
		left_area.add_theme_stylebox_override("panel", guide_style)
	if right_area:
		right_area.add_theme_stylebox_override("panel", guide_style)

func show_current_step():
	"""显示当前步骤"""
	if current_step >= 0 and current_step < tutorial_steps.size():
		var step = tutorial_steps[current_step]

		# 更新UI
		step_label.text = "第 %d 步 / %d" % [current_step + 1, tutorial_steps.size()]
		instruction_label.text = step.instruction
		hint_label.text = step.hint

		# 显示/隐藏触屏指示器
		touch_indicator.visible = step.show_touch

		# 如果显示触屏指示器，启动脉冲动画
		if step.show_touch:
			start_pulse_animation()
		else:
			stop_pulse_animation()

		# 更新按钮状态
		prev_button.visible = current_step > 0
		next_button.visible = current_step < tutorial_steps.size() - 1
		start_button.visible = current_step == tutorial_steps.size() - 1

		# 如果从游戏中进入，修改最后一步的按钮文本
		if from_game and current_step == tutorial_steps.size() - 1:
			start_button.text = "返回游戏"

		print("显示教程步骤: ", current_step + 1)

func _on_prev_button_pressed():
	"""上一步按钮"""
	if current_step > 0:
		current_step -= 1
		show_current_step()

func _on_next_button_pressed():
	"""下一步按钮"""
	if current_step < tutorial_steps.size() - 1:
		current_step += 1
		show_current_step()

func _on_start_button_pressed():
	"""开始游戏按钮"""
	print("开始游戏")
	stop_pulse_animation()  # 清理动画
	mark_tutorial_completed()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func has_played_before() -> bool:
	"""检查是否之前玩过游戏"""
	var save_file = "user://tutorial_completed.save"
	return FileAccess.file_exists(save_file)

func mark_tutorial_completed():
	"""标记教程已完成"""
	var save_file = FileAccess.open("user://tutorial_completed.save", FileAccess.WRITE)
	if save_file:
		save_file.store_string("completed")
		save_file.close()
	print("教程已完成并保存")

func _input(event):
	"""处理输入事件"""
	# 允许玩家在教程中测试触屏控制
	if touch_indicator.visible and event is InputEventScreenTouch:
		if event.pressed:
			test_touch_control(event.position)
	elif touch_indicator.visible and event is InputEventMouseButton:
		if event.pressed:
			test_touch_control(event.position)

func _unhandled_input(event):
	"""处理未被UI处理的输入事件"""
	# 确保在触屏区域外的点击也能被处理
	if touch_indicator.visible and (event is InputEventScreenTouch or event is InputEventMouseButton):
		if event.pressed:
			test_touch_control(event.position)

func test_touch_control(pos: Vector2):
	"""测试触屏控制"""
	var screen_size = get_viewport().get_visible_rect().size
	var screen_center = screen_size.x / 2

	# 检查点击是否在触屏引导区域内（屏幕下方65%-95%区域）
	var touch_area_top = screen_size.y * 0.65
	var touch_area_bottom = screen_size.y * 0.95

	if pos.y >= touch_area_top and pos.y <= touch_area_bottom:
		if pos.x < screen_center:
			print("测试：向左移动")
			flash_area(left_area)
		else:
			print("测试：向右移动")
			flash_area(right_area)

func start_pulse_animation():
	"""启动优雅的脉冲动画"""
	stop_pulse_animation()  # 先停止之前的动画

	# 简化的脉冲动画 - 两个区域同步脉冲
	pulse_tween = create_tween()
	pulse_tween.set_loops()

	# 同时对两个区域进行脉冲动画
	pulse_tween.tween_method(_update_pulse_alpha, 0.3, 0.8, 1.5)
	pulse_tween.tween_method(_update_pulse_alpha, 0.8, 0.3, 1.5)

func _update_pulse_alpha(alpha: float):
	"""更新脉冲透明度"""
	if left_area:
		left_area.modulate.a = alpha
	if right_area:
		right_area.modulate.a = alpha * 0.9  # 右侧稍微暗一点，产生层次感

func stop_pulse_animation():
	"""停止脉冲动画"""
	if pulse_tween:
		pulse_tween.kill()
		pulse_tween = null

	# 重置透明度
	if left_area:
		left_area.modulate.a = 0.8
	if right_area:
		right_area.modulate.a = 0.8

func flash_area(area: Panel):
	"""优雅的触摸反馈效果"""
	if not area:
		return

	# 创建触摸反馈动画
	var feedback_tween = create_tween()

	# 快速放大并变亮
	feedback_tween.parallel().tween_property(area, "scale", Vector2(1.05, 1.05), 0.1)
	feedback_tween.parallel().tween_property(area, "modulate", Color(1.2, 1.2, 1.5, 1.0), 0.1)

	# 恢复原状
	feedback_tween.parallel().tween_property(area, "scale", Vector2(1.0, 1.0), 0.2)
	feedback_tween.parallel().tween_property(area, "modulate", Color(1, 1, 1, 0.8), 0.2)
