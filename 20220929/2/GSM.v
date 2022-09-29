module GSM(A,B,P,a1,b1,a2,b2,a3,b3,p1,p2,p3);
input [3:0]A,B;
output signed [7:0] P;
input [7:0] a1,b1,b3;
input [15:0] a2,b2,a3;
output signed [15:0] p1;
output signed [31:0] p2;
output signed [23:0] p3;

SIGNED_MULTI #(4,4) multiply_0(.a(A),.b(B),.p(P));

SIGNED_MULTI #(8,8) multiply_1(.a(a1),.b(b1),.p(p1));
								 
SIGNED_MULTI #(16,16) multiply_2(.a(a2),.b(b2),.p(p2));
								 
SIGNED_MULTI #(16,8) multiply_3(.a(a3),.b(b3),.p(p3));
								 
endmodule 


module SIGNED_MULTI(a,b,p);

parameter a_size=16;
parameter b_size=16;
input [a_size-1:0] a;
input [b_size-1:0] b;
output reg [a_size+b_size-1:0] p;
reg [a_size+b_size+a_size-2:0] save[b_size-1:0];
reg [a_size-1:0] Complement_a;
reg [a_size+b_size+a_size:0]carry;
reg check_one;
integer x,y,z;
always @(*)begin
//========<歸零>==========
	p=0;
	for(x=0;x<b_size;x=x+1)begin
		save[x]=0;
	end
	Complement_a=a;
	carry=0;
	check_one=1'b0;
//=========================
	for(y=0;y<b_size;y=y+1)begin
		for(x=0;x<a_size;x=x+1)begin
			if(x==a_size-1) begin			//最高位元處理
				if(Complement_a[a_size-1]==1 && b[y]==1)begin
					for(z=x+0;z<x+b_size;z=z+1)begin
						save[y][y+z]=1'b1;	//最高位元為1
					end
				end
				else begin
					for(z=x+0;z<x+b_size;z=z+1)begin
						save[y][y+z]=1'b0;	//最高位元為0
					end
				end
			end
			else begin
				//===============<取2的補數>==================
				if(y==b_size-1 && x==0 && b[b_size-1]==1)begin
					for(z=0;z<a_size;z=z+1)begin
						if(check_one==0)begin
							if(a[z])begin
								check_one=1'b1;
								Complement_a[z]=a[z];
							end
							else begin
								Complement_a[z]=a[z];
							end
						end
						else begin
							Complement_a[z]=~a[z];
						end
					end
				end
				save[y][x+y]=Complement_a[x]&b[y];		//最高位元以外運算
			end
		end
	end
	for(y=0;y<b_size;y=y+1)begin
		carry=carry+save[y][a_size+b_size-1:0];
	end
	p=carry;
	
	//p=save[3][a_size+b_size-1:0]+save[2][a_size+b_size-1:0]+save[1][a_size+b_size-1:0]+save[0][a_size+b_size-1:0];
end

endmodule 

/*
module adder16bits(X,Y,sum);
input [15:0] X,Y;
output [15:0] sum;
wire [15:0] Carry;

FA f0(sum[0],Carry[0],X[0],Y[0],carry_in);
genvar x;
generate 
	
	for(x=1;x<=15;x=x+1)begin :adder_16
		FA ff(sum[x],Carry[x],X[x],Y[x],Carry[x-1]);
	end
endgenerate


endmodule

module FA(s, Carry_out, x, y, Carry_in);
input x, y, Carry_in;
output s, Carry_out;
wire c1,c2,s1;
HA HA_1(.s(s1),.c(c1),.x(x),.y(y));
HA HA_2(.s(s),.c(c2),.x(Carry_in),.y(s1));
or or1(Carry_out,c1,c2);
endmodule

module HA(s, c, x, y);
    input x, y;
    output s, c;
    xor xor1(s,x,y);
    and ans1(c,x,y);
endmodule 
*/