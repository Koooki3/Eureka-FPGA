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
    parameter TEST_LINE_NUM = 10;   // 增加测试行数
    parameter IDLE_CYCLES = 20;     // 行间空闲周期数
    reg [11:0] pixel_cnt;          // 像素计数器
    reg [11:0] line_cnt;           // 行计数器
    reg [31:0] error_cnt;          // 错误计数器

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
        error_cnt = 32'd0;

        $display("测试开始时间: %0t", $time);
        
        // 设置随机数种子
        $random($time);

        // 复位测试
        #(CLK_PERIOD * 10) rst_n = 1'b1;
        #(CLK_PERIOD * 5);

        // 测试用例1：全黑图像
        send_image_data(8'd0, 8'd0, 8'd0, 5);
        
        // 测试用例2：全白图像
        send_image_data(8'd255, 8'd255, 8'd255, 5);
        
        // 测试用例3：随机图像
        send_random_image(TEST_LINE_NUM);

        // 等待处理完成
        wait_process_done();
        
        $display("测试结束时间: %0t", $time);
        $display("检测到错误数: %0d", error_cnt);
        $fclose(file_out);        // 在结束前关闭文件
        $finish;
    end

    // 修改发送固定RGB值的图像数据任务
    task send_image_data;
        input [7:0] r, g, b;
        input [11:0] num_lines;
        integer i, j;
        begin
            // 发送3行以上的数据以满足高斯滤波要求
            for(i = 0; i < num_lines + 2; i = i + 1) begin
                for(j = 0; j < IMG_WIDTH; j = j + 1) begin
                    @(posedge clk);
                    din_valid = 1'b1;
                    r_data = r;
                    g_data = g;
                    b_data = b;
                    pixel_cnt = j;
                    line_cnt = i;
                end
                @(posedge clk);
                din_valid = 1'b0;
                #(CLK_PERIOD * 2);  // 减少行间隙时间
            end
        end
    endtask

    // 发送随机图像数据
    task send_random_image;
        input [11:12] num_lines;
        integer i, j;
        begin
            for(i = 0; i < num_lines; i = i + 1) begin
                for(j = 0; j < IMG_WIDTH; j = j + 1) begin
                    @(posedge clk);
                    din_valid = 1'b1;
                    r_data = $random & 8'hFF;
                    g_data = $random & 8'hFF;
                    b_data = $random & 8'hFF;
                    pixel_cnt = j;
                    line_cnt = i;
                end
                @(posedge clk);
                din_valid = 1'b0;
                #(CLK_PERIOD * IDLE_CYCLES);
            end
        end
    endtask

    // 修改等待处理完成任务
    task wait_process_done;
        integer timeout_cnt;
        begin
            din_valid = 1'b0;
            timeout_cnt = 0;
            
            // 增加等待时间
            while(timeout_cnt < IMG_WIDTH * 10) begin
                @(posedge clk);
                if(dout_valid)
                    $display("Output at time %0t: data=%h", $time, proc_data);
                timeout_cnt = timeout_cnt + 1;
            end
            
            #(CLK_PERIOD * 100);
        end
    endtask

    // 数据监控和记录
    initial begin
        $monitor("[%0t] line=%0d pixel=%0d valid=%b data=%0d", 
                 $time, line_cnt, pixel_cnt, dout_valid, proc_data);
    end

    // 波形和数据文件记录
    integer file_out;
    initial begin
        file_out = $fopen("D:/Eureka-FPGA/Eureka/Eureka.srcs/sim_1/new/process_result.txt", "w");
        forever @(posedge clk) begin
            if(dout_valid)
                $fwrite(file_out, "%0t,%0d,%0d,%0d\n", 
                       $time, line_cnt, pixel_cnt, proc_data);
        end
    end

    // 数据监控和错误计数
    always @(posedge clk) begin
        if (dout_valid && proc_data === 8'bx) begin
            error_cnt = error_cnt + 1;
            $display("Error: proc_data is X at time %0t, line=%0d, pixel=%0d", 
                    $time, line_cnt, pixel_cnt);
        end
    end

    // 生成波形文件
    initial begin
        $dumpfile("imgpreProcess_wave.vcd");
        $dumpvars(0, imgpreProcess_tb);
    end

endmodule
