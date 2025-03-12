`timescale 1ns/1ps

module a
#(
    parameter W_WIDTH  = 16,
    parameter X_WIDTH  = 16,
    parameter S_WIDTH  = 32,

    parameter FRAME_LENGTH = 10
)
(
    input  logic                                       clk,
    input  logic                                       arstn,

    input  logic                                       valid_i,
    input  logic signed [X_WIDTH-1:0]                  x1,
    input  logic signed [X_WIDTH-1:0]                  x2,
    
    output logic signed [S_WIDTH-1:0]                  re1,
    output logic signed [S_WIDTH-1:0]                  im1,
    output logic signed [S_WIDTH-1:0]                  re2,
    output logic signed [S_WIDTH-1:0]                  im2,
    output logic signed                                valid_o
);
    logic signed [W_WIDTH-1:0] w_re [FRAME_LENGTH-1:0];
    logic signed [W_WIDTH-1:0] w_im [FRAME_LENGTH-1:0];
    
    initial $readmemb(".\\weigths\\w_re.txt", w_re);
    initial $readmemb(".\\weigths\\w_im.txt", w_im);
    
    serial_fft_coral #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .S_WIDTH  (S_WIDTH),
        .FRAME_LENGTH (FRAME_LENGTH)
    ) node (
        .clk           (clk   ),
        .arstn         (arstn ),
        .w_re          (w_re  ),
        .w_im          (w_im  ),

        .valid_i       (valid_i),
        .x1            (x1      ),
        .x2            (x2),

        .re1            (re1),
        .im1            (im1),
        .re2            (re2),
        .im2            (im2),
        .valid_o       (valid_o)
    );
endmodule

module testbench;
    // Подключение
    localparam W_WIDTH  = 16;
    localparam X_WIDTH  = 16;
    localparam S_WIDTH  = 32;
    localparam FRAME_LENGTH = 4;

    logic                                        clk;
    logic                                        arstn;

    logic                                        valid_i;
    logic signed [X_WIDTH-1:0]                   x1;
    logic signed [X_WIDTH-1:0]                   x2;

    logic signed [S_WIDTH-1:0]                   re1;
    logic signed [S_WIDTH-1:0]                   im1;
    logic signed [S_WIDTH-1:0]                   re2;
    logic signed [S_WIDTH-1:0]                   im2;
    logic                                        valid_o;

    a #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .S_WIDTH  (S_WIDTH),
        .FRAME_LENGTH (FRAME_LENGTH)
    ) node (
        .clk           (clk   ),
        .arstn         (arstn ),

        .valid_i       (valid_i),
        .x1            (x1     ),
        .x2            (x2     ),

        .re1            (re1),
        .im1            (im1),
        .re2            (re2),
        .im2            (im2),
        .valid_o       (valid_o)
    );

    initial begin
        $dumpfile("serial_fft_coral.vcd");
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
        valid_i <= 'b0;

        wait(arstn);
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        //1
        @(posedge clk);
        valid_i <= 'b1;
        x1 <= 'd1;
        x2 <= 'd2;

        @(posedge clk);
        x1 <= 'd3;
        x2 <= 'd4;

        @(posedge clk);
        x1 <= 'd5;
        x2 <= 'd6;

        @(posedge clk);
        x1 <= 'd7;
        x2 <= 'd8;

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