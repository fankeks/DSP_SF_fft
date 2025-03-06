`include ".\syst_node\syst_node.sv"

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
    //------------------------------------------------------------------------

    localparam pointer_width = $clog2 (FRAME_LENGTH);

    //------------------------------------------------------------------------

    // Счётчик для мультиплексирования
    logic [pointer_width - 1:0] counter;
    always_ff @ (posedge clk or negedge arstn)
        if (!arstn)
        begin
            counter <= 'b0;
            valid_o <= 'b0;
        end
        else if (valid_i)
        begin
            if (counter == (FRAME_LENGTH - 1))
            begin
                counter <= '0;
                valid_o <= 'b1;
            end
            else
            begin
                counter <= counter + 1'b1;
                valid_o <= 'b0;
            end
        end

    //------------------------------------------------------------------------

    // RE

    logic signed [S_WIDTH-1:0] psumm_i_re;
    logic                valid_psumm_i_re;

    logic signed [S_WIDTH-1:0] psumm_o_re;
    logic                 valid_psumm_o_re;

    assign psumm_i_re       = (counter == 0) ? 'b0 : psumm_o_re;
    assign valid_psumm_i_re = 'b1;

    logic signed [W_WIDTH-1:0] weight_re;
    assign weight_re = w_re[counter];

    syst_node #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .SI_WIDTH (S_WIDTH),
        .SO_WIDTH (S_WIDTH)
    ) re_node (
        .clk           (clk),
        .arstn         (arstn),
        .enable        (valid_i),
        .weight_i      (weight_re),

        .psumm_i       (psumm_i_re),
        .valid_psumm_i (valid_psumm_i_re),

        .x_i           (x),
        .valid_x_i     (valid_i),

        .psumm_o       (psumm_o_re),
        .valid_o       (valid_psumm_o_re)
    );
    assign re = psumm_o_re;

    //------------------------------------------------------------------------

    // IM

    logic signed [S_WIDTH-1:0] psumm_i_im;
    logic                valid_psumm_i_im;

    logic signed [S_WIDTH-1:0] psumm_o_im;
    logic                 valid_psumm_o_im;

    assign psumm_i_im       = (counter == 0) ? 'b0 : psumm_o_im;
    assign valid_psumm_i_im = 'b1;

    logic signed [W_WIDTH-1:0] weight_im;
    assign weight_im = w_im[counter];

    syst_node #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .SI_WIDTH (S_WIDTH),
        .SO_WIDTH (S_WIDTH)
    ) im_node (
        .clk           (clk),
        .arstn         (arstn),
        .enable        (valid_i),
        .weight_i      (weight_im),

        .psumm_i       (psumm_i_im),
        .valid_psumm_i (valid_psumm_i_im),

        .x_i           (x),
        .valid_x_i     (valid_i),

        .psumm_o       (psumm_o_im),
        .valid_o       (valid_psumm_o_im)
    );
    assign im = psumm_o_im;

endmodule