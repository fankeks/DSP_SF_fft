`include "custom_fifo_uart_tx/custom_fifo_uart_tx_valid_ready.sv"

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

    always_ff @ (posedge clk or negedge arstn) begin
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

    always_ff @ (posedge clk or negedge arstn) begin
        if (!arstn | (state == READY_TO_LOAD))
            cnt <= scale - 'b1;
        else
            if (enable)
                cnt <= scale - 'b1;
            else
                cnt <= cnt - 'b1;
    end
    assign enable = (cnt == '0);

    always_ff @ (posedge clk or negedge arstn) begin
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


module uart_tx
# (
    parameter DEPTH = 4,
              clk_mhz = 50,
              boadrate = 9600
)
(
    input                         clk,
    input                         arstn,

    input                         up_valid,    // upstream
    output                        up_ready,
    input  logic [DEPTH-1:0][7:0] data_i,  // Эллементы буфера

    output logic tx
);

    logic       down_valid;  // downstream
    logic       down_ready;
    logic [7:0] down_data;

    custom_fifo_uart_tx_valid_ready #(
        .WIDTH  (8),
        .DEPTH  (DEPTH)
    ) fifo (
        .clk           (clk   ),
        .arstn         (arstn ),

        .up_valid      (up_valid),
        .up_ready      (up_ready),
        .data_i        (data_i ),

        .down_valid    (down_valid),
        .down_ready    (down_ready),
        .down_data     (down_data)
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