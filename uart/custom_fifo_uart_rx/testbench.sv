`timescale 1ns/1ps

module testbench;
    // Подключение
    localparam WIDTH = 8; // fifo width
    localparam DEPTH = 4;  // fifo depth

    logic                clk;
    logic                arstn;

    logic                push;
    logic [WIDTH - 1:0]  write_data;

    logic               valid_o;
    logic [DEPTH-1:0][WIDTH - 1:0] data_o;

    custom_fifo_uart_rx #(
        .WIDTH  (WIDTH),
        .DEPTH  (DEPTH)
    ) node (
        .clk           (clk   ),
        .arstn         (arstn ),

        .push          (push),
        .write_data    (write_data),

        .valid_o        (valid_o ),
        .read_data         (data_o)
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
        push   <= 'b0;

        wait(arstn);
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        //1
        @(posedge clk);
        push <= 'b1;
        write_data <= 'h1;
        
        @(posedge clk);
        write_data <= 'h2;
        @(posedge clk);
        write_data <= 'h3;
        @(posedge clk);
        write_data <= 'h4;
        @(posedge clk);
        write_data <= 'h5;
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