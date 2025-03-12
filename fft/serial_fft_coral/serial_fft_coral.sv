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
    input  logic signed [X_WIDTH-1:0]                  x1,
    input  logic signed [X_WIDTH-1:0]                  x2,
    
    output logic signed [S_WIDTH-1:0]                  re1,
    output logic signed [S_WIDTH-1:0]                  im1,
    output logic signed [S_WIDTH-1:0]                  re2,
    output logic signed [S_WIDTH-1:0]                  im2,
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

    logic signed [S_WIDTH-1:0] psumm_i_re1;
    logic                valid_psumm_i_re1;

    logic signed [S_WIDTH-1:0] psumm_o_re1;
    logic                 valid_psumm_o_re1;

    assign psumm_i_re1       = (counter == 0) ? 'b0 : psumm_o_re1;
    assign valid_psumm_i_re1 = 'b1;

    logic signed [W_WIDTH-1:0] weight_re;
    assign weight_re = w_re[counter];

    syst_node #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .SI_WIDTH (S_WIDTH),
        .SO_WIDTH (S_WIDTH)
    ) re_node1 (
        .clk           (clk),
        .arstn         (arstn),
        .enable        (valid_i),
        .weight_i      (weight_re),

        .psumm_i       (psumm_i_re1),
        .valid_psumm_i (valid_psumm_i_re1),

        .x_i           (x1),
        .valid_x_i     (valid_i),

        .psumm_o       (psumm_o_re1),
        .valid_o       (valid_psumm_o_re1)
    );
    assign re1 = psumm_o_re1;

    //------------------------------------------------------------------------

    // IM

    logic signed [S_WIDTH-1:0] psumm_i_im1;
    logic                valid_psumm_i_im1;

    logic signed [S_WIDTH-1:0] psumm_o_im1;
    logic                 valid_psumm_o_im1;

    assign psumm_i_im1       = (counter == 0) ? 'b0 : psumm_o_im1;
    assign valid_psumm_i_im1 = 'b1;

    logic signed [W_WIDTH-1:0] weight_im;
    assign weight_im = w_im[counter];

    syst_node #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .SI_WIDTH (S_WIDTH),
        .SO_WIDTH (S_WIDTH)
    ) im_node1 (
        .clk           (clk),
        .arstn         (arstn),
        .enable        (valid_i),
        .weight_i      (weight_im),

        .psumm_i       (psumm_i_im1),
        .valid_psumm_i (valid_psumm_i_im1),

        .x_i           (x1),
        .valid_x_i     (valid_i),

        .psumm_o       (psumm_o_im1),
        .valid_o       (valid_psumm_o_im1)
    );
    assign im1 = psumm_o_im1;

    //------------------------------------------------------------------------

    // RE

    logic signed [S_WIDTH-1:0] psumm_i_re2;
    logic                valid_psumm_i_re2;

    logic signed [S_WIDTH-1:0] psumm_o_re2;
    logic                 valid_psumm_o_re2;

    assign psumm_i_re2       = (counter == 0) ? 'b0 : psumm_o_re2;
    assign valid_psumm_i_re2 = 'b1;

    syst_node #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .SI_WIDTH (S_WIDTH),
        .SO_WIDTH (S_WIDTH)
    ) re_node2 (
        .clk           (clk),
        .arstn         (arstn),
        .enable        (valid_i),
        .weight_i      (weight_re),

        .psumm_i       (psumm_i_re2),
        .valid_psumm_i (valid_psumm_i_re2),

        .x_i           (x2),
        .valid_x_i     (valid_i),

        .psumm_o       (psumm_o_re2),
        .valid_o       (valid_psumm_o_re2)
    );
    assign re2 = psumm_o_re2;

    //------------------------------------------------------------------------

    // IM

    logic signed [S_WIDTH-1:0] psumm_i_im2;
    logic                valid_psumm_i_im2;

    logic signed [S_WIDTH-1:0] psumm_o_im2;
    logic                 valid_psumm_o_im2;

    assign psumm_i_im2       = (counter == 0) ? 'b0 : psumm_o_im2;
    assign valid_psumm_i_im2 = 'b1;

    syst_node #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .SI_WIDTH (S_WIDTH),
        .SO_WIDTH (S_WIDTH)
    ) im_node2 (
        .clk           (clk),
        .arstn         (arstn),
        .enable        (valid_i),
        .weight_i      (weight_im),

        .psumm_i       (psumm_i_im2),
        .valid_psumm_i (valid_psumm_i_im2),

        .x_i           (x2),
        .valid_x_i     (valid_i),

        .psumm_o       (psumm_o_im2),
        .valid_o       (valid_psumm_o_im2)
    );
    assign im2 = psumm_o_im2;

    

endmodule