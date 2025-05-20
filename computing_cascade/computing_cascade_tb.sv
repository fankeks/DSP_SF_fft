module testbench;
    // Подключение
    localparam CHANELS = 4;
    localparam MEAN_STEPS = 1;

    localparam W_WIDTH  = 16;
    localparam X_WIDTH  = 16;
    localparam S_WIDTH  = 38;
    localparam FRAME_LENGTH = 5;

    localparam NSTAGES = 4;

    logic [31:0] GLOBAL_COUNTER;

    logic                                        clk;
    logic                                        rstn;

    logic                                        i_vld;
    logic signed [X_WIDTH-1:0]                   x1;
    logic signed [X_WIDTH-1:0]                   x2;

    logic [$clog2(CHANELS)-1:0] address_registration;
    logic [$clog2(CHANELS)-1:0] address_output;

    logic signed [31:0]                          delta_ph;
    logic        [31:0]                          mag;
    logic                                        o_vld;
    
    logic finish;
    logic address_registration_en;
    assign address_registration_en = address_registration == CHANELS-1;
    always_ff @(posedge clk) begin
        if (!rstn)                       address_registration <= 'b0;
        else if (finish) begin
            if (address_registration_en) address_registration <= 'b0;
            else                         address_registration <= address_registration + 'b1;
        end
    end

    computing_cascade #(
        .CHANELS(CHANELS),
        .MEAN_STEPS (MEAN_STEPS),

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

        .ac_ph_finish(finish),
        .address_registration(address_registration),
        .address_output (address_output),

        .ph (delta_ph),
        .ac  (mag),
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
        repeat(10000) begin
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
        repeat((1 << MEAN_STEPS) * 2) begin
            repeat(FRAME_LENGTH) begin
                i_vld <= 'b1;
                x1 <= x1 + 'd1;
                x2 <= x2 + 'd2;
                @(posedge clk);
                i_vld <= 'b0;
                repeat(8) begin
                    @(posedge clk);
                end
            end
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

            repeat(FRAME_LENGTH) begin
                @(posedge clk);
                i_vld <= 'b1;
                x1 <= x1 + 'd1;
                x2 <= x2 + 'd2;
            end

            @(posedge clk);
            i_vld <= 'b0;
        end

        repeat(120) begin
            @(posedge clk);
        end

        $finish;
    end
endmodule