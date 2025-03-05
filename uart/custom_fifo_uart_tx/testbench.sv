`timescale 1ns/1ps

module testbench;
    // Подключение
    localparam WIDTH = 8; // fifo width
    localparam DEPTH = 4;  // fifo depth

    logic                clk;
    logic                arstn;
    logic                up_valid;    // upstream
    logic               up_ready;
    logic [DEPTH-1:0][WIDTH - 1:0] data_i;  // Эллементы буфера
    logic               down_valid;  // downstream
    logic                down_ready;
    logic [WIDTH - 1:0] down_data;

    custom_fifo_uart_tx_valid_ready #(
        .WIDTH  (WIDTH),
        .DEPTH  (DEPTH)
    ) node (
        .clk           (clk   ),
        .arstn         (arstn ),

        .up_valid      (up_valid),
        .up_ready      (up_ready),
        .data_i        (data_i ),

        .down_valid    (down_valid),
        .down_ready    (down_ready),
        .down_data     (down_data)
    );

    initial begin
        $dumpfile("test.vcd");
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
        up_valid   <= 'b0;
        down_ready <= 'b1;

        wait(arstn);
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        //1
        @(posedge clk);
        up_valid <= 'b1;
        data_i[0] <= 'd1;
        data_i[1] <= 'd2;
        data_i[2] <= 'd3;
        data_i[3] <= 'd4;
        
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