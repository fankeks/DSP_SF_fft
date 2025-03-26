module testbench;
    // Подключение
    localparam W_WIDTH  = 16;
    localparam X_WIDTH  = 16;
    localparam S_WIDTH  = 38;
    localparam FRAME_LENGTH = 33;
    localparam NSTAGES = 21;

    logic [31:0] GLOBAL_COUNTER;

    logic                                        clk;
    logic                                        rstn;

    logic                                        i_vld;
    logic signed [X_WIDTH-1:0]                   x1;
    logic signed [X_WIDTH-1:0]                   x2;

    logic signed [31:0]                          delta_ph;
    logic        [31:0]                          div_mag;
    logic                                        o_vld;

    computing_cascade #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .S_WIDTH  (S_WIDTH),
        .FRAME_LENGTH (FRAME_LENGTH),

        .NSTAGES (NSTAGES)
    ) test (
        .clk           (clk   ),
        .rstn         (rstn ),

        .i_vld       (i_vld),
        .x1            (x1    ),
        .x2            (x2    ),

        .delta_ph (delta_ph),
        .div_mag  (div_mag),
        .o_vld    (o_vld)
    );

    initial begin
        $dumpfile("computing_cascade.vcd");
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
        rstn <= 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        rstn <= 1;
    end

    initial begin
        GLOBAL_COUNTER <= 'b0;
        wait(i_vld);
        repeat(160) begin
            @(posedge clk);
            GLOBAL_COUNTER <= GLOBAL_COUNTER + 'b1;
        end
    end

    // Генерация входных сигналов
    initial begin
        i_vld <= 'b0;
        x1 <= 'b0;
        x2 <= 'b0;

        wait(rstn);
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        //1
        repeat(FRAME_LENGTH) begin
            @(posedge clk);
            i_vld <= 'b1;
            x1 <= x1 + 'd1;
            x2 <= x2 + 'd2;
        end
        repeat(FRAME_LENGTH) begin
            @(posedge clk);
            i_vld <= 'b1;
            x1 <= x1 + 'd1;
            x2 <= x2 + 'd2;
        end

        @(posedge clk);
        i_vld <= 'b0;

        repeat(120) begin
            @(posedge clk);
        end

        $finish;
    end
endmodule