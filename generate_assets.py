#!/usr/bin/env python3
"""
生成萌爪集星游戏的基本图像资源
使用PIL库创建简单的占位符图像
"""

from PIL import Image, ImageDraw
import os

def create_player_image():
    """创建玩家角色图像 - 可爱的小猫爪"""
    size = (40, 20)
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 绘制猫爪形状
    # 主体部分
    draw.ellipse([5, 5, 35, 15], fill=(255, 182, 193, 255))  # 粉色
    
    # 爪子部分
    draw.ellipse([8, 2, 12, 6], fill=(255, 105, 180, 255))   # 深粉色
    draw.ellipse([16, 1, 20, 5], fill=(255, 105, 180, 255))
    draw.ellipse([24, 1, 28, 5], fill=(255, 105, 180, 255))
    draw.ellipse([32, 2, 36, 6], fill=(255, 105, 180, 255))
    
    img.save('assets/images/player.png')
    print("✓ 玩家图像已生成")

def create_star_image():
    """创建普通星星图像"""
    size = (30, 30)
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 绘制五角星
    center = (15, 15)
    points = []
    import math
    
    for i in range(10):
        angle = i * math.pi / 5
        if i % 2 == 0:
            radius = 12
        else:
            radius = 6
        x = center[0] + radius * math.cos(angle - math.pi/2)
        y = center[1] + radius * math.sin(angle - math.pi/2)
        points.append((x, y))
    
    draw.polygon(points, fill=(255, 255, 0, 255))  # 黄色
    draw.polygon(points, outline=(255, 215, 0, 255), width=2)  # 金色边框
    
    img.save('assets/images/star.png')
    print("✓ 普通星星图像已生成")

def create_special_star_image():
    """创建特殊星星图像"""
    size = (35, 35)
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 绘制更大的五角星
    center = (17.5, 17.5)
    points = []
    import math
    
    for i in range(10):
        angle = i * math.pi / 5
        if i % 2 == 0:
            radius = 15
        else:
            radius = 7
        x = center[0] + radius * math.cos(angle - math.pi/2)
        y = center[1] + radius * math.sin(angle - math.pi/2)
        points.append((x, y))
    
    draw.polygon(points, fill=(255, 20, 147, 255))  # 深粉色
    draw.polygon(points, outline=(255, 255, 255, 255), width=2)  # 白色边框
    
    # 添加闪光效果
    draw.ellipse([14, 14, 21, 21], fill=(255, 255, 255, 128))
    
    img.save('assets/images/special_star.png')
    print("✓ 特殊星星图像已生成")

def create_icon():
    """创建游戏图标"""
    size = (64, 64)
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 背景圆形
    draw.ellipse([2, 2, 62, 62], fill=(75, 0, 130, 255))  # 紫色背景
    
    # 绘制星星
    center = (32, 32)
    points = []
    import math
    
    for i in range(10):
        angle = i * math.pi / 5
        if i % 2 == 0:
            radius = 25
        else:
            radius = 12
        x = center[0] + radius * math.cos(angle - math.pi/2)
        y = center[1] + radius * math.sin(angle - math.pi/2)
        points.append((x, y))
    
    draw.polygon(points, fill=(255, 255, 0, 255))
    
    img.save('assets/images/icon.png')
    print("✓ 游戏图标已生成")

def main():
    """主函数"""
    print("开始生成萌爪集星游戏资源...")
    
    # 确保目录存在
    os.makedirs('assets/images', exist_ok=True)
    
    try:
        create_player_image()
        create_star_image()
        create_special_star_image()
        create_icon()
        print("\n🎉 所有图像资源生成完成!")
        print("请在Godot中导入这些图像文件。")
    except ImportError:
        print("❌ 需要安装PIL库: pip install Pillow")
    except Exception as e:
        print(f"❌ 生成图像时出错: {e}")

if __name__ == "__main__":
    main()
