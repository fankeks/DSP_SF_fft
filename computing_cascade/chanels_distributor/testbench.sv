`timescale 1ns/1ps

module testbench;
    // Подключение
    localparam WIDTH  = 32;
    localparam CHANELS = 4;
    localparam STADIES = 2;

    logic                               clk;
    logic                               arstn;

    logic [$clog2(CHANELS)-1:0]         i_addres;
    logic                               i_vld;
    logic [WIDTH-1:0]                   i_ac;
    logic [WIDTH-1:0]                   i_ph;

    logic                               o_vld;
    logic [$clog2(CHANELS)-1:0]         o_addres;
    logic [WIDTH-1:0]                   o_ac;
    logic [WIDTH-1:0]                   o_ph;

    chanels_distributor # (
        .CHANELS(4),
        .STADIES(STADIES)
    ) test (
        .clk(clk),
        .rstn(arstn),

        .i_vld(i_vld),
        .i_addres(i_addres),
        .i_ac(i_ac),
        .i_ph(i_ph),

        .o_vld(o_vld),
        .o_addres(o_addres),
        .o_ac(o_ac),
        .o_ph(o_ph)
    );

    initial begin
        $dumpfile("chanels_distributor.vcd");
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
        i_addres <= 'd0;

        wait(arstn);
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        //1
        for (int i=0; i < (1<<STADIES); i++) begin
            @(posedge clk);
            i_vld <= 'b1;
            i_addres <= 'd0;
            i_ac   <= 'd2 + i;
            i_ph   <= 'd2 - i;

            @(posedge clk);
            i_vld <= 'b1;
            i_addres <= 'd1;
            i_ac   <= 'd2 + i;
            i_ph   <= 'd2 - i;

            @(posedge clk);
            i_vld <= 'b1;
            i_addres <= 'd2;
            i_ac   <= 'd2 + i;
            i_ph   <= 'd2 - i;

            @(posedge clk);
            i_vld <= 'b1;
            i_addres <= 'd3;
            i_ac   <= 'd2 + i;
            i_ph   <= 'd2 - i;
        end

        @(posedge clk);
        i_vld <= 'b0;
        @(posedge clk);
        @(posedge clk);

        $finish;
    end
    
endmodule