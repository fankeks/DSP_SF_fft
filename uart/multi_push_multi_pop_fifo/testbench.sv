`timescale 1ns/1ps

module testbench;
    // Подключение
    localparam W = 8;
    localparam D = 4;
    localparam N = 4;
    localparam WN = $clog2(N + 1);

    logic                clk;
    logic                rst;

    logic [WN - 1 : 0] push;
    logic [N - 1 : 0][W - 1 : 0] push_data;

    logic [WN - 1 : 0] pop;
    logic [N - 1 : 0][W - 1 : 0] pop_data;

    logic [WN - 1 : 0] can_push;
    logic [WN - 1 : 0] can_pop;

    multi_push_multi_pop_fifo #(
    .W  (W),
    .D  (D),
    .NI (N),
    .NO (N)   // max push / pop
    ) node (
        .clk(clk),
        .rst(rst),

        .push(push),
        .push_data(push_data),

        .pop(pop),
        .pop_data(pop_data),

        .can_push(can_push),
        .can_pop(can_pop)
    );

    initial begin
        $dumpfile("fifo_multi.vcd");
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
        rst <= 'b1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        rst <= 'b0;
    end

    // Генерация входных сигналов
    initial begin
        pop <= 'b0;
        wait(rst);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        push <= 'd3;
        push_data[0] <= 'd1;
        push_data[1] <= 'd2;
        push_data[2] <= 'd3;
        push_data[3] <= 'd4;

        @(posedge clk);
        push <='d0;
        pop <= 'd1;

        @(posedge clk);
        pop <= 'd1;

        @(posedge clk);
        pop <= 'd1;

        @(posedge clk);
        pop <= 'd0;

        @(posedge clk);
        pop <= 'd0;
        push <= 'd3;
        push_data[0] <= 'd6;
        push_data[1] <= 'd7;
        push_data[2] <= 'd8;
        push_data[3] <= 'd9;

        @(posedge clk);
        push <= 'd0;
        pop <= 'd2;
        @(posedge clk);
        push <= 'd0;
        pop <= 'd0;
    //---------------------------------------------------------------------------------------------
        //1
        @(posedge clk);
        repeat (20) begin
            @(posedge clk);
        end
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