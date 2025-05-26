extends RigidBody2D

# 特殊星星脚本
# 继承自普通星星，但有更高的分值和特殊效果

# 信号定义
signal star_missed

# 特殊星星属性
@export var fall_speed: float = 120.0  # 稍慢一些
@export var points_value: int = 50     # 更高分值
@export var rotation_speed: float = 4.0  # 更快旋转
@export var pulse_speed: float = 3.0   # 脉动效果速度

# 状态变量
var collected: bool = false
var time_passed: float = 0.0

func _ready():
	"""初始化特殊星星"""
	# 设置下落速度
	linear_velocity = Vector2(0, fall_speed)

	# 添加一些随机的水平速度
	linear_velocity.x = randf_range(-20, 20)

	print("特殊星星生成，价值: ", points_value, " 分")

func _physics_process(delta):
	"""物理更新 - 处理旋转和脉动动画"""
	if not collected:
		time_passed += delta

		# 旋转动画
		rotation += rotation_speed * delta

		# 脉动效果 - 让星星大小周期性变化
		var pulse_scale = 1.0 + sin(time_passed * pulse_speed) * 0.2
		scale = Vector2(pulse_scale * 2, pulse_scale * 2)

func collect() -> int:
	"""特殊星星被收集时调用"""
	if collected:
		return 0

	collected = true

	# 播放特殊收集动画（闪烁效果）
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(self, "modulate", Color.YELLOW, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

	# 缩放消失
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)

	# 延迟删除（不阻塞返回值）
	tween.finished.connect(queue_free)

	return points_value

func _on_visibility_notifier_2d_screen_exited():
	"""特殊星星离开屏幕时"""
	if not collected:
		print("特殊星星漏接了! 损失了 ", points_value, " 分")
		star_missed.emit()

	queue_free()
