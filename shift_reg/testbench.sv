`timescale 1ns/1ps

module test;
    // Подключение
    localparam LENGTH = 4;

    logic              clk;
    logic              arstn;
    logic              enable;
    logic [LENGTH-1:0] register;

    shift_reg #(
        .LENGTH  (LENGTH)
    ) r (
        .clk           (clk   ),
        .arstn         (arstn ),
        .enable        (enable),
        .register      (register)
    );

    initial begin
        $dumpfile("shift_reg.vcd");
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
        enable <= 'b1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        enable <= 'b0;
        @(posedge clk);
        @(posedge clk);
        enable <= 'b1;
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