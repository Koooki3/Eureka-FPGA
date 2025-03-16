import cv2
import numpy as np

def process_image(image_path, output_path, size=(640, 640), format='txt'):
    # 读取图像
    img = cv2.imread(image_path)
    if img is None:
        raise ValueError(f"无法读取图像: {image_path}")
    
    # 调整图像大小
    img = cv2.resize(img, size)
    
    # 分离RGB通道（OpenCV使用BGR顺序）
    b, g, r = cv2.split(img)
    
    # 创建测试数据文件
    with open(output_path, 'w') as f:
        if format == 'txt':
            # 写入文件头注释
            f.write("# Image Test Data\n")
            f.write(f"# Image Size: {size[0]}x{size[1]}\n")
            f.write("# Format: R G B (Hex)\n\n")
            
            # 逐像素写入RGB数据（十六进制格式）
            for y in range(size[0]):
                for x in range(size[1]):
                    f.write(f"{r[y,x]:02X} {g[y,x]:02X} {b[y,x]:02X}\n")

if __name__ == "__main__":
    # 设置输入输出路径
    input_image = "D:\Eureka-FPGA\Eureka\input\input.png"  # 替换为你的测试图像路径
    output_file = "D:\Eureka-FPGA\Eureka\output\image_test_data.txt"
    
    try:
        process_image(input_image, output_file, format='txt')
        print(f"测试数据已生成到: {output_file}")
    except Exception as e:
        print(f"错误: {str(e)}")
