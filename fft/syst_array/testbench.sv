`timescale 1ns/1ps

module test;
    // Подключение
    localparam W_WIDTH  = 16;
    localparam X_WIDTH  = 16;
    localparam S_WIDTH  = 32;
    localparam FRAME_LENGTH = 4;

    logic                                        clk;
    logic                                        arstn;
    logic                                        enable;
    logic signed [W_WIDTH-1:0] w_re [FRAME_LENGTH-1:0];
    logic signed [W_WIDTH-1:0] w_im [FRAME_LENGTH-1:0];
    logic        [FRAME_LENGTH-1:0]              valid_x;
    logic signed [X_WIDTH-1:0]                   x;
    logic signed [S_WIDTH-1:0]                   re;
    logic signed [S_WIDTH-1:0]                   im;
    logic                                        valid_o;

    syst_array #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .S_WIDTH  (S_WIDTH),
        .FRAME_LENGTH (FRAME_LENGTH)
    ) node (
        .clk           (clk   ),
        .arstn         (arstn ),
        .enable        (enable),
        .w_re          (w_re  ),
        .w_im          (w_im  ),

        .valid_x       (valid_x),
        .x             (x      ),

        .re            (re),
        .im            (im),
        .valid_o       (valid_o)
    );

    initial begin
        $dumpfile("syst_array.vcd");
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
        w_re[0] <= 2;
        w_re[1] <= 3;
        w_re[2] <= 4;
        w_re[3] <= 5;

        w_im[0] <= 1;
        w_im[1] <= -2;
        w_im[2] <= -3;
        w_im[3] <= 4;

        valid_x <= 3'b000;
        enable  <= 'b1;

        wait(arstn);
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        @(posedge clk);
        x <= 'd1;
        valid_x <= 4'b1000;

        @(posedge clk);
        x <= 'd2;
        valid_x <= 4'b0100;

        @(posedge clk);
        x <= 'd3;
        valid_x <= 4'b0010;

        @(posedge clk);
        enable  <= 'b0;
        @(posedge clk);
        @(posedge clk);

        @(posedge clk);
        enable  <= 'b1;
        x <= 'd4;
        valid_x <= 4'b0001;
    //---------------------------------------------------------------------------------------------
        @(posedge clk);
        x <= 'd10;
        valid_x <= 4'b1000;

        @(posedge clk);
        x <= 'd20;
        valid_x <= 4'b0100;

        @(posedge clk);
        x <= 'd30;
        valid_x <= 4'b0010;

        @(posedge clk);
        x <= 'd40;
        valid_x <= 4'b0001;



        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $finish;
    end
    
    // Проверка
    // initial begin
    //     wait(~arstn);
    //     @(posedge clk);
    //     @(posedge clk);
    // //---------------------------------------------------------------------------------------------
    //     repeat (32)
    //     begin
    //         @(posedge clk);
    //         if ($signed(psumm_o) != ($signed(psumm_i) + $signed(weight_i) * $signed(x_i) )) begin
    //             $display($signed(psumm_o));
    //             $display(($signed(psumm_i) + $signed(weight_i) * $signed(x_i)));
    //             $display($signed(psumm_i));
    //             $display($signed(weight_i));
    //             $display($signed(x_i));
    //             $error("BAD");
    //         end
    //         else begin
    //             $display("PASS");
    //             // $display($signed(psumm_o));
    //             // $display($signed(psumm_i));
    //             // $display($signed(weight_i));
    //             // $display($signed(x_i));
    //         end
    //     end
    // //---------------------------------------------------------------------------------------------
    //     @(posedge clk);
    //     @(posedge clk);
    //     @(posedge clk);
    //     $finish;
    // end
endmodule