`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-16-2025 17:17:01
// Design Name:
// Module Name: top_imgprocess_tb
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module top_imgprocess_tb();
    // 定义参数
    parameter CLK_PERIOD = 2;
    parameter IMG_WIDTH = 640;
    parameter IMG_SIZE = IMG_WIDTH * IMG_WIDTH;
    
    // 定义信号
    reg clk;
    reg rst_n;
    reg din_valid;
    reg [7:0] r_data, g_data, b_data;
    wire dout_valid;
    wire [7:0] edge_data;
    
    // 文件处理变量
    integer input_file, output_file;
    integer scan_count;
    reg [7:0] temp_r, temp_g, temp_b;
    integer i;
    integer output_count;  // 移到这里
    
    initial output_count = 0;  // 初始化移到这里
    
    // 实例化待测模块
    top_imgprocess #(
        .IMG_WIDTH(IMG_WIDTH),
        .EDGE_THRESHOLD(150)
    ) u_top_imgprocess(
        .clk(clk),
        .rst_n(rst_n),
        .din_valid(din_valid),
        .r_data(r_data),
        .g_data(g_data),
        .b_data(b_data),
        .dout_valid(dout_valid),
        .edge_data(edge_data)
    );
    
    // 时钟生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // 主测试过程
    initial begin
        // 初始化
        rst_n = 0;
        din_valid = 0;
        r_data = 0;
        g_data = 0;
        b_data = 0;
        
        // 打开文件
        input_file = $fopen("D:/Eureka-FPGA/Eureka/output/image_test_data.txt", "r");
        output_file = $fopen("D:/Eureka-FPGA/Eureka/output/processed_img_data.txt", "w");
        
        if (input_file == 0 || output_file == 0) begin
            $display("Error opening file!");
            $finish;
        end else begin
            $display("Files opened successfully");
        end
        
        // 复位
        #(CLK_PERIOD*10);
        rst_n = 1;
        #(CLK_PERIOD*2);
        
        // 跳过文件头注释行
        for (i = 0; i < 4; i = i + 1) begin
            scan_count = $fgets(temp_r, input_file);
            $display("Header line %0d: %0s", i+1, temp_r);
        end
        
        // 读取并处理图像数据
        i = 0;  // 重置计数器
        while (!$feof(input_file)) begin
            scan_count = $fscanf(input_file, "%h %h %h\n", temp_r, temp_g, temp_b);
            if (scan_count == 3) begin
                @(posedge clk);
                #1; // 添加小延迟确保数据稳定
                din_valid = 1;
                r_data = temp_r;
                g_data = temp_g;
                b_data = temp_b;
                
                // 每1000个像素显示一次进度
                if ((i % 1000) == 0) begin
                    $display("Reading pixel %0d: R=%h G=%h B=%h", i, temp_r, temp_g, temp_b);
                end
                i = i + 1;
            end else begin
                // 增加错误处理信息
                if (!$feof(input_file)) begin
                    $display("Error: Invalid data format at line %0d (scan_count=%0d)", i+5, scan_count);
                    $display("Attempting to skip invalid line...");
                    scan_count = $fgets(temp_r, input_file);  // 跳过这一行
                end
            end
        end
        
        $display("Total pixels read: %0d", i);
        
        // 处理完成后的清理
        @(posedge clk);
        din_valid = 0;
        
        // 等待处理完成
        #(CLK_PERIOD*IMG_SIZE*8);  // 进一步增加等待时间
        
        if (output_count == 0) begin
            $display("Warning: No output data generated!");
        end else begin
            $display("Total pixels processed: %0d", output_count);
        end
        
        // 关闭文件
        $fclose(input_file);
        $fclose(output_file);
        $finish;
    end
    
    // 输出数据监控
    always @(posedge clk) begin
        if (dout_valid) begin
            $fwrite(output_file, "%h\n", edge_data);
            output_count = output_count + 1;
            
            // 添加更详细的调试信息
            if (output_count % 1000 == 0) begin
                $display("Processed %0d pixels, current edge_data=%h", output_count, edge_data);
            end
        end
    end

endmodule
