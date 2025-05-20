`include ".\\\chanel_postprocessor\\chanel_postprocessor.sv"


module chanels_distributor
# (
    parameter CHANELS = 4,
    parameter STADIES = 2
)
(
    input                              clk,
    input                              rstn,

    input                              i_vld,
    input  logic [$clog2(CHANELS)-1:0] i_addres,
    input  logic [31:0]                i_ac,
    input  logic [31:0]                i_ph,

    output                             o_vld,
    output logic [$clog2(CHANELS)-1:0] o_addres,
    output logic [31:0]                o_ac,
    output logic [31:0]                o_ph
);
    // COUNTER
    logic [CHANELS - 1 : 0] inds;
    always_comb begin
    for (integer i = 0; i < CHANELS; i++) begin 
        inds[i] = i_addres == i;
        end
    end

    // DISTRIBUTOR
    logic        [CHANELS - 1 : 0][31:0] res_ac;
    logic signed [CHANELS - 1 : 0][31:0] res_ph;
    logic        [CHANELS - 1 : 0]       res_vld;
    genvar i;
    generate
        for (i = 0; i<CHANELS; i++) begin : CHANEL
            chanel_postprocessor #(
                .WIDTH  (32),
                .DEPTH_WIDTH  (32 + (STADIES)),
                //.DEPTH_WIDTH  (32 + (1 << STADIES)),
                .N (STADIES)
            ) m_ac (
                .clk         (clk   ),
                .rstn        (rstn ),

                .i_vld       (inds[i] & i_vld),
                .i_data      (i_ac),

                .o_vld       (res_vld[i]),
                .o_data      (res_ac[i])
            );

            chanel_postprocessor #(
                .WIDTH  (32),
                .DEPTH_WIDTH  (32 + (STADIES)),
                //.DEPTH_WIDTH  (32 + (1 << STADIES)),
                .N (STADIES),
                .SIG(1)
            ) m_ph (
                .clk         (clk   ),
                .rstn        (rstn ),

                .i_vld       (inds[i] & i_vld),
                .i_data      (i_ph),

                .o_data      (res_ph[i])
            );
        end
    endgenerate

    // MUX res
    // Syntes latch
    always @ (*) begin
        o_ac = 'b0;
        o_ph = 'b0;
        o_addres = 'b0;
        for (int j = 0; j < CHANELS; j++) begin 
            if (res_vld[j]) begin
                o_ac = res_ac[j];
                o_ph = res_ph[j];
                o_addres = j;
            end
        end
    end

    // OR vld
    assign o_vld = |res_vld;

endmodule