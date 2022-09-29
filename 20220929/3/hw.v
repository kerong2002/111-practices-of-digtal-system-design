module hw (
    input [3:0] a_x ,
    input [3:0] a_y ,
    input [3:0] b_x ,
    input [3:0] b_y ,
    input [3:0] c_x ,
    input [3:0] c_y ,
    input [3:0] d_x ,
    input [3:0] d_y ,
    output [2:0] A_score,
    output [2:0] B_score,
    output [2:0] C_score,
    output [2:0] D_score,
    output reg [2:0]  Max_score,

    output signed [1:0] c1,
    output signed [1:0] c2,
    output signed [1:0] c3,
    output signed [5:0] y1
);


    findLocation f1(a_x,a_y,A_score);
    findLocation f2(b_x,b_y,B_score, c1,c2,c3,y1);
    findLocation f3(c_x,c_y,C_score);
    findLocation f4(d_x,d_y,D_score);

    always @(*) begin
        Max_score = A_score;
        if (Max_score < B_score)
            Max_score = B_score;
        if (Max_score < C_score)
            Max_score = C_score;
        if (Max_score < D_score)
            Max_score = D_score;
    end

endmodule

module findLocation (
    input [3:0] x,
    input [3:0] y,
    output reg [2:0] loc,

    output signed [1:0] c1,
    output signed [1:0] c2,
    output signed [1:0] c3,
    output signed [5:0] y1
);
    //wire signed [5:0] y1;
    wire signed [5:0] y2;
    wire signed [5:0] y3;

    equation  #(-6'd2, 6'd16) (x,y1);
    equation  #(6'd2, -6'd9) (x,y2);
    equation  #(6'd0, 6'd10) (x,y3);

    //wire signed [1:0] c1;
    //wire signed [1:0] c2;
    //wire signed [1:0] c3;

    cmpS5bit cmp1({2'b0,y} , y1 ,c1);
    cmpS5bit cmp2({2'b0,y} , y2 ,c2);
    cmpS5bit cmp3({2'b0,y} , y3 ,c3);

    always @(*) begin
        casex ({c1,c2,c3})
            {  2'd0,  2'dx,  2'dx }:  loc = 0;
            {  2'dx,  2'd0,  2'dx }:  loc = 0;
            {  2'dx,  2'dx,  2'd0 }:  loc = 0;

            { -2'd1,  2'd1, -2'd1 }:  loc = 1;
            { -2'd1,  2'd1,  2'd1 }:  loc = 2;
            {  2'd1,  2'd1,  2'd1 }:  loc = 3;
            {  2'd1, -2'd1,  2'd1 }:  loc = 4;
            {  2'd1, -2'd1, -2'd1 }:  loc = 5;
            { -2'd1, -2'd1, -2'd1 }:  loc = 6;
            {  2'd1,  2'd1, -2'd1 }:  loc = 7;
            default: loc = 0;
        endcase

    end

endmodule

module cmpS5bit (
    input signed [5:0] a ,
    input signed [5:0] b ,
    output reg signed [1:0] sol
);
    always @(*) begin
        if (a<b)
            sol = -2'd1;
        else if (a>b)
            sol = 2'd1;
        else
            sol = 2'd0;
    end
endmodule


module equation (
    input [3:0] x ,
    output signed [5:0] y
);
    parameter A = 6'd0;
    parameter B = 6'd0;

    assign y = A*{2'd0, x} + B;
endmodule

