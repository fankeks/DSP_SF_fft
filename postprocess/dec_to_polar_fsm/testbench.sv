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
    logic ready;

    localparam NSTAGES = 16;
	//
	logic signed [31:0] cordic_angle [0:(NSTAGES-1)];
	assign	cordic_angle[ 0] = 32'h06a4_29cc; //  26.565051 deg
	assign	cordic_angle[ 1] = 32'h0382_51d0; //  14.036243 deg
	assign	cordic_angle[ 2] = 32'h01c8_0044; //   7.125016 deg
	assign	cordic_angle[ 3] = 32'h00e4_e2a9; //   3.576334 deg
	assign	cordic_angle[ 4] = 32'h0072_8de5; //   1.789911 deg
	assign	cordic_angle[ 5] = 32'h0039_4a86; //   0.895174 deg
	assign	cordic_angle[ 6] = 32'h001c_a5b5; //   0.447614 deg
	assign	cordic_angle[ 7] = 32'h000e_52e9; //   0.223811 deg
	assign	cordic_angle[ 8] = 32'h0007_2976; //   0.111906 deg
	assign	cordic_angle[ 9] = 32'h0003_94bb; //   0.055953 deg
	assign	cordic_angle[10] = 32'h0001_ca5d; //   0.027976 deg
	assign	cordic_angle[11] = 32'h0000_e52e; //   0.013988 deg
	assign	cordic_angle[12] = 32'h0000_7297; //   0.006994 deg
	assign	cordic_angle[13] = 32'h0000_394b; //   0.003497 deg
	assign	cordic_angle[14] = 32'h0000_1ca5; //   0.001749 deg
	assign	cordic_angle[15] = 32'h0000_0e52; //   0.000874 deg
	//assign	cordic_angle[16] = 32'h0000_0729; //   0.000437 deg
	//assign	cordic_angle[17] = 32'h0000_0394; //   0.000219 deg

    topolar_fsm tp (
        .clk           (clk),
        .rst         (~arstn),

        .cordic_angle (cordic_angle),

        .i_vld (i_vld),
        .i_x (i_xval),
        .i_y (i_yval),

        .o_mag (o_mag),
        .o_phase (o_phase),
        .o_vld (o_vld),
        .ready (ready)
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

        @(posedge o_vld);
        i_vld <= 'b1;
        i_xval <= 32'd5 << 'd10;
        i_yval <= 32'd1 << 'd10;
        $display("%d", 32'd5);
        $display("%d", 32'd1);
        @(posedge o_vld);
        i_vld <= 'b1;
        i_xval <= 32'd1 << 'd10;
        i_yval <= 32'd5 << 'd10;
        $display("%d", 32'd1);
        $display("%d", 32'd5);

        @(posedge o_vld);
        i_vld <= 'b1;
        i_xval <= -32'd5 << 'd10;
        i_yval <= 32'd1 << 'd10;
        $display("-%d", 32'd5);
        $display("%d", 32'd1);
        @(posedge o_vld);
        i_vld <= 'b1;
        i_xval <= -32'd1 << 'd10;
        i_yval <= 32'd5 << 'd10;
        $display("-%d", 32'd1);
        $display("%d", 32'd5);

        @(posedge o_vld);
        i_vld <= 'b1;
        i_xval <= -32'd5 << 'd10;
        i_yval <= -32'd1 << 'd10;
        $display("-%d", 32'd5);
        $display("-%d", 32'd1);
        @(posedge o_vld);
        i_vld <= 'b1;
        i_xval <= -32'd1 << 'd10;
        i_yval <= -32'd5 << 'd10;
        $display("-%d", 32'd1);
        $display("-%d", 32'd5);

        @(posedge o_vld);
        i_vld <= 'b1;
        i_xval <= 32'd5 << 'd10;
        i_yval <= -32'd1 << 'd10;
        $display("%d", 32'd5);
        $display("-%d", 32'd1);
        @(posedge o_vld);
        i_vld <= 'b1;
        i_xval <= 32'd1 << 'd10;
        i_yval <= -32'd5 << 'd10;
        $display("%d", 32'd1);
        $display("-%d", 32'd5);
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