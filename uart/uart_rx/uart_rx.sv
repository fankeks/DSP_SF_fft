`include "multi_push_multi_pop_fifo/multi_push_multi_pop_fifo.sv"


module uart_rx_writer
# ( parameter clk_mhz = 50,
              boadrate = 9600
)
(
    input clk,
    input rstn,
    input rx,

    output logic [7:0] data,
    output logic valid
);
    localparam scale = clk_mhz * 1000 * 1000 / boadrate;

    // Описание состояний
    typedef enum bit { 
        WAIT   = 1'b0,
        READ   = 1'b1
    } states;
    states state, next_state;

    always_ff @ (posedge clk) begin
        if (!rstn)
            state <= WAIT;
        else
            state <= next_state;
    end

    // Генераторы сигналов
    logic [31:0] cnt;
    wire enable;
    logic [3:0] read_bit;
    wire read_stop_bit;

    always_ff @ (posedge clk) begin
        if ((!rstn) | (state == WAIT))
            cnt <= scale - 'b1 + scale / 2;
        else
            if (enable)
                cnt <= scale - 'b1;
            else
                cnt <= cnt - 'b1;
    end
    assign enable = (cnt == '0);

    always_ff @ (posedge clk) begin
        if ((!rstn) | (state == WAIT))
            read_bit <= '0;
        else
            if (enable)
                if (read_stop_bit) read_bit <= '0;
                else               read_bit <= read_bit + 'b1;
    end
    assign read_stop_bit = (read_bit >= 'd9);

    // Описание переходов
    always_comb begin
        next_state = state;
        case (state)
            WAIT             : if (~rx) next_state = READ;
            READ             : if (read_stop_bit) next_state = WAIT;
            default          : next_state = state;
        endcase
    end

    // Сохранение значения
    logic [7:0] parallel_data;
    always_ff @ (posedge clk) begin
        if  (enable)
                parallel_data[read_bit] <= rx;
    end

    // Логика формирования выходов
    logic valid_reg;
    always_ff @(posedge clk) begin
        valid_reg <= read_stop_bit;
    end
    assign valid = !valid_reg & read_stop_bit;
    assign data = parallel_data;
endmodule


module uart_rx_module
# ( parameter clk_mhz = 50,
              boadrate = 9600,
              DEPTH = 4,
              N = 4
)
(
    input clk,
    input rstn,
    input rx,

    output logic [N - 1:0][7:0]          data,
    input logic [$clog2(N + 1) - 1 : 0]  pop,
    output logic [$clog2(N + 1) - 1 : 0] can_pop
);
    wire uart_valid;
    wire [7:0] uart_data;
    uart_rx_writer#
    (
        .clk_mhz(clk_mhz),
        .boadrate(boadrate)
    )uart_rx_w
    (
        .clk(clk),
        .rstn(rstn),
        .rx(rx),

        .valid(uart_valid),
        .data(uart_data)
    );

    // up_stream
    wire can_push;
    wire push;
    assign push = uart_valid & (|can_push);

    // down_stream
    wire [$clog2(N + 1) - 1 : 0] pop_buffer;
    assign pop_buffer = (pop > can_pop) ? 'b0 : pop;

    multi_push_multi_pop_fifo #(
    .W (8),    // UART
    .D (DEPTH),
    .NO (N),   // max pop
    .NI (1)    // max push
    ) buffer (
        .clk(clk),
        .rstn(rstn),

        .push(push),
        .push_data(uart_data),

        .pop(pop_buffer),
        .pop_data(data),

        .can_push(can_push),
        .can_pop(can_pop)
    );

endmodule