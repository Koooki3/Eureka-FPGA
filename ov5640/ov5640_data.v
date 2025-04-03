`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04-02-2025 21:23:06
// Design Name:
// Module Name: ov5640_data
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


// FPGA   : 小梅哥AC620
// EDA 	  : Quartus II 13.0sp1 (64-bit) and ModelSim SE-64 10.5 
// Author : FPGA小白758 https://blog.csdn.net/q1594?spm=1010.2135.3001.5343
// File   : ov5640_data.v
// Create : 2022-05-13 19:05:10
// Revise : 2022-05-13 19:05:12
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

module	ov5640_data(
	input	wire			s_rst_n		,
	input	wire			ov5640_pclk	,	//输出时钟
	input	wire			ov5640_href	,	//数据有效信号
	input	wire			ov5640_vsync, 	//帧同步
	input	wire	[7:0]	ov5640_data	, 	//数据

	output	reg 			frame_vld 	,
	output	wire 	[15:0]	frame_rgb 	,
	output	wire 	[11:0]		i_x 	,
	output	wire 	[11:0]		i_y 	
	);
//裁剪范围是sccb_ov5640_cfg文件中的CMOS_H_PIXEL和CMOS_V_PIXEL（1024*768）
parameter	H_TOTAL 		=		1024;
parameter	V_TOTAL 		=		768 ;
parameter	H_SRART 		=		200	;//裁剪后水平起始位置
parameter	H_STOP 		 	=		1000;//裁剪后水平结束位置
parameter	V_START 		=		200	;//裁剪后垂直起始位置
parameter	V_STOP 			=		680	;//裁剪后垂直结束位置

reg 			ov5640_vsync_r 			;		//打拍
wire 			vsync_flag 				;		//帧标志
reg 	[4:0]	vsync_cnt				;		//帧计数
wire			output_en 				;		//输出使能
reg 			data_flag 				;		//摄像头输出的数据是高位还是低位信号
reg		[15:0]	cmos_out_data 			; 		//摄像头输出的数据
reg 			cmos_out_flag 	 		;		//摄像头输出的数据有效信号
reg 	[11:0]	cmos_out_H_cnt			; 		//摄像头输出行计数
reg 	[11:0]	cmos_out_V_cnt 			; 		//摄像头输出场计数

//打拍
always @(posedge ov5640_pclk or negedge s_rst_n) begin
	if (s_rst_n == 1'b0) begin
		// reset
		ov5640_vsync_r <= 'd0;
	end
	else begin
		ov5640_vsync_r <= ov5640_vsync;
	end
end

//上升沿标志
assign vsync_flag = ov5640_vsync & ~ov5640_vsync_r;

//上升沿计数
always @(posedge ov5640_pclk or negedge s_rst_n) begin
	if (s_rst_n == 1'b0) begin
		vsync_cnt <= 'd0;
	end
	else if(vsync_flag == 1'b1 && vsync_cnt <= 10) begin
		vsync_cnt <= vsync_cnt + 1'b1;
	end
end

//计数满后使能
assign output_en = (vsync_cnt >= 'd10)? 1'b1 : 1'b0;

//输出高低位标志
always @(posedge ov5640_pclk or negedge s_rst_n) begin
	if (s_rst_n == 1'b0) begin
		// reset
		data_flag <= 1'b0;
	end
	else if (ov5640_href == 1'b1) begin
		data_flag <= ~data_flag;
	end
end

//数据拼接
always @(posedge ov5640_pclk or negedge s_rst_n) begin
	if (s_rst_n == 1'b0) begin
		// reset
		cmos_out_data <= 15'd0;
	end
	else if (data_flag == 1'b0 && ov5640_href == 1'b1) begin
		cmos_out_data[15:8] <= ov5640_data; 
	end
	else if (data_flag == 1'b1 && ov5640_href == 1'b1) begin
		cmos_out_data[ 7:0] <= ov5640_data; 
	end
end

//数据有效标志位
always @(posedge ov5640_pclk or negedge s_rst_n) begin
	if(s_rst_n == 1'b0) begin
		cmos_out_flag <= 1'b0;
	end
	else if (data_flag == 1'b1 & output_en == 1'b1) begin
		cmos_out_flag <= 1'b1;
	end
	else begin
		cmos_out_flag <= 1'b0;
	end
end


//数据行场计数
always @(posedge ov5640_pclk or negedge s_rst_n) begin
	if(s_rst_n == 1'b0)begin
		cmos_out_H_cnt <= 'd0;
	end
	else if (cmos_out_H_cnt == H_TOTAL)begin
		cmos_out_H_cnt <= 'd0;
	end
	else if (data_flag == 1'b1 & output_en == 1'b1) begin
		cmos_out_H_cnt <= cmos_out_H_cnt + 1'b1;
	end
end

always @(posedge ov5640_pclk or negedge s_rst_n) begin
	if (s_rst_n == 1'b0) begin
		cmos_out_V_cnt <= 'd0;
	end
	else if (cmos_out_V_cnt == V_TOTAL)begin
		cmos_out_V_cnt <= 'd0;
	end
	else if (cmos_out_H_cnt == 'd0 && data_flag == 1'b1 & output_en == 1'b1) begin
		cmos_out_V_cnt <= cmos_out_V_cnt + 1'b1;
	end
end

//1024*768裁剪出800*480
always @(posedge ov5640_pclk or negedge s_rst_n) begin
	if (s_rst_n == 1'b0) begin
		frame_vld <= 1'b0;
	end
	else if (cmos_out_H_cnt - 1 >= H_SRART & cmos_out_H_cnt - 1'b1 < H_STOP 
		& cmos_out_V_cnt - 1 >= V_START & cmos_out_V_cnt - 1'b1 < V_STOP 
		& data_flag == 1'b1)begin
		frame_vld <= 1'b1;
	end
	else begin
		frame_vld <= 1'b0;
	end
end

assign frame_rgb = (cmos_out_H_cnt >= H_SRART & cmos_out_H_cnt < H_STOP
	& cmos_out_V_cnt >= V_START & cmos_out_V_cnt < V_STOP 
	& data_flag == 'd0 & output_en == 1'b1
	)? cmos_out_data:15'b0;
assign i_x = (cmos_out_H_cnt >= H_SRART & cmos_out_H_cnt < H_STOP
	& cmos_out_V_cnt >= V_START & cmos_out_V_cnt < V_STOP 
	& data_flag == 'd0 & output_en == 1'b1
	)?  cmos_out_H_cnt-8'd200:'d0;
assign i_y = (cmos_out_H_cnt >= H_SRART & cmos_out_H_cnt < H_STOP
	& cmos_out_V_cnt >= V_START & cmos_out_V_cnt < V_STOP 
	& data_flag == 'd0 & output_en == 1'b1
	)? 	cmos_out_V_cnt-8'd200:'d0;
endmodule

