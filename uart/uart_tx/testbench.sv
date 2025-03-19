`timescale 1ns/1ps


module test;
  // Подключение
  localparam DEPTH = 8;
  localparam N = 8;

  logic clk;
  logic clk_baud;
  logic arstn;
  logic tx;

  logic [N - 1 : 0][7 : 0] data_i;
  logic [$clog2(N + 1) - 1 : 0] push;
  logic [$clog2(N + 1) - 1 : 0] can_push;

  localparam BOADRATE_PARAM = 115200;
  uart_tx_module #
  (.boadrate(BOADRATE_PARAM),
   .DEPTH(DEPTH),
   .N    (N)
  )
  mrx1 
  (.clk(clk), 
   .arstn(arstn), 
   .tx(tx), 
  
   .data_i(data_i), 
   .push(push), 
   .can_push(can_push));

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
    push <= 'b0;
    wait(!arstn);
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk);

    push <= 'd8;
    data_i <= {32'h01020304, 32'h10203040};
    @(posedge clk);
    push <= 'd8;
    data_i <= 'd9;
    //valid <= 'b0;

    // repeat(80) begin
    //   @(posedge clk_baud);
    // end
    @(posedge can_push == 'd4);
    push <= 'd4;
    data_i <= 'h11121314;

    // repeat(80) begin
    //   @(posedge clk_baud);
    // end
    @(posedge can_push == 'd4);
    push <= 'b0;

    @(posedge can_push == 'd8);

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