extends CharacterBody2D

# 玩家控制脚本
# 处理玩家移动和碰撞检测

# 信号定义 - 用于与主场景通信
signal star_collected(points: int)
signal life_lost

# 移动参数
@export var speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# 屏幕边界
var screen_size: Vector2

func _ready():
	"""初始化玩家"""
	screen_size = get_viewport_rect().size
	print("玩家初始化完成")

func _physics_process(delta):
	"""物理更新 - 处理玩家移动"""
	handle_input(delta)
	move_and_slide()
	clamp_to_screen()

func handle_input(delta):
	"""处理输入控制"""
	var input_direction = 0

	# 检测左右移动输入
	if Input.is_action_pressed("move_left"):
		input_direction -= 1
	if Input.is_action_pressed("move_right"):
		input_direction += 1

	# 应用移动逻辑
	if input_direction != 0:
		# 有输入时加速
		velocity.x = move_toward(velocity.x, input_direction * speed, acceleration * delta)
	else:
		# 无输入时减速
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func clamp_to_screen():
	"""限制玩家在屏幕范围内"""
	var half_width = 40  # 玩家精灵的一半宽度
	position.x = clamp(position.x, half_width, screen_size.x - half_width)

func _on_area_2d_area_entered(area):
	"""检测到区域进入 - 处理星星收集"""
	var star = area.get_parent()

	if star.has_method("collect"):
		var points = star.collect()
		star_collected.emit(points)
		print("玩家收集到星星，获得 ", points, " 分!")

# 可选：鼠标控制支持
func _input(event):
	"""处理鼠标输入（可选功能）"""
	if event is InputEventMouseMotion:
		# 可以启用鼠标控制
		# position.x = event.position.x
		pass
