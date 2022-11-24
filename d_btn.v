//will output logic "HIGH" when press the button.
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
