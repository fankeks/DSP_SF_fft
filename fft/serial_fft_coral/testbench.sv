`timescale 1ns/1ps

module a
#(
    parameter W_WIDTH  = 16,
    parameter X_WIDTH  = 16,
    parameter S_WIDTH  = 32,

    parameter FRAME_LENGTH = 10
)
(
    input  logic                                       clk,
    input  logic                                       arstn,

    input  logic                                       valid_i,
    input  logic signed [X_WIDTH-1:0]                  x,
    
    output logic signed [S_WIDTH-1:0]                  re,
    output logic signed [S_WIDTH-1:0]                  im,
    output logic signed                                valid_o
);
    logic signed [W_WIDTH-1:0] w_re [FRAME_LENGTH-1:0];
    logic signed [W_WIDTH-1:0] w_im [FRAME_LENGTH-1:0];
    
    initial $readmemb(".\\weigths\\w_re.txt", w_re);
    initial $readmemb(".\\weigths\\w_im.txt", w_im);
    
    serial_fft_coral #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .S_WIDTH  (S_WIDTH),
        .FRAME_LENGTH (FRAME_LENGTH)
    ) node (
        .clk           (clk   ),
        .arstn         (arstn ),
        .w_re          (w_re  ),
        .w_im          (w_im  ),

        .valid_i       (valid_i),
        .x             (x      ),

        .re            (re),
        .im            (im),
        .valid_o       (valid_o)
    );
endmodule

module testbench;
    // Подключение
    localparam W_WIDTH  = 16;
    localparam X_WIDTH  = 16;
    localparam S_WIDTH  = 32;
    localparam FRAME_LENGTH = 360;

    logic                                        clk;
    logic                                        arstn;

    logic                                        valid_i;
    logic signed [X_WIDTH-1:0]                   x;

    logic signed [S_WIDTH-1:0]                   re;
    logic signed [S_WIDTH-1:0]                   im;
    logic                                        valid_o;

    a #(
        .W_WIDTH  (W_WIDTH),
        .X_WIDTH  (X_WIDTH),
        .S_WIDTH  (S_WIDTH),
        .FRAME_LENGTH (FRAME_LENGTH)
    ) node (
        .clk           (clk   ),
        .arstn         (arstn ),

        .valid_i       (valid_i),
        .x             (x      ),

        .re            (re),
        .im            (im),
        .valid_o       (valid_o)
    );

    initial begin
        $dumpfile("serial_fft_coral.vcd");
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
valid_i <= 'b1;
x       <= 'd2047;
@(posedge clk);
x       <= 'd2188;
@(posedge clk);
x       <= 'd2328;
@(posedge clk);
x       <= 'd2466;
@(posedge clk);
x       <= 'd2603;
@(posedge clk);
x       <= 'd2737;
@(posedge clk);
x       <= 'd2868;
@(posedge clk);
x       <= 'd2994;
@(posedge clk);
x       <= 'd3117;
@(posedge clk);
x       <= 'd3234;
@(posedge clk);
x       <= 'd3346;
@(posedge clk);
x       <= 'd3452;
@(posedge clk);
x       <= 'd3551;
@(posedge clk);
x       <= 'd3642;
@(posedge clk);
x       <= 'd3727;
@(posedge clk);
x       <= 'd3803;
@(posedge clk);
x       <= 'd3871;
@(posedge clk);
x       <= 'd3931;
@(posedge clk);
x       <= 'd3981;
@(posedge clk);
x       <= 'd4023;
@(posedge clk);
x       <= 'd4055;
@(posedge clk);
x       <= 'd4078;
@(posedge clk);
x       <= 'd4091;
@(posedge clk);
x       <= 'd4094;
@(posedge clk);
x       <= 'd4088;
@(posedge clk);
x       <= 'd4072;
@(posedge clk);
x       <= 'd4047;
@(posedge clk);
x       <= 'd4012;
@(posedge clk);
x       <= 'd3968;
@(posedge clk);
x       <= 'd3915;
@(posedge clk);
x       <= 'd3853;
@(posedge clk);
x       <= 'd3782;
@(posedge clk);
x       <= 'd3703;
@(posedge clk);
x       <= 'd3617;
@(posedge clk);
x       <= 'd3523;
@(posedge clk);
x       <= 'd3422;
@(posedge clk);
x       <= 'd3315;
@(posedge clk);
x       <= 'd3201;
@(posedge clk);
x       <= 'd3082;
@(posedge clk);
x       <= 'd2959;
@(posedge clk);
x       <= 'd2831;
@(posedge clk);
x       <= 'd2699;
@(posedge clk);
x       <= 'd2564;
@(posedge clk);
x       <= 'd2427;
@(posedge clk);
x       <= 'd2288;
@(posedge clk);
x       <= 'd2147;
@(posedge clk);
x       <= 'd2007;
@(posedge clk);
x       <= 'd1866;
@(posedge clk);
x       <= 'd1727;
@(posedge clk);
x       <= 'd1589;
@(posedge clk);
x       <= 'd1453;
@(posedge clk);
x       <= 'd1319;
@(posedge clk);
x       <= 'd1190;
@(posedge clk);
x       <= 'd1064;
@(posedge clk);
x       <= 'd943;
@(posedge clk);
x       <= 'd827;
@(posedge clk);
x       <= 'd717;
@(posedge clk);
x       <= 'd613;
@(posedge clk);
x       <= 'd516;
@(posedge clk);
x       <= 'd427;
@(posedge clk);
x       <= 'd345;
@(posedge clk);
x       <= 'd270;
@(posedge clk);
x       <= 'd205;
@(posedge clk);
x       <= 'd148;
@(posedge clk);
x       <= 'd100;
@(posedge clk);
x       <= 'd61;
@(posedge clk);
x       <= 'd31;
@(posedge clk);
x       <= 'd11;
@(posedge clk);
x       <= 'd1;
@(posedge clk);
x       <= 'd0;
@(posedge clk);
x       <= 'd9;
@(posedge clk);
x       <= 'd28;
@(posedge clk);
x       <= 'd56;
@(posedge clk);
x       <= 'd94;
@(posedge clk);
x       <= 'd140;
@(posedge clk);
x       <= 'd196;
@(posedge clk);
x       <= 'd261;
@(posedge clk);
x       <= 'd334;
@(posedge clk);
x       <= 'd415;
@(posedge clk);
x       <= 'd503;
@(posedge clk);
x       <= 'd599;
@(posedge clk);
x       <= 'd702;
@(posedge clk);
x       <= 'd811;
@(posedge clk);
x       <= 'd926;
@(posedge clk);
x       <= 'd1047;
@(posedge clk);
x       <= 'd1172;
@(posedge clk);
x       <= 'd1301;
@(posedge clk);
x       <= 'd1434;
@(posedge clk);
x       <= 'd1569;
@(posedge clk);
x       <= 'd1707;
@(posedge clk);
x       <= 'd1846;
@(posedge clk);
x       <= 'd1987;
@(posedge clk);
x       <= 'd2127;
@(posedge clk);
x       <= 'd2268;
@(posedge clk);
x       <= 'd2407;
@(posedge clk);
x       <= 'd2545;
@(posedge clk);
x       <= 'd2680;
@(posedge clk);
x       <= 'd2812;
@(posedge clk);
x       <= 'd2941;
@(posedge clk);
x       <= 'd3065;
@(posedge clk);
x       <= 'd3185;
@(posedge clk);
x       <= 'd3299;
@(posedge clk);
x       <= 'd3407;
@(posedge clk);
x       <= 'd3509;
@(posedge clk);
x       <= 'd3604;
@(posedge clk);
x       <= 'd3692;
@(posedge clk);
x       <= 'd3771;
@(posedge clk);
x       <= 'd3843;
@(posedge clk);
x       <= 'd3906;
@(posedge clk);
x       <= 'd3961;
@(posedge clk);
x       <= 'd4006;
@(posedge clk);
x       <= 'd4043;
@(posedge clk);
x       <= 'd4069;
@(posedge clk);
x       <= 'd4087;
@(posedge clk);
x       <= 'd4094;
@(posedge clk);
x       <= 'd4092;
@(posedge clk);
x       <= 'd4080;
@(posedge clk);
x       <= 'd4059;
@(posedge clk);
x       <= 'd4028;
@(posedge clk);
x       <= 'd3988;
@(posedge clk);
x       <= 'd3939;
@(posedge clk);
x       <= 'd3880;
@(posedge clk);
x       <= 'd3813;
@(posedge clk);
x       <= 'd3738;
@(posedge clk);
x       <= 'd3655;
@(posedge clk);
x       <= 'd3564;
@(posedge clk);
x       <= 'd3466;
@(posedge clk);
x       <= 'd3361;
@(posedge clk);
x       <= 'd3250;
@(posedge clk);
x       <= 'd3134;
@(posedge clk);
x       <= 'd3012;
@(posedge clk);
x       <= 'd2886;
@(posedge clk);
x       <= 'd2756;
@(posedge clk);
x       <= 'd2622;
@(posedge clk);
x       <= 'd2486;
@(posedge clk);
x       <= 'd2347;
@(posedge clk);
x       <= 'd2208;
@(posedge clk);
x       <= 'd2067;
@(posedge clk);
x       <= 'd1926;
@(posedge clk);
x       <= 'd1786;
@(posedge clk);
x       <= 'd1647;
@(posedge clk);
x       <= 'd1510;
@(posedge clk);
x       <= 'd1376;
@(posedge clk);
x       <= 'd1245;
@(posedge clk);
x       <= 'd1117;
@(posedge clk);
x       <= 'd994;
@(posedge clk);
x       <= 'd876;
@(posedge clk);
x       <= 'd764;
@(posedge clk);
x       <= 'd657;
@(posedge clk);
x       <= 'd557;
@(posedge clk);
x       <= 'd464;
@(posedge clk);
x       <= 'd379;
@(posedge clk);
x       <= 'd301;
@(posedge clk);
x       <= 'd232;
@(posedge clk);
x       <= 'd171;
@(posedge clk);
x       <= 'd119;
@(posedge clk);
x       <= 'd76;
@(posedge clk);
x       <= 'd43;
@(posedge clk);
x       <= 'd19;
@(posedge clk);
x       <= 'd4;
@(posedge clk);
x       <= 'd0;
@(posedge clk);
x       <= 'd4;
@(posedge clk);
x       <= 'd19;
@(posedge clk);
x       <= 'd43;
@(posedge clk);
x       <= 'd76;
@(posedge clk);
x       <= 'd119;
@(posedge clk);
x       <= 'd171;
@(posedge clk);
x       <= 'd232;
@(posedge clk);
x       <= 'd301;
@(posedge clk);
x       <= 'd379;
@(posedge clk);
x       <= 'd464;
@(posedge clk);
x       <= 'd557;
@(posedge clk);
x       <= 'd657;
@(posedge clk);
x       <= 'd764;
@(posedge clk);
x       <= 'd876;
@(posedge clk);
x       <= 'd995;
@(posedge clk);
x       <= 'd1118;
@(posedge clk);
x       <= 'd1245;
@(posedge clk);
x       <= 'd1376;
@(posedge clk);
x       <= 'd1511;
@(posedge clk);
x       <= 'd1648;
@(posedge clk);
x       <= 'd1787;
@(posedge clk);
x       <= 'd1927;
@(posedge clk);
x       <= 'd2067;
@(posedge clk);
x       <= 'd2208;
@(posedge clk);
x       <= 'd2348;
@(posedge clk);
x       <= 'd2486;
@(posedge clk);
x       <= 'd2622;
@(posedge clk);
x       <= 'd2756;
@(posedge clk);
x       <= 'd2886;
@(posedge clk);
x       <= 'd3012;
@(posedge clk);
x       <= 'd3134;
@(posedge clk);
x       <= 'd3251;
@(posedge clk);
x       <= 'd3362;
@(posedge clk);
x       <= 'd3466;
@(posedge clk);
x       <= 'd3564;
@(posedge clk);
x       <= 'd3655;
@(posedge clk);
x       <= 'd3738;
@(posedge clk);
x       <= 'd3814;
@(posedge clk);
x       <= 'd3880;
@(posedge clk);
x       <= 'd3939;
@(posedge clk);
x       <= 'd3988;
@(posedge clk);
x       <= 'd4028;
@(posedge clk);
x       <= 'd4059;
@(posedge clk);
x       <= 'd4080;
@(posedge clk);
x       <= 'd4092;
@(posedge clk);
x       <= 'd4094;
@(posedge clk);
x       <= 'd4086;
@(posedge clk);
x       <= 'd4069;
@(posedge clk);
x       <= 'd4042;
@(posedge clk);
x       <= 'd4006;
@(posedge clk);
x       <= 'd3961;
@(posedge clk);
x       <= 'd3906;
@(posedge clk);
x       <= 'd3843;
@(posedge clk);
x       <= 'd3771;
@(posedge clk);
x       <= 'd3691;
@(posedge clk);
x       <= 'd3604;
@(posedge clk);
x       <= 'd3509;
@(posedge clk);
x       <= 'd3407;
@(posedge clk);
x       <= 'd3299;
@(posedge clk);
x       <= 'd3184;
@(posedge clk);
x       <= 'd3065;
@(posedge clk);
x       <= 'd2940;
@(posedge clk);
x       <= 'd2812;
@(posedge clk);
x       <= 'd2680;
@(posedge clk);
x       <= 'd2544;
@(posedge clk);
x       <= 'd2407;
@(posedge clk);
x       <= 'd2267;
@(posedge clk);
x       <= 'd2127;
@(posedge clk);
x       <= 'd1987;
@(posedge clk);
x       <= 'd1846;
@(posedge clk);
x       <= 'd1707;
@(posedge clk);
x       <= 'd1569;
@(posedge clk);
x       <= 'd1433;
@(posedge clk);
x       <= 'd1301;
@(posedge clk);
x       <= 'd1171;
@(posedge clk);
x       <= 'd1046;
@(posedge clk);
x       <= 'd926;
@(posedge clk);
x       <= 'd811;
@(posedge clk);
x       <= 'd702;
@(posedge clk);
x       <= 'd599;
@(posedge clk);
x       <= 'd503;
@(posedge clk);
x       <= 'd414;
@(posedge clk);
x       <= 'd333;
@(posedge clk);
x       <= 'd260;
@(posedge clk);
x       <= 'd196;
@(posedge clk);
x       <= 'd140;
@(posedge clk);
x       <= 'd94;
@(posedge clk);
x       <= 'd56;
@(posedge clk);
x       <= 'd28;
@(posedge clk);
x       <= 'd9;
@(posedge clk);
x       <= 'd0;
@(posedge clk);
x       <= 'd1;
@(posedge clk);
x       <= 'd11;
@(posedge clk);
x       <= 'd31;
@(posedge clk);
x       <= 'd61;
@(posedge clk);
x       <= 'd100;
@(posedge clk);
x       <= 'd148;
@(posedge clk);
x       <= 'd205;
@(posedge clk);
x       <= 'd271;
@(posedge clk);
x       <= 'd345;
@(posedge clk);
x       <= 'd427;
@(posedge clk);
x       <= 'd517;
@(posedge clk);
x       <= 'd614;
@(posedge clk);
x       <= 'd717;
@(posedge clk);
x       <= 'd827;
@(posedge clk);
x       <= 'd943;
@(posedge clk);
x       <= 'd1064;
@(posedge clk);
x       <= 'd1190;
@(posedge clk);
x       <= 'd1320;
@(posedge clk);
x       <= 'd1453;
@(posedge clk);
x       <= 'd1589;
@(posedge clk);
x       <= 'd1727;
@(posedge clk);
x       <= 'd1867;
@(posedge clk);
x       <= 'd2007;
@(posedge clk);
x       <= 'd2148;
@(posedge clk);
x       <= 'd2288;
@(posedge clk);
x       <= 'd2427;
@(posedge clk);
x       <= 'd2564;
@(posedge clk);
x       <= 'd2699;
@(posedge clk);
x       <= 'd2831;
@(posedge clk);
x       <= 'd2959;
@(posedge clk);
x       <= 'd3083;
@(posedge clk);
x       <= 'd3201;
@(posedge clk);
x       <= 'd3315;
@(posedge clk);
x       <= 'd3422;
@(posedge clk);
x       <= 'd3523;
@(posedge clk);
x       <= 'd3617;
@(posedge clk);
x       <= 'd3704;
@(posedge clk);
x       <= 'd3782;
@(posedge clk);
x       <= 'd3853;
@(posedge clk);
x       <= 'd3915;
@(posedge clk);
x       <= 'd3968;
@(posedge clk);
x       <= 'd4012;
@(posedge clk);
x       <= 'd4047;
@(posedge clk);
x       <= 'd4072;
@(posedge clk);
x       <= 'd4088;
@(posedge clk);
x       <= 'd4094;
@(posedge clk);
x       <= 'd4091;
@(posedge clk);
x       <= 'd4078;
@(posedge clk);
x       <= 'd4055;
@(posedge clk);
x       <= 'd4023;
@(posedge clk);
x       <= 'd3981;
@(posedge clk);
x       <= 'd3931;
@(posedge clk);
x       <= 'd3871;
@(posedge clk);
x       <= 'd3803;
@(posedge clk);
x       <= 'd3727;
@(posedge clk);
x       <= 'd3642;
@(posedge clk);
x       <= 'd3550;
@(posedge clk);
x       <= 'd3451;
@(posedge clk);
x       <= 'd3346;
@(posedge clk);
x       <= 'd3234;
@(posedge clk);
x       <= 'd3117;
@(posedge clk);
x       <= 'd2994;
@(posedge clk);
x       <= 'd2867;
@(posedge clk);
x       <= 'd2737;
@(posedge clk);
x       <= 'd2603;
@(posedge clk);
x       <= 'd2466;
@(posedge clk);
x       <= 'd2327;
@(posedge clk);
x       <= 'd2187;
@(posedge clk);
x       <= 'd2047;
@(posedge clk);
x       <= 'd1906;
@(posedge clk);
x       <= 'd1766;
@(posedge clk);
x       <= 'd1628;
@(posedge clk);
x       <= 'd1491;
@(posedge clk);
x       <= 'd1357;
@(posedge clk);
x       <= 'd1226;
@(posedge clk);
x       <= 'd1099;
@(posedge clk);
x       <= 'd977;
@(posedge clk);
x       <= 'd860;
@(posedge clk);
x       <= 'd748;
@(posedge clk);
x       <= 'd642;
@(posedge clk);
x       <= 'd543;
@(posedge clk);
x       <= 'd451;
@(posedge clk);
x       <= 'd367;
@(posedge clk);
x       <= 'd291;
@(posedge clk);
x       <= 'd223;
@(posedge clk);
x       <= 'd163;
@(posedge clk);
x       <= 'd112;
@(posedge clk);
x       <= 'd71;
@(posedge clk);
x       <= 'd39;
@(posedge clk);
x       <= 'd16;
@(posedge clk);
x       <= 'd3;
@(posedge clk);
x       <= 'd0;
@(posedge clk);
x       <= 'd6;
@(posedge clk);
x       <= 'd22;
@(posedge clk);
x       <= 'd47;
@(posedge clk);
x       <= 'd82;
@(posedge clk);
x       <= 'd126;
@(posedge clk);
x       <= 'd179;
@(posedge clk);
x       <= 'd241;
@(posedge clk);
x       <= 'd312;
@(posedge clk);
x       <= 'd391;
@(posedge clk);
x       <= 'd477;
@(posedge clk);
x       <= 'd571;
@(posedge clk);
x       <= 'd672;
@(posedge clk);
x       <= 'd780;
@(posedge clk);
x       <= 'd893;
@(posedge clk);
x       <= 'd1012;
@(posedge clk);
x       <= 'd1136;
@(posedge clk);
@(posedge clk);
@(posedge clk);

        $finish;
    end
    
    // Проверка
    // initial begin
    //     wait(~arstn);
    //     @(posedge clk);
    //     @(posedge clk);
    // //---------------------------------------------------------------------------------------------
    //     repeat (32)
    //     begin
    //         @(posedge clk);
    //         if ($signed(psumm_o) != ($signed(psumm_i) + $signed(weight_i) * $signed(x_i) )) begin
    //             $display($signed(psumm_o));
    //             $display(($signed(psumm_i) + $signed(weight_i) * $signed(x_i)));
    //             $display($signed(psumm_i));
    //             $display($signed(weight_i));
    //             $display($signed(x_i));
    //             $error("BAD");
    //         end
    //         else begin
    //             $display("PASS");
    //             // $display($signed(psumm_o));
    //             // $display($signed(psumm_i));
    //             // $display($signed(weight_i));
    //             // $display($signed(x_i));
    //         end
    //     end
    // //---------------------------------------------------------------------------------------------
    //     @(posedge clk);
    //     @(posedge clk);
    //     @(posedge clk);
    //     $finish;
    // end
endmodule