module pipeline(clk, rst, a, b, c, d, Y);
	input clk, rst;
	input [5:0] a, b, c, d;
	output reg[7:0] Y;
	reg [5:0] reg_a, reg_b, reg_c;
	reg [11:0] reg_d;
	reg [6:0] next_sum_abc;
	reg [6:0] next_carry_abc;
	reg [6:0] reg_sum_abc;
	reg [6:0] reg_carry_abc;
	reg [7:0] next_sum_d;
	reg [7:0] next_carry_d;
	reg [7:0] reg_sum_d;
	reg [7:0] reg_carry_d;

	integer x;
	
	always @(*)begin : adder_abc
		next_sum_abc[6] = 1'b0;
		next_carry_abc[0] = 1'b0;
		for(x=0;x<6;x=x+1)begin
			{next_carry_abc[x+1],next_sum_abc[x]} = reg_a[x] + reg_b[x] + reg_c[x];
		end
	end
	
	always @(*)begin : adder_d
		next_sum_d[7] = 1'b0;
		next_carry_d[0] = 1'b0;
		for(x=0;x<6;x=x+1)begin
			{next_carry_d[x+1],next_sum_d[x]} = reg_carry_abc[x] + reg_sum_abc[x] + reg_d[x]; 
		end
		{next_carry_d[7],next_sum_d[6]} = reg_carry_abc[6] + reg_sum_abc[6];
	end
	
	always @(posedge clk or posedge rst)begin : pipeline1
		if(rst)begin
			reg_a <= 6'd0;
			reg_b <= 6'd0;
			reg_c <= 6'd0;
			reg_d <= 12'd0;
		end
		else begin
			reg_a <= a;
			reg_b <= b;
			reg_c <= c;
			reg_d <= {d,reg_d[11:6]};
		end
	end
	
	always @(posedge clk or posedge rst)begin : pipeline2
		if(rst)begin
			reg_sum_abc   <= 7'd0;
			reg_carry_abc <= 7'd0;
		end
		else begin
			reg_sum_abc   <= next_sum_abc;
			reg_carry_abc <= next_carry_abc;
		end
	end
	
	always @(posedge clk or posedge rst)begin : pipeline3
		if(rst)begin
			reg_sum_d   <= 8'd0;
			reg_carry_d <= 8'd0;
		end
		else begin
			reg_carry_d   <= next_carry_d;
			reg_sum_d     <= next_sum_d;
		end
	end
	
	always @(posedge clk or posedge rst)begin : pipeline4
		if(rst)begin
			Y <= 8'd0;
		end
		else begin
			Y <= reg_sum_d + reg_carry_d;
		end
	end

endmodule 