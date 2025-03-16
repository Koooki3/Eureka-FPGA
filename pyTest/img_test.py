import cv2
import numpy as np
from PIL import ImageFont, ImageDraw, Image

def read_input_image(file_path, size=(640, 640)):
    # 读取原始RGB数据
    img = np.zeros((size[0], size[1], 3), dtype=np.uint8)
    with open(file_path, 'r') as f:
        # 跳过前4行注释
        for _ in range(4):
            next(f)
        
        # 读取RGB数据
        for y in range(size[0]):
            for x in range(size[1]):
                line = f.readline().strip()
                if line:
                    r, g, b = [int(val, 16) for val in line.split()]
                    img[y, x] = [b, g, r]  # OpenCV使用BGR顺序
    return img

def read_output_image(file_path, size=(640, 640)):
    # 读取处理后的边缘检测数据
    img = np.zeros((size[0], size[1]), dtype=np.uint8)
    with open(file_path, 'r') as f:
        y, x = 0, 0
        for line in f:
            try:
                val = int(line.strip(), 16)
                img[y, x] = val
                x += 1
                if x == size[1]:
                    x = 0
                    y += 1
                if y == size[0]:
                    break
            except ValueError:
                # 跳过无效的十六进制值
                continue
    return img

def main():
    # 设置输入输出路径
    input_path = "D:/Eureka-FPGA/Eureka/output/image_test_data.txt"
    output_path = "D:/Eureka-FPGA/Eureka/output/processed_img_data.txt"
    
    try:
        # 读取原始图像和处理后的图像
        original_img = read_input_image(input_path)
        processed_img = read_output_image(output_path)
        
        # 创建并排显示的图像
        combined_img = np.hstack((cv2.cvtColor(original_img, cv2.COLOR_BGR2GRAY), processed_img))
        
        # 使用英文窗口标题避免乱码
        cv2.imshow('Comparison (Left: Original Grayscale, Right: Edge Detection)', combined_img)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
        
        # 保存对比图像
        cv2.imwrite("D:/Eureka-FPGA/Eureka/output/comparison.png", combined_img)
        print("对比图像已保存到: D:/Eureka-FPGA/Eureka/output/comparison.png")
        
    except Exception as e:
        print(f"错误: {str(e)}")

if __name__ == "__main__":
    main()
