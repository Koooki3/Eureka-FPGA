`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-16-2025 13:49:40
// Design Name:
// Module Name: rgb2gray_tb
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

module rgb2gray_tb();
    reg clk;
    reg rst_n;
    reg din_valid;
    reg [7:0] r_data;
    reg [7:0] g_data;
    reg [7:0] b_data;
    wire dout_valid;
    wire [7:0] gray_data;
    
    rgb2gray u_rgb2gray(
        .clk(clk),
        .rst_n(rst_n),
        .din_valid(din_valid),
        .r_data(r_data),
        .g_data(g_data),
        .b_data(b_data),
        .dout_valid(dout_valid),
        .gray_data(gray_data)
    );
    always #5000 clk = ~clk;
    
    initial begin

        clk = 0;
        rst_n = 1;
        din_valid = 0;
        r_data = 0;
        g_data = 0;
        b_data = 0;
        
        // 复位测试
        #10000;
        rst_n = 0;
        #10000;
        rst_n = 1;
        
        #20000;
        
        // 测试用例1：纯白
        din_valid = 1;
        r_data = 8'd255;
        g_data = 8'd255;
        b_data = 8'd255;
        #10000;
        
        // 测试用例2：纯黑
        r_data = 8'd0;
        g_data = 8'd0;
        b_data = 8'd0;
        #10000;
        
        // 测试用例3：纯红
        r_data = 8'd255;
        g_data = 8'd0;
        b_data = 8'd0;
        #10000;
        
        // 测试用例4：灰色
        r_data = 8'd128;
        g_data = 8'd128;
        b_data = 8'd128;
        #10000;
        
        // 测试用例5：纯绿
        r_data = 8'd0;
        g_data = 8'd255;
        b_data = 8'd0;
        #10000;
        
        // 测试用例6：纯蓝
        r_data = 8'd0;
        g_data = 8'd0;
        b_data = 8'd255;
        #10000;
        
        din_valid = 0;
        #20000;
        
        $finish;
    end
    
    initial begin
        $dumpfile("rgb2gray_tb.vcd");
        $dumpvars(0, rgb2gray_tb);
        $monitor("Time=%4d ns: valid=%b, R=%3d, G=%3d, B=%3d, gray=%3d", 
                 $time/1000, dout_valid, r_data, g_data, b_data, gray_data);
    end

endmodule
