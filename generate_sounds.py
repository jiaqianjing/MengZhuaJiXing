#!/usr/bin/env python3
"""
生成萌爪集星游戏的基本音效文件
使用简单的正弦波生成音效
"""

import numpy as np
import wave
import os

def generate_tone(frequency, duration, sample_rate=44100, amplitude=0.3):
    """生成指定频率和时长的正弦波音调"""
    frames = int(duration * sample_rate)
    arr = np.zeros(frames)
    
    for i in range(frames):
        arr[i] = amplitude * np.sin(2 * np.pi * frequency * i / sample_rate)
    
    return arr

def save_wav(filename, audio_data, sample_rate=44100):
    """保存音频数据为WAV文件"""
    # 转换为16位整数
    audio_data = (audio_data * 32767).astype(np.int16)
    
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # 单声道
        wav_file.setsampwidth(2)  # 16位
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(audio_data.tobytes())

def create_star_collect_sound():
    """创建收集星星的音效 - 上升音调"""
    sample_rate = 44100
    duration = 0.3
    
    # 创建上升音调 (C5 到 C6)
    freq_start = 523  # C5
    freq_end = 1047   # C6
    frames = int(duration * sample_rate)
    
    audio = np.zeros(frames)
    for i in range(frames):
        # 线性插值频率
        freq = freq_start + (freq_end - freq_start) * i / frames
        # 衰减幅度
        amplitude = 0.3 * (1 - i / frames)
        audio[i] = amplitude * np.sin(2 * np.pi * freq * i / sample_rate)
    
    save_wav('assets/sounds/star_collect.wav', audio, sample_rate)
    print("✓ 星星收集音效已生成")

def create_special_star_sound():
    """创建特殊星星的音效 - 和弦音"""
    sample_rate = 44100
    duration = 0.5
    
    # 创建C大调和弦 (C-E-G)
    freq1 = 523  # C5
    freq2 = 659  # E5
    freq3 = 784  # G5
    
    frames = int(duration * sample_rate)
    audio = np.zeros(frames)
    
    for i in range(frames):
        # 衰减幅度
        amplitude = 0.2 * np.exp(-3 * i / frames)
        audio[i] = amplitude * (
            np.sin(2 * np.pi * freq1 * i / sample_rate) +
            np.sin(2 * np.pi * freq2 * i / sample_rate) +
            np.sin(2 * np.pi * freq3 * i / sample_rate)
        )
    
    save_wav('assets/sounds/special_star.wav', audio, sample_rate)
    print("✓ 特殊星星音效已生成")

def create_game_over_sound():
    """创建游戏结束音效 - 下降音调"""
    sample_rate = 44100
    duration = 1.0
    
    # 创建下降音调
    freq_start = 523  # C5
    freq_end = 262    # C4
    frames = int(duration * sample_rate)
    
    audio = np.zeros(frames)
    for i in range(frames):
        # 线性插值频率
        freq = freq_start + (freq_end - freq_start) * i / frames
        # 保持幅度
        amplitude = 0.3
        audio[i] = amplitude * np.sin(2 * np.pi * freq * i / sample_rate)
    
    save_wav('assets/sounds/game_over.wav', audio, sample_rate)
    print("✓ 游戏结束音效已生成")

def create_background_music():
    """创建简单的背景音乐 - 循环旋律"""
    sample_rate = 44100
    duration = 8.0  # 8秒循环
    
    # 简单的旋律音符 (C大调音阶)
    notes = [
        (523, 0.5),  # C5
        (587, 0.5),  # D5
        (659, 0.5),  # E5
        (698, 0.5),  # F5
        (784, 0.5),  # G5
        (880, 0.5),  # A5
        (987, 0.5),  # B5
        (1047, 1.0), # C6
        (987, 0.5),  # B5
        (880, 0.5),  # A5
        (784, 0.5),  # G5
        (698, 0.5),  # F5
        (659, 0.5),  # E5
        (587, 0.5),  # D5
        (523, 1.0),  # C5
    ]
    
    frames = int(duration * sample_rate)
    audio = np.zeros(frames)
    
    current_frame = 0
    for freq, note_duration in notes:
        note_frames = int(note_duration * sample_rate)
        
        for i in range(note_frames):
            if current_frame + i < frames:
                # 添加包络（淡入淡出）
                envelope = 1.0
                if i < note_frames * 0.1:  # 淡入
                    envelope = i / (note_frames * 0.1)
                elif i > note_frames * 0.9:  # 淡出
                    envelope = (note_frames - i) / (note_frames * 0.1)
                
                amplitude = 0.1 * envelope  # 背景音乐音量较小
                audio[current_frame + i] = amplitude * np.sin(2 * np.pi * freq * (current_frame + i) / sample_rate)
        
        current_frame += note_frames
    
    save_wav('assets/music/background.wav', audio, sample_rate)
    print("✓ 背景音乐已生成")

def main():
    """主函数"""
    print("开始生成萌爪集星游戏音效...")
    
    # 确保目录存在
    os.makedirs('assets/sounds', exist_ok=True)
    os.makedirs('assets/music', exist_ok=True)
    
    try:
        create_star_collect_sound()
        create_special_star_sound()
        create_game_over_sound()
        create_background_music()
        print("\n🎵 所有音效文件生成完成!")
        print("请在Godot中导入这些音频文件。")
    except ImportError:
        print("❌ 需要安装numpy库: pip install numpy")
    except Exception as e:
        print(f"❌ 生成音效时出错: {e}")

if __name__ == "__main__":
    main()
