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
    
    gaussianFilter u_gaussianFilter(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_valid(data_valid),
        .img_width(img_width),
        .data_out(data_out),
        .data_out_valid(data_out_valid)
    );
    
    always begin
        clk = 0;
        #5000;
        clk = 1;
        #5000;
    end
    
    integer i;
    initial begin

        rst_n = 1;
        data_in = 0;
        data_valid = 0;
        img_width = 12'd32;  // 设置测试图像宽度为32
        
        // 复位
        #10000;
        rst_n = 0;
        #20000;
        rst_n = 1;
        
        // 等待几个时钟周期
        #20000;
        
        // 输入测试数据（模拟3行图像数据）
        for(i = 0; i < 96; i = i + 1) begin
            @(posedge clk);
            data_valid = 1;
            // 生成测试数据模式（此处使用简单的递增模式）
            data_in = i[7:0];
            #10000;
        end
        
        data_valid = 0;
        
        #100000;
        
        $finish;
    end
    
    always @(posedge clk) begin
        if(data_out_valid) begin
            $display("Time=%0t data_out=%d", $time, data_out);
        end
    end

endmodule
