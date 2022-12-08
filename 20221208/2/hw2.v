module hw2(Clk, rst_n, IRDA_RXD, LEDR, LEDG, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, SRAM_ADDR, SRAM_DQ, SRAM_LB_N, SRAM_WE_N, SRAM_OE_N, SRAM_UB_N, SRAM_CE_N);
	input Clk, rst_n, IRDA_RXD;
	output [19:0] SRAM_ADDR;
	inout wire [15:0] SRAM_DQ;
	output SRAM_LB_N = 0;
	output SRAM_UB_N = 0;
	output reg SRAM_CE_N;
	output SRAM_WE_N = mod;
	output SRAM_OE_N = !mod;
	output reg [17:0] LEDR;
	output [8:0]LEDG;
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	wire IR_READY;
	wire [31:0] IR_DATA;
	reg [3:0] LED_shift [3:0];
	reg [3:0] LED_addr [1:0];
	reg [15:0] Data_in;
	reg READY;
	reg mod = 0;
	wire [15:0] DQ;
	wire [7:0]IR_keycode;
	integer i;
	assign SRAM_DQ = mod ? 16'bz : Data_in;
	assign DQ = SRAM_DQ;
	assign LEDG[8] = mod;
	assign IR_keycode = IR_DATA[23:16];
	assign SRAM_ADDR = {LED_addr[1], LED_addr[0]};
	reg [3:0] state;
	
	
	switch H0(LED_shift[0], {HEX0[0],HEX0[1],HEX0[2],HEX0[3],HEX0[4],HEX0[5],HEX0[6]});
	switch H1(LED_shift[1], {HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]});
	switch H2(LED_shift[2], {HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]});
	switch H3(LED_shift[3], {HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]});
	switch H4(LED_addr[0], {HEX4[0],HEX4[1],HEX4[2],HEX4[3],HEX4[4],HEX4[5],HEX4[6]});
	switch H5(LED_addr[1], {HEX5[0],HEX5[1],HEX5[2],HEX5[3],HEX5[4],HEX5[5],HEX5[6]});

	IR_RECEIVE u1(Clk, rst_n, IRDA_RXD, IR_READY, IR_DATA);
	
	always@(negedge Clk) READY <= IR_READY;
	always@(negedge Clk, negedge rst_n)begin
		if(!rst_n)begin
			for(i=0; i<=3; i=i+1)begin
				LED_shift[i] = 8'd0;
			end
			LED_addr[0] <= 8'd0;
			LED_addr[1] <= 8'd0;
			LEDR <= 18'd0;
			mod <= 0;
		end else begin
			case(state)
				4'd0:begin
					SRAM_CE_N <= 1;
					if (READY == 1 && IR_READY == 0)begin
						case(IR_keycode)
							8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'h08, 8'h09:begin
								for(i=1; i<=3; i=i+1)begin
									LED_shift[i] <= LED_shift[i-1];
								end
								LED_shift[0] <= IR_keycode;
								//LEDR <= {10'd0, IR_keycode};
							end
							8'h0F:{LED_addr[1], LED_addr[0]} <= {LED_shift[1], LED_shift[0]};
							8'h13:{LED_addr[1], LED_addr[0]} <= 8'd0;
							8'h10:{LED_shift[3], LED_shift[2], LED_shift[1], LED_shift[0]} <= 16'd0;
							8'h11:mod <= ~mod;
							8'h17:state <= mod ? 4'd1 : 4'd4;
						endcase
					end
				end
				4'd1:begin
					SRAM_CE_N <= 0;
					state <= 4'd2;
				end
				4'd2:begin
					LEDR[15:0] <= SRAM_DQ;
					state <= 4'd0;
				end
				4'd3:begin
					SRAM_CE_N <= 1;
					state <= 4'd0;
				end
				4'd4:begin
					Data_in <= {LED_shift[3], LED_shift[2], LED_shift[1], LED_shift[0]};
					state <= 4'd4;
				end
				4'd5:begin
					SRAM_CE_N <= 0;
					state <= 4'd6;
				end
				4'd6:begin
					state <= 4'd7;
				end
				4'd7:begin
					SRAM_CE_N <= 1;
					state <= 4'd0;
				end
			endcase
		end
	end
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
