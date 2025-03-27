`timescale 1ns/1ps


module test;
  // Подключение
  localparam DEPTH = 4;
  localparam N = 4;

  logic clk;
  logic clk_baud;
  logic arstn;
  logic rx;

  logic [N - 1:0][7:0] data;
  logic [$clog2(N + 1) - 1 : 0] pop;
  logic [$clog2(N + 1) - 1 : 0] can_pop;

  parameter BOADRATE_PARAM = 115200;
  uart_rx_module #
  (
    .boadrate(BOADRATE_PARAM),
    .DEPTH(DEPTH),
    .N (N)
  ) mrx1 
  (
    .clk(clk), 
    .rstn(arstn), 
    .rx(rx), 

    .data(data), 
    .pop(pop),
    .can_pop(can_pop)
  );

  initial begin
    $dumpfile("UART_RX.vcd");
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

  initial begin
    clk_baud <= 0;
    forever begin
      #(1000_000_000 / BOADRATE_PARAM); clk_baud <= ~clk_baud;
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

  // Генерация входных сигналов
  initial begin
    rx <= 1;
    wait(!arstn);
    pop <= 'd4;
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);
    // Старт бит
    rx <= 0;
    @(clk_baud);

    // Данные
    // 1
    rx <= 1;
    @(clk_baud);
    // 2
    rx <= 0;
    @(clk_baud);
    // 3
    rx <= 1;
    @(clk_baud);
    // 4
    rx <= 0;
    @(clk_baud);
    // 5
    rx <= 1;
    @(clk_baud);
    // 6
    rx <= 0;
    @(clk_baud);
    // 7
    rx <= 1;
    @(clk_baud);
    // 8
    rx <= 0;
    @(clk_baud);

    // Стоп бит
    rx <= 1;
    @(clk_baud);

    // Старт бит
    rx <= 0;
    @(clk_baud);

    // Данные
    // 1
    rx <= 0;
    @(clk_baud);
    // 2
    rx <= 0;
    @(clk_baud);
    // 3
    rx <= 0;
    @(clk_baud);
    // 4
    rx <= 0;
    @(clk_baud);
    // 5
    rx <= 1;
    @(clk_baud);
    // 6
    rx <= 1;
    @(clk_baud);
    // 7
    rx <= 1;
    @(clk_baud);
    // 8
    rx <= 1;
    @(clk_baud);

    // Стоп бит
    rx <= 1;
    @(clk_baud);

    // Старт бит
    rx <= 0;
    @(clk_baud);

    // Данные
    // 1
    rx <= 0;
    @(clk_baud);
    // 2
    rx <= 0;
    @(clk_baud);
    // 3
    rx <= 0;
    @(clk_baud);
    // 4
    rx <= 0;
    @(clk_baud);
    // 5
    rx <= 1;
    @(clk_baud);
    // 6
    rx <= 1;
    @(clk_baud);
    // 7
    rx <= 1;
    @(clk_baud);
    // 8
    rx <= 1;
    @(clk_baud);

    // Стоп бит
    rx <= 1;
    @(posedge clk_baud);

    // Старт бит
    rx <= 0;
    @(clk_baud);

    // Данные
    // 1
    rx <= 0;
    @(clk_baud);
    // 2
    rx <= 0;
    @(clk_baud);
    // 3
    rx <= 0;
    @(clk_baud);
    // 4
    rx <= 0;
    @(clk_baud);
    // 5
    rx <= 1;
    @(clk_baud);
    // 6
    rx <= 1;
    @(clk_baud);
    // 7
    rx <= 1;
    @(clk_baud);
    // 8
    rx <= 1;
    @(clk_baud);

    // Стоп бит
    rx <= 1;
    @(posedge clk_baud);
    @(posedge clk_baud);
    @(posedge clk_baud);
    $finish;
  end
endmodule