`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-16-2025 13:43:08
// Design Name:
// Module Name: rgb2gray
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

module rgb2gray(
    input                 clk,        // 时钟信号
    input                 rst_n,      // 低电平复位
    input                 din_valid,  // 输入数据有效
    input        [7:0]    r_data,     // R分量
    input        [7:0]    g_data,     // G分量
    input        [7:0]    b_data,     // B分量
    output  reg          dout_valid,  // 输出数据有效
    output  reg  [7:0]   gray_data    // 灰度输出
);

    reg [7:0] gray_result;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gray_result <= 8'd0;
            dout_valid <= 1'b0;
        end else begin
            // R*0.299 ≈ R*77/256 ≈ R/4 + R/8 + R/16
            // G*0.587 ≈ G*150/256 ≈ G/2 + G/8 + G/16
            // B*0.114 ≈ B*29/256 ≈ B/8 + B/16
            gray_result <= ({2'b0,r_data[7:2]} + {3'b0,r_data[7:3]} + {4'b0,r_data[7:4]}) +
                         ({1'b0,g_data[7:1]} + {3'b0,g_data[7:3]} + {4'b0,g_data[7:4]}) +
                         ({3'b0,b_data[7:3]} + {4'b0,b_data[7:4]});
            dout_valid <= din_valid;
        end
    end
    
    assign gray_data = gray_result;

endmodule
