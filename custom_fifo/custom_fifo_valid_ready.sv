module custom_fifo
#(
    parameter WIDTH = 8, // fifo width
    parameter DEPTH = 4  // fifo depth
)
(
    input                clk,
    input                arstn,

    input                valid_i,
    input logic [DEPTH-1:0][WIDTH - 1:0] data_i,  // Эллементы буфера

    input                pop,               
    output [WIDTH - 1:0] read_data,           // Эллемент для чтения

    output               empty
);

   //------------------------------------------------------------------------
    localparam pointer_width = $clog2 (DEPTH),
               counter_width = $clog2 (DEPTH + 1);

    localparam [counter_width - 1:0] max_ptr = counter_width' (DEPTH - 1);

    //------------------------------------------------------------------------

    logic [pointer_width - 1:0] wr_ptr, rd_ptr;
    logic wr_ptr_odd_circle, rd_ptr_odd_circle;

    logic [DEPTH-1:0][WIDTH - 1:0] data;

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or negedge arstn)
        if (!arstn)
        begin
            wr_ptr <= '0;
            wr_ptr_odd_circle <= 1'b0;
        end
        else if (valid_i)
        begin
            wr_ptr <= '0;
            wr_ptr_odd_circle <= ~ wr_ptr_odd_circle;
        end

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or negedge arstn)
        if (!arstn)
        begin
            rd_ptr <= '0;
            rd_ptr_odd_circle <= 1'b0;
        end
        else if (pop)
        begin
            if (rd_ptr == max_ptr)
            begin
                rd_ptr <= '0;
                rd_ptr_odd_circle <= ~ rd_ptr_odd_circle;
            end
            else
            begin
                rd_ptr <= rd_ptr + 1'b1;
            end
        end

    //------------------------------------------------------------------------

    always_ff @ (posedge clk)
        if (valid_i)
            data <= data_i;

    assign read_data = data[rd_ptr];

    //------------------------------------------------------------------------

    wire equal_ptrs = (wr_ptr == rd_ptr);

    assign empty = equal_ptrs & wr_ptr_odd_circle == rd_ptr_odd_circle;
    
endmodule

module custom_fifo_valid_ready
# (
    parameter WIDTH = 8, 
    parameter DEPTH = 4
)
(
    input                clk,
    input                arstn,

    input                up_valid,    // upstream
    output               up_ready,
    input logic [DEPTH-1:0][WIDTH - 1:0] data_i,  // Эллементы буфера

    output               down_valid,  // downstream
    input                down_ready,
    output [WIDTH - 1:0] down_data
);

    wire fifo_push;
    wire fifo_pop;
    wire fifo_empty;
    wire fifo_full;

    assign up_ready   = fifo_empty;
    assign valid_i    = up_valid & up_ready;

    assign down_valid = ~ fifo_empty;
    assign pop        = down_valid & down_ready;

    custom_fifo
    # (.WIDTH (WIDTH), .DEPTH (DEPTH))
    fifo
    (
        .clk        ( clk        ),
        .arstn      ( arstn      ),

        .valid_i    ( valid_i    ),
        .pop        ( pop        ),
        .data_i     ( data_i     ),
        .read_data  ( down_data  ),
        .empty      ( fifo_empty )
    );

endmodule