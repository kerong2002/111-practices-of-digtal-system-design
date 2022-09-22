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
FA f1(S[1],Carry[1],A[1],B[1],Cin[1]);
FA f2(S[2],Carry[2],A[2],B[2],Cin[2]);
FA f3(S[3],Carry[3],A[3],B[3],Cin[3]);
FA f4(S[4],Carry[4],A[4],B[4],Cin[4]);
FA f5(S[5],Carry[5],A[5],B[5],Cin[5]);
FA f6(S[6],Carry[6],A[6],B[6],Cin[6]);
FA f7(S[7],Carry[7],A[7],B[7],Cin[7]);
FA f8(S[8],Carry[8],A[8],B[8],Cin[8]);
FA f9(S[9],Carry[9],A[9],B[9],Cin[9]);
FA f10(S[10],Carry[10],A[10],B[10],Cin[10]);
FA f11(S[11],Carry[11],A[11],B[11],Cin[11]);
FA f12(S[12],Carry[12],A[12],B[12],Cin[12]);
FA f13(S[13],Carry[13],A[13],B[13],Cin[13]);
FA f14(S[14],Carry[14],A[14],B[14],Cin[14]);
FA f15(S[15],Carry[15],A[15],B[15],Cin[15]);

HA h1(SUM[1],c_out[0],Carry[0],S[1]);
FA ff2(SUM[2],c_out[1],Carry[1],S[2],c_out[0]);
FA ff3(SUM[3],c_out[2],Carry[2],S[3],c_out[1]);
FA ff4(SUM[4],c_out[3],Carry[3],S[4],c_out[2]);
FA ff5(SUM[5],c_out[4],Carry[4],S[5],c_out[3]);
FA ff6(SUM[6],c_out[5],Carry[5],S[6],c_out[4]);
FA ff7(SUM[7],c_out[6],Carry[6],S[7],c_out[5]);
FA ff8(SUM[8],c_out[7],Carry[7],S[8],c_out[6]);
FA ff9(SUM[9],c_out[8],Carry[8],S[9],c_out[7]);
FA ff10(SUM[10],c_out[9],Carry[9],S[10],c_out[8]);
FA ff11(SUM[11],c_out[10],Carry[10],S[11],c_out[9]);
FA ff12(SUM[12],c_out[11],Carry[11],S[12],c_out[10]);
FA ff13(SUM[13],c_out[12],Carry[12],S[13],c_out[11]);
FA ff14(SUM[14],c_out[13],Carry[13],S[14],c_out[12]);
FA ff15(SUM[15],c_out[14],Carry[14],S[15],c_out[13]);
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



