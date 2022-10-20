module alu(A,B,C,sel,alu);
input [7:0] A,B;
input [4:0] C;
input [1:0] sel;
output reg [8:0] alu;

always @(*)begin
	case(sel)
		2'b00:alu=A+B;
		2'b01:alu=(C[0])?A:~A;
		2'b11:alu=(C[1:0]>A[1:0])?C:A;
		2'b10:alu=(C>5)?A^B:~(A&B);
	endcase
end

endmodule 