`include "multi_push_multi_pop_fifo/multi_push_multi_pop_fifo.sv"

module uart_tx_writer
# ( parameter clk_mhz = 50,
              boadrate = 9600
)
(
    input clk,
    input arstn,

    input valid,
    input [7:0] data,

    output logic ready, // 1 - Можно загружать новый пакет для отправки,
                        // 0 - Нужно ждать (Процесс отправки)
    output logic tx
);
    localparam scale = clk_mhz * 1000 * 1000 / boadrate;

    // Описание состояний
    typedef enum bit { 
        READY_TO_LOAD   = 1'b0, // Готовность загружать данные на отправку
        OUTPUT = 1'b1           // Отправка данных
    } states;
    states state, next_state;

    always_ff @ (posedge clk) begin
        if (!arstn)
            state <= READY_TO_LOAD;
        else
            state <= next_state;
    end

    // Генераторы сигналов
    logic [31:0] cnt;
    wire enable;
    logic [3:0] output_bit;
    wire output_stop_bit;

    always_ff @ (posedge clk) begin
        if (!arstn | (state == READY_TO_LOAD))
            cnt <= scale - 'b1;
        else
            if (enable)
                cnt <= scale - 'b1;
            else
                cnt <= cnt - 'b1;
    end
    assign enable = (cnt == '0);

    always_ff @ (posedge clk) begin
        if (!arstn | (state == READY_TO_LOAD))
            output_bit <= 'b0;
        else
            if (enable)
                if (output_stop_bit)
                    output_bit <= 'b0;
                else
                    output_bit <= output_bit + 'b1;
    end
    assign output_stop_bit = (output_bit >= 'd10);

    // Описание переходов
    always_comb begin
        next_state = state;
        case (state)
            READY_TO_LOAD    : if (valid) next_state = OUTPUT;
            OUTPUT           : if (output_stop_bit) next_state = READY_TO_LOAD;
            default          : next_state = state;
        endcase
    end

    // Регистр отправки данных
    logic [7:0] data_register;
    always_ff @ (posedge clk)
        if (valid & (ready))
            data_register <= data;
    wire [10:0] data_output = {1'b1, 1'b1, data_register, 1'b0};

    // Логика формирования выходов
    always_comb begin
        case (state)
            READY_TO_LOAD : begin 
                                ready = 1'b1; 
                                tx = 1'b1; 
                            end
            OUTPUT        : begin 
                                ready = 'b0;
                                tx = data_output[output_bit]; 
                            end
            default       : begin 
                                ready = 1'b1; 
                                tx = 1'b1; 
                            end
        endcase
    end
endmodule


module uart_tx_module
# (
    parameter DEPTH = 4,
              N = 4,
              clk_mhz = 50,
              boadrate = 9600
)
(
    input                                clk,
    input                                arstn,

    input  logic [$clog2(N + 1) - 1 : 0] push,        // Количество эллементов, которые запишутся в буфер
    output logic [$clog2(N + 1) - 1 : 0] can_push,    // Количество мест в буфере
    input  logic [N - 1 : 0][7:0]        data_i,      // Эллементы для записи

    output logic tx
);
    // up_interface
    wire [$clog2(N + 1) - 1 : 0] push_uart;
    assign push_uart = (push > can_push) ? 0 : push;

    // down_interface
    logic  down_valid;

    logic [7 : 0] down_data;

    logic down_ready;
    wire  pop = down_valid & down_ready;

    multi_push_multi_pop_fifo #(
    .W (8),    // UART
    .D (DEPTH),
    .NO (1),   // max pop
    .NI (N)    // max push
    ) buffer (
        .clk(clk),
        .rst(~arstn),

        .push(push_uart),
        .push_data(data_i),

        .pop(pop),
        .pop_data(down_data),

        .can_push(can_push),
        .can_pop(down_valid)
    );

    uart_tx_writer #(
        .clk_mhz (clk_mhz),
        .boadrate (boadrate)
    ) uart (
        .clk       (clk   ),
        .arstn     (arstn ),

        .valid     (down_valid),
        .data      (down_data),
        .ready     (down_ready),

        .tx        (tx)
    );
endmodule