module RAM_w_re
#(
    parameter WIDTH = 32,
    parameter DEPTH = 360
)
(
    input                         clk,
    input                         write_enable,
    input  [$clog2 (DEPTH) - 1:0] address,
    input  [WIDTH-1:0]            data_in,
    output [WIDTH-1:0]            data_out
);

  logic [WIDTH-1:0] w_re [0:DEPTH-1];
  initial $readmemb(".\\weigths\\w_re.txt", w_re);

  always @(posedge clk)
    if (write_enable)
      w_re[address] <= data_in;

  assign data_out = w_re[address];

endmodule