`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-16-2025 13:59:07
// Design Name:
// Module Name: gaussianFilter_tb
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

module gaussianFilter_tb();

    reg clk;
    reg rst_n;
    reg [7:0] data_in;
    reg data_valid;
    reg [11:0] img_width;
    wire [7:0] data_out;
    wire data_out_valid;
    
    integer outfile;
    reg [15:0] cycle_count;
    integer seed;  // 随机数种子
    
    gaussianFilter u_gaussianFilter(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_valid(data_valid),
        .img_width(img_width),
        .data_out(data_out),
        .data_out_valid(data_out_valid)
    );
    
    // 修改时钟周期为10ns
    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end
    
    integer i;
    initial begin
        // 初始化随机数种子
        seed = 123456;
        
        // 打开输出文件
        outfile = $fopen("gaussian_output.txt", "w");
        
        cycle_count = 0;
        rst_n = 1;
        data_in = 0;
        data_valid = 0;
        img_width = 12'd640;  // 设置图像宽度为640
        
        // 复位
        #100;
        rst_n = 0;
        #200;
        rst_n = 1;
        
        // 等待系统稳定
        #200;
        
        // 输入测试数据（模拟640x480图像）
        for(i = 0; i < 307200; i = i + 1) begin
            @(posedge clk);
            data_valid = 1;
            // 生成随机RGB值 (0-255)
            data_in = $random(seed) & 8'hFF;
            #10;
        end
        
        data_valid = 0;
        
        // 增加等待时间以处理更大的图像
        #10000;
        
        $fclose(outfile);
        $finish;
    end
    
    // 计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end
    
    // 输出结果到文件和控制台
    always @(posedge clk) begin
        if(data_out_valid) begin
            $display("Cycle=%d Time=%0t data_out=%d", cycle_count, $time, data_out);
            $fwrite(outfile, "%d\n", data_out);
        end
    end

endmodule
