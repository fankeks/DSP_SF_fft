//`include ".\syst_node\syst_node.sv"
`include ".\\fft\\syst_node\\syst_node.sv"

module serial_fft_coral
#(
    parameter W_WIDTH      = 16,
    parameter X_WIDTH      = 16,
    parameter S_WIDTH      = 32,

    parameter FRAME_LENGTH = 3,
    parameter CHANELS      = 2
)
(
    input  logic                                    clk,
    input  logic                                    rstn,

    output logic        [$clog2(FRAME_LENGTH)-1:0]  counter,
    input  logic signed [W_WIDTH-1:0]               w_re,
    input  logic signed [W_WIDTH-1:0]               w_im,

    input  logic                                    valid_i,
    input  logic signed [CHANELS-1:0] [X_WIDTH-1:0] x,
    
    output logic signed [CHANELS-1:0] [S_WIDTH-1:0] re,
    output logic signed [CHANELS-1:0] [S_WIDTH-1:0] im,
    output logic                                    valid_o,
    output logic                                    finish
);
    //------------------------------------------------------------------------

    //------------------------------------------------------------------------

    // Счётчик для мультиплексирования
    logic counter_enable;
    assign counter_enable = counter == (FRAME_LENGTH - 1);
    assign finish = counter_enable & valid_i;
    always_ff @(posedge clk) begin
        if (!rstn)              valid_o <= 'b0;
        else if(counter_enable) valid_o <= valid_i;
        else                    valid_o <= 'b0;
    end
    always_ff @ (posedge clk)
        if (!rstn) begin
                                counter <= 'b0;
        end
        else if (valid_i) begin
            if (counter_enable) counter <= 'b0;
            else                counter <= counter + 1'b1;
        end
    
    logic reset_node;
    assign reset_node = |counter;

    //------------------------------------------------------------------------
    // RE
    genvar i;
    generate
        for (i = 0; i<CHANELS; i++) begin : RE
            logic signed [S_WIDTH-1:0] psumm_i_re;
            logic                valid_psumm_i_re;

            logic signed [S_WIDTH-1:0] psumm_o_re;
            logic                valid_psumm_o_re;

            assign psumm_i_re = reset_node ? psumm_o_re : 'b0;
            assign valid_psumm_i_re = 'b1;

            syst_node #(
                .W_WIDTH  (W_WIDTH),
                .X_WIDTH  (X_WIDTH),
                .SI_WIDTH (S_WIDTH),
                .SO_WIDTH (S_WIDTH)
            ) re_node1 (
                .clk           (clk             ),
                .rstn          (rstn            ),
                .enable        (valid_i         ),
                .weight_i      (w_re            ),

                .psumm_i       (psumm_i_re      ),
                .valid_psumm_i (valid_psumm_i_re),

                .x_i           (x[i]            ),
                .valid_x_i     (valid_i         ),

                .psumm_o       (psumm_o_re      ),
                .valid_o       (valid_psumm_o_re)
            );
            assign re[i] = psumm_o_re;
        end
    endgenerate

    //------------------------------------------------------------------------

    // IM
    genvar j;
    generate
        for (j = 0; j<CHANELS; j++) begin : IM
            logic signed [S_WIDTH-1:0] psumm_i_im;
            logic                valid_psumm_i_im;

            logic signed [S_WIDTH-1:0] psumm_o_im;
            logic                valid_psumm_o_im;

            assign psumm_i_im = reset_node ? psumm_o_im : 'b0;
            assign valid_psumm_i_im = 'b1;

            syst_node #(
                .W_WIDTH  (W_WIDTH),
                .X_WIDTH  (X_WIDTH),
                .SI_WIDTH (S_WIDTH),
                .SO_WIDTH (S_WIDTH)
            ) im_node1 (
                .clk           (clk             ),
                .rstn          (rstn            ),
                .enable        (valid_i         ),
                .weight_i      (w_im            ),

                .psumm_i       (psumm_i_im      ),
                .valid_psumm_i (valid_psumm_i_im),

                .x_i           (x[j]            ),
                .valid_x_i     (valid_i         ),

                .psumm_o       (psumm_o_im      ),
                .valid_o       (valid_psumm_o_im)
            );
            assign im[j] = psumm_o_im;
        end
    endgenerate

endmodule