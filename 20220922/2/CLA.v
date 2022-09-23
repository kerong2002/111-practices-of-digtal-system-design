module CLA(A, B, SUM);
    input [7:0] A, B;
    output [8:0] SUM;
    wire [7:0] p, g;
    wire [8:0] c;
    HA Adder[7:0](A, B, p, g);
    assign c[0] = 0;
    genvar i;
    generate
        for(i=0;i<=7;i=i+1)begin:init
            assign c[i+1] = g[i] ^ (c[i] & p[i]);
            assign SUM[i] = c[i] ^ p[i];
        end
    endgenerate
    assign SUM[8] = c[8];
endmodule

module HA(A, B, SUM, Cout);
    input A, B;
    output SUM, Cout;
    assign SUM = A ^ B;
    assign Cout = A & B;
endmodule
