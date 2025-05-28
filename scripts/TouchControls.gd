extends Control

# 触屏控制脚本
# 为移动设备提供虚拟按钮控制

signal move_left_pressed
signal move_right_pressed
signal move_stopped

# 控制区域
var left_area: Rect2
var right_area: Rect2
var is_touching_left: bool = false
var is_touching_right: bool = false

# 触摸ID跟踪
var left_touch_id: int = -1
var right_touch_id: int = -1

func _ready():
	"""初始化触屏控制"""
	# 设置控制区域（屏幕左右两半）
	setup_control_areas()
	
	# 只在移动设备上显示
	if OS.has_feature("mobile"):
		visible = true
		print("触屏控制已启用")
	else:
		visible = false
		print("非移动设备，触屏控制已禁用")

func setup_control_areas():
	"""设置控制区域"""
	var screen_size = get_viewport().get_visible_rect().size
	
	# 左侧控制区域（屏幕左半部分）
	left_area = Rect2(0, 0, screen_size.x / 2, screen_size.y)
	
	# 右侧控制区域（屏幕右半部分）
	right_area = Rect2(screen_size.x / 2, 0, screen_size.x / 2, screen_size.y)

func _input(event):
	"""处理触屏输入事件"""
	if not visible:
		return
	
	if event is InputEventScreenTouch:
		handle_touch_event(event)
	elif event is InputEventScreenDrag:
		handle_drag_event(event)

func handle_touch_event(event: InputEventScreenTouch):
	"""处理触摸事件"""
	var touch_pos = event.position
	
	if event.pressed:
		# 触摸开始
		if left_area.has_point(touch_pos) and left_touch_id == -1:
			left_touch_id = event.index
			is_touching_left = true
			move_left_pressed.emit()
			print("开始向左移动")
		elif right_area.has_point(touch_pos) and right_touch_id == -1:
			right_touch_id = event.index
			is_touching_right = true
			move_right_pressed.emit()
			print("开始向右移动")
	else:
		# 触摸结束
		if event.index == left_touch_id:
			left_touch_id = -1
			is_touching_left = false
			if not is_touching_right:
				move_stopped.emit()
			print("停止向左移动")
		elif event.index == right_touch_id:
			right_touch_id = -1
			is_touching_right = false
			if not is_touching_left:
				move_stopped.emit()
			print("停止向右移动")

func handle_drag_event(event: InputEventScreenDrag):
	"""处理拖拽事件"""
	var touch_pos = event.position
	
	# 检查拖拽是否离开了原始区域
	if event.index == left_touch_id:
		if not left_area.has_point(touch_pos):
			# 拖拽离开左侧区域
			left_touch_id = -1
			is_touching_left = false
			if not is_touching_right:
				move_stopped.emit()
	elif event.index == right_touch_id:
		if not right_area.has_point(touch_pos):
			# 拖拽离开右侧区域
			right_touch_id = -1
			is_touching_right = false
			if not is_touching_left:
				move_stopped.emit()

func _draw():
	"""绘制触屏控制区域（调试用）"""
	if not visible or not OS.has_feature("debug"):
		return
	
	# 绘制半透明的控制区域
	var left_color = Color.BLUE
	var right_color = Color.RED
	left_color.a = 0.2
	right_color.a = 0.2
	
	if is_touching_left:
		left_color.a = 0.4
	if is_touching_right:
		right_color.a = 0.4
	
	draw_rect(left_area, left_color)
	draw_rect(right_area, right_color)
	
	# 绘制分割线
	var screen_size = get_viewport().get_visible_rect().size
	draw_line(
		Vector2(screen_size.x / 2, 0),
		Vector2(screen_size.x / 2, screen_size.y),
		Color.WHITE,
		2.0
	)

func get_current_input() -> float:
	"""获取当前输入方向"""
	if is_touching_left and is_touching_right:
		return 0.0  # 同时按下左右，不移动
	elif is_touching_left:
		return -1.0  # 向左
	elif is_touching_right:
		return 1.0   # 向右
	else:
		return 0.0   # 不移动
