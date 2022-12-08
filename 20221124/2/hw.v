//`include "./numMapToLed7.v"
`include "./led7_inf.v"
`include "./counterDivider.v"
`include "./dBtn.v"
`include "./binToLed7.v"

`define MODE_TIME 1'd0
`define MODE_DATE 1'd1

module hw (
    //input rst,
    input clk,
    input [17:0] SW,
    input [3:0] KEY,
    output [7:0] LEDG,
    output reg [17:0] LEDR,
    output reg [6:0] HEX0,
    output reg [6:0] HEX1,
    output reg [6:0] HEX2,
    output reg [6:0] HEX3,
    output reg [6:0] HEX4,
    output reg [6:0] HEX5,
    output reg [6:0] HEX6,
    output reg [6:0] HEX7

    //output clk18
);
    wire rst;
    assign rst = ~KEY[1];
    wire clk50M;
    assign clk50M = clk;


    //wire clk18;
    //counterDivider #(22, 22'd2777778) D18(clk, rst, clk18);
    wire clk_5;
    counterDivider #(77, 50000000/200000) D18(clk, rst, clk_5);
    wire clk216;
    counterDivider #(22, 50000000/216) D19(clk, rst, clk216);
    wire clk108;
    counterDivider #(22, 50000000/108) D20(clk, rst, clk108);
    wire clk72;
    counterDivider #(22, 50000000/72) D21(clk, rst, clk72);
    wire clk54;
    counterDivider #(22, 50000000/54) D22(clk, rst, clk54);
    wire clk43;
    counterDivider #(22, 50000000/43) D23(clk, rst, clk43);
    wire clk36;
    counterDivider #(22, 50000000/36) D24(clk, rst, clk36);
    wire clk31;
    counterDivider #(22, 50000000/31) D25(clk, rst, clk31);
    wire clk27;
    counterDivider #(22, 50000000/27) D26(clk, rst, clk27);
    wire clk24;
    counterDivider #(22, 50000000/24) D27(clk, rst, clk24);
    wire clk22;
    counterDivider #(22, 50000000/22) D28(clk, rst, clk22);
    wire clk20;
    counterDivider #(22, 50000000/20) D29(clk, rst, clk20);
    wire clk18;
    counterDivider #(22, 50000000/18) D30(clk, rst, clk18);
    wire clk17;
    counterDivider #(22, 50000000/17) D31(clk, rst, clk17);
    wire clk15;
    counterDivider #(22, 50000000/15) D32(clk, rst, clk15);
    wire clk14;
    counterDivider #(22, 50000000/14) D33(clk, rst, clk14);
    wire clk13;
    counterDivider #(22, 50000000/13) D34(clk, rst, clk13);
    wire clk12;
    counterDivider #(22, 50000000/12) D35(clk, rst, clk12);

    wire modeChangSignal, modeChangSignal_;
    assign modeChangSignal = ~modeChangSignal_;
    KEY_Debounce dKEY3(clk50M, ~rst, KEY[3], modeChangSignal_);

    assign LEDG[2] = modeChangSignal;
    assign LEDG[3] = KEY[3];

    reg mode;
    always @(posedge modeChangSignal, posedge rst)
        mode <= (rst)? `MODE_TIME:~mode;
    //assign LEDG[3] = modeChangSignal;

    reg [4:0] hh;
    reg [5:0] mm, ss;

    wire [27:0] yearL7;
    wire [13:0] monL7;
    wire [13:0] dateL7;
    binToLed7_4 ly(2022,yearL7);
    binToLed7_4 lm(11,monL7);
    binToLed7_4 ld(24,dateL7);

    wire [13:0] hhL7;
    wire [13:0] mmL7;
    wire [13:0] ssL7;
    binToLed7_4 lhh(hh,hhL7);
    binToLed7_4 lmm(mm,mmL7);
    binToLed7_4 lss(ss,ssL7);

    reg dateShow;
    always @(posedge LEDR[0], posedge rst) begin
        dateShow <= (rst)? 0:~dateShow;
    end

    always @(*) begin
        if (mode == `MODE_TIME)
            {HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} =
                {inf_led7_h, inf_led7_l ,hhL7, mmL7, ssL7};

        else if (dateShow)
            {HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} =
                {dateL7, monL7, yearL7};
        else
            {HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = {{56{1'd1}}};
    end

    wire [17:0] lowPrioritySW;
    genvar ia;
    assign lowPrioritySW[0] = SW[0];
    generate
        for ( ia = 1; ia <= 17; ia = ia + 1) begin :gd
            assign lowPrioritySW[ia] = ~(|SW[ia-1:0]) & SW[ia];
        end
    endgenerate
    //genvar j;
    //generate
    //for(i=0; i<3; i=i+1)begin: inst_rtl
    //flow_proc U_PROC(clk, rst_n, data_vld, in_data);
    //end
    //endgenerate


    always @(posedge clk18, posedge rst) begin
        integer ia;
        if (rst)
            LEDR <= {1'd1, 17'd0};
        else if (LEDR == 0 || LEDR[0] == 1)
            LEDR <= lowPrioritySW;
        else
            LEDR <= LEDR >> 1;
    end

    always @(posedge clk18, posedge rst) begin
        if (rst)
            ss <= 0;
        else if (ss == 60)
            ss <= 0;
        else if (LEDR[0] == 1)
            ss <= ss + 1;

        if (rst)
            mm <= 0;
        else if (mm == 60)
            mm <= 0;
        else if (ss == 60)
            mm <= mm + 1;

        if (rst)
            hh <= 0;
        else if (hh == 23)
            hh <= 0;
        else if (mm == 60)
            hh <= hh + 1;
    end

    reg inf_clk;
    //wire inf_rst;
    wire [6:0] inf_led7_h;
    wire [6:0] inf_led7_l;
    reg [3:0] inf_idx;
    //reg [3:0] count;

    led7_inf inf(inf_clk, inf_idx, inf_led7_h, inf_led7_l);

    always @(*) begin
        case (lowPrioritySW)
            18'b00_0000_0000_0000_0000: inf_clk = 0;
            18'b00_0000_0000_0000_0001: inf_clk = clk216;
            18'b00_0000_0000_0000_0010: inf_clk = clk108;
            18'b00_0000_0000_0000_0100: inf_clk = clk72;
            18'b00_0000_0000_0000_1000: inf_clk = clk54;
            18'b00_0000_0000_0001_0000: inf_clk = clk43;
            18'b00_0000_0000_0010_0000: inf_clk = clk36;
            18'b00_0000_0000_0100_0000: inf_clk = clk31;
            18'b00_0000_0000_1000_0000: inf_clk = clk27;
            18'b00_0000_0001_0000_0000: inf_clk = clk24;
            18'b00_0000_0010_0000_0000: inf_clk = clk22;
            18'b00_0000_0100_0000_0000: inf_clk = clk20;
            18'b00_0000_1000_0000_0000: inf_clk = clk18;
            18'b00_0001_0000_0000_0000: inf_clk = clk17;
            18'b00_0010_0000_0000_0000: inf_clk = clk15;
            18'b00_0100_0000_0000_0000: inf_clk = clk14;
            18'b00_1000_0000_0000_0000: inf_clk = clk13;
            18'b01_0000_0000_0000_0000: inf_clk = clk13;
            18'b10_0000_0000_0000_0000: inf_clk = clk12;
            default: inf_clk = 0;
        endcase
    end

    always @(posedge inf_clk, posedge rst) begin
        if (rst)
            inf_idx <= 0;
        //else if (LEDR[0] == 0)
        //inf_idx <= 0;
        else if (inf_idx == 11)
            inf_idx <= 0;
        else
            inf_idx <= inf_idx + 1;
    end

endmodule





