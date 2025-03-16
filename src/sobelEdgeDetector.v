`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-16-2025 16:59:23
// Design Name:
// Module Name: sobelEdgeDetector
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

module sobel_edge_detector #(
    parameter IMG_WIDTH = 640,          // ͼ����
    parameter THRESHOLD = 150           // ��Ե�����ֵ
)(
    input                   clk,
    input                   rst_n,      // ��λ�źţ��͵�ƽ��Ч
    input                   valid_in,   // ����������Ч
    input      [7:0]       pixel_data,  // ������������
    output reg             valid_out,   // ���������Ч
    output reg [7:0]       edge_data    // �����Ե����
);

// �л��涨��
reg [7:0] line_buffer [0:2][0:IMG_WIDTH-1];
reg signed [10:0] gx, gy;
reg [10:0] gradient;
integer i;

// �����ˮ�߼Ĵ���
reg signed [10:0] gx_pipe, gy_pipe;
reg [10:0] abs_gx, abs_gy;
reg valid_pipe1, valid_pipe2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_out <= 1'b0;
        edge_data <= 8'd0;
        for (i = 0; i < IMG_WIDTH; i = i + 1) begin
            line_buffer[0][i] <= 8'd0;
            line_buffer[1][i] <= 8'd0;
            line_buffer[2][i] <= 8'd0;
        end
        gx_pipe <= 11'd0;
        gy_pipe <= 11'd0;
        abs_gx <= 11'd0;
        abs_gy <= 11'd0;
        valid_pipe1 <= 1'b0;
        valid_pipe2 <= 1'b0;
    end else if (valid_in) begin
        // ��λ�л���
        for (i = 0; i < IMG_WIDTH-1; i = i + 1) begin
            line_buffer[0][i+1] <= line_buffer[0][i];
            line_buffer[1][i+1] <= line_buffer[1][i];
            line_buffer[2][i+1] <= line_buffer[2][i];
        end
        
        // ���������ؽ����л���
        line_buffer[0][0] <= line_buffer[1][0];
        line_buffer[1][0] <= line_buffer[2][0];
        line_buffer[2][0] <= pixel_data;

        // Stage 1: ����Gx��Gy
        gx_pipe <= (line_buffer[0][2] - line_buffer[0][0]) + 
                  ((line_buffer[1][2] - line_buffer[1][0]) << 1) + 
                  (line_buffer[2][2] - line_buffer[2][0]);
        gy_pipe <= (line_buffer[0][0] - line_buffer[2][0]) + 
                  ((line_buffer[0][1] - line_buffer[2][1]) << 1) + 
                  (line_buffer[0][2] - line_buffer[2][2]);
        valid_pipe1 <= valid_in;

        // Stage 2: �������ֵ
        abs_gx <= gx_pipe[10] ? -gx_pipe : gx_pipe;
        abs_gy <= gy_pipe[10] ? -gy_pipe : gy_pipe;
        valid_pipe2 <= valid_pipe1;

        // Stage 3: ������
        valid_out <= valid_pipe2;
        edge_data <= ((abs_gx + abs_gy) > THRESHOLD) ? 8'd255 : 8'd0;
    end else begin
        valid_pipe1 <= 1'b0;
        valid_pipe2 <= 1'b0;
        valid_out <= 1'b0;
    end
end

endmodule
