module HW1(clk, rst, SW, LEDR, KEY);
	input [17:0] SW;
	input [3:0] KEY;
	input clk, rst;
	output [17:0] LEDR;
	assign LEDR = LED_shift;
	wire pKEY1, pKEY2;
	reg [19:0] cnt5hz = 20'd0;
	reg [17:0] LED_shift = 18'd0;
	reg clk5hz = 0, k1 = 0, k2 = 0;
	d_btn btn1(clk, rst, KEY[1], pKEY1);
	d_btn btn2(clk, rst, KEY[3], pKEY2);
	
	always@(posedge pKEY1)begin
		k1 <= ~k1;
	end
	
	always@(posedge pKEY2)begin
		k2 <= ~k2;
	end
	
	always@(posedge clk5hz)begin
		if (k1)begin
			LED_shift[17:2] <= SW[15:0];
			LED_shift[1:0] <= 2'd0;
		end else if (!k2) begin
			case(SW[17:16])
				2'd0:LED_shift <= {LED_shift[16:0], LED_shift[17]};
				2'd1:LED_shift <= {LED_shift[0], LED_shift[17:1]};
				2'd2:LED_shift <= {LED_shift[16:8], LED_shift[17], LED_shift[0], LED_shift[7:1]};
				2'd3:LED_shift <= {LED_shift[8], LED_shift[17:9], LED_shift[6:0], LED_shift[7]};
			endcase
		end
	end
	
	
	always@(posedge clk)begin
		if (cnt5hz >= 20'd1000000) begin
			clk5hz <= ~clk5hz;
			cnt5hz <= 1;
		end else begin
			cnt5hz <= cnt5hz + 20'd1;
		end
	end
endmodule

//will output logic HIGH when press the button.
module d_btn(clk, rst, KEY, pKEY);
	input clk, rst, KEY;
	output pKEY;
	assign pKEY = _KEY;
	reg _KEY;
	reg [9:0] count;
	always@(posedge clk, negedge rst)begin
		if (!rst)begin
			count <= 0;
			_KEY <= 1;
		end else begin
			if (count>=1000)begin
				count<=0;
				_KEY<=KEY;
			end
			else if(_KEY^KEY) count<=count+1;
			else count<=0;
		end
	end
endmodule
