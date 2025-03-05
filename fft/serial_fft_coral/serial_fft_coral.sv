`include ".\syst_array\syst_array.sv"
`include ".\shift_reg\shift_reg.sv"

module serial_fft_coral
#(
    parameter W_WIDTH  = 16,
    parameter X_WIDTH  = 16,
    parameter S_WIDTH  = 32,

    parameter FRAME_LENGTH = 3
)
(
    input  logic                                       clk,
    input  logic                                       arstn,
    input logic signed [W_WIDTH-1:0] w_re [FRAME_LENGTH-1:0],
    input logic signed [W_WIDTH-1:0] w_im [FRAME_LENGTH-1:0],

    input  logic                                       valid_i,
    input  logic signed [X_WIDTH-1:0]                  x,
    
    output logic signed [S_WIDTH-1:0]                  re,
    output logic signed [S_WIDTH-1:0]                  im,
    output logic signed                                valid_o
);
    logic [FRAME_LENGTH-1:0] register;

    shift_reg #(
        .LENGTH  (FRAME_LENGTH)
    ) r (
        .clk           (clk   ),
        .arstn         (arstn ),
        .enable        (valid_i),
        .register      (register)
    );

    syst_array #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .S_WIDTH  (S_WIDTH),
        .FRAME_LENGTH (FRAME_LENGTH)
    ) array (
        .clk           (clk   ),
        .arstn         (arstn ),
        .enable        (valid_i),

        .w_re          (w_re  ),
        .w_im          (w_im  ),

        .valid_x       (register),
        .x             (x      ),

        .re            (re),
        .im            (im),
        .valid_o       (valid_o)
    );

endmodule