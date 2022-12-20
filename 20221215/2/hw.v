
module hw(clk, rst, VGA_HS, VGA_VS ,VGA_R, VGA_G, VGA_B,VGA_BLANK_N,VGA_CLOCK);

    input clk, rst;     //clk 50MHz
    output VGA_HS, VGA_VS;
    output reg [7:0] VGA_R,VGA_G,VGA_B;
    output VGA_BLANK_N,VGA_CLOCK;

    reg VGA_HS, VGA_VS;
    reg[10:0] counterHS;
    reg[9:0] counterVS;
    reg [2:0] valid;
    reg clk25M;

    reg [12:0] X,Y;
    wire signed [13:0] dXY;
    assign dXY = (X-Y);
    reg [1:0] img;

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

    always@(posedge clk)
        clk25M = ~clk25M;


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

    always@(posedge clk25M)
    begin
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

    reg [23:0]color[3:0];


    always@(posedge clk25M)
    begin
        if (!rst) begin
            {VGA_R,VGA_G,VGA_B}<=0;
            objY <= 13'd215; //480
            objX <= 13'd305; //640
            img  <= 2'd1;
        end
        else begin
            case(img)
                SQUARE:begin
                    if((Y+25)>objY && Y<(objY+25)&&(X+25)>objX && X<(objX+25))begin
                        {VGA_R,VGA_G,VGA_B}<=color[0];
                    end
                    else begin
                        {VGA_R,VGA_G,VGA_B}<=24'b0;
                    end
                end
                TRIANGLE:begin

                    if (     Y<100 && X+Y>300 && X-Y<300)
                        {VGA_R,VGA_G,VGA_B} <= color[0];

                    else if (Y<200 && X+Y>395 && X-Y<205)
                        {VGA_R,VGA_G,VGA_B} <= color[1];

                    else if (Y<300 && X+Y>495 && X<105+Y)
                        {VGA_R,VGA_G,VGA_B} <= color[2];

                    else if (300<=Y && Y<400 && 250<X && X<350)
                        {VGA_R,VGA_G,VGA_B} <= color[3];

                    else
                        {VGA_R,VGA_G,VGA_B}<=24'b0;

                end
                CIRCLE:begin
                    if(((X-objX)*(X-objX) + (Y-objY)*(Y-objY)) <= 26'd900)begin
                        {VGA_R,VGA_G,VGA_B}<=color[2];
                    end
                    else begin
                        {VGA_R,VGA_G,VGA_B}<=0;
                    end
                end
                TREE:begin

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

