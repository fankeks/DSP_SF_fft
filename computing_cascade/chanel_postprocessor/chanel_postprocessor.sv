//`include ".\\AC_PH\\postprocess\\round\\round.sv"

module chanel_postprocessor
#(
    parameter WIDTH = 32,
    parameter DEPTH_WIDTH = 33,
    parameter N = 1,             // Количество эллементов (степень двойки)
    parameter SIG = 0
) 
(
    input logic clk,
    input logic rstn,

    input logic i_vld,
    input logic [WIDTH-1:0] i_data,

    output logic o_vld,
    output logic [WIDTH-1:0] o_data
);
    generate
        if (N>0) begin
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
            //-------------------------------------------------------------------------------------
            if (SIG == 0) begin
                always_ff @(posedge clk) begin
                    if(~rstn_sum)   sum <= i_data;
                    else if (i_vld) sum <= sum + i_data;
                end
                //assign o_data = sum >> N;
            end
            else begin
                always_ff @(posedge clk) begin
                    if(~rstn_sum)   sum <= {{(DEPTH_WIDTH-WIDTH){i_data[WIDTH-1]}}, i_data};
                    else if (i_vld) sum <= sum + {{(DEPTH_WIDTH-WIDTH){i_data[WIDTH-1]}}, i_data};
                end
                //assign o_data = {{(N){sum[DEPTH_WIDTH-1]}}, sum[DEPTH_WIDTH-1:N]};
            end
            //-------------------------------------------------------------------------------------
            logic o_vld_sum;
            always_ff @(posedge clk) begin
                if (!rstn)       o_vld_sum <= 'b0;
                else if (enable) o_vld_sum <= i_vld;
                else             o_vld_sum <= 'b0;
            end
            //-------------------------------------------------------------------------------------
            round#(
                .W_IN (DEPTH_WIDTH),
                .W_OUT(DEPTH_WIDTH-N)
            ) r (
                .clk(clk),
                .rstn(rstn),

                .i_data(sum),
                .i_vld(o_vld_sum),

                .o_data(o_data),
                .o_vld(o_vld)
            );
        end
        else begin
            assign o_vld = i_vld;
            assign o_data = i_data;
        end
    endgenerate
    
endmodule