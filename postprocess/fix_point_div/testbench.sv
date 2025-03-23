`timescale 1ns/1ps

module test;
    // Подключение

    logic                clk;
    logic                arstn;

    logic signed	[31:0] a, b;
    logic i_vld;

    logic signed	[31:0] c;
    logic o_vld;

    div tp (
        .a (a),
        .b (b),
        .c (c)
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
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        @(posedge clk);

        a <= 32'd1 << 'd3;
        b <= 32'd1 << 'd3;

        @(posedge clk);
        a <= 32'd5 << 'd3;
        b <= 32'd1 << 'd3;

        @(posedge clk);
        a <= 32'd1 << 'd3;
        b <= 32'd5 << 'd3;

        @(posedge clk);
        a <= -32'd5 << 'd3;
        b <= 32'd1 << 'd3;

        @(posedge clk);
        a <= -32'd1 << 'd3;
        b <= 32'd5 << 'd3;

        @(posedge clk);
        a <= -32'd5 << 'd3;
        b <= -32'd1 << 'd3;

        @(posedge clk);
        a <= -32'd1 << 'd3;
        b <= -32'd5 << 'd3;

        @(posedge clk);
        $display("RESULTS");
        repeat(9) begin
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