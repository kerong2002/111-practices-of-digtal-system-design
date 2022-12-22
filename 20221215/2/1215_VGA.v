module VGA(clk, rst, VGA_HS, VGA_VS ,VGA_R, VGA_G, VGA_B,VGA_BLANK_N,VGA_CLOCK);

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
        if (!rst)
        begin
            {VGA_R,VGA_G,VGA_B}<=0;
        end
        else
        begin
            if(X < 320 && Y < 240) begin
                {VGA_R,VGA_G,VGA_B}<=color[0];
            end else if(X < 320 && Y >= 240) begin
                {VGA_R,VGA_G,VGA_B}<=color[1];
            end else if(X >= 320 && Y < 240) begin
                {VGA_R,VGA_G,VGA_B}<=color[2];
            end else begin
                {VGA_R,VGA_G,VGA_B}<=color[3];
            end
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

