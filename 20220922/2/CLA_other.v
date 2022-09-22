//2022/09/22 陳科融
//8bits Carry-Lookahead Adder
module CLA(A,B,sum);
input [7:0] A,B;
output [8:0] sum;
wire [7:0] p,g;
wire c_out;

genvar x;
generate
	for(x=0;x<8;x=x+1)begin:HA_Loop
		HA U_PROC(A[x],B[x],g[x],p[x]);
	end
endgenerate


CLG clg1(g[3:0],p[3:0],sum[3:0],0,c_out);
CLG clg2(g[7:4],p[7:4],sum[7:4],c_out,sum[8]);

endmodule 

module HA(a,b,carry,sum);
input a,b;
output carry,sum;

assign carry=a&b;
assign sum=a^b;

endmodule 

module CLG(g,p,sum,c_in,c_out);

input [3:0] g,p;
output [3:0] sum;
wire [4:0] c;  
input c_in;
output c_out;

assign c[1]=g[0]^c_in&p[0];
assign c[2]=g[1]^g[0]&p[1]^c_in&p[0]&p[1];
assign c[3]=g[2]^g[1]&p[2]^g[0]&p[1]&p[2]^c_in&p[0]&p[1]&p[2];
assign c[4]=g[3]^g[2]&p[3]^g[1]&p[2]&p[3]^g[0]&p[1]&p[2]&p[3]^c_in&p[0]&p[1]&p[2]&p[3];

assign c_out=c[4];
assign c[0]=c_in;

genvar x;
generate 
	for(x=0;x<4;x=x+1)begin:sum_loop
		assign sum[x]=p[x]^c[x];
	end
endgenerate

endmodule 