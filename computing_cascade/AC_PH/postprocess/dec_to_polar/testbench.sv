`timescale 1ns/1ps

module test;
    // Подключение

    logic                clk;
    logic                arstn;
    logic                enable;

    logic signed	[31:0] i_xval, i_yval;
    logic i_vld;

    logic signed	[31:0] o_mag;
    logic signed	[31:0] o_phase;
    logic o_vld;

    topolar tp (
        .clk           (clk),
        .rst         (~arstn),

        .i_vld (i_vld),
        .i_x (i_xval),
        .i_y (i_yval),

        .o_mag (o_mag),
        .o_phase (o_phase),
        .o_vld (o_vld)

    );

    initial begin
        $dumpfile("syst_node.vcd");
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
        i_xval <= 32'd1 << 'd10;
        i_yval <= 32'd1 << 'd10;
        $display("%d", 32'd1);
        $display("%d", 32'd1);

        @(posedge clk);
        i_vld <= 'b1;
        i_xval <= 32'd5 << 'd10;
        i_yval <= 32'd1 << 'd10;
        $display("%d", 32'd5);
        $display("%d", 32'd1);
        @(posedge clk);
        i_vld <= 'b1;
        i_xval <= 32'd1 << 'd10;
        i_yval <= 32'd5 << 'd10;
        $display("%d", 32'd1);
        $display("%d", 32'd5);

        @(posedge clk);
        i_vld <= 'b1;
        i_xval <= -32'd5 << 'd10;
        i_yval <= 32'd1 << 'd10;
        $display("-%d", 32'd5);
        $display("%d", 32'd1);
        @(posedge clk);
        i_vld <= 'b1;
        i_xval <= -32'd1 << 'd10;
        i_yval <= 32'd5 << 'd10;
        $display("-%d", 32'd1);
        $display("%d", 32'd5);

        @(posedge clk);
        i_vld <= 'b1;
        i_xval <= -32'd5 << 'd10;
        i_yval <= -32'd1 << 'd10;
        $display("-%d", 32'd5);
        $display("-%d", 32'd1);
        @(posedge clk);
        i_vld <= 'b1;
        i_xval <= -32'd1 << 'd10;
        i_yval <= -32'd5 << 'd10;
        $display("-%d", 32'd1);
        $display("-%d", 32'd5);

        @(posedge clk);
        i_vld <= 'b1;
        i_xval <= 32'd5 << 'd10;
        i_yval <= -32'd1 << 'd10;
        $display("%d", 32'd5);
        $display("-%d", 32'd1);
        @(posedge clk);
        i_vld <= 'b1;
        i_xval <= 32'd1 << 'd10;
        i_yval <= -32'd5 << 'd10;
        $display("%d", 32'd1);
        $display("-%d", 32'd5);

        @(posedge o_vld);
        $display("RESULTS");
        repeat(9) begin
            @(posedge clk);
            $display("%d", o_phase);
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