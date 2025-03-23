
module	topolar_fsm
#(
    parameter WIDTH_XY   = 32,
	parameter WIDTH_PH   = 32,
	parameter NSTAGES    = 16
)
(
	input                                clk, 
	input                                rst, 

	input  logic signed [WIDTH_PH-1:0]   cordic_angle [0:(NSTAGES-1)],
	
	input                                i_vld,
	input  logic signed [WIDTH_XY - 1:0] i_x, 
	input  logic signed [WIDTH_XY - 1:0] i_y,

	output logic                         o_vld,
	output logic signed [WIDTH_XY - 1:0] o_mag,
	output logic signed [WIDTH_PH - 1:0] o_phase,
	output logic                         ready
	);

	enum logic[1:0]
  	{
    	IDLE   = 2'b00,
    	BUSY   = 2'b01,
    	OUTPUT = 2'b10
	}
	state, new_state;
	always_ff @ (posedge clk)
    if (rst)
    	state <= IDLE;
    else
    	state <= new_state;

	// Логика переходов
	localparam counter_width = $clog2 (NSTAGES + 1);
	logic [counter_width-1:0] cnt;
	logic en;
	assign en = cnt == (NSTAGES - 1);
	always_ff @(posedge clk) begin
		if (rst) cnt <= 'b0;
		else if (state == BUSY) begin
			if (en) cnt <= 'b0;
			else    cnt <= cnt + 'b1;
		end
		else cnt <= 'b0;
	end

	always_comb
	begin
		new_state = state;
		case (state)
		IDLE:   if (i_vld) new_state = BUSY;
		BUSY:   if (en   ) new_state = OUTPUT;
		OUTPUT: if (i_vld) new_state = BUSY;
				else       new_state = IDLE;
		default: new_state = state;
		endcase
	end

	logic signed [WIDTH_XY-1:0] xs;
	logic signed [WIDTH_XY-1:0] ys;
	logic signed [WIDTH_PH-1:0] phs;
    
	logic signed [WIDTH_XY-1:0] ys_abs;
	logic sig;
	assign sig = ys[WIDTH_XY-1];
	assign ys_abs = sig ? -ys : ys;

	always_ff @(posedge clk) begin
		// Предварительный поворот в сектор -45 45
		if (i_vld & ready) begin
			case ({i_y[WIDTH_XY-1], i_x[WIDTH_XY-1]} )
				2'b00:begin
					xs  <= i_x + i_y;
					ys  <= i_y - i_x;
					// Угол в градусах
					// 1  - знак
					// 9  - целая часть
					// 22 - дробная часть
					phs <= 32'h0b40_0000;    // 45 градусов
				end
				2'b01:begin
					xs  <= i_y - i_x;
					ys  <= -i_x - i_y;
					phs <= 32'h21c0_0000;    //135
				end
				2'b11:begin
					xs  <= -i_y - i_x;
					ys  <= i_x - i_y;
					phs <= 32'hde40_0000;    //225 - 360
				end
				2'b10:begin
					xs  <= i_x - i_y;
					ys  <= i_x + i_y;
					phs <= 32'hf4c0_0000;    //315 - 360
				end
				default: begin
					xs  <= i_x + i_y;
					ys  <= i_y - i_x;
					phs <= 32'h0c90_fdaa;
				end
			endcase
		end
		else if (state == BUSY) begin
			if (sig) begin
				xs <= xs + (ys_abs >> (cnt + 'b1));
				ys <= ys + (xs >> (cnt + 'b1));
				phs <= phs - cordic_angle[cnt];
			end 
			else begin
				xs <= xs + (ys >> (cnt + 'b1));
				ys <= ys - (xs >> (cnt + 'b1));
				phs <= phs + cordic_angle[cnt];
			end
		end
	end 

	assign o_mag = xs;
    assign o_phase = phs;
	assign o_vld = state == OUTPUT;
	assign ready = state != BUSY;

endmodule