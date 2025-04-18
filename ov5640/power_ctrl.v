`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04-02-2025 21:19:02
// Design Name:
// Module Name: power_ctrl
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


/*
	摄像头上电初始化过程
	上电时序
	初始：pwdn = 1,rst_n = 0;done = 0;
	6ms后：pwdn = 0,rst_n = 0; done = 0;
	2ms后：pwdn = 0,rst_n = 1; done = 0;
	21ms后：pwdn = 0,rst_n = 1; done = 1;
*/
module	power_ctrl(
	input	wire			clk						,	//50MHZ时钟
	input	wire			rst_n 					,	//复位信号

	output	wire			ov5640_pwdn				,	//ov5640的pwdn信号线，初始为高，6ms后拉低			
	output	wire			ov5640_rst_n,				//ov5640的rst_n复位信号线，低电平有效

	output	wire			power_done 					//上电完成标志位，完成后一直为高
);

localparam	DELAY_6MS		=		30_0000			;
localparam	DELAY_2MS		=		10_0000			;
localparam	DELAY_21MS		=		105_0000		;

reg		[18:0]		cnt_6ms							;
reg		[16:0]		cnt_2ms							;
reg		[20:0]		cnt_21ms						;

always @(posedge clk) begin
	if (rst_n == 1'b0) begin
		// reset
		cnt_6ms <= 'd0;
	end
	else if (ov5640_pwdn == 1'b1) begin
		cnt_6ms <= cnt_6ms + 1'b1;
	end
end

always @(posedge clk) begin
	if (rst_n == 1'b0) begin
		// reset
		cnt_2ms <= 'd0;
	end
	else if (ov5640_rst_n == 1'b0 && ov5640_pwdn == 1'b0) begin
		cnt_2ms <= cnt_2ms + 1'b1;
	end
end

always @(posedge clk) begin
	if (rst_n == 1'b0) begin
		// reset
		cnt_21ms <= 'd0;
	end
	else if (ov5640_rst_n == 1'b1 & power_done == 1'b0) begin
		cnt_21ms <= cnt_21ms + 1'b1;
	end
end

assign ov5640_pwdn = (cnt_6ms >= DELAY_6MS) ? 1'b0 : 1'b1;		//初始为高，6ms后置低
assign ov5640_rst_n = (cnt_2ms >= DELAY_2MS) ? 1'b1 : 1'b0; 	//初始为低，pwdn拉低后2ms置高
assign power_done = (cnt_21ms >= DELAY_21MS) ? 1'b1 : 1'b0;		//初始为低，上电完成后置高

endmodule
