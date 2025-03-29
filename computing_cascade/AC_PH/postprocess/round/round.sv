module round #(
    parameter W_IN  = 32,
    parameter W_OUT = 16
) 
(
    input                    clk,
    input                    rstn,

    input  logic [W_IN-1:0]  i_data,
    input  logic             i_vld,

    output logic [W_OUT-1:0] o_data,
    output logic             o_vld
);
    wire [W_IN-1:0] w_convergent;
    assign	w_convergent = i_data[(W_IN-1):0] + { {(W_OUT){1'b0}},
				                                  i_data[(W_IN-W_OUT)],
				                                  {(W_IN-W_OUT-1){!i_data[(W_IN-W_OUT)]}}
                                                };

    always_ff @(posedge clk) begin
        if (!rstn) o_vld <= 'b0;
        else begin
            o_vld <= i_vld;
            if (i_vld) o_data <= w_convergent[(W_IN-1):(W_IN-W_OUT)];
        end
    end
    
endmodule