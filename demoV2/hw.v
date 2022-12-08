module HW(clk, IRDA_RXD, KEY, LEDR, LEDG);
	input clk, rst, IRDA_RXD;
	output [17:0] LEDR;
    output [8:0] LEDG;
    output [3:0] KEY;

    wire oDATA_READY;
	wire [31:0] oDATA;
	IR_RECEIVE u1(clk, rst, IRDA_RXD, oDATA_READY, oDATA);

    reg oDATA_READY_d2;
    always @(negedge oDATA_READY) oDATA_READY_d2 <= oDATA_READY;

    reg IR_READY;
    always @(*) IR_DATA_READY = oDATA_READY == 0 && oDATA_READY_d2 == 1 ;

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

