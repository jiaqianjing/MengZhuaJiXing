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

# 玩家状态枚举
enum PlayerState {
	STILL,    # 静止状态
	RUNNING,  # 移动状态
	CATCHING  # 捕获星星状态
}

# 状态相关变量
var current_state: PlayerState = PlayerState.STILL
var catch_animation_timer: float = 0.0
var catch_animation_duration: float = 0.3  # 捕获动画持续时间

# 移动方向
var last_movement_direction: float = 1.0  # 1.0 = 向右, -1.0 = 向左

# 显示设置
@export var player_display_size: float = 60.0  # 玩家显示大小（像素）

# 纹理资源
@export var still_texture: Texture2D
@export var run_texture: Texture2D
@export var catch_texture: Texture2D

# 屏幕边界
var screen_size: Vector2

# 触屏控制
var touch_input_direction: float = 0.0

# 节点引用
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	"""初始化玩家"""
	screen_size = get_viewport_rect().size

	# 确保精灵节点可见
	if sprite:
		sprite.visible = true

	# 加载纹理资源
	load_textures()

	# 设置初始状态（这会立即显示静止纹理）
	change_state(PlayerState.STILL)

	# 确保纹理立即应用
	if sprite and sprite.texture:
		adjust_sprite_scale(sprite.texture)

	print("玩家初始化完成，当前纹理: ", sprite.texture)

func load_textures():
	"""加载所有状态的纹理资源"""
	still_texture = load("res://assets/images/image_still.png")
	run_texture = load("res://assets/images/image_run.png")
	catch_texture = load("res://assets/images/image_catch.png")

	if not still_texture or not run_texture or not catch_texture:
		print("警告：部分玩家纹理加载失败，使用默认纹理")
		# 如果新纹理加载失败，使用原始纹理作为备用
		var default_texture = load("res://assets/images/player.png")
		if not still_texture:
			still_texture = default_texture
		if not run_texture:
			run_texture = default_texture
		if not catch_texture:
			catch_texture = default_texture
	else:
		print("所有玩家状态纹理加载成功")

func change_state(new_state: PlayerState):
	"""改变玩家状态并更新纹理"""
	if current_state == new_state:
		return

	current_state = new_state

	# 根据状态更新纹理和缩放
	match current_state:
		PlayerState.STILL:
			sprite.texture = still_texture
			adjust_sprite_scale(still_texture)
			print("切换到静止状态")
		PlayerState.RUNNING:
			sprite.texture = run_texture
			adjust_sprite_scale(run_texture)
			# 根据移动方向设置镜像
			update_sprite_direction()
			print("切换到移动状态，方向: ", last_movement_direction)
		PlayerState.CATCHING:
			sprite.texture = catch_texture
			adjust_sprite_scale(catch_texture)
			catch_animation_timer = catch_animation_duration
			print("切换到捕获状态")

func update_sprite_direction():
	"""根据移动方向更新精灵镜像"""
	# 你的素材是向左奔跑的，所以向右移动时需要镜像反转
	if last_movement_direction > 0:  # 向右移动
		sprite.scale.x = abs(sprite.scale.x) * -1  # 镜像反转（负缩放）
	else:  # 向左移动
		sprite.scale.x = abs(sprite.scale.x)  # 保持原始方向（正缩放）

func adjust_sprite_scale(texture: Texture2D):
	"""根据纹理大小调整精灵缩放，保持合适的显示尺寸"""
	if not texture:
		return

	# 计算缩放比例，使用可调整的显示大小
	var texture_size = texture.get_size()
	var scale_ratio = player_display_size / max(texture_size.x, texture_size.y)

	# 保持当前的方向（正负值）
	var current_x_direction = 1.0 if sprite.scale.x >= 0 else -1.0

	# 应用统一缩放，保持宽高比和方向
	sprite.scale = Vector2(scale_ratio * current_x_direction, scale_ratio)

	print("纹理尺寸: %s, 目标大小: %s像素, 应用缩放: %s" % [texture_size, player_display_size, scale_ratio])

func _physics_process(delta):
	"""物理更新 - 处理玩家移动"""
	handle_input(delta)
	move_and_slide()
	clamp_to_screen()
	update_state(delta)

func update_state(delta):
	"""更新玩家状态"""
	# 处理捕获动画计时器
	if current_state == PlayerState.CATCHING:
		catch_animation_timer -= delta
		if catch_animation_timer <= 0:
			# 捕获动画结束，根据当前移动状态切换
			if abs(velocity.x) > 10:  # 如果还在移动
				change_state(PlayerState.RUNNING)
			else:
				change_state(PlayerState.STILL)
		return  # 捕获状态期间不改变其他状态

	# 根据移动速度更新状态
	if abs(velocity.x) > 10:  # 移动阈值
		if current_state != PlayerState.RUNNING:
			change_state(PlayerState.RUNNING)
	else:
		if current_state != PlayerState.STILL:
			change_state(PlayerState.STILL)

func handle_input(delta):
	"""处理输入控制 - 支持键盘和触屏"""
	var input_direction = 0

	# 检测键盘左右移动输入
	if Input.is_action_pressed("move_left"):
		input_direction -= 1
	if Input.is_action_pressed("move_right"):
		input_direction += 1

	# 检测触屏输入
	var touch_input = get_touch_input()
	if touch_input != 0:
		input_direction = touch_input

	# 记录移动方向（用于镜像反转）
	if input_direction != 0:
		last_movement_direction = input_direction

	# 应用移动逻辑
	if input_direction != 0:
		# 有输入时加速
		velocity.x = move_toward(velocity.x, input_direction * speed, acceleration * delta)
	else:
		# 无输入时减速
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func get_touch_input() -> float:
	"""获取触屏输入方向"""
	# 使用触屏控制变量
	return touch_input_direction

func _input(event):
	"""处理触屏和鼠标输入"""
	# 处理触屏事件
	if event is InputEventScreenTouch:
		handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		handle_screen_drag(event)
	# 处理鼠标事件（用于桌面测试）
	elif event is InputEventMouseButton:
		if event.pressed:
			handle_mouse_input(event.position)
		else:
			touch_input_direction = 0.0

func handle_screen_touch(event: InputEventScreenTouch):
	"""处理触屏触摸事件"""
	if event.pressed:
		handle_touch_position(event.position)
	else:
		touch_input_direction = 0.0

func handle_screen_drag(event: InputEventScreenDrag):
	"""处理触屏拖拽事件"""
	handle_touch_position(event.position)

func handle_mouse_input(mouse_pos: Vector2):
	"""处理鼠标输入（用于桌面测试）"""
	handle_touch_position(mouse_pos)

func handle_touch_position(touch_pos: Vector2):
	"""根据触摸位置确定移动方向"""
	var screen_center = screen_size.x / 2

	if touch_pos.x < screen_center:
		touch_input_direction = -1.0  # 向左移动
		print("触屏：向左移动")
	else:
		touch_input_direction = 1.0   # 向右移动
		print("触屏：向右移动")

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

		# 触发捕获状态动画
		change_state(PlayerState.CATCHING)

		print("玩家收集到星星，获得 ", points, " 分!")
