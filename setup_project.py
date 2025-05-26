#!/usr/bin/env python3
"""
萌爪集星项目设置脚本
自动生成游戏资源并提供详细的操作指导
"""

import os
import sys
import subprocess

def print_header():
    """打印项目标题"""
    print("=" * 60)
    print("🌟 萌爪集星 - Godot 2D休闲游戏项目 🌟")
    print("=" * 60)
    print()

def check_dependencies():
    """检查依赖库"""
    print("📋 检查依赖库...")
    
    missing_deps = []
    
    try:
        import PIL
        print("✓ PIL (Pillow) 已安装")
    except ImportError:
        missing_deps.append("Pillow")
    
    try:
        import numpy
        print("✓ NumPy 已安装")
    except ImportError:
        missing_deps.append("numpy")
    
    if missing_deps:
        print(f"\n❌ 缺少依赖库: {', '.join(missing_deps)}")
        print("请运行以下命令安装:")
        print(f"pip install {' '.join(missing_deps)}")
        return False
    
    print("✅ 所有依赖库已安装")
    return True

def generate_assets():
    """生成游戏资源"""
    print("\n🎨 生成游戏资源...")
    
    try:
        # 生成图像资源
        print("生成图像资源...")
        result = subprocess.run([sys.executable, "generate_assets.py"], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print("✓ 图像资源生成成功")
        else:
            print(f"❌ 图像资源生成失败: {result.stderr}")
            return False
        
        # 生成音效资源
        print("生成音效资源...")
        result = subprocess.run([sys.executable, "generate_sounds.py"], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print("✓ 音效资源生成成功")
        else:
            print(f"❌ 音效资源生成失败: {result.stderr}")
            return False
        
        return True
    except Exception as e:
        print(f"❌ 资源生成过程中出错: {e}")
        return False

def show_project_structure():
    """显示项目结构"""
    print("\n📁 项目结构:")
    print("""
MengZhuaJiXing/
├── project.godot          # Godot项目配置文件
├── scenes/                # 场景文件
│   ├── Main.tscn          # 主游戏场景
│   ├── Player.tscn        # 玩家场景
│   ├── Star.tscn          # 普通星星场景
│   └── SpecialStar.tscn   # 特殊星星场景
├── scripts/               # 脚本文件
│   ├── Main.gd            # 主游戏逻辑
│   ├── Player.gd          # 玩家控制
│   ├── Star.gd            # 普通星星逻辑
│   └── SpecialStar.gd     # 特殊星星逻辑
├── assets/                # 资源文件
│   ├── images/            # 图像资源
│   ├── sounds/            # 音效文件
│   └── music/             # 背景音乐
├── README.md              # 项目说明
├── GODOT_GUIDE.md         # Godot学习指南
└── setup_project.py       # 项目设置脚本
    """)

def show_godot_instructions():
    """显示Godot操作指导"""
    print("\n🚀 Godot 引擎操作指导:")
    print("""
第一步：安装 Godot 引擎
1. 访问 https://godotengine.org/download
2. 下载 Godot 4.3 或更新版本
3. 根据您的操作系统选择对应版本

第二步：导入项目
1. 启动 Godot Hub
2. 点击"导入"按钮
3. 选择本项目的 project.godot 文件
4. 点击"导入并编辑"

第三步：运行游戏
1. 在 Godot 编辑器中，点击右上角的播放按钮 ▶️
2. 如果提示选择主场景，选择 scenes/Main.tscn
3. 游戏窗口会打开，您可以开始游戏了！

游戏控制：
- 左右方向键 或 A/D键：移动小猫爪
- 目标：接住掉落的星星获得分数
- 注意：不要漏接星星，会扣生命值！
    """)

def show_learning_resources():
    """显示学习资源"""
    print("\n📚 学习资源:")
    print("""
1. README.md - 项目详细说明和游戏特色介绍
2. GODOT_GUIDE.md - 完整的Godot引擎学习指南
3. Godot官方文档: https://docs.godotengine.org/
4. GDScript教程: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/

建议学习顺序：
1. 先阅读 GODOT_GUIDE.md 了解基础概念
2. 在Godot中打开项目，熟悉编辑器界面
3. 运行游戏，体验完整的游戏流程
4. 查看和修改脚本代码，理解游戏逻辑
5. 尝试修改游戏参数，如分数、速度等
6. 添加新功能，如新的星星类型、音效等
    """)

def show_customization_tips():
    """显示自定义建议"""
    print("\n🎨 自定义建议:")
    print("""
简单修改：
1. 调整游戏难度：修改 scripts/Main.gd 中的 star_spawn_timer
2. 更改分数：修改星星脚本中的 points_value
3. 调整移动速度：修改 scripts/Player.gd 中的 speed

进阶功能：
1. 添加新的星星类型
2. 实现道具系统（如加速、减速）
3. 添加背景音乐和音效
4. 创建开始菜单和设置界面
5. 实现最高分记录系统

替换资源：
1. 将新的图像文件放入 assets/images/ 文件夹
2. 在Godot中重新分配纹理资源
3. 调整碰撞形状以匹配新图像
    """)

def main():
    """主函数"""
    print_header()
    
    # 检查依赖
    if not check_dependencies():
        print("\n请先安装依赖库，然后重新运行此脚本。")
        return
    
    # 生成资源
    if not generate_assets():
        print("\n资源生成失败，请检查错误信息。")
        return
    
    # 显示项目信息
    show_project_structure()
    show_godot_instructions()
    show_learning_resources()
    show_customization_tips()
    
    print("\n" + "=" * 60)
    print("🎉 项目设置完成！")
    print("现在您可以在 Godot 中打开项目开始学习了！")
    print("祝您学习愉快！🌟")
    print("=" * 60)

if __name__ == "__main__":
    main()
