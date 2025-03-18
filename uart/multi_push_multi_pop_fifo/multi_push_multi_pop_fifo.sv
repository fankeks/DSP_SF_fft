module multi_push_multi_pop_fifo #(
    parameter W = 16,
    parameter D = 16,
    parameter N = 2,   // max push / pop
    localparam WN = $clog2(N + 1)
) (
    input  logic                         clk,
    input  logic                         rst,

    input  logic [WN - 1 : 0]            push,
    input  logic [ N - 1 : 0][W - 1 : 0] push_data,

    input  logic [WN - 1 : 0]            pop,
    output logic [ N - 1 : 0][W - 1 : 0] pop_data,

    output logic [WN - 1 : 0]            can_push,
    output logic [WN - 1 : 0]            can_pop
);

    //------------------------------------------------------------------------

    localparam pointer_width = $clog2 (D),
                          counter_width = $clog2 (D + 1);

    localparam [counter_width - 1:0] max_ptr = counter_width' (D - 1);

    //------------------------------------------------------------------------

    logic [pointer_width - 1:0] wr_ptr, rd_ptr;
    logic wr_ptr_odd_circle, rd_ptr_odd_circle;

    logic [D - 1 : 0] [W - 1:0] data;

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or posedge rst)
        if (rst)
        begin
            wr_ptr <= '0;
            wr_ptr_odd_circle <= 1'b0;
        end
        else if (|push)
        begin
            if (wr_ptr + push > max_ptr)
            begin
                wr_ptr <= wr_ptr + push - max_ptr - 1;
                wr_ptr_odd_circle <= ~ wr_ptr_odd_circle;
            end
            else
            begin
                wr_ptr <= wr_ptr + push;
            end
        end

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or posedge rst)
        if (rst)
        begin
            rd_ptr <= '0;
            rd_ptr_odd_circle <= 1'b0;
        end
        else if (|pop)
        begin
            if (rd_ptr + pop > max_ptr)
            begin
                rd_ptr <= rd_ptr + pop - max_ptr - 1;
                rd_ptr_odd_circle <= ~ rd_ptr_odd_circle;
            end
            else
            begin
                rd_ptr <= rd_ptr + pop;
            end
        end

    //------------------------------------------------------------------------
    // output

    always_ff @(posedge clk) begin
        if (|push) begin
            for (int i = 0; i < N; i++) begin
                if (i < push) begin
                    data[(i + wr_ptr > max_ptr) ? i + wr_ptr - max_ptr - 1 : i + wr_ptr] <= push_data[i];
                end
            end
        end
    end

    always_comb begin
        for (int j = 0; j < N; j++) begin
            pop_data[j] = data[(j + rd_ptr > max_ptr) ? j + rd_ptr - max_ptr - 1 : j + rd_ptr];
        end
    end

    // // can_push / can_pop
    wire [counter_width - 1:0] c_push;
    assign c_push = (rd_ptr_odd_circle == wr_ptr_odd_circle) ? D - (wr_ptr - rd_ptr) : (rd_ptr - wr_ptr);
    assign can_push = (c_push > N) ? N : c_push;

    wire [counter_width - 1:0] c_pop;
    assign c_pop = (rd_ptr_odd_circle == wr_ptr_odd_circle) ? wr_ptr - rd_ptr : D - (rd_ptr - wr_ptr);
    assign can_pop = (c_pop > N) ? N : c_pop;
    
endmodule