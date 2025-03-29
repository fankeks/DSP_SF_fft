
module	topolar 
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
	output	logic signed [31:0]	       o_phase
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

	logic	signed [NSTAGES:0] [WIDTH-1:0]	xs;
	logic	signed [NSTAGES:0] [WIDTH-1:0]	ys;
	logic	signed [NSTAGES:0] [WIDTH-1:0]	phs;
	logic          [NSTAGES:0]              valids;
    
	// Предварительный поворот в сектор -45 45
	always_ff @(posedge clk) begin
		if (rst) valids[0] <= 'b0;
		else begin
			valids[0] <= i_vld;
			if (i_vld) begin
				case ({i_y[WIDTH-1], i_x[WIDTH-1]} )
					2'b00:begin
						xs[0]  <= i_x + i_y;
						ys[0]  <= i_y - i_x;
						// Угол в градусах
						// 1  - знак
						// 9  - целая часть
						// 22 - дробная часть
						phs[0] <= 32'h0b40_0000;    // 45 градусов
					end
					2'b01:begin
						xs[0]  <= i_y - i_x;
						ys[0]  <= -i_x - i_y;
						phs[0] <= 32'h21c0_0000;    //135
					end
					2'b11:begin
						xs[0]  <= -i_y - i_x;
						ys[0]  <= i_x - i_y;
						phs[0] <= 32'hde40_0000;    //225 - 360
					end
					2'b10:begin
						xs[0]  <= i_x - i_y;
						ys[0]  <= i_x + i_y;
						phs[0] <= 32'hf4c0_0000;    //315 - 360
					end
					default: begin
						xs[0]  <= i_x + i_y;
						ys[0]  <= i_y - i_x;
						phs[0] <= 32'h0c90_fdaa;
					end
				endcase
			end
		end
	end

	genvar	i;
	generate for(i = 0; i < NSTAGES; i++) begin : TOPOLARloop
		always @(posedge clk)
		if (rst)begin
			valids[i+1] <= 'b0;
		end 
		else begin
			valids[i+1] <= valids[i];
			if (valids[i]) begin
				if (~ys[i][WIDTH-1]) begin
					xs[i+1] <= xs[i] + {{(i+1){ys[i][WIDTH-1]}}, ys[i][WIDTH-1:(i+1)]};
					ys[i+1] <= ys[i] - {{(i+1){xs[i][WIDTH-1]}}, xs[i][WIDTH-1:(i+1)]};
					phs[i+1] <= phs[i] + cordic_angle[i];
				end 
				else begin
					xs[i+1] <= xs[i] - {{(i+1){ys[i][WIDTH-1]}}, ys[i][WIDTH-1:(i+1)]};
					ys[i+1] <= ys[i] + {{(i+1){xs[i][WIDTH-1]}}, xs[i][WIDTH-1:(i+1)]};
					phs[i+1] <= phs[i] - cordic_angle[i];
				end
			end
		end
	end 
	endgenerate

	assign o_mag = xs[NSTAGES];
    assign o_phase = phs[NSTAGES];
	assign o_vld = valids[NSTAGES];

endmodule