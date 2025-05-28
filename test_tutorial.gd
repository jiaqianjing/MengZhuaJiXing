# 测试脚本 - 用于重置教程状态
extends SceneTree

func _init():
	print("=== 萌爪集星 - 教程测试脚本 ===")
	
	# 删除教程完成标记，模拟首次游戏
	var save_file = "user://tutorial_completed.save"
	if FileAccess.file_exists(save_file):
		DirAccess.remove_absolute(save_file)
		print("✅ 教程状态已重置 - 下次启动将显示教程")
	else:
		print("ℹ️  教程状态已经是首次游戏状态")
	
	print("=== 测试完成 ===")
	quit()
