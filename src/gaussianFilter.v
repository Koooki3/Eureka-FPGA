`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-16-2025 13:58:13
// Design Name:
// Module Name: gaussianFilter
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

module gaussianFilter(
    input wire clk,                    // 时钟信号
    input wire rst_n,                  // 低电平复位
    input wire [7:0] data_in,          // 输入像素数据
    input wire data_valid,             // 输入数据有效
    input wire [11:0] img_width,       // 图像宽度
    output reg [7:0] data_out,         // 输出像素数据
    output reg data_out_valid          // 输出数据有效
);

    // 修改参数值以改善滤波效果
    parameter GAUSSIAN_3X3_1 = 2;    // 角点权重
    parameter GAUSSIAN_3X3_2 = 4;    // 边缘权重
    parameter GAUSSIAN_3X3_4 = 8;    // 中心权重

    // 减小行缓存大小，根据实际图像宽度定义
    parameter MAX_WIDTH = 1024;  // 根据实际需要调整
    reg [7:0] line_buffer1 [MAX_WIDTH-1:0];
    reg [7:0] line_buffer2 [MAX_WIDTH-1:0];
    
    // 3x3窗口寄存器
    reg [7:0] window [8:0];
    
    // 计数器和控制信号
    reg [11:0] pixel_count;
    reg [1:0] valid_rows;
    
    // 窗口数据更新逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_count <= 12'd0;
            valid_rows <= 2'd0;
        end else if (data_valid) begin
            // 更新行缓存
            line_buffer2[pixel_count] <= line_buffer1[pixel_count];
            line_buffer1[pixel_count] <= data_in;
            
            // 更新窗口寄存器
            window[0] <= window[1];
            window[1] <= window[2];
            window[2] <= line_buffer2[pixel_count];
            window[3] <= window[4];
            window[4] <= window[5];
            window[5] <= line_buffer1[pixel_count];
            window[6] <= window[7];
            window[7] <= window[8];
            window[8] <= data_in;
            
            // 更新计数器
            if (pixel_count == img_width - 1) begin
                pixel_count <= 12'd0;
                if (valid_rows < 2'd2)
                    valid_rows <= valid_rows + 1'd1;
            end else
                pixel_count <= pixel_count + 1'd1;
        end
    end
    
    // 添加流水线寄存器
    reg [9:0] sum_corners_reg, sum_edges_reg;
    reg [7:0] center_reg;
    reg valid_pipe;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_corners_reg <= 10'd0;
            sum_edges_reg <= 10'd0;
            center_reg <= 8'd0;
            valid_pipe <= 1'b0;
        end else if (valid_rows == 2'd2 && data_valid) begin
            // Stage 1: 累加计算
            sum_corners_reg <= window[0] + window[2] + window[6] + window[8];
            sum_edges_reg <= window[1] + window[3] + window[5] + window[7];
            center_reg <= window[4];
            valid_pipe <= 1'b1;

            // Stage 2: 最终输出
            data_out <= ({2'b0,sum_corners_reg,1'b0} + 
                         {1'b0,sum_edges_reg,2'b0} + 
                         {center_reg,3'b0}) >> 5;
            data_out_valid <= valid_pipe;
        end else begin
            valid_pipe <= 1'b0;
            data_out_valid <= 1'b0;
        end
    end

endmodule
