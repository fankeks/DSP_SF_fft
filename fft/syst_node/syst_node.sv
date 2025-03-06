module syst_node
#(
    parameter W_WIDTH  = 16,
    parameter X_WIDTH  = 16,
    parameter SI_WIDTH = 32,
    parameter SO_WIDTH = 32
)
(
    input  logic                       clk,
    input  logic                       arstn,
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
    logic signed [X_WIDTH+W_WIDTH-1:0] weight_mult;

    logic valid;
    assign valid = valid_x_i & valid_psumm_i;

    // Расчёт результата
    logic en;
    assign en = enable & valid;
    assign weight_mult = x_i * weight_i;
    always_ff @(posedge clk) begin
        if (en)
            psumm_reg <= psumm_i + weight_mult;
    end

    // Расчёт валидности
    always_ff @(posedge clk or negedge arstn) begin
        if (~arstn)
            valid_o <= '0;
        else
            if (enable)
                valid_o <= valid;
    end

    assign psumm_o = psumm_reg;
    assign valid_x_o = valid_x_i;
    assign x_o = x_i;

endmodule