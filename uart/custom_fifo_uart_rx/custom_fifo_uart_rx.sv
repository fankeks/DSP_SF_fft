module custom_fifo_uart_rx
#(
    parameter WIDTH = 8, // fifo width
    parameter DEPTH = 4  // fifo depth
)
(
    input                clk,
    input                arstn,

    input                push,
    input [WIDTH - 1:0]  write_data,

    output logic               valid_o,
    output logic [DEPTH - 1:0][WIDTH - 1:0] read_data
);

    //------------------------------------------------------------------------

    localparam pointer_width = $clog2 (DEPTH),
                          counter_width = $clog2 (DEPTH + 1);

    localparam [counter_width - 1:0] max_ptr = counter_width' (DEPTH - 1);

    //------------------------------------------------------------------------

    logic [pointer_width - 1:0] wr_ptr;
    logic wr_ptr_odd_circle, rd_ptr_odd_circle;

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or negedge arstn)
        if (!arstn)
        begin
            wr_ptr <= '0;
            wr_ptr_odd_circle <= 1'b0;
        end
        else if (push)
        begin
            if (wr_ptr == max_ptr)
            begin
                wr_ptr <= '0;
                wr_ptr_odd_circle <= ~ wr_ptr_odd_circle;
            end
            else
            begin
                wr_ptr <= wr_ptr + 1'b1;
            end
        end

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or negedge arstn)
        if (!arstn)
        begin
            rd_ptr_odd_circle <= 1'b0;
        end
        else if (valid_o)
        begin
            rd_ptr_odd_circle <= ~ rd_ptr_odd_circle;
        end

    //------------------------------------------------------------------------

    always_ff @ (posedge clk)
        if (push)
            read_data [wr_ptr] <= write_data;

    //------------------------------------------------------------------------

    wire equal_ptrs = (wr_ptr == '0);

    assign valid_o  = equal_ptrs & wr_ptr_odd_circle != rd_ptr_odd_circle;

endmodule