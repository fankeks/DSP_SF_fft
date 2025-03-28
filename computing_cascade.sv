`include ".\\fft\\RAM_fft\\RAM_w_re.sv"
`include ".\\fft\\RAM_fft\\RAM_w_im.sv"
`include ".\\fft\\serial_fft_coral\\serial_fft_coral.sv"
`include ".\\postprocess\\round\\round.sv"
`include ".\\postprocess\\dec_to_polar_fsm\\dec_to_polar_fsm.sv"
`include ".\\postprocess\\RAM_angle\\RAM_angle.sv"
`include ".\\postprocess\\fifo_valid_ready\\flip_flop_fifo_empty_full_optimized.sv"
`include ".\\postprocess\\fifo_valid_ready\\ff_fifo_wrapped_in_valid_ready.sv"
`include ".\\postprocess\\fix_point_div\\fix_point_div.sv"


module computing_cascade
#(
    // FFT
    parameter FRAME_LENGTH = 360,
    parameter W_WIDTH      = 16,
    parameter X_WIDTH      = 16,
    parameter S_WIDTH      = 38,

    // to polar
    parameter NSTAGES      = 20
)
(
    input logic clk,
    input logic rstn,

    input logic i_vld,
    input logic [X_WIDTH-1:0] x1,
    input logic [X_WIDTH-1:0] x2,

    output logic [$clog2(FRAME_LENGTH) - 1:0] cnt,

    output logic [31:0] mag,
    output logic signed [31:0] delta_ph,
    output logic o_vld
);
    //#############################################################
    // FFT
    localparam CHANELS = 2;
    logic signed [W_WIDTH-1:0] w_re;
    logic signed [W_WIDTH-1:0] w_im;
    logic signed [CHANELS-1:0][S_WIDTH-1:0] re;
    logic signed [CHANELS-1:0][S_WIDTH-1:0] im;
    logic valid_fft;

    RAM_w_re #(
        .WIDTH(W_WIDTH),
        .DEPTH(FRAME_LENGTH)
    ) ram_re (
        .clk(clk),
        .address (cnt),
        .data_out (w_re)
    );
    RAM_w_im #(
        .WIDTH(W_WIDTH),
        .DEPTH(FRAME_LENGTH)
    ) ram_im (
        .clk(clk),
        .address (cnt),
        .data_out (w_im)
    );

    serial_fft_coral #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .S_WIDTH  (S_WIDTH),
        .FRAME_LENGTH (FRAME_LENGTH),
        .CHANELS (CHANELS)
    ) fft_core (
        .clk       (clk             ),
        .rstn      (rstn            ),

        .counter   (cnt             ),
        .w_re      (w_re            ),
        .w_im      (w_im            ),

        .valid_i   (i_vld           ),
        .x         ({x2, x1}        ),

        .re        (re              ),
        .im        (im              ),
        .valid_o   (valid_fft )
    );

    //#######################################################################
    // Округление
    logic valid_fft_round;
    logic [31:0] round_re1;
    logic [31:0] round_im1;
    logic [31:0] round_re2;
    logic [31:0] round_im2;
    round #(
        .W_IN(S_WIDTH),
        .W_OUT(32)
    )
    r_re1
    (
        .clk           (clk),
        .rstn          (rstn),

        .i_data (re[0]),
        .i_vld  (valid_fft),

        .o_data (round_re1),
        .o_vld (valid_fft_round)
    );

    round #(
        .W_IN(S_WIDTH),
        .W_OUT(32)
    )
    r_im1
    (
        .clk           (clk),
        .rstn           (rstn),

        .i_data (im[0]),
        .i_vld  (valid_fft),

        .o_data (round_im1)
    );

    round #(
        .W_IN(S_WIDTH),
        .W_OUT(32)
    )
    r_re2
    (
        .clk           (clk),
        .rstn           (rstn),

        .i_data (re[1]),
        .i_vld  (valid_fft),

        .o_data (round_re2)
    );

    round #(
        .W_IN(S_WIDTH),
        .W_OUT(32)
    )
    r_im2
    (
        .clk           (clk),
        .rstn           (rstn),

        .i_data (im[1]),
        .i_vld  (valid_fft),

        .o_data (round_im2)
    );

    //##########################################################################
    // Амплитуда и фаза

    logic signed [31:0] o_mag1;
    logic signed [31:0] o_phase1;
    logic signed [31:0] o_mag2;
    logic signed [31:0] o_phase2;
    logic to_polar_vld;
	//
    logic [$clog2(NSTAGES)-1:0] address_angle;
	logic signed [31:0] cordic_angle;
    RAM_angle #(
        .WIDTH(32),
        .DEPTH(NSTAGES)
    ) ram_angle (
        .clk(clk),
        .address (address_angle),
        .data_out (cordic_angle)
    );
	
    dec_to_polar_fsm #(
        .WIDTH_XY (32),
        .WIDTH_PH (32),
        .NSTAGES  (NSTAGES)
    ) to_polar1 (
        .clk           (clk),
        .rstn         (rstn),

        .cordic_angle (cordic_angle),
        .cnt (address_angle),

        .i_vld (valid_fft_round),
        .i_x (round_re1),
        .i_y (round_im1),

        .o_mag (o_mag1),
        .o_phase (o_phase1),
        .o_vld (to_polar_vld)

    );

    dec_to_polar_fsm #(
        .WIDTH_XY(32),
        .WIDTH_PH(32),
        .NSTAGES (NSTAGES)
    ) to_polar2 (
        .clk           (clk),
        .rstn         (rstn),
        .cordic_angle (cordic_angle),

        .i_vld (valid_fft_round),
        .i_x (round_re2),
        .i_y (round_im2),

        .o_mag (o_mag2),
        .o_phase (o_phase2)
    );

    //#############################################################################################
    // Расчёт дельты

    assign delta_ph = o_phase1 - o_phase2;
    assign mag = o_mag2;
    assign o_vld = to_polar_vld;
    
endmodule