`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-16-2025 14:10:37
// Design Name:
// Module Name: imgpreProcess
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

module imgpreProcess(
    input                 clk,        
    input                 rst_n,      
    input                 din_valid,  
    input        [7:0]    r_data,     
    input        [7:0]    g_data,     
    input        [7:0]    b_data,     
    input        [11:0]   img_width,  
    output               dout_valid,  
    output       [7:0]   proc_data    
);

    // 优化process_en逻辑，减少寄存器使用
    reg process_en;
    reg [11:0] pixel_cnt, line_cnt;
    reg [1:0] line_valid_cnt;  // 用于跟踪有效行数
    wire pixel_end = pixel_cnt == img_width - 1;
    wire line_end = line_cnt == img_width - 1;
    
    // 修改计数器逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            process_en <= 1'b0;
            pixel_cnt <= 12'd0;
            line_cnt <= 12'd0;
            line_valid_cnt <= 2'd0;
        end else begin
            if (din_valid) begin
                if (pixel_cnt == img_width - 1) begin
                    pixel_cnt <= 12'd0;
                    if (line_cnt == img_width - 1)
                        line_cnt <= 12'd0;
                    else
                        line_cnt <= line_cnt + 1'd1;
                end else begin
                    pixel_cnt <= pixel_cnt + 1'd1;
                end
                
                // 修改行计数逻辑
                if (pixel_cnt == img_width - 1) begin
                    if (line_valid_cnt < 2'd2)
                        line_valid_cnt <= line_valid_cnt + 1'd1;
                end
            end
            // 更新process_en逻辑
            process_en <= (line_valid_cnt == 2'd2) && din_valid;
        end
    end

    wire        gray_valid;
    wire [7:0]  gray_data;

    rgb2gray u_rgb2gray(
        .clk        (clk),
        .rst_n      (rst_n),
        .din_valid  (din_valid & process_en),  // 添加使能控制
        .r_data     (r_data),
        .g_data     (g_data),
        .b_data     (b_data),
        .dout_valid (gray_valid),
        .gray_data  (gray_data)
    );

    gaussianFilter u_gaussian(
        .clk            (clk),
        .rst_n          (rst_n),
        .data_in        (gray_data),
        .data_valid     (gray_valid),
        .img_width      (img_width),
        .data_out       (proc_data),
        .data_out_valid (dout_valid)
    );

endmodule
