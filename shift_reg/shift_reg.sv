module shift_reg
#(
    parameter LENGTH  = 3
)
(
    input  logic              clk,
    input  logic              arstn,
    input  logic              enable,
    
    output logic [LENGTH-1:0] register
);
    always_ff @ (posedge clk or negedge arstn)
       if (~arstn) begin
           register[LENGTH-2:0] <= 'b0;
           register[LENGTH-1]   <= 'b1;
       end
       else if (enable)
           register <= { register[0], register[LENGTH-1:1] };

endmodule