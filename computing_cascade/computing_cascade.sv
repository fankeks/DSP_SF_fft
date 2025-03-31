`include ".\\AC_PH\\AC_PH.sv"
`include ".\\chanels_distributor\\chanels_distributor.sv"
`include ".\\fifo_valid_ready\\flip_flop_fifo_empty_full_optimized.sv"
`include ".\\fifo_valid_ready\\ff_fifo_wrapped_in_valid_ready.sv"


module computing_cascade 
#(
    // Chanel_distributor
    parameter CHANELS = 4,
    parameter MEAN_STEPS = 2,
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

    output logic ac_ph_finish,
    input  logic [$clog2(CHANELS)-1:0] address_registration,
    output logic [$clog2(CHANELS)-1:0] address_output,

    output logic [31:0] ac,
    output logic signed [31:0] ph,
    output logic o_vld
);

    logic        [31:0] ac_chanel;
    logic signed [31:0] ph_chanel;
    logic               ac_ph_vld;
    //logic               ac_ph_finish;
    AC_PH #(
        .W_WIDTH      (W_WIDTH),
        .X_WIDTH      (X_WIDTH),
        .S_WIDTH      (S_WIDTH),
        .FRAME_LENGTH (FRAME_LENGTH),

        .NSTAGES      (NSTAGES)
    ) ac_ph_computing (
        .clk          (clk   ),
        .rstn         (rstn ),
    
        .i_vld        (i_vld),
        .x1           (x1    ),
        .x2           (x2    ),
    
        .ph           (ph_chanel),
        .ac           (ac_chanel),
        .o_vld        (ac_ph_vld),
        .finish       (ac_ph_finish)
    );

    // logic address_registration_en;
    // assign address_registration_en = address_registration == CHANELS-1;
    // always_ff @(posedge clk) begin
    //     if (!rstn)                       address_registration <= 'b0;
    //     else if (ac_ph_finish) begin
    //         if (address_registration_en) address_registration <= 'b0;
    //         else                         address_registration <= address_registration + 'b1;
    //     end
    // end

    logic                       fifo_vld;
    logic [$clog2(CHANELS)-1:0] down_address;
    ff_fifo_wrapped_in_valid_ready #(
        .width($clog2(CHANELS)),
        .depth(3)
    ) fifo (
        .clk(clk),
        .rstn (rstn),

        .up_valid(ac_ph_finish),    // upstream
        .up_data(address_registration),

        .down_valid(fifo_vld),  // downstream
        .down_ready(ac_ph_vld),
        .down_data(down_address)
    );

    chanels_distributor # (
        .CHANELS(CHANELS),
        .STADIES(MEAN_STEPS)
    ) chanels_distributor_module (
        .clk     (clk),
        .rstn    (rstn),

        .i_vld   (ac_ph_vld),
        .i_addres(down_address),
        .i_ac    (ac_chanel),
        .i_ph    (ph_chanel),

        .o_vld(o_vld),
        .o_addres(address_output),
        .o_ac(ac),
        .o_ph(ph)
    );

    
endmodule