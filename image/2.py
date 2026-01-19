from PIL import Image

def mem_to_image(mem_path, output_image_path, size):
    img = Image.new("RGB", (size, size))
    pixels = img.load()

    with open(mem_path, "r") as f:
        lines = f.readlines()

    if len(lines) != size * size:
        print("Error: .mem file size does not match expected image size.")
        return

    for y in range(size):
        for x in range(size):
            rgb444 = int(lines[y * size + x], 16)
            r = (rgb444 >> 8) & 0xF
            g = (rgb444 >> 4) & 0xF
            b = rgb444 & 0xF
            # 扩展到 8-bit 通道（乘 17）
            pixels[x, y] = (r * 17, g * 17, b * 17)

    img.save(output_image_path)
    print(f"[✓] 已保存图像预览：{output_image_path}")

# 示例用法
mem_to_image("box_32x32.mem", "preview_box.png", 32)
# python convert_png_to_rgb444_mem.py wall.png --size 32
