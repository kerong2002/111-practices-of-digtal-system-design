`define bcd_uint0 bcd[3:0]
`define bcd_uint1 bcd[7:4]
`define bcd_uint2 bcd[11:8]
`define bcd_uint3 bcd[15:12]
module calculate(clk, rst, SW, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	input clk, rst;
	input [17:0] SW;
	output [6:0] HEX7, HEX6, HEX5, HEX4;
	output reg [6:0] HEX3, HEX2, HEX1, HEX0;
	wire [6:0] take3, take2, take1, take0;
	switch sw7(SW[17:14], {HEX7[0],HEX7[1],HEX7[2],HEX7[3],HEX7[4],HEX7[5],HEX7[6]});
	switch sw6(SW[13:10], {HEX6[0],HEX6[1],HEX6[2],HEX6[3],HEX6[4],HEX6[5],HEX6[6]});
	switch sw5(SW[9:6]  , {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]});
	switch sw4(SW[5:2]  , {HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]});
	
	reg [15:0] ans;
	wire [15:0] bcd_change;
	parameter ADD = 2'b00;
	parameter SUB = 2'b01;
	parameter MUL = 2'b10;
	parameter DIV = 2'b11;
	
	always @(*)begin
		if(SW[17:14]>=10 || SW[13:10]>=10 || SW[9:6]>=10 || SW[5:2]>=10)begin
			{HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} = 7'b0001001;
			{HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} = 7'b0001000;
			{HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} = 7'b0001001;
		end
		else begin
			case({SW[1],SW[0]})
				ADD : begin
					ans = SW[17:14]*10 + SW[13:10] + SW[9:6]*10 + SW[5:2];
					HEX3 = take3;
					HEX2 = take2;
					HEX1 = take1;
					HEX0 = take0;
				end
				SUB : begin
					ans = (SW[17:14]*10 + SW[13:10]) - (SW[9:6]*10 + SW[5:2]);
					HEX3 = take3;
					HEX2 = take2;
					HEX1 = take1;
					HEX0 = take0;
				end
				MUL : begin
					ans = (SW[17:14]*10 + SW[13:10]) * (SW[9:6]*10 + SW[5:2]);
					HEX3 = take3;
					HEX2 = take2;
					HEX1 = take1;
					HEX0 = take0;
				end
				DIV : begin
					if(SW[9:2] == 0)begin
						{HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]} = 7'b1000001;
						{HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]} = 7'b0001001;
						{HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]} = 7'b1000010;
						{HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]} = 7'b0111000;
					end
					else begin
						ans = (SW[17:14]*10 + SW[13:10]) / (SW[9:6]*10 + SW[5:2]);
						HEX3 = take3;
						HEX2 = take2;
						HEX1 = take1;
						HEX0 = take0;
					end
				end
			endcase
		end
	end
	hw set_ans(ans,bcd_change);
	switch ADD_3(bcd_change[15:12],{take3[0],take3[1],take3[2],take3[3],take3[4],take3[5],take3[6]});
	switch ADD_2(bcd_change[11:8] ,{take2[0],take2[1],take2[2],take2[3],take2[4],take2[5],take2[6]});
	switch ADD_1(bcd_change[7:4]  ,{take1[0],take1[1],take1[2],take1[3],take1[4],take1[5],take1[6]});
	switch ADD_0(bcd_change[3:0]  ,{take0[0],take0[1],take0[2],take0[3],take0[4],take0[5],take0[6]});
	
	
endmodule 

module switch(in_4,out_LED_7);
	input [3:0] in_4;
	output reg [6:0] out_LED_7;
	always @(*)begin
		case(in_4)
			4'h0 : out_LED_7 = 7'b0000001;
			4'h1 : out_LED_7 = 7'b1001111;
			4'h2 : out_LED_7 = 7'b0010010;
			4'h3 : out_LED_7 = 7'b0000110;
			4'h4 : out_LED_7 = 7'b1001100;
			4'h5 : out_LED_7 = 7'b0100100;
			4'h6 : out_LED_7 = 7'b1100000;
			4'h7 : out_LED_7 = 7'b0001111;
			4'h8 : out_LED_7 = 7'b0000000;
			4'h9 : out_LED_7 = 7'b0001100;
			4'ha : out_LED_7 = 7'b0001000;
			4'hb : out_LED_7 = 7'b1100000;
			4'hc : out_LED_7 = 7'b0110001;
			4'hd : out_LED_7 = 7'b1000010;
			4'he : out_LED_7 = 7'b0110000;
			4'hf : out_LED_7 = 7'b0111000;
		endcase
	end
	
endmodule 
module hw (
    input [15:0] bin,
    output reg [15:0] bcd
);

    reg [15:0] reg_bin;
    integer i;
    always @(*) begin:hi
        bcd = 16'd0;
        reg_bin = bin;

        for ( i = 0; i < 16; i = i + 1) begin:hi2
            if (`bcd_uint0 >= 5) `bcd_uint0  = `bcd_uint0 + 3;
            if (`bcd_uint1 >= 5) `bcd_uint1  = `bcd_uint1 + 3;
            if (`bcd_uint2 >= 5) `bcd_uint2  = `bcd_uint2 + 3;
            if (`bcd_uint3 >= 5) `bcd_uint3  = `bcd_uint3 + 3;
            bcd = {bcd[14:0], reg_bin[15]};
            reg_bin = reg_bin << 1;

        end
    end
endmodule
	