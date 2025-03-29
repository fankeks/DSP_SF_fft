// https://github.com/WangXuan95/FPGA-FixedPoint/tree/master


module fxp_zoom #(
    parameter WII  = 8,
    parameter WIF  = 8,
    parameter WOI  = 8,
    parameter WOF  = 8
)(
    input  logic [WII+WIF-1:0] in,
    output logic [WOI+WOF-1:0] out
);
    logic [WII+WOF-1:0] inr;
    logic [WII-1:0]     ini;
    logic [WOI-1:0]     outi;
    logic [WOF-1:0]     outf;

    generate if(WOF<WIF) begin
        assign inr = in[WII+WIF-1:WIF-WOF];
    end
    else if(WOF==WIF) begin
            assign inr[WII+WOF-1:WOF-WIF] = in;
        end 
        else begin
            assign inr[WII+WOF-1:WOF-WIF] = in;
            assign inr[WOF-WIF-1:0] = 0;
        end 
    endgenerate


    generate if(WOI<WII) begin
        always_comb begin
            {ini, outf} = inr;
            if ( ~ini[WII-1] & |ini[WII-2:WOI-1] ) begin
                outi = {WOI{1'b1}};
                outi[WOI-1] = 1'b0;
                outf = {WOF{1'b1}};
            end 
            else if(  ini[WII-1] & ~(&ini[WII-2:WOI-1]) ) begin
                outi = 0;
                outi[WOI-1] = 1'b1;
                outf = 0;
            end 
            else begin
                outi = ini[WOI-1:0];
            end
        end
    end 
    else begin
        always @ (*) begin
            {ini, outf} = inr;
            outi = ini[WII-1] ? {WOI{1'b1}} : 0;
            outi[WII-1:0] = ini;
        end
    end 
    endgenerate

    assign out = {outi, outf};

endmodule


module fxp_div_fsm #(
    parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8
)(
    input  wire                  rstn,
    input  wire                  clk,

    input  logic                 i_vld,
    input  logic [WIIA+WIFA-1:0] dividend,
    input  logic [WIIB+WIFB-1:0] divisor,

    output logic [WOI+WOF -1:0]  out,
    output logic                 o_vld,
    output logic                 ready
);
    // Переменные
    localparam WRI = WOI+WIIB > WIIA ? WOI+WIIB : WIIA;
    localparam WRF = WOF+WIFB > WIFA ? WOF+WIFB : WIFA;

    logic [WRI+WRF-1:0] divd, divr;
    logic [WRI+WRF-1:0] acc;
    logic [WRI+WRF-1:0] divdp;
    logic [WRI+WRF-1:0] divrp;
    logic [WOI+WOF-1:0] res;

    // Состояния
    enum logic[1:0]
  	{
    	IDLE   = 2'b00,
    	BUSY   = 2'b01,
    	OUTPUT = 2'b10
	}
	state, new_state;
	always_ff @ (posedge clk)
    if (!rstn)
    	state <= IDLE;
    else
    	state <= new_state;
    
    // Логика переходов
    logic en;
    logic [$clog2(WOI+WOF)-1:0] cnt;
	assign en = cnt == (WOI+WOF - 1);
	always_ff @(posedge clk) begin
		if (!rstn)  cnt <= 'b0;
		else if (state == BUSY) begin
			if (en) cnt <= 'b0;
			else    cnt <= cnt + 'b1;
		end
		else        cnt <= 'b0;
	end

	always_comb
	begin
		new_state = state;
		case (state)
		IDLE:   if (i_vld) new_state = BUSY;
		BUSY:   if (en   ) new_state = OUTPUT;
		OUTPUT: if (i_vld) new_state = BUSY;
				else       new_state = IDLE;
		default:           new_state = state;
		endcase
	end

    // Расчёт

    fxp_zoom # (
        .WII      ( WIIA      ),
        .WIF      ( WIFA      ),
        .WOI      ( WRI       ),
        .WOF      ( WRF       )
    ) dividend_zoom (
        .in       ( dividend ),
        .out      ( divd     )
    );

    fxp_zoom # (
        .WII      ( WIIB      ),
        .WIF      ( WIFB      ),
        .WOI      ( WRI       ),
        .WOF      ( WRF       )
    )  divisor_zoom (
        .in       ( divisor   ),
        .out      ( divr      )
    );

    logic [WRI+ WRF-1:0] tmp;
    assign tmp = (cnt < WOI) ? acc + (divrp<<(WOI - 'b1 - cnt)) : acc + (divrp>>('b1 + cnt - WOI));
    always_ff @(posedge clk) begin
        if (state != BUSY) begin
            if (i_vld & ready) begin
                res <= 'b0;
                acc <= 'b0;
                divdp <= divd;
                divrp <= divr;
            end
        end
        else begin
            if( tmp < divdp ) begin
                acc <= tmp;
                res[WOF+WOI-'b1-cnt] <= 1'b1;
            end 
            else begin
                acc <= acc;
                res[WOF+WOI-'b1-cnt] <= 1'b0;
            end
        end
    end

    // Выход
    assign out = res;
    assign ready = state != BUSY;
    assign o_vld = state == OUTPUT;

endmodule