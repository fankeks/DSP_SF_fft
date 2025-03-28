module mean 
#(
    parameter WIDTH = 32,
    parameter DEPTH_WIDTH = 33,
    parameter N = 1            // Количество эллементов (степень двойки)
) 
(
    input logic clk,
    input logic rstn,

    input logic i_vld,
    input logic [WIDTH-1:0] i_data,

    output logic o_vld,
    output logic [WIDTH-1:0] o_data
);

    localparam cnt_max = (1 << N) - 1;
    logic [N-1:0] cnt;
    logic enable;
    assign enable = cnt == cnt_max;
    always_ff @(posedge clk) begin
        if (!rstn) cnt <= 'b0;
        else if (i_vld) begin
            cnt <= cnt + 'b1;
        end
    end

    logic [DEPTH_WIDTH-1:0] sum;
    logic rstn_sum;
    assign rstn_sum = |cnt;
    always_ff @(posedge clk) begin
        if(~rstn_sum)   sum <= i_data;
        else if (i_vld) sum <= sum + i_data;
    end

    always_ff @(posedge clk) begin
        if (!rstn)       o_vld <= 'b0;
        else if (enable) o_vld <= i_vld;
        else             o_vld <= 'b0;
    end

    assign o_data = sum >> N;
    
endmodule