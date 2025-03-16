`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-16-2025 17:14:16
// Design Name:
// Module Name: top_imgprocess
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

module top_imgprocess #(
    parameter IMG_WIDTH = 640,
    parameter EDGE_THRESHOLD = 150
)(
    input                 clk,        
    input                 rst_n,      
    input                 din_valid,  
    input        [7:0]    r_data,     
    input        [7:0]    g_data,     
    input        [7:0]    b_data,     
    output               dout_valid,  
    output       [7:0]   edge_data    
);

    wire preproc_valid;
    wire [7:0] preproc_data;

    imgpreProcess u_imgpreProcess(
        .clk        (clk),
        .rst_n      (rst_n),
        .din_valid  (din_valid),
        .r_data     (r_data),
        .g_data     (g_data),
        .b_data     (b_data),
        .img_width  (IMG_WIDTH),
        .dout_valid (preproc_valid),
        .proc_data  (preproc_data)
    );

    sobel_edge_detector #(
        .IMG_WIDTH(IMG_WIDTH),
        .THRESHOLD(EDGE_THRESHOLD)
    ) u_sobel_edge_detector(
        .clk        (clk),
        .rst_n      (rst_n),
        .valid_in   (preproc_valid),
        .pixel_data (preproc_data),
        .valid_out  (dout_valid),
        .edge_data  (edge_data)
    );

endmodule
