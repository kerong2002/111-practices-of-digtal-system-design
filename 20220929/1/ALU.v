module ALU (A,B,sel,alu,Parity);
input[3:0]      A;
input[3:0]      B;
input[2:0]      sel;   
output[7:0]     alu;
reg[7:0]        alu;
output Parity;
reg Parity;
reg [7:0]save;
reg set;
integer x;
always @(A or B)
begin
    case(sel)
        3'b000:alu={4'b0000,~(A&B)};
        3'b001:alu=9'b10000_0000-B;
        3'b010:alu={A|B,A|B};
        3'b011:alu={A^B,~(A|B)};
        3'b100:alu=(A>=B)?(A<<B[1:0]):B<<(A[1:0]);
        3'b101:alu={A,B};
        3'b110:begin
				save={A,A};
				alu=save%B;
		  end
		  3'b111:begin
				save=A*B;
				for(x=0;x<B%8;x=x+1) begin
					save={save[6:0],save[7]};
				end
				alu=save;
		  end
    endcase
	 Parity=^alu;
end
endmodule 
