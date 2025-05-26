extends RigidBody2D

# 普通星星脚本
# 处理星星的下落、收集和消失

# 信号定义
signal star_missed

# 星星属性
@export var fall_speed: float = 150.0
@export var points_value: int = 10
@export var rotation_speed: float = 2.0

# 状态变量
var collected: bool = false

func _ready():
	"""初始化星星"""
	# 设置下落速度
	linear_velocity = Vector2(0, fall_speed)

	# 添加一些随机的水平速度
	linear_velocity.x = randf_range(-30, 30)

	print("普通星星生成，价值: ", points_value, " 分")

func _physics_process(delta):
	"""物理更新 - 处理旋转动画"""
	if not collected:
		rotation += rotation_speed * delta

func collect() -> int:
	"""星星被收集时调用"""
	if collected:
		return 0

	collected = true

	# 播放收集动画（简单的缩放效果）
	create_tween().tween_property(self, "scale", Vector2.ZERO, 0.2)

	# 延迟删除（不阻塞返回值）
	get_tree().create_timer(0.2).timeout.connect(queue_free)

	return points_value

func _on_visibility_notifier_2d_screen_exited():
	"""星星离开屏幕时"""
	if not collected:
		print("星星漏接了!")
		star_missed.emit()

	queue_free()
