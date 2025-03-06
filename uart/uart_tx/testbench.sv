`timescale 1ns/1ps


module test;
  // Подключение
  localparam DEPTH = 8;

  logic clk;
  logic clk_baud;
  logic arstn;
  logic tx;

  logic [DEPTH-1:0][7:0] data_i;
  logic up_valid;
  logic up_ready;

  parameter BOADRATE_PARAM = 115200;
  uart_tx_module #
  (.boadrate(BOADRATE_PARAM),
   .DEPTH(DEPTH)) 
  mrx1 
  (.clk(clk), 
   .arstn(arstn), 
   .tx(tx), 
  
   .data_i(data_i), 
   .up_valid(up_valid), 
   .up_ready(up_ready));

  initial begin
    $dumpfile("UART_TX.vcd");
    $dumpvars;
  end

  // Генерация clk
  parameter CLK_PERIOD = 20; // 50 МГц
  initial begin
    clk <= 0;
    forever begin
      #(CLK_PERIOD / 2); clk <= ~clk;
    end
  end

  //Генерация rst
  initial begin
    arstn <= '0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    arstn <= '1;
  end

  initial begin
    clk_baud <= 0;
    wait(arstn);
    forever begin
      #(1000_000_000 / BOADRATE_PARAM); clk_baud <= ~clk_baud;
    end
  end

  // Генерация входных сигналов
  initial begin
    up_valid <= 'b0;
    wait(!arstn);
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk);

    data_i <= {32'h01020304, 32'h10203040};

    up_valid <= 'b1;
    @(posedge clk);
    //valid <= 'b0;

    @(posedge up_ready);
    data_i <= 'h11121314;

    up_valid <= 'b1;
    @(posedge up_ready);
    up_valid <= 'b0;

    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);

    @(posedge clk_baud);
    @(posedge clk_baud);
    
    $finish;
  end
endmodule