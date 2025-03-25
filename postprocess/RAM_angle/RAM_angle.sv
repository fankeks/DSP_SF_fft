module RAM_angle
#(
    parameter WIDTH = 32,
    parameter DEPTH = 18
)
(
    input        clk,            // best to make it synchronous
    input        write_enable,     // a simple active high write enable
    input [$clog2 (DEPTH) - 1:0]  address,          // a single address bus in this example
    input [WIDTH-1:0]  data_in,          // input data
    output [WIDTH-1:0] data_out
);        // output data

  logic [WIDTH-1:0] w_re [0:DEPTH-1];          // here is the array; make this the size you need
  initial $readmemh(".\\weigths\\angle.txt", w_re);

  always @(posedge clk)
    if (write_enable)
      w_re[address] <= data_in;

  assign data_out = w_re[address];

endmodule