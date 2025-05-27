extends Node2D

# 游戏主控制脚本
# 负责管理游戏状态、分数、生命值和星星生成

# 预加载星星场景
@export var star_scene: PackedScene = preload("res://scenes/Star.tscn")
@export var special_star_scene: PackedScene = preload("res://scenes/SpecialStar.tscn")

# 游戏状态变量
var score: int = 0
var lives: int = 3
var game_over: bool = false

# 星星生成相关
var star_spawn_timer: float = 1.5
var min_spawn_time: float = 0.8
var spawn_time_decrease: float = 0.02

# UI节点引用
@onready var score_label = $UI/ScoreLabel
@onready var lives_label = $UI/LivesLabel
@onready var game_over_panel = $UI/GameOverPanel
@onready var star_spawner = $StarSpawner
@onready var player = $Player

func _ready():
	"""游戏初始化"""
	print("萌爪集星游戏开始!")
	update_ui()

	# 连接玩家信号
	if player:
		player.star_collected.connect(_on_star_collected)
		player.life_lost.connect(_on_life_lost)

func _on_star_spawner_timeout():
	"""星星生成器超时回调 - 生成新的星星"""
	if game_over:
		return

	spawn_star()

	# 逐渐增加游戏难度
	if star_spawn_timer > min_spawn_time:
		star_spawn_timer -= spawn_time_decrease
		star_spawner.wait_time = star_spawn_timer

func spawn_star():
	"""生成星星的函数"""
	# 随机选择生成普通星星还是特殊星星 (10%概率生成特殊星星)
	var star_instance
	if randf() < 0.1:
		star_instance = special_star_scene.instantiate()
	else:
		star_instance = star_scene.instantiate()

	# 设置星星的随机水平位置
	var spawn_x = randf_range(50, get_viewport().size.x - 50)
	star_instance.position = Vector2(spawn_x, -50)

	# 连接星星信号
	star_instance.star_missed.connect(_on_star_missed)

	# 添加到场景
	add_child(star_instance)

func _on_star_collected(points: int):
	"""星星被收集时的回调"""
	score += points
	update_ui()
	print("收集到星星! 获得 ", points, " 分")

func _on_life_lost():
	"""失去生命时的回调"""
	lives -= 1
	update_ui()
	print("失去一条生命! 剩余生命: ", lives)

	if lives <= 0:
		end_game()

func _on_star_missed():
	"""星星漏接时的回调"""
	lives -= 1
	update_ui()
	print("漏接星星! 剩余生命: ", lives)

	if lives <= 0:
		end_game()

func update_ui():
	"""更新UI显示"""
	if score_label:
		score_label.text = "分数: " + str(score)
	if lives_label:
		lives_label.text = "生命: " + str(lives)

func end_game():
	"""游戏结束处理"""
	game_over = true
	star_spawner.stop()

	# 暂停游戏（除了UI）
	get_tree().paused = true

	# 设置游戏结束面板为不受暂停影响
	if game_over_panel:
		game_over_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		game_over_panel.visible = true

	print("游戏结束! 最终分数: ", score)

func clear_all_stars():
	"""清除场景中所有的星星"""
	# 获取所有子节点
	for child in get_children():
		# 检查是否是星星节点（通过组或脚本判断）
		if child.has_method("collect") or child.name.begins_with("Star") or child.name.begins_with("SpecialStar"):
			child.queue_free()

func _on_restart_button_pressed():
	"""重新开始按钮回调"""
	print("重新开始游戏")
	# 取消暂停
	get_tree().paused = false
	# 重新加载场景
	get_tree().reload_current_scene()
