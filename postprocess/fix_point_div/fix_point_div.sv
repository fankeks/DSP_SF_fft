module div 
#(
    parameter W_INTEGER_I    = 29,
    parameter W_FRACTIONAL_I = 3,

    parameter W_INTEGER_O    = 16,
    parameter W_FRACTIONAL_O = 16
)
(
    input  logic signed [W_INTEGER_I + W_FRACTIONAL_I - 1:0] a,
    input  logic signed [W_INTEGER_I + W_FRACTIONAL_I - 1:0] b,

    output logic signed [W_INTEGER_O + W_FRACTIONAL_O - 1:0] c
);
    wire signed [W_INTEGER_I + W_FRACTIONAL_I + W_FRACTIONAL_O - 1:0] a_extended;
    assign a_extended = a << W_FRACTIONAL_O;

    assign c = a_extended / b;
    
endmodule