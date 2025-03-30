`timescale 1ns/1ps

module testbench;
    // Подключение
    localparam WIDTH  = 32;
    localparam DEPTH_WIDTH  = 33;
    localparam N = 2;
    localparam SIG = 1;

    logic                                        clk;
    logic                                        arstn;

    logic                                        i_vld;
    logic [WIDTH-1:0]                   i_data;

    logic                                        o_vld;
    logic [WIDTH-1:0]                   o_data;

    chanel_postprocessor #(
        .WIDTH  (WIDTH),
        .DEPTH_WIDTH  (DEPTH_WIDTH),
        .N (N),
        .SIG(SIG)
    ) m (
        .clk         (clk   ),
        .rstn       (arstn ),

        .i_vld       (i_vld),
        .i_data      (i_data),

        .o_vld       (o_vld),
        .o_data      (o_data)
    );

    initial begin
        $dumpfile("mean.vcd");
        $dumpvars;
    end
    // Запись значений в веса

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
        arstn <= 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        arstn <= 1;
    end

    // Генерация входных сигналов
    initial begin
        i_vld <= 'b0;

        wait(arstn);
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        //1
        @(posedge clk);
        i_vld <= 'b1;
        i_data <= 'd1;

        @(posedge clk);
        i_data <= -'d2;

        @(posedge clk);
        i_data <= 'd3;

        @(posedge clk);
        i_data <= 'd4;

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        $finish;
    end
    
endmodule