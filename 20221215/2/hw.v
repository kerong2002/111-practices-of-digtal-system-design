`include "./1201_IR.v"
`include "./counterDivider.v"
module hw
    (clk, rst, VGA_HS, VGA_VS ,VGA_R, VGA_G, VGA_B,VGA_BLANK_N,VGA_CLOCK, IRDA_RXD);

    input clk, rst;     //clk 50MHz
    output VGA_HS, VGA_VS;
    output reg [7:0] VGA_R,VGA_G,VGA_B;
    output VGA_BLANK_N,VGA_CLOCK;

    input IRDA_RXD;
    //output[17:0] LEDR;
    wire oDATA_READY;
    wire [31:0] oDATA;
    IR_RECEIVE u1(clk, rst, IRDA_RXD, oDATA_READY, oDATA);

    reg VGA_HS, VGA_VS;
    reg[10:0] counterHS;
    reg[9:0] counterVS;
    reg [2:0] valid;
    reg clk25M;

    reg [12:0] X,Y;
    wire signed [13:0] dXY;
    assign dXY = (X-Y);
    reg [1:0] img;

    wire clk8;
    counterDivider #(22, 50000000/180) D30(clk, ~rst, clk8);

    parameter SQUARE   = 2'd0;
    parameter TRIANGLE = 2'd1;
    parameter CIRCLE   = 2'd2;
    parameter TREE     = 2'd3;

    parameter H_FRONT = 16;
    parameter H_SYNC  = 96;
    parameter H_BACK  = 48;
    parameter H_ACT   = 640;//
    parameter H_BLANK = H_FRONT + H_SYNC + H_BACK;
    parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

    parameter V_FRONT = 11;
    parameter V_SYNC  = 2;
    parameter V_BACK  = 32;
    parameter V_ACT   = 480;//
    parameter V_BLANK = V_FRONT + V_SYNC + V_BACK;
    parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;
    assign VGA_SYNC_N = 1'b0;
    assign VGA_BLANK_N = ~((counterHS<H_BLANK)||(counterVS<V_BLANK));
    assign VGA_CLOCK = ~clk25M;
    reg [12:0] objX,objY;


    reg [23:0]color [3:0];
    reg [23:0]displayColor;
    reg showSnow;

    reg [9:0]showOffset;

    always@(posedge clk)
        clk25M = ~clk25M;


    always@(negedge oDATA_READY, negedge rst)begin
        if (!rst)begin
            img <= SQUARE;
            displayColor <= color[0];
            showSnow <= 1'b0;
        end else begin
            case(oDATA[23:16])
                8'h01:begin
                    img <= SQUARE;
                end
                8'h02:begin
                    img <= TRIANGLE;
                end
                8'h03:begin
                    img <= CIRCLE;
                end
                8'h04:begin
                    img <= TREE;
                end
                8'h0f:begin
                    displayColor <= color[0];
                end
                8'h13:begin
                    displayColor <= color[1];
                end
                8'h10:begin
                    displayColor <= color[2];
                end
                8'h12:begin
                    //showSnow <= 1;
                    showSnow <= ~showSnow;
                end
            endcase
        end
    end


    always@(posedge clk25M)
    begin
        if(!rst)
            counterHS <= 0;
        else begin

            if(counterHS == H_TOTAL)
                counterHS <= 0;
            else
                counterHS <= counterHS + 1'b1;

            if(counterHS == H_FRONT-1)
                VGA_HS <= 1'b0;
            if(counterHS == H_FRONT + H_SYNC -1)
                VGA_HS <= 1'b1;

            if(counterHS >= H_BLANK)
                X <= counterHS-H_BLANK;
            else
                X <= 0;
        end
    end

    always@(posedge clk25M) begin
        if(!rst)
            counterVS <= 0;
        else begin

            if(counterVS == V_TOTAL)
                counterVS <= 0;
            else if(counterHS == H_TOTAL)
                counterVS <= counterVS + 1'b1;

            if(counterVS == V_FRONT-1)
                VGA_VS <= 1'b0;
            if(counterVS == V_FRONT + V_SYNC -1)
                VGA_VS <= 1'b1;
            if(counterVS >= V_BLANK)
                Y <= counterVS-V_BLANK;
            else
                Y <= 0;
        end
    end

    always@(posedge clk8, negedge rst)begin
        if (!rst) begin
            showOffset <= 0;
        end else if (showSnow>2000) begin
            showOffset <= 0;
        end else if(img == TREE) begin
            showOffset <= showOffset + 1;
        end
    end

    always@(posedge clk25M, negedge rst)
    begin
        if (!rst) begin
            {VGA_R,VGA_G,VGA_B}<=0;
            objY <= 13'd215; //480
            objX <= 13'd305; //640
            //img  <= 2'd1;
        end
        else begin
            case(img)
                SQUARE:begin
                    if((Y+25)>objY && Y<(objY+25)&&(X+25)>objX && X<(objX+25))begin
                        {VGA_R,VGA_G,VGA_B}<=displayColor;
                    end
                    else begin
                        {VGA_R,VGA_G,VGA_B}<=24'b0;
                    end
                end
                TRIANGLE:begin
                    if (Y<300 && X+Y>495 && X<105+Y)
                        {VGA_R,VGA_G,VGA_B} <= displayColor;
                    else
                        {VGA_R,VGA_G,VGA_B}<=24'b0;

                end
                CIRCLE:begin
                    if(((X-objX)*(X-objX) + (Y-objY)*(Y-objY)) <= 26'd900)begin
                        {VGA_R,VGA_G,VGA_B}<=displayColor;
                    end
                    else begin
                        {VGA_R,VGA_G,VGA_B}<=0;
                    end
                end
                TREE:begin

                    if (
                       (  5<X && X<10  && (-100+showOffset)<Y && Y<(-95+showOffset))
                    || ( 43<X && X<48  && (-500+showOffset)<Y && Y<(-495+showOffset))
                    || ( 43<X && X<48  && (-500+showOffset)<Y && Y<(-495+showOffset))
                    || (120<X && X<125 && (-30+showOffset)<Y && Y<(-25+showOffset))
                    || (157<X && X<162 && (-430+showOffset)<Y && Y<(-425+showOffset))
                    || (241<X && X<246 && (-240+showOffset)<Y && Y<(-235+showOffset))
                    || (285<X && X<290 && (-151+showOffset)<Y && Y<(-146+showOffset))
                    || (305<X && X<310 && (-603+showOffset)<Y && Y<(-598+showOffset))
                    || (332<X && X<337 && (-530+showOffset)<Y && Y<(-525+showOffset))
                    || (361<X && X<366 && (-211+showOffset)<Y && Y<(-206+showOffset))
                    || (427<X && X<432 && (-363+showOffset)<Y && Y<(-358+showOffset))
                    || (477<X && X<482 && (-640+showOffset)<Y && Y<(-635+showOffset))
                    || (561<X && X<566 && (-434+showOffset)<Y && Y<(-429+showOffset))
                    || (597<X && X<602 && (-222+showOffset)<Y && Y<(-217+showOffset))
                    || (627<X && X<632 && (-333+showOffset)<Y && Y<(-328+showOffset))
                    || (661<X && X<666 && (-444+showOffset)<Y && Y<(-439+showOffset))
                    )
                        {VGA_R,VGA_G,VGA_B} <= 24'hffffff;
                    
                    else if (     Y<100 && X+Y>300 && X-Y<300)
                    {VGA_R,VGA_G,VGA_B} <= displayColor;

                    else if (Y<200 && X+Y>395 && X-Y<205)
                    {VGA_R,VGA_G,VGA_B} <= displayColor;

                    else if (Y<300 && X+Y>495 && X<105+Y)
                    {VGA_R,VGA_G,VGA_B} <= displayColor;

                    else if (300<=Y && Y<400 && 250<X && X<350)
                    {VGA_R,VGA_G,VGA_B} <= color[3];

                    else
                        {VGA_R,VGA_G,VGA_B}<=24'b0;


                end
            endcase
        end
    end

    always@(posedge clk,negedge rst)begin
        if(!rst)begin
            color[0]<=24'h000000;//
            color[1]<=24'h000000;//
            color[2]<=24'h000000;//
            color[3]<=24'h000000;//
        end else begin
            color[0]<=24'h0000ff;//blue
            color[1]<=24'h00ff00;//green
            color[2]<=24'hff0000;//red
            color[3]<=24'h00ffff;//
        end
    end

endmodule

