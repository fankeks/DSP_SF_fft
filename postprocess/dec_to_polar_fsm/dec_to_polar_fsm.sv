
module	topolar_fsm
#(
    parameter WIDTH = 32
)
(
	input                              clk, 
	input                              rst, 
	
	input                              i_vld,
	input   logic signed [WIDTH - 1:0] i_x, 
	input   logic signed [WIDTH - 1:0] i_y,

	output  logic                      o_vld,
	output	logic signed [WIDTH - 1:0] o_mag,
	output	logic signed [31:0]	       o_phase,
	output  logic                      ready
	);
	localparam NSTAGES = 16;
	//
	logic signed [31:0] cordic_angle [0:(NSTAGES-1)];
	assign	cordic_angle[ 0] = 32'h06a4_29cc; //  26.565051 deg
	assign	cordic_angle[ 1] = 32'h0382_51d0; //  14.036243 deg
	assign	cordic_angle[ 2] = 32'h01c8_0044; //   7.125016 deg
	assign	cordic_angle[ 3] = 32'h00e4_e2a9; //   3.576334 deg
	assign	cordic_angle[ 4] = 32'h0072_8de5; //   1.789911 deg
	assign	cordic_angle[ 5] = 32'h0039_4a86; //   0.895174 deg
	assign	cordic_angle[ 6] = 32'h001c_a5b5; //   0.447614 deg
	assign	cordic_angle[ 7] = 32'h000e_52e9; //   0.223811 deg
	assign	cordic_angle[ 8] = 32'h0007_2976; //   0.111906 deg
	assign	cordic_angle[ 9] = 32'h0003_94bb; //   0.055953 deg
	assign	cordic_angle[10] = 32'h0001_ca5d; //   0.027976 deg
	assign	cordic_angle[11] = 32'h0000_e52e; //   0.013988 deg
	assign	cordic_angle[12] = 32'h0000_7297; //   0.006994 deg
	assign	cordic_angle[13] = 32'h0000_394b; //   0.003497 deg
	assign	cordic_angle[14] = 32'h0000_1ca5; //   0.001749 deg
	assign	cordic_angle[15] = 32'h0000_0e52; //   0.000874 deg
	//assign	cordic_angle[16] = 32'h0000_0729; //   0.000437 deg
	//assign	cordic_angle[17] = 32'h0000_0394; //   0.000219 deg

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

	logic signed [WIDTH-1:0] xs;
	logic signed [WIDTH-1:0] ys;
	logic signed [WIDTH-1:0] phs;
    
	logic signed [WIDTH-1:0] ys_abs;
	assign ys_abs = (ys[WIDTH-1]) ? -ys : ys;

	always_ff @(posedge clk) begin
		// Предварительный поворот в сектор -45 45
		if (i_vld & ready) begin
			case ({i_y[WIDTH-1], i_x[WIDTH-1]} )
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
			if (ys[WIDTH-1]) begin
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
		else begin
			xs <= 'b0;
			ys <= 'b0;
			phs <= 'b0;
		end
	end 

	assign o_mag = xs;
    assign o_phase = phs;
	assign o_vld = state == OUTPUT;
	assign ready = state != BUSY;

endmodule