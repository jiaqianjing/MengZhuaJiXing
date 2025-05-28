# 测试优雅教程效果
extends SceneTree

func _init():
	print("=== 萌爪集星 - 优雅教程测试 ===")
	
	# 重置教程状态，确保能看到完整教程
	var save_file = "user://tutorial_completed.save"
	if FileAccess.file_exists(save_file):
		DirAccess.remove_absolute(save_file)
		print("✅ 教程状态已重置")
	
	print("🎨 新的优雅触屏引导特性：")
	print("   • 半透明毛玻璃效果")
	print("   • 淡蓝色发光边框")
	print("   • 圆角设计")
	print("   • 优雅的脉冲动画")
	print("   • 触摸反馈效果")
	print("   • 更友好的文案和图标")
	
	print("\n🚀 启动游戏查看效果...")
	print("=== 测试完成 ===")
	quit()
