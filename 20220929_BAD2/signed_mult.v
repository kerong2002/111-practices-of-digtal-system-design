module signed_mult(a1, b1, a2, b2, a3, b3, p1, p2, p3);
	input [7:0] a1, b1, b3;
	input [15:0] a2, b2, a3;
	output signed [8+8-1:0] p1;
	output signed[16+16-1:0] p2;
	output signed [16+8-1:0] p3;
	SIGNED_MULTI #(8, 8) u_8x8_multi(.a(a1), .b(b1), .p(p1));
	SIGNED_MULTI #(16, 16) u_16x16_multi(.a(a2), .b(b2), .p(p2));
	SIGNED_MULTI #(16, 8) u_16x8_multi(.a(a3), .b(b3), .p(p3));
endmodule

module SIGNED_MULTI (a, b, p);
	parameter x = 8, y = 8;
	input signed [x-1:0] a;
	input signed [y-1:0] b;
	output reg signed [x+y-1:0] p;
	parameter max = x > y ? x : y;
	integer i, j, k;
	always@(*)begin
		reg signed [40:0] partial;
		reg signed [40:0] temp;

		//reg [x+y-1:0] partial[y-1:0];
		for(i = 0; i < y; i=i+1)begin
			for (j = 0;j < y; j=j+1)begin
				temp[j+i] = a[j] & b[i];
			end
			for(j = y+i; j < 41; j=j+1)begin
				temp[j] = temp[y+i-1];
			end
			for(j = 0; j < i;j=j+1)begin
				temp[j] = 1'b0;
			end
			partial = i ? partial + temp : temp;
		end
		p = partial[x+y-1:0];
	end
endmodule
