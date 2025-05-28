# 语法测试脚本
extends SceneTree

func _init():
	print("=== 语法检查测试 ===")
	
	# 测试Tutorial.gd是否可以正常加载
	var tutorial_script = load("res://scripts/Tutorial.gd")
	if tutorial_script:
		print("✅ Tutorial.gd 语法正确，可以正常加载")
	else:
		print("❌ Tutorial.gd 加载失败")
	
	# 测试Main.gd是否可以正常加载
	var main_script = load("res://scripts/Main.gd")
	if main_script:
		print("✅ Main.gd 语法正确，可以正常加载")
	else:
		print("❌ Main.gd 加载失败")
	
	# 测试Player.gd是否可以正常加载
	var player_script = load("res://scripts/Player.gd")
	if player_script:
		print("✅ Player.gd 语法正确，可以正常加载")
	else:
		print("❌ Player.gd 加载失败")
	
	print("=== 语法检查完成 ===")
	quit()
