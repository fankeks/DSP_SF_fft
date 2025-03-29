module arithmetic_right_shift
# (
    parameter N = 32, 
    parameter S = 10
)
(
    input  [N - 1:0] a, 
    output [N - 1:0] res
);
  assign res = { {S{a[N-1]}}, a[N-1:S]};
endmodule



module serial_fft_fsm
#(
    parameter W_WIDTH      = 16,
    parameter X_WIDTH      = 16,
    parameter S_WIDTH      = 32,
    parameter WF           = 10,

    parameter FRAME_LENGTH = 3,
    parameter CHANELS      = 2
)
(
    input  logic                                    clk,
    input  logic                                    rstn,

    input  logic signed [W_WIDTH-1:0]               w_re,
    input  logic signed [W_WIDTH-1:0]               w_im,

    input  logic                                    valid_i,
    input  logic signed [CHANELS-1:0] [X_WIDTH-1:0] x,
    
    output logic signed [CHANELS-1:0] [S_WIDTH-1:0] re,
    output logic signed [CHANELS-1:0] [S_WIDTH-1:0] im,
    output logic                                    valid_o,
    output logic                                    finish
);
    logic [$clog2(FRAME_LENGTH):0] cnt;
    logic cnt_enable;
    assign cnt_enable = cnt == FRAME_LENGTH-1;
    assign finish = cnt_enable & valid_i;
    always_ff @(posedge clk) begin
        if (!rstn)          cnt <= 'b0;
        if (valid_i) begin
            if (cnt_enable) cnt <= 'b0;
            else            cnt <= cnt + 'b1;
        end
    end

    always_ff @(posedge clk) begin
        if (!rstn)                     valid_o <= 'b0;
        else if(cnt_enable) valid_o <= valid_i;
        else                           valid_o <= 'b0;
    end

    genvar i;
    generate
        for (i=0; i<CHANELS; i++) begin : CHANEL
            logic signed [S_WIDTH-1:0] sn;
            logic signed [S_WIDTH-1:0] sn1;

            wire signed [S_WIDTH-1:0] s_mul;
            arithmetic_right_shift#(
                .N(S_WIDTH),
                .S(WF)
            ) mul_sn (
                .a(sn * (w_re << 1)),
                .res(s_mul)
            );

            always_ff @(posedge clk) begin
                if (valid_i) begin
                    if (|cnt) begin
                        sn <= s_mul - sn1 + (x[i] << WF);
                        sn1 <= sn;
                    end
                    else begin
                        sn <= x[i] <<< WF;
                        sn1 <= 'b0;
                    end
                end
            end

            logic signed [S_WIDTH-1:0] re_mul;
            arithmetic_right_shift#(
                .N(S_WIDTH),
                .S(WF)
            ) mul_re (
                .a(sn * w_re),
                .res(re_mul)
            );
            assign re[i] = re_mul - sn1;

            logic signed [S_WIDTH-1:0] im_mul;
            arithmetic_right_shift#(
                .N(S_WIDTH),
                .S(WF)
            ) mul_im (
                .a(sn * w_im),
                .res(im_mul)
            );
            assign im[i] = im_mul;
        end
    endgenerate
endmodule