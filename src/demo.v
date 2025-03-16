`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-16-2025 10:02:14
// Design Name:
// Module Name: demo
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


module demo(
    input clk,
    input rst, 
    output reg [7:0] led    
    );
    
    reg [31:0] cnt;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 32'd0;
        end
        else begin
            if (cnt >= 32'd5000_0000)
                cnt <= 32'd0;
            else
                cnt <= cnt + 1'b1;
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led <= 8'b0000_0001;
        end
        else if (cnt == 32'd5000_0000) begin
            led <= {led[6:0], led[7]};
        end
    end
    
endmodule
