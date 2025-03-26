`timescale 1ns/1ps

module test;
    // Подключение
    localparam W_IN  = 33;
    localparam W_OUT = 32;

    logic                clk;
    logic                arstn;

    logic signed [W_IN-1:0] i_data;
    logic i_vld;

    logic signed [W_OUT-1:0] o_data;
    logic o_vld;

    round #(
        .W_IN(W_IN),
        .W_OUT(W_OUT)
    )
    r1
    (
        .clk    (clk),
        .rstn   (arstn),

        .i_data (i_data),
        .i_vld  (i_vld),

        .o_data (o_data),
        .o_vld  (o_vld)

    );

    initial begin
        $dumpfile("round.vcd");
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
        i_vld <= 'b0;
        wait(arstn);
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        @(posedge clk);
        i_vld <= 'b1;
        i_data <= 33'd65535;
        @(posedge clk);
        i_vld <= 'b0;

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