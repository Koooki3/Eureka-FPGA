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

    // 添加内部控制信号
    reg         process_en;    // 处理使能信号
    reg [11:0]  pixel_cnt;     // 像素计数器
    reg [11:0]  line_cnt;      // 行计数器
    
    // 处理控制逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            process_en <= 1'b0;
            pixel_cnt <= 12'd0;
            line_cnt <= 12'd0;
        end else if (din_valid) begin
            if (pixel_cnt == img_width - 1) begin
                pixel_cnt <= 12'd0;
                if (line_cnt == img_width - 1)
                    line_cnt <= 12'd0;
                else
                    line_cnt <= line_cnt + 1'd1;
            end else begin
                pixel_cnt <= pixel_cnt + 1'd1;
            end
            process_en <= (line_cnt > 12'd1) || (line_cnt == 12'd1 && pixel_cnt > 12'd1);
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
