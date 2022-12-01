module HW(clk, rst, IRDA_RXD, LEDR);
	input clk, rst, IRDA_RXD;
	output[17:0] LEDR;
	wire oDATA_READY;
	wire [31:0] oDATA;
	reg [17:0] LED = 18'b0, LED_save = 18'b0;
	assign LEDR = LED;
	IR_RECEIVE u1(clk, rst, IRDA_RXD, oDATA_READY, oDATA);
	always@(negedge oDATA_READY, negedge rst)begin
		if (!rst)begin
			LED <= 18'b0;
			LED_save <= 18'b0;
		end else begin
			case(oDATA[23:16])
				8'h1B:begin
					LED <= {1'b1, LED[17:1]};
				end
				8'h1F:begin
					LED <= {LED[16:0], 1'b0};
				end
				8'h1E:begin
					LED <= ~LED;
				end
				8'h0C:begin
					LED <= LED_save;
					LED_save <= (LED_save) == 18'b0 ? LED : 18'b0;
				end
			endcase
		end
	end
endmodule
