module pipeline(clk,rst,a,b,c,d,Y);
input clk,rst;
input [5:0] a,b,c,d;
output reg[7:0] Y;

reg [6:0] s1;
reg [6:0] c1;
reg [7:0] s2;
reg [7:0] c2;
reg [5:0] save_d;
always @(posedge clk,posedge rst)begin
	if(rst)begin
		Y <= 8'd0;
	end
	else begin
		save_d <= d;
		Y <= (c2 + s2);
	end
end
//=========<第一級流水>==========
integer x;
always @(posedge clk,posedge rst)begin
	if(rst)begin
		c1 <= 7'd0;
		s1 <= 7'd0;
	end
	else begin
		s1[6] <= 1'b0;
		c1[0] <= 1'b0;//>>>
		for(x=0;x<6;x=x+1)begin
			{c1[x+1],s1[x]} <= a[x] + b[x] + c[x];
		end
	end
end 
//=========<第二級流水>==========
always @(posedge clk,posedge rst)begin
	if(rst)begin
		c2 <= 8'd0;
		s2 <= 8'd0;
	end
	else begin
		s2[7] <= 1'b0;
		c2[0] <= 1'b0;
		for(x=0;x<6;x=x+1)begin
			{c2[x+1],s2[x]} <= c1[x] + s1[x] + save_d[x]; 
		end
		{c2[7],s2[6]} <= c1[6] + s1[6];
	end
end 

endmodule 