`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-16-2025 14:13:31
// Design Name:
// Module Name: imgpreProcess_tb
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

module imgpreProcess_tb();

    parameter CLK_PERIOD = 1000;   // 1ns时钟周期
    parameter IMG_WIDTH  = 640;    // 图像宽度
    parameter IMG_HEIGHT = 480;    // 图像高度
    parameter TEST_LINE_NUM = 5;   // 测试行数
    reg [11:0] pixel_cnt;          // 像素计数器
    reg [11:0] line_cnt;           // 行计数器

    reg                clk;
    reg                rst_n;
    reg                din_valid;
    reg     [7:0]      r_data;
    reg     [7:0]      g_data;
    reg     [7:0]      b_data;
    reg     [11:0]     img_width;
    wire               dout_valid;
    wire    [7:0]      proc_data;

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    imgpreProcess u_imgpreProcess(
        .clk        (clk),
        .rst_n      (rst_n),
        .din_valid  (din_valid),
        .r_data     (r_data),
        .g_data     (g_data),
        .b_data     (b_data),
        .img_width  (img_width),
        .dout_valid (dout_valid),
        .proc_data  (proc_data)
    );

    initial begin
        rst_n = 1'b0;
        din_valid = 1'b0;
        r_data = 8'd0;
        g_data = 8'd0;
        b_data = 8'd0;
        img_width = IMG_WIDTH;
        pixel_cnt = 12'd0;
        line_cnt = 12'd0;

        // 设置随机数种子
        $random($time);

        // 复位
        #1000
        rst_n = 1'b1;
        #1000;

        // 发送连续的图像数据
        for(line_cnt = 0; line_cnt < TEST_LINE_NUM; line_cnt = line_cnt + 1) begin
            for(pixel_cnt = 0; pixel_cnt < IMG_WIDTH; pixel_cnt = pixel_cnt + 1) begin
                @(posedge clk);
                din_valid = 1'b1;
                
                // 生成随机RGB值
                r_data = $random & 8'hFF;
                g_data = $random & 8'hFF;
                b_data = $random & 8'hFF;
            end
            
            // 行间隙
            @(posedge clk);
            din_valid = 1'b0;
            #(CLK_PERIOD * 10);  // 行间等待时间
        end

        // 等待处理完成
        din_valid = 1'b0;
        #(CLK_PERIOD * IMG_WIDTH * 2);
        $finish;
    end

    initial begin
        $monitor("Time=%0t line=%d pixel=%d valid=%b data=%d", 
                 $time, line_cnt, pixel_cnt, dout_valid, proc_data);
    end

    integer file_out;
    initial begin
        file_out = $fopen("D:/Eureka-FPGA/Eureka/Eureka.srcs/sim_1/new/process_result.txt", "w"); //自定义地址
        forever @(posedge clk) begin
            if(dout_valid)
                $fwrite(file_out, "Time=%0t proc_data=%d\n", $time, proc_data);
        end
    end

    initial begin
        $dumpfile("imgpreProcess_tb.vcd");
        $dumpvars(0, imgpreProcess_tb);
    end

endmodule
