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


// FPGA   : С÷��AC620
// EDA 	  : Quartus II 13.0sp1 (64-bit) and ModelSim SE-64 10.5 
// Author : FPGAС��758 https://blog.csdn.net/q1594?spm=1010.2135.3001.5343
// File   : ov5640_data.v
// Create : 2022-05-13 19:05:10
// Revise : 2022-05-13 19:05:12
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

module	ov5640_data(
	input	wire			s_rst_n		,
	input	wire			ov5640_pclk	,	//���ʱ��
	input	wire			ov5640_href	,	//������Ч�ź�
	input	wire			ov5640_vsync, 	//֡ͬ��
	input	wire	[7:0]	ov5640_data	, 	//����

	output	reg 			frame_vld 	,
	output	wire 	[15:0]	frame_rgb 	,
	output	wire 	[11:0]		i_x 	,
	output	wire 	[11:0]		i_y 	
	);
//�ü���Χ��sccb_ov5640_cfg�ļ��е�CMOS_H_PIXEL��CMOS_V_PIXEL��1024*768��
parameter	H_TOTAL 		=		1024;
parameter	V_TOTAL 		=		768 ;
parameter	H_SRART 		=		200	;//�ü���ˮƽ��ʼλ��
parameter	H_STOP 		 	=		1000;//�ü���ˮƽ����λ��
parameter	V_START 		=		200	;//�ü���ֱ��ʼλ��
parameter	V_STOP 			=		680	;//�ü���ֱ����λ��

reg 			ov5640_vsync_r 			;		//����
wire 			vsync_flag 				;		//֡��־
reg 	[4:0]	vsync_cnt				;		//֡����
wire			output_en 				;		//���ʹ��
reg 			data_flag 				;		//����ͷ����������Ǹ�λ���ǵ�λ�ź�
reg		[15:0]	cmos_out_data 			; 		//����ͷ���������
reg 			cmos_out_flag 	 		;		//����ͷ�����������Ч�ź�
reg 	[11:0]	cmos_out_H_cnt			; 		//����ͷ����м���
reg 	[11:0]	cmos_out_V_cnt 			; 		//����ͷ���������

//����
always @(posedge ov5640_pclk or negedge s_rst_n) begin
	if (s_rst_n == 1'b0) begin
		// reset
		ov5640_vsync_r <= 'd0;
	end
	else begin
		ov5640_vsync_r <= ov5640_vsync;
	end
end

//�����ر�־
assign vsync_flag = ov5640_vsync & ~ov5640_vsync_r;

//�����ؼ���
always @(posedge ov5640_pclk or negedge s_rst_n) begin
	if (s_rst_n == 1'b0) begin
		vsync_cnt <= 'd0;
	end
	else if(vsync_flag == 1'b1 && vsync_cnt <= 10) begin
		vsync_cnt <= vsync_cnt + 1'b1;
	end
end

//��������ʹ��
assign output_en = (vsync_cnt >= 'd10)? 1'b1 : 1'b0;

//����ߵ�λ��־
always @(posedge ov5640_pclk or negedge s_rst_n) begin
	if (s_rst_n == 1'b0) begin
		// reset
		data_flag <= 1'b0;
	end
	else if (ov5640_href == 1'b1) begin
		data_flag <= ~data_flag;
	end
end

//����ƴ��
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

//������Ч��־λ
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


//�����г�����
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

//1024*768�ü���800*480
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

