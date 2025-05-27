extends Node2D

# 音频测试脚本 - 用于调试音效问题

# 音频播放器
@onready var star_sound = AudioStreamPlayer.new()
@onready var special_sound = AudioStreamPlayer.new()
@onready var game_over_sound = AudioStreamPlayer.new()
@onready var background_music = AudioStreamPlayer.new()

func _ready():
	"""初始化音频测试"""
	print("🎵 音频测试场景启动")

	# 添加音频播放器到场景
	add_child(star_sound)
	add_child(special_sound)
	add_child(game_over_sound)
	add_child(background_music)

	# 加载音频文件
	load_all_audio()

	print("按数字键1-4测试不同音效")

func load_all_audio():
	"""加载所有音频文件"""
	print("正在加载音频文件...")

	# 加载星星收集音效
	var star_audio = load("res://assets/sounds/star_collect.wav")
	if star_audio:
		star_sound.stream = star_audio
		print("✅ 星星收集音效加载成功")
	else:
		print("❌ 星星收集音效加载失败")

	# 加载特殊星星音效
	var special_audio = load("res://assets/sounds/special_star.wav")
	if special_audio:
		special_sound.stream = special_audio
		print("✅ 特殊星星音效加载成功")
	else:
		print("❌ 特殊星星音效加载失败")

	# 加载游戏结束音效
	var game_over_audio = load("res://assets/sounds/game_over.wav")
	if game_over_audio:
		game_over_sound.stream = game_over_audio
		print("✅ 游戏结束音效加载成功")
	else:
		print("❌ 游戏结束音效加载失败")

	# 加载背景音乐
	var bg_audio = load("res://assets/music/background.wav")
	if bg_audio:
		background_music.stream = bg_audio
		background_music.volume_db = -10.0
		print("✅ 背景音乐加载成功")
	else:
		print("❌ 背景音乐加载失败")

func _input(event):
	"""处理按键输入"""
	if event.is_action_pressed("ui_cancel"):  # ESC键
		print("返回主场景")
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		return

	if not event.pressed:
		return

	# 数字键测试音效
	if event is InputEventKey:
		match event.keycode:
			KEY_1:
				test_star_sound()
			KEY_2:
				test_special_sound()
			KEY_3:
				test_game_over_sound()
			KEY_4:
				toggle_background_music()

func test_star_sound():
	"""测试星星收集音效"""
	print("🌟 测试星星收集音效")
	if star_sound.stream:
		star_sound.play()
		print("播放星星收集音效")
	else:
		print("星星收集音效未加载")

func test_special_sound():
	"""测试特殊星星音效"""
	print("⭐ 测试特殊星星音效")
	if special_sound.stream:
		special_sound.play()
		print("播放特殊星星音效")
	else:
		print("特殊星星音效未加载")

func test_game_over_sound():
	"""测试游戏结束音效"""
	print("💀 测试游戏结束音效")
	if game_over_sound.stream:
		game_over_sound.play()
		print("播放游戏结束音效")
	else:
		print("游戏结束音效未加载")

func toggle_background_music():
	"""切换背景音乐"""
	if background_music.stream:
		if background_music.playing:
			background_music.stop()
			print("🎵 停止背景音乐")
		else:
			background_music.play()
			print("🎵 播放背景音乐")
	else:
		print("背景音乐未加载")
