module hw (
    input [0:31] D ,
    output [5:0] C
);

    wire [5:0] addrWireL1[7:0];
    wire [5:0] addrWireL2[3:0];
    wire [5:0] addrWireL3[1:0];

    counter ic0(D[0:3],addrWireL1[0]);
    counter ic1(D[4:7],addrWireL1[1]);
    counter ic2(D[8:11],addrWireL1[2]);
    counter ic3(D[12:15],addrWireL1[3]);
    counter ic4(D[16:19],addrWireL1[4]);
    counter ic5(D[20:23],addrWireL1[5]);
    counter ic6(D[24:27],addrWireL1[6]);
    counter ic7(D[28:31],addrWireL1[7]);

    adder i1a0(addrWireL1[0],addrWireL1[1],addrWireL2[0]);
    adder i1a1(addrWireL1[2],addrWireL1[3],addrWireL2[1]);
    adder i1a2(addrWireL1[4],addrWireL1[5],addrWireL2[2]);
    adder i1a3(addrWireL1[6],addrWireL1[7],addrWireL2[3]);

    adder i2a0(addrWireL2[0],addrWireL2[1],addrWireL3[0]);
    adder i2a1(addrWireL2[2],addrWireL2[3],addrWireL3[1]);

    adder i3a1(addrWireL3[0],addrWireL3[1],C);

endmodule

module counter(
    input [3:0] D ,
    output [5:0] C
);
    //module HA(s, c, x, y);
    wire [1:0] s0;
    wire [1:0] s1;

    FA f1(s0[0],s0[1],D[1],D[0]);
    FA f2(s1[0],s1[1],D[2],D[3]);


    adder ad1({4'b0000,s0},{4'b0000,s1},C);

endmodule

module adder (
    input [5:0] a ,
    input [5:0] b ,
    output [5:0] c
);
    wire [5:0] sum;
    wire carry_out;
    adder4bits ia4(a,b,c,1'b0,carry_out);


endmodule

module adder4bits(X,Y,sum,carry_in,carry_out);
    input [5:0] X,Y;
    input carry_in;
    output carry_out;
    output [5:0] sum;
    wire [5:0] Carry;

    FA f0(sum[0],Carry[0],X[0],Y[0],carry_in);
    FA f1(sum[1],Carry[1],X[1],Y[1],Carry[0]);
    FA f2(sum[2],Carry[2],X[2],Y[2],Carry[1]);
    FA f3(sum[3],Carry[3],X[3],Y[3],Carry[2]);
    FA f4(sum[4],Carry[4],X[4],Y[4],Carry[3]);
    FA f5(sum[5],carry_out,X[5],Y[5],Carry[4]);

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



