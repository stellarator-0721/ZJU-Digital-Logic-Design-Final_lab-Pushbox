from PIL import Image
import argparse
import os

def convert_image_to_rgb444_mem(input_path, output_path, size):
    # 加载图片并缩放为指定大小
    img = Image.open(input_path).convert('RGB')
    img_resized = img.resize((size, size), Image.Resampling.LANCZOS)

    
    pixels = img_resized.load()

    with open(output_path, "w") as f:
        for y in range(size):
            for x in range(size):
                r, g, b = pixels[x, y]
                # 压缩为 4-bit 每通道（RGB444）
                r4 = r >> 4
                g4 = g >> 4
                b4 = b >> 4
                rgb444 = (r4 << 8) | (g4 << 4) | b4
                f.write(f"{rgb444:03x}\n")

    print(f"[✓] 转换完成：{output_path}（{size}x{size} RGB444）")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert PNG image to RGB444 .mem file for VGA.")
    parser.add_argument("input_image", help="输入 PNG 图片路径")
    parser.add_argument("-s", "--size", type=int, default=32, choices=[32, 64], help="缩放尺寸（默认 32x32）")
    parser.add_argument("-o", "--output", help="输出 .mem 文件名（可选）")

    args = parser.parse_args()

    input_path = args.input_image
    size = args.size
    output_path = args.output or os.path.splitext(os.path.basename(input_path))[0] + f"_{size}x{size}.mem"

    convert_image_to_rgb444_mem(input_path, output_path, size)
