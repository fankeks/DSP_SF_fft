`timescale 1ns/1ps

module test;
    // Подключение
    localparam W_WIDTH  = 16;
    localparam X_WIDTH  = 16;
    localparam SI_WIDTH = 32;
    localparam SO_WIDTH = 32;

    logic                clk;
    logic                arstn;
    logic                enable;
    logic signed [W_WIDTH -1:0] weight_i;

    logic signed [SI_WIDTH-1:0] psumm_i;
    logic                valid_psumm_i;

    logic signed [X_WIDTH -1:0] x_i;
    logic                valid_x_i;

    logic signed [SO_WIDTH-1:0] psumm_o;
    logic                valid_o;

    logic signed [X_WIDTH -1:0] x_o;
    logic                valid_x_o;

    syst_node #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .SI_WIDTH (SI_WIDTH),
        .SO_WIDTH (SO_WIDTH)
    ) node (
        .clk           (clk),
        .arstn         (arstn),
        .enable        (enable),
        .weight_i      (weight_i),

        .psumm_i       (psumm_i),
        .valid_psumm_i (valid_psumm_i),

        .x_i           (x_i),
        .valid_x_i     (valid_x_i),

        .psumm_o       (psumm_o),
        .valid_o       (valid_o),

        .x_o           (x_o),
        .valid_x_o     (valid_x_o)
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
        valid_psumm_i <= 'b0;
        valid_x_i     <= 'b0;
        enable        <= 'b1;
        x_i           <= 'x;
        psumm_i       <= 'x;

        wait(arstn);
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        repeat (3)
        begin
            @(posedge clk);
            weight_i      <= $urandom();

            valid_psumm_i <= 'b1;
            psumm_i       = $urandom();

            valid_x_i     <= 'b1;
            x_i           <= $urandom();
        end
    //---------------------------------------------------------------------------------------------
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