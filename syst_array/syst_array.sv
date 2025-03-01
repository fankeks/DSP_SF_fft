`include ".\syst_node\syst_node.sv"

module syst_array 
#(
    parameter W_WIDTH  = 16,
    parameter X_WIDTH  = 16,
    parameter S_WIDTH  = 32,

    parameter FRAME_LENGTH = 3
) 
(
    input  logic                                        clk,
    input  logic                                        arstn,
    input  logic                                        enable,
    input  logic signed [W_WIDTH-1:0] w_re [FRAME_LENGTH-1:0],
    input  logic signed [W_WIDTH-1:0] w_im [FRAME_LENGTH-1:0],

    input  logic        [FRAME_LENGTH-1:0]              valid_x,
    input  logic signed [X_WIDTH-1:0]                   x,

    output logic signed [S_WIDTH-1:0]                   re,
    output logic signed [S_WIDTH-1:0]                   im,
    output logic                                        valid_o
);
    logic signed [FRAME_LENGTH-1:0][X_WIDTH-1:0]       x1;
    logic        [FRAME_LENGTH-1:0]                    valid_x1;

    //---------------------------------------------------------------------------------------------
    // RE
    logic        [FRAME_LENGTH-1:0]               valid_generate1_re;
    logic signed [S_WIDTH-1:0]  psumm_generate1_re [FRAME_LENGTH-1:0];
    syst_node #(
        .W_WIDTH       ( W_WIDTH               ),
        .X_WIDTH       ( X_WIDTH               ),
        .SI_WIDTH      ( S_WIDTH               ),
        .SO_WIDTH      ( S_WIDTH               )
    ) node (  
        .clk           ( clk                   ),
        .arstn         ( arstn                 ),
        .enable        ( enable                ),
        .weight_i      ( w_re[0]               ),
 
        .psumm_i       ( 'd0                    ),
        .valid_psumm_i ( 1'b1                   ),
  
        .x_i           ( x                     ),
        .valid_x_i     ( valid_x[FRAME_LENGTH-1]            ),
  
        .psumm_o       ( psumm_generate1_re[0] ),
        .valid_o       ( valid_generate1_re[0] ),
  
        .x_o           ( x1[0]                 ),
        .valid_x_o     ( valid_x1[0]           )
    );
    genvar i;
    generate
        for (i = 1; i<FRAME_LENGTH; i=i+1) begin : newgen
            syst_node #(
                .W_WIDTH       ( W_WIDTH                 ),
                .X_WIDTH       ( X_WIDTH                 ),
                .SI_WIDTH      ( S_WIDTH                 ),
                .SO_WIDTH      ( S_WIDTH                 )
            ) node (
                .clk           ( clk                     ),
                .arstn         ( arstn                   ),
                .enable        ( enable                  ),
                .weight_i      ( w_re[i]                 ),
  
                .psumm_i       ( psumm_generate1_re[i-1] ),
                .valid_psumm_i ( valid_generate1_re[i-1] ),
  
                .x_i           ( x                       ),
                .valid_x_i     ( valid_x[FRAME_LENGTH-1-i]              ),
  
                .psumm_o       ( psumm_generate1_re[i]   ),
                .valid_o       ( valid_generate1_re[i]   ),
  
                .x_o           ( x1[i]                   ),
                .valid_x_o     ( valid_x1[i]             )
            );
        end
    endgenerate
    assign valid_o = valid_generate1_re[FRAME_LENGTH-1];
    assign re      = psumm_generate1_re[FRAME_LENGTH-1];
    //---------------------------------------------------------------------------------------------
    // IM
    logic        [FRAME_LENGTH-1:0]               valid_generate1_im;
    logic signed [S_WIDTH-1:0] psumm_generate1_im [FRAME_LENGTH-1:0];
    syst_node #(
        .W_WIDTH  ( W_WIDTH                    ),
        .X_WIDTH  ( X_WIDTH                    ),
        .SI_WIDTH ( S_WIDTH                    ),
        .SO_WIDTH ( S_WIDTH                    )
    ) node_gen (
        .clk           ( clk                   ),
        .arstn         ( arstn                 ),
        .enable        ( enable                ),
        .weight_i      ( w_im[0]               ),
 
        .psumm_i       ( 'd0                    ),
        .valid_psumm_i ( 1'b1                    ),
 
        .x_i           ( x1[0]                 ),
        .valid_x_i     ( valid_x1[0]           ),
 
        .psumm_o       ( psumm_generate1_im[0] ),
        .valid_o       ( valid_generate1_im[0] )
    );

    generate
        for (i = 1; i<FRAME_LENGTH; i=i+1) begin : newgen1
            syst_node #(
                .W_WIDTH       ( W_WIDTH                 ),
                .X_WIDTH       ( X_WIDTH                 ),
                .SI_WIDTH      ( S_WIDTH                 ),
                .SO_WIDTH      ( S_WIDTH                 )
            ) node (
                .clk           ( clk                     ),
                .arstn         ( arstn                   ),
                .enable        ( enable                  ),
                .weight_i      ( w_im[i]                 ),

                .psumm_i       ( psumm_generate1_im[i-1] ),
                .valid_psumm_i ( valid_generate1_im[i-1] ),

                .x_i           ( x1[i]                   ),
                .valid_x_i     ( valid_x1[i]             ),

                .psumm_o       ( psumm_generate1_im[i]   ),
                .valid_o       ( valid_generate1_im[i]   )
            );
        end
    endgenerate
    assign im       = psumm_generate1_im[FRAME_LENGTH-1];
    assign valid_im = valid_generate1_im[FRAME_LENGTH-1];
    
endmodule