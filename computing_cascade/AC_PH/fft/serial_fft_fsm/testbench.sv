`timescale 1ns/1ps

module a
#(
    parameter W_WIDTH  = 16,
    parameter X_WIDTH  = 16,
    parameter S_WIDTH  = 32,

    parameter FRAME_LENGTH = 10,
    parameter CHANELS = 2
)
(
    input  logic                                       clk,
    input  logic                                       arstn,

    input  logic                                       valid_i,
    input  logic signed [CHANELS-1:0] [X_WIDTH-1:0]    x,
    
    output logic signed [CHANELS-1:0][S_WIDTH-1:0]     re,
    output logic signed [CHANELS-1:0][S_WIDTH-1:0]     im,
    output logic                                       valid_o,
    output logic                                       finish
);
    logic signed [W_WIDTH-1:0] w_re;
    logic signed [W_WIDTH-1:0] w_im;

    assign w_re = 'd65376;
    assign w_im = -'d4572;
    
    serial_fft_fsm #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .S_WIDTH  (S_WIDTH),
        .FRAME_LENGTH (FRAME_LENGTH),
        .WF(16)

    ) core (
        .clk           (clk   ),
        .rstn         (arstn ),

        .w_re          (w_re  ),
        .w_im          (w_im  ),

        .valid_i       (valid_i),
        .x            (x      ),

        .re            (re),
        .im            (im),
        .valid_o       (valid_o),
        .finish        (finish)
    );
endmodule

module testbench;
    // Подключение
    localparam W_WIDTH  = 17;
    localparam X_WIDTH  = 16;
    localparam S_WIDTH  = 64;
    localparam FRAME_LENGTH = 360;
    localparam CHANELS = 2;

    logic                                        clk;
    logic                                        arstn;

    logic                                        valid_i;
    logic signed [CHANELS-1:0][X_WIDTH-1:0]      x;
    logic signed [X_WIDTH-1:0]                   x1;
    logic signed [X_WIDTH-1:0]                   x2;
    assign x = {x2, x1};

    logic signed [CHANELS-1:0][S_WIDTH-1:0]      re;
    logic signed [S_WIDTH-1:0] re1;
    logic signed [CHANELS-1:0][S_WIDTH-1:0]      im;
    logic signed [S_WIDTH-1:0] im1;
    logic                                        valid_o;
    logic                                        finish;
    assign re1 = re[0];
    assign im1 = im[0];

    a #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .S_WIDTH  (S_WIDTH),
        .FRAME_LENGTH (FRAME_LENGTH),
        .CHANELS (CHANELS)
    ) test (
        .clk           (clk   ),
        .arstn         (arstn ),

        .valid_i       (valid_i),
        .x            (x     ),

        .re            (re),
        .im            (im),
        .valid_o       (valid_o),
        .finish        (finish)
    );

    initial begin
        $dumpfile("serial_fft_fsm.vcd");
        $dumpvars;
    end
    // Запись значений в веса

    // Генерация clk
    parameter CLK_PERIOD = 20; // 50 МГц
    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD / 2); clk <= ~clk;
        end
    end

    //Генерация rst
    initial begin
        arstn <= 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        arstn <= 1;
    end

    // Генерация входных сигналов
    initial begin
        valid_i <= 'b0;

        wait(arstn);
        @(posedge clk);
    //---------------------------------------------------------------------------------------------
        //1
        @(posedge clk);
        @(posedge clk);
        valid_i <= 'b1;
x1       <= 'd2047;
@(posedge clk);
x1       <= 'd2188;
@(posedge clk);
x1       <= 'd2328;
@(posedge clk);
x1       <= 'd2466;
@(posedge clk);
x1       <= 'd2603;
@(posedge clk);
x1       <= 'd2737;
@(posedge clk);
x1       <= 'd2868;
@(posedge clk);
x1       <= 'd2994;
@(posedge clk);
x1       <= 'd3117;
@(posedge clk);
x1       <= 'd3234;
@(posedge clk);
x1       <= 'd3346;
@(posedge clk);
x1       <= 'd3452;
@(posedge clk);
x1       <= 'd3551;
@(posedge clk);
x1       <= 'd3642;
@(posedge clk);
x1       <= 'd3727;
@(posedge clk);
x1       <= 'd3803;
@(posedge clk);
x1       <= 'd3871;
@(posedge clk);
x1       <= 'd3931;
@(posedge clk);
x1       <= 'd3981;
@(posedge clk);
x1       <= 'd4023;
@(posedge clk);
x1       <= 'd4055;
@(posedge clk);
x1       <= 'd4078;
@(posedge clk);
x1       <= 'd4091;
@(posedge clk);
x1       <= 'd4094;
@(posedge clk);
x1       <= 'd4088;
@(posedge clk);
x1       <= 'd4072;
@(posedge clk);
x1       <= 'd4047;
@(posedge clk);
x1       <= 'd4012;
@(posedge clk);
x1       <= 'd3968;
@(posedge clk);
x1       <= 'd3915;
@(posedge clk);
x1       <= 'd3853;
@(posedge clk);
x1       <= 'd3782;
@(posedge clk);
x1       <= 'd3703;
@(posedge clk);
x1       <= 'd3617;
@(posedge clk);
x1       <= 'd3523;
@(posedge clk);
x1       <= 'd3422;
@(posedge clk);
x1       <= 'd3315;
@(posedge clk);
x1       <= 'd3201;
@(posedge clk);
x1       <= 'd3082;
@(posedge clk);
x1       <= 'd2959;
@(posedge clk);
x1       <= 'd2831;
@(posedge clk);
x1       <= 'd2699;
@(posedge clk);
x1       <= 'd2564;
@(posedge clk);
x1       <= 'd2427;
@(posedge clk);
x1       <= 'd2288;
@(posedge clk);
x1       <= 'd2147;
@(posedge clk);
x1       <= 'd2007;
@(posedge clk);
x1       <= 'd1866;
@(posedge clk);
x1       <= 'd1727;
@(posedge clk);
x1       <= 'd1589;
@(posedge clk);
x1       <= 'd1453;
@(posedge clk);
x1       <= 'd1319;
@(posedge clk);
x1       <= 'd1190;
@(posedge clk);
x1       <= 'd1064;
@(posedge clk);
x1       <= 'd943;
@(posedge clk);
x1       <= 'd827;
@(posedge clk);
x1       <= 'd717;
@(posedge clk);
x1       <= 'd613;
@(posedge clk);
x1       <= 'd516;
@(posedge clk);
x1       <= 'd427;
@(posedge clk);
x1       <= 'd345;
@(posedge clk);
x1       <= 'd270;
@(posedge clk);
x1       <= 'd205;
@(posedge clk);
x1       <= 'd148;
@(posedge clk);
x1       <= 'd100;
@(posedge clk);
x1       <= 'd61;
@(posedge clk);
x1       <= 'd31;
@(posedge clk);
x1       <= 'd11;
@(posedge clk);
x1       <= 'd1;
@(posedge clk);
x1       <= 'd0;
@(posedge clk);
x1       <= 'd9;
@(posedge clk);
x1       <= 'd28;
@(posedge clk);
x1       <= 'd56;
@(posedge clk);
x1       <= 'd94;
@(posedge clk);
x1       <= 'd140;
@(posedge clk);
x1       <= 'd196;
@(posedge clk);
x1       <= 'd261;
@(posedge clk);
x1       <= 'd334;
@(posedge clk);
x1       <= 'd415;
@(posedge clk);
x1       <= 'd503;
@(posedge clk);
x1       <= 'd599;
@(posedge clk);
x1       <= 'd702;
@(posedge clk);
x1       <= 'd811;
@(posedge clk);
x1       <= 'd926;
@(posedge clk);
x1       <= 'd1047;
@(posedge clk);
x1       <= 'd1172;
@(posedge clk);
x1       <= 'd1301;
@(posedge clk);
x1       <= 'd1434;
@(posedge clk);
x1       <= 'd1569;
@(posedge clk);
x1       <= 'd1707;
@(posedge clk);
x1       <= 'd1846;
@(posedge clk);
x1       <= 'd1987;
@(posedge clk);
x1       <= 'd2127;
@(posedge clk);
x1       <= 'd2268;
@(posedge clk);
x1       <= 'd2407;
@(posedge clk);
x1       <= 'd2545;
@(posedge clk);
x1       <= 'd2680;
@(posedge clk);
x1       <= 'd2812;
@(posedge clk);
x1       <= 'd2941;
@(posedge clk);
x1       <= 'd3065;
@(posedge clk);
x1       <= 'd3185;
@(posedge clk);
x1       <= 'd3299;
@(posedge clk);
x1       <= 'd3407;
@(posedge clk);
x1       <= 'd3509;
@(posedge clk);
x1       <= 'd3604;
@(posedge clk);
x1       <= 'd3692;
@(posedge clk);
x1       <= 'd3771;
@(posedge clk);
x1       <= 'd3843;
@(posedge clk);
x1       <= 'd3906;
@(posedge clk);
x1       <= 'd3961;
@(posedge clk);
x1       <= 'd4006;
@(posedge clk);
x1       <= 'd4043;
@(posedge clk);
x1       <= 'd4069;
@(posedge clk);
x1       <= 'd4087;
@(posedge clk);
x1       <= 'd4094;
@(posedge clk);
x1       <= 'd4092;
@(posedge clk);
x1       <= 'd4080;
@(posedge clk);
x1       <= 'd4059;
@(posedge clk);
x1       <= 'd4028;
@(posedge clk);
x1       <= 'd3988;
@(posedge clk);
x1       <= 'd3939;
@(posedge clk);
x1       <= 'd3880;
@(posedge clk);
x1       <= 'd3813;
@(posedge clk);
x1       <= 'd3738;
@(posedge clk);
x1       <= 'd3655;
@(posedge clk);
x1       <= 'd3564;
@(posedge clk);
x1       <= 'd3466;
@(posedge clk);
x1       <= 'd3361;
@(posedge clk);
x1       <= 'd3250;
@(posedge clk);
x1       <= 'd3134;
@(posedge clk);
x1       <= 'd3012;
@(posedge clk);
x1       <= 'd2886;
@(posedge clk);
x1       <= 'd2756;
@(posedge clk);
x1       <= 'd2622;
@(posedge clk);
x1       <= 'd2486;
@(posedge clk);
x1       <= 'd2347;
@(posedge clk);
x1       <= 'd2208;
@(posedge clk);
x1       <= 'd2067;
@(posedge clk);
x1       <= 'd1926;
@(posedge clk);
x1       <= 'd1786;
@(posedge clk);
x1       <= 'd1647;
@(posedge clk);
x1       <= 'd1510;
@(posedge clk);
x1       <= 'd1376;
@(posedge clk);
x1       <= 'd1245;
@(posedge clk);
x1       <= 'd1117;
@(posedge clk);
x1       <= 'd994;
@(posedge clk);
x1       <= 'd876;
@(posedge clk);
x1       <= 'd764;
@(posedge clk);
x1       <= 'd657;
@(posedge clk);
x1       <= 'd557;
@(posedge clk);
x1       <= 'd464;
@(posedge clk);
x1       <= 'd379;
@(posedge clk);
x1       <= 'd301;
@(posedge clk);
x1       <= 'd232;
@(posedge clk);
x1       <= 'd171;
@(posedge clk);
x1       <= 'd119;
@(posedge clk);
x1       <= 'd76;
@(posedge clk);
x1       <= 'd43;
@(posedge clk);
x1       <= 'd19;
@(posedge clk);
x1       <= 'd4;
@(posedge clk);
x1       <= 'd0;
@(posedge clk);
x1       <= 'd4;
@(posedge clk);
x1       <= 'd19;
@(posedge clk);
x1       <= 'd43;
@(posedge clk);
x1       <= 'd76;
@(posedge clk);
x1       <= 'd119;
@(posedge clk);
x1       <= 'd171;
@(posedge clk);
x1       <= 'd232;
@(posedge clk);
x1       <= 'd301;
@(posedge clk);
x1       <= 'd379;
@(posedge clk);
x1       <= 'd464;
@(posedge clk);
x1       <= 'd557;
@(posedge clk);
x1       <= 'd657;
@(posedge clk);
x1       <= 'd764;
@(posedge clk);
x1       <= 'd876;
@(posedge clk);
x1       <= 'd995;
@(posedge clk);
x1       <= 'd1118;
@(posedge clk);
x1       <= 'd1245;
@(posedge clk);
x1       <= 'd1376;
@(posedge clk);
x1       <= 'd1511;
@(posedge clk);
x1       <= 'd1648;
@(posedge clk);
x1       <= 'd1787;
@(posedge clk);
x1       <= 'd1927;
@(posedge clk);
x1       <= 'd2067;
@(posedge clk);
x1       <= 'd2208;
@(posedge clk);
x1       <= 'd2348;
@(posedge clk);
x1       <= 'd2486;
@(posedge clk);
x1       <= 'd2622;
@(posedge clk);
x1       <= 'd2756;
@(posedge clk);
x1       <= 'd2886;
@(posedge clk);
x1       <= 'd3012;
@(posedge clk);
x1       <= 'd3134;
@(posedge clk);
x1       <= 'd3251;
@(posedge clk);
x1       <= 'd3362;
@(posedge clk);
x1       <= 'd3466;
@(posedge clk);
x1       <= 'd3564;
@(posedge clk);
x1       <= 'd3655;
@(posedge clk);
x1       <= 'd3738;
@(posedge clk);
x1       <= 'd3814;
@(posedge clk);
x1       <= 'd3880;
@(posedge clk);
x1       <= 'd3939;
@(posedge clk);
x1       <= 'd3988;
@(posedge clk);
x1       <= 'd4028;
@(posedge clk);
x1       <= 'd4059;
@(posedge clk);
x1       <= 'd4080;
@(posedge clk);
x1       <= 'd4092;
@(posedge clk);
x1       <= 'd4094;
@(posedge clk);
x1       <= 'd4086;
@(posedge clk);
x1       <= 'd4069;
@(posedge clk);
x1       <= 'd4042;
@(posedge clk);
x1       <= 'd4006;
@(posedge clk);
x1       <= 'd3961;
@(posedge clk);
x1       <= 'd3906;
@(posedge clk);
x1       <= 'd3843;
@(posedge clk);
x1       <= 'd3771;
@(posedge clk);
x1       <= 'd3691;
@(posedge clk);
x1       <= 'd3604;
@(posedge clk);
x1       <= 'd3509;
@(posedge clk);
x1       <= 'd3407;
@(posedge clk);
x1       <= 'd3299;
@(posedge clk);
x1       <= 'd3184;
@(posedge clk);
x1       <= 'd3065;
@(posedge clk);
x1       <= 'd2940;
@(posedge clk);
x1       <= 'd2812;
@(posedge clk);
x1       <= 'd2680;
@(posedge clk);
x1       <= 'd2544;
@(posedge clk);
x1       <= 'd2407;
@(posedge clk);
x1       <= 'd2267;
@(posedge clk);
x1       <= 'd2127;
@(posedge clk);
x1       <= 'd1987;
@(posedge clk);
x1       <= 'd1846;
@(posedge clk);
x1       <= 'd1707;
@(posedge clk);
x1       <= 'd1569;
@(posedge clk);
x1       <= 'd1433;
@(posedge clk);
x1       <= 'd1301;
@(posedge clk);
x1       <= 'd1171;
@(posedge clk);
x1       <= 'd1046;
@(posedge clk);
x1       <= 'd926;
@(posedge clk);
x1       <= 'd811;
@(posedge clk);
x1       <= 'd702;
@(posedge clk);
x1       <= 'd599;
@(posedge clk);
x1       <= 'd503;
@(posedge clk);
x1       <= 'd414;
@(posedge clk);
x1       <= 'd333;
@(posedge clk);
x1       <= 'd260;
@(posedge clk);
x1       <= 'd196;
@(posedge clk);
x1       <= 'd140;
@(posedge clk);
x1       <= 'd94;
@(posedge clk);
x1       <= 'd56;
@(posedge clk);
x1       <= 'd28;
@(posedge clk);
x1       <= 'd9;
@(posedge clk);
x1       <= 'd0;
@(posedge clk);
x1       <= 'd1;
@(posedge clk);
x1       <= 'd11;
@(posedge clk);
x1       <= 'd31;
@(posedge clk);
x1       <= 'd61;
@(posedge clk);
x1       <= 'd100;
@(posedge clk);
x1       <= 'd148;
@(posedge clk);
x1       <= 'd205;
@(posedge clk);
x1       <= 'd271;
@(posedge clk);
x1       <= 'd345;
@(posedge clk);
x1       <= 'd427;
@(posedge clk);
x1       <= 'd517;
@(posedge clk);
x1       <= 'd614;
@(posedge clk);
x1       <= 'd717;
@(posedge clk);
x1       <= 'd827;
@(posedge clk);
x1       <= 'd943;
@(posedge clk);
x1       <= 'd1064;
@(posedge clk);
x1       <= 'd1190;
@(posedge clk);
x1       <= 'd1320;
@(posedge clk);
x1       <= 'd1453;
@(posedge clk);
x1       <= 'd1589;
@(posedge clk);
x1       <= 'd1727;
@(posedge clk);
x1       <= 'd1867;
@(posedge clk);
x1       <= 'd2007;
@(posedge clk);
x1       <= 'd2148;
@(posedge clk);
x1       <= 'd2288;
@(posedge clk);
x1       <= 'd2427;
@(posedge clk);
x1       <= 'd2564;
@(posedge clk);
x1       <= 'd2699;
@(posedge clk);
x1       <= 'd2831;
@(posedge clk);
x1       <= 'd2959;
@(posedge clk);
x1       <= 'd3083;
@(posedge clk);
x1       <= 'd3201;
@(posedge clk);
x1       <= 'd3315;
@(posedge clk);
x1       <= 'd3422;
@(posedge clk);
x1       <= 'd3523;
@(posedge clk);
x1       <= 'd3617;
@(posedge clk);
x1       <= 'd3704;
@(posedge clk);
x1       <= 'd3782;
@(posedge clk);
x1       <= 'd3853;
@(posedge clk);
x1       <= 'd3915;
@(posedge clk);
x1       <= 'd3968;
@(posedge clk);
x1       <= 'd4012;
@(posedge clk);
x1       <= 'd4047;
@(posedge clk);
x1       <= 'd4072;
@(posedge clk);
x1       <= 'd4088;
@(posedge clk);
x1       <= 'd4094;
@(posedge clk);
x1       <= 'd4091;
@(posedge clk);
x1       <= 'd4078;
@(posedge clk);
x1       <= 'd4055;
@(posedge clk);
x1       <= 'd4023;
@(posedge clk);
x1       <= 'd3981;
@(posedge clk);
x1       <= 'd3931;
@(posedge clk);
x1       <= 'd3871;
@(posedge clk);
x1       <= 'd3803;
@(posedge clk);
x1       <= 'd3727;
@(posedge clk);
x1       <= 'd3642;
@(posedge clk);
x1       <= 'd3550;
@(posedge clk);
x1       <= 'd3451;
@(posedge clk);
x1       <= 'd3346;
@(posedge clk);
x1       <= 'd3234;
@(posedge clk);
x1       <= 'd3117;
@(posedge clk);
x1       <= 'd2994;
@(posedge clk);
x1       <= 'd2867;
@(posedge clk);
x1       <= 'd2737;
@(posedge clk);
x1       <= 'd2603;
@(posedge clk);
x1       <= 'd2466;
@(posedge clk);
x1       <= 'd2327;
@(posedge clk);
x1       <= 'd2187;
@(posedge clk);
x1       <= 'd2047;
@(posedge clk);
x1       <= 'd1906;
@(posedge clk);
x1       <= 'd1766;
@(posedge clk);
x1       <= 'd1628;
@(posedge clk);
x1       <= 'd1491;
@(posedge clk);
x1       <= 'd1357;
@(posedge clk);
x1       <= 'd1226;
@(posedge clk);
x1       <= 'd1099;
@(posedge clk);
x1       <= 'd977;
@(posedge clk);
x1       <= 'd860;
@(posedge clk);
x1       <= 'd748;
@(posedge clk);
x1       <= 'd642;
@(posedge clk);
x1       <= 'd543;
@(posedge clk);
x1       <= 'd451;
@(posedge clk);
x1       <= 'd367;
@(posedge clk);
x1       <= 'd291;
@(posedge clk);
x1       <= 'd223;
@(posedge clk);
x1       <= 'd163;
@(posedge clk);
x1       <= 'd112;
@(posedge clk);
x1       <= 'd71;
@(posedge clk);
x1       <= 'd39;
@(posedge clk);
x1       <= 'd16;
@(posedge clk);
x1       <= 'd3;
@(posedge clk);
x1       <= 'd0;
@(posedge clk);
x1       <= 'd6;
@(posedge clk);
x1       <= 'd22;
@(posedge clk);
x1       <= 'd47;
@(posedge clk);
x1       <= 'd82;
@(posedge clk);
x1       <= 'd126;
@(posedge clk);
x1       <= 'd179;
@(posedge clk);
x1       <= 'd241;
@(posedge clk);
x1       <= 'd312;
@(posedge clk);
x1       <= 'd391;
@(posedge clk);
x1       <= 'd477;
@(posedge clk);
x1       <= 'd571;
@(posedge clk);
x1       <= 'd672;
@(posedge clk);
x1       <= 'd780;
@(posedge clk);
x1       <= 'd893;
@(posedge clk);
x1       <= 'd1012;
@(posedge clk);
x1       <= 'd1136;

@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);


        $finish;
    end
    
endmodule