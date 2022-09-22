//2022/09/22 陳科融
//16bits Carry-Save Adder
module CSA(A,B,Cin,Cout,SUM,Carry,S);
input [15:0] A,B,Cin;
output [16:0] SUM;
output [15:0] Carry;
output Cout;
output [15:0]S;
wire [15:0] S;
wire [15:0] c_out;

FA f0(SUM[0],Carry[0],A[0],B[0],Cin[0]);

genvar x;
generate
	for(x=1;x<=15;x=x+1)begin:Caculate_Loop
		FA	U_PROC(S[x],Carry[x],A[x],B[x],Cin[x]);
	end
endgenerate


HA h1(SUM[1],c_out[0],Carry[0],S[1]);

generate
	for(x=2;x<=15;x=x+1)begin:Out_Loop
		FA U_PROC(SUM[x],c_out[x-1],Carry[x-1],S[x],c_out[x-2]);
	end
endgenerate

HA ha15(SUM[16],Cout,Carry[15],c_out[14]);

endmodule

module HA(s, c, x, y);

input x, y;
output s, c;
xor xor1(s,x,y);
and and1(c,x,y);

endmodule

module FA(s, Carry_out, x, y, Carry_in);

input x, y, Carry_in;
output s, Carry_out;
wire c1,c2,s1;
HA HA_1(.s(s1),.c(c1),.x(x),.y(y));
HA HA_2(.s(s),.c(c2),.x(Carry_in),.y(s1));
or or1(Carry_out,c1,c2);  

endmodule 



