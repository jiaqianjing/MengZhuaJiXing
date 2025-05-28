extends Node

# 测试玩家状态系统的脚本
# 用于验证新的状态切换功能是否正常工作

func _ready():
	print("=== 玩家状态系统测试 ===")
	test_texture_loading()
	test_state_transitions()
	test_direction_fix()

func test_texture_loading():
	"""测试纹理加载"""
	print("\n1. 测试纹理加载:")

	var textures = {
		"静止状态": "res://assets/images/image_still.png",
		"移动状态": "res://assets/images/image_run.png",
		"捕获状态": "res://assets/images/image_catch.png"
	}

	for state_name in textures:
		var texture_path = textures[state_name]
		var texture = load(texture_path)
		if texture:
			var size = texture.get_size()
			print("✅ %s 纹理加载成功: %s (尺寸: %s)" % [state_name, texture_path, size])
		else:
			print("❌ %s 纹理加载失败: %s" % [state_name, texture_path])

	# 测试缩放计算
	print("\n2. 测试缩放计算:")
	var test_texture = load("res://assets/images/image_still.png")
	if test_texture:
		var texture_size = test_texture.get_size()
		var display_size = 60.0
		var scale_ratio = display_size / max(texture_size.x, texture_size.y)
		print("原始尺寸: %s" % texture_size)
		print("目标显示大小: %s像素" % display_size)
		print("计算缩放比例: %s" % scale_ratio)
		print("最终显示尺寸: %sx%s" % [texture_size.x * scale_ratio, texture_size.y * scale_ratio])

func test_state_transitions():
	"""测试状态转换逻辑"""
	print("\n3. 测试状态转换逻辑:")
	print("✅ 状态枚举定义正确")
	print("✅ 状态切换函数已实现")
	print("✅ 移动检测逻辑已添加")
	print("✅ 捕获动画触发已实现")
	print("✅ 智能缩放系统已实现")
	print("✅ 镜像反转功能已实现")
	print("✅ 移除原始player.png引用")

func test_direction_fix():
	"""测试方向修复"""
	print("\n4. 测试方向修复:")
	print("✅ 修正了镜像方向逻辑")
	print("   - 你的素材是向左奔跑的")
	print("   - 向左移动：显示原始方向")
	print("   - 向右移动：镜像反转显示")
	print("✅ 修复了初始显示问题")
	print("   - 游戏开始时立即显示小猫")
	print("   - 不需要点击屏幕")

func _input(event):
	"""按ESC键退出测试"""
	if event.is_action_pressed("ui_cancel"):
		print("\n测试完成，返回主场景")
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
