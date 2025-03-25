module syst_node
#(
    parameter W_WIDTH  = 16,
    parameter X_WIDTH  = 16,
    parameter SI_WIDTH = 32,
    parameter SO_WIDTH = 32
)
(
    input  logic                       clk,
    input  logic                       rstn,
    input  logic                       enable,
    input  logic signed [W_WIDTH -1:0] weight_i,

    input  logic signed [SI_WIDTH-1:0] psumm_i,
    input  logic                       valid_psumm_i,

    input  logic signed [X_WIDTH -1:0] x_i,
    input  logic                       valid_x_i,

    output logic signed [SO_WIDTH-1:0] psumm_o,
    output logic                       valid_o,

    output logic signed [X_WIDTH -1:0] x_o,
    output logic                       valid_x_o
);

    logic signed [SO_WIDTH       -1:0] psumm_reg;
    logic signed [SO_WIDTH       -1:0] psumm_o_logic;
    logic signed [X_WIDTH+W_WIDTH-1:0] weight_mult;
    logic                              en;

    logic  valid_o_logic;
    assign valid_o_logic = valid_x_i & valid_psumm_i;

    // Расчёт результата
    assign en = enable & valid_o_logic;
    assign weight_mult = x_i * weight_i;
    assign psumm_o_logic = psumm_i + weight_mult;
    always_ff @(posedge clk)
        if (en) psumm_reg <= psumm_o_logic;

    // Расчёт валидности
    always_ff @(posedge clk)
        if (~rstn)       valid_o <= 'b0;
        else if (enable) valid_o <= valid_o_logic;

    assign psumm_o = psumm_reg;
    assign valid_x_o = valid_x_i;
    assign x_o = x_i;

endmodule