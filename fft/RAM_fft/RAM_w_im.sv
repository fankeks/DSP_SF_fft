module RAM_w_im
#(
    parameter WIDTH = 32,
    parameter DEPTH = 360
)
(
    input                        clk,         
    input                        write_enable,
    input [$clog2 (DEPTH) - 1:0] address,     
    input [WIDTH-1:0]            data_in,     
    output [WIDTH-1:0]           data_out
);

  reg [WIDTH-1:0] w_im [0:DEPTH-1];          // here is the array; make this the size you need
  initial $readmemb(".\\weigths\\w_im.txt", w_im);

  always @(posedge clk)
    if (write_enable)
      w_im[address] <= data_in;

  assign data_out = w_im[address];

endmodule