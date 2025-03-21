
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
	assign	cordic_angle[ 0] = 32'h1dac_6705; //  26.565051 deg
	assign	cordic_angle[ 1] = 32'h0fad_bafc; //  14.036243 deg
	assign	cordic_angle[ 2] = 32'h07f5_6ea6; //   7.125016 deg
	assign	cordic_angle[ 3] = 32'h03fe_ab76; //   3.576334 deg
	assign	cordic_angle[ 4] = 32'h01ff_d55b; //   1.789911 deg
	assign	cordic_angle[ 5] = 32'h00ff_faaa; //   0.895174 deg
	assign	cordic_angle[ 6] = 32'h007f_ff55; //   0.447614 deg
	assign	cordic_angle[ 7] = 32'h003f_ffea; //   0.223811 deg
	assign	cordic_angle[ 8] = 32'h001f_fffd; //   0.111906 deg
	assign	cordic_angle[ 9] = 32'h000f_ffff; //   0.055953 deg
	assign	cordic_angle[10] = 32'h0007_ffff; //   0.027976 deg
	assign	cordic_angle[11] = 32'h0003_ffff; //   0.013988 deg
	assign	cordic_angle[12] = 32'h0001_ffff; //   0.006994 deg
	assign	cordic_angle[13] = 32'h0000_ffff; //   0.003497 deg
	assign	cordic_angle[14] = 32'h0000_7fff; //   0.001749 deg
	assign	cordic_angle[15] = 32'h0000_3fff; //   0.000874 deg
	//assign	cordic_angle[16] = 32'h0000_1fff; //   0.000437 deg
	//assign	cordic_angle[17] = 32'h0000_0fff; //   0.000219 deg

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
						// Угол в радианах
						// 1  - знак
						// 1  - целая часть
						// 30 - дробная часть
						phs[0] <= 32'h3243f6a8;    // 45 градусов
					end
					2'b01:begin
						xs[0]  <= i_y - i_x;
						ys[0]  <= -i_x - i_y;
						phs[0] <= 32'hcdbc0958;    //135 - 180
					end
					2'b11:begin
						xs[0]  <= -i_y - i_x;
						ys[0]  <= i_x - i_y;
						phs[0] <= 32'h3243f6a8;    //225 - 180
					end
					2'b01:begin
						xs[0]  <= i_x - i_y;
						ys[0]  <= i_x + i_y;
						phs[0] <= 32'hcdbc0958;    //315 - 360
					end
					default: begin
						xs[0]  <= i_x + i_y;
						ys[0]  <= i_y - i_x;
						phs[0] <= 32'h3243f6a8;
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