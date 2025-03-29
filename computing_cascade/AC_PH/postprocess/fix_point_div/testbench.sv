`timescale 1ns/1ps

module test;
    // Подключение

    logic                clk;
    logic                arstn;

    logic [31:0] a, b;
    logic i_vld;

    logic [31:0] c;
    logic o_vld;
    logic ready;

    fxp_div_fsm #(
        .WIIA(29),
        .WIFA(3),

        .WIIB(29),
        .WIFB(3),

        .WOI(16),
        .WOF(16)
        ) tp (
        .clk (clk),
        .rstn (arstn),

        .i_vld (i_vld),
        .dividend (a),
        .divisor (b),

        .out (c),
        .o_vld(o_vld),
        .ready (ready)
    );

    initial begin
        $dumpfile("div.vcd");
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
        arstn <= 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        arstn <= 1;
    end

    // Генерация входных сигналов
    initial begin

        wait(arstn);
        i_vld <= 'b1;
        a <= 'd5 << 8;
        b <= 'd2 << 8;
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        @(posedge clk);
        $display("RESULTS");
        repeat(32) begin
            @(posedge clk);
            //$display("%d", o_phase);
        end

    //---------------------------------------------------------------------------------------------
        repeat(18) begin
            @(posedge clk);
        end
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $finish;
    end
endmodule