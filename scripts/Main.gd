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

# 音频节点引用
@onready var star_collect_sound = $AudioPlayers/StarCollectSound
@onready var special_star_sound = $AudioPlayers/SpecialStarSound
@onready var game_over_sound = $AudioPlayers/GameOverSound
@onready var background_music = $AudioPlayers/BackgroundMusic

func _ready():
	"""游戏初始化"""
	print("萌爪集星游戏开始!")
	update_ui()

	# 加载音效文件
	load_audio_files()

	# 连接玩家信号
	if player:
		player.star_collected.connect(_on_star_collected)
		player.life_lost.connect(_on_life_lost)

func load_audio_files():
	"""加载音效文件"""
	var audio_loaded = true

	if star_collect_sound:
		var audio_resource = load("res://assets/sounds/star_collect.wav")
		if audio_resource:
			star_collect_sound.stream = audio_resource
		else:
			audio_loaded = false

	if special_star_sound:
		var audio_resource = load("res://assets/sounds/special_star.wav")
		if audio_resource:
			special_star_sound.stream = audio_resource
		else:
			audio_loaded = false

	if game_over_sound:
		var audio_resource = load("res://assets/sounds/game_over.wav")
		if audio_resource:
			game_over_sound.stream = audio_resource
		else:
			audio_loaded = false

	if background_music:
		var audio_resource = load("res://assets/music/background.wav")
		if audio_resource:
			background_music.stream = audio_resource
			background_music.volume_db = -10.0
			background_music.autoplay = true
			# 手动播放背景音乐，确保它开始播放
			background_music.play()
			print("背景音乐开始播放")
		else:
			audio_loaded = false

	if audio_loaded:
		print("音效文件加载完成")
	else:
		print("部分音效文件加载失败，游戏将以静音模式运行")

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

	# 设置星星的随机水平位置（适应竖屏480宽度）
	var spawn_x = randf_range(50, 430)  # 480 - 50 = 430
	star_instance.position = Vector2(spawn_x, -50)

	# 连接星星信号
	star_instance.star_missed.connect(_on_star_missed)

	# 添加到场景
	add_child(star_instance)

func _on_star_collected(points: int):
	"""星星被收集时的回调"""
	score += points
	update_ui()

	# 播放音效
	if points == 50:  # 特殊星星
		if special_star_sound and special_star_sound.stream:
			special_star_sound.play()
			print("播放特殊星星音效")
		else:
			print("特殊星星音效播放失败 - 音频节点或流为空")
	else:  # 普通星星
		if star_collect_sound and star_collect_sound.stream:
			star_collect_sound.play()
			print("播放普通星星音效")
		else:
			print("普通星星音效播放失败 - 音频节点或流为空")

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

	# 停止背景音乐
	if background_music:
		background_music.stop()

	# 设置音频播放器不受暂停影响
	if game_over_sound and game_over_sound.stream:
		game_over_sound.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		game_over_sound.play()
		print("播放游戏结束音效")
	else:
		print("游戏结束音效播放失败 - 音频节点或流为空")

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

func _on_tutorial_button_pressed():
	"""教程按钮回调"""
	print("显示操作指南")
	# 跳转到教程场景
	get_tree().change_scene_to_file("res://scenes/Tutorial.tscn")
