`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-16-2025 16:59:46
// Design Name:
// Module Name: sobelEdgeDetector_tb
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


module sobelEdgeDetector_tb();

// 定义参数
parameter CLOCK_PERIOD = 10;
parameter IMG_WIDTH = 8;      // 使用较小的图像宽度进行测试
parameter THRESHOLD = 100;

// 定义信号
reg clk;
reg rst_n;
reg valid_in;
reg [7:0] pixel_data;
wire valid_out;
wire [7:0] edge_data;
reg [31:0] test_count;

// 定义测试数据
reg [7:0] vertical_edge [0:8];
reg [7:0] horizontal_edge [0:8];
reg [7:0] diagonal_edge [0:8];
reg [7:0] gradient_edge [0:8];
reg [7:0] no_edge [0:8];

// 实例化被测试模块
sobel_edge_detector #(
    .IMG_WIDTH(IMG_WIDTH),
    .THRESHOLD(THRESHOLD)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .pixel_data(pixel_data),
    .valid_out(valid_out),
    .edge_data(edge_data)
);

// 修改task定义，改为单个输入
task input_pixel_sequence;
    input [7:0] p0, p1, p2, p3, p4, p5, p6, p7, p8;  // 9个像素值作为独立输入
    begin
        pixel_data = p0; #10;
        pixel_data = p1; #10;
        pixel_data = p2; #10;
        pixel_data = p3; #10;
        pixel_data = p4; #10;
        pixel_data = p5; #10;
        pixel_data = p6; #10;
        pixel_data = p7; #10;
        pixel_data = p8; #10;
    end
endtask

// 时钟生成
initial begin
    clk = 0;
    forever #(CLOCK_PERIOD/2) clk = ~clk;
end

// 测试激励
initial begin
    // 初始化信号和测试数据
    rst_n = 0;
    valid_in = 0;
    pixel_data = 0;
    test_count = 0;
    
    // 初始化测试数据
    vertical_edge[0] = 50;  vertical_edge[1] = 50;  vertical_edge[2] = 200;
    vertical_edge[3] = 50;  vertical_edge[4] = 50;  vertical_edge[5] = 200;
    vertical_edge[6] = 50;  vertical_edge[7] = 50;  vertical_edge[8] = 200;
    
    horizontal_edge[0] = 200; horizontal_edge[1] = 200; horizontal_edge[2] = 200;
    horizontal_edge[3] = 200; horizontal_edge[4] = 200; horizontal_edge[5] = 200;
    horizontal_edge[6] = 50;  horizontal_edge[7] = 50;  horizontal_edge[8] = 50;
    
    diagonal_edge[0] = 200; diagonal_edge[1] = 200; diagonal_edge[2] = 200;
    diagonal_edge[3] = 200; diagonal_edge[4] = 150; diagonal_edge[5] = 50;
    diagonal_edge[6] = 200; diagonal_edge[7] = 50;  diagonal_edge[8] = 50;
    
    gradient_edge[0] = 50;  gradient_edge[1] = 100; gradient_edge[2] = 150;
    gradient_edge[3] = 75;  gradient_edge[4] = 125; gradient_edge[5] = 175;
    gradient_edge[6] = 100; gradient_edge[7] = 150; gradient_edge[8] = 200;
    
    no_edge[0] = 100; no_edge[1] = 100; no_edge[2] = 100;
    no_edge[3] = 100; no_edge[4] = 100; no_edge[5] = 100;
    no_edge[6] = 100; no_edge[7] = 100; no_edge[8] = 100;
    
    // 等待100ns后释放复位
    #100;
    rst_n = 1;
    #100;

    // 测试场景1：垂直边缘
    valid_in = 1;
    $display("test scene1: vertical edge detection");
    input_pixel_sequence(
        50, 50, 200,
        50, 50, 200,
        50, 50, 200
    );
    #50;
    
    // 测试场景2：水平边缘
    $display("test scene2: horizontal edge detection");
    input_pixel_sequence(
        200, 200, 200,
        200, 200, 200,
        50, 50, 50
    );
    #50;
    
    // 测试场景3：斜边缘
    $display("test scene3: diagonal edge detection");
    input_pixel_sequence(
        200, 200, 200,
        200, 150, 50,
        200, 50, 50
    );
    #50;
    
    // 测试场景4：渐变边缘
    $display("test scene4: gradient edge detection");
    input_pixel_sequence(
        50, 100, 150,
        75, 125, 175,
        100, 150, 200
    );
    #50;
    
    // 测试场景5：无边缘区域
    $display("test scene5: no edge detection");
    input_pixel_sequence(
        100, 100, 100,
        100, 100, 100,
        100, 100, 100
    );
    #50;

    // 结束测试
    valid_in = 0;
    #200;
    $finish;
end

// 监视输出
initial begin
    $monitor("Time=%0t rst_n=%b valid_in=%b pixel_data=%d valid_out=%b edge_data=%d",
             $time, rst_n, valid_in, pixel_data, valid_out, edge_data);
end

// 结果检查
always @(posedge clk) begin
    if (valid_out) begin
        test_count <= test_count + 1;
        $display("time:%0t, test%0d: edge_data=%d %s", 
                $time, 
                test_count,
                edge_data,
                edge_data > 0 ? "detected" : "undected");
    end
end

endmodule
