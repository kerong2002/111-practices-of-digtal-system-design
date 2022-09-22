module CLA(inDatA, inDatB, outDat);
    input [7:0] inDatA, inDatB;
    output [8:0] outDat;
    wire Cin;
    CLA4Bits first(inDatA[3:0], inDatB[3:0], outDat[3:0],0, Cin);
    CLA4Bits second(inDatA[7:4], inDatB[7:4], outDat[7:4], Cin, outDat[8]);
endmodule

module CLA4Bits(A, B, Sum, Carryin, CarryOut);
    input [3:0]A, B;
    input Carryin;
    output [3:0]Sum;
    wire [3:0]Cout;
    output CarryOut;
    FA a0(A[0], B[0], Carryin, Cout[0], Sum[0]);
    FA a1(A[1], B[1], Cout[0], Cout[1], Sum[1]);
    FA a2(A[2], B[2], Cout[1], Cout[2], Sum[2]);
    FA a3(A[3], B[3], Cout[2], Cout[3], Sum[3]);
    assign CarryOut = Cout[3];
endmodule

module FA(A, B, Cin, Cout, Sum);
    input A, B, Cin;
    output Cout, Sum;
    assign Sum = A ^ B ^ Cin;
    assign Cout = (A & B) | (A & Cin) | (B & Cin);
endmodule