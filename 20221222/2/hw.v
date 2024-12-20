`include "./1201_IR.v"
`include "./hw_sub.v"

module hw(  clk,
    rst,
    IRDA_RXD,
    SW,
    LCD_EN,
    LCD_RW,
    LCD_RS,
    LCD_DATA,
    VGA_HS,
    VGA_VS,
    VGA_R,
    VGA_G,
    VGA_B,
    VGA_BLANK_N,
    VGA_CLOCK,
    KEY_1);

    input clk;                      //clk 50MHz
    input rst;                      //重製訊號
    input KEY_1;                //按鈕
    //==========<IR>=================
    input IRDA_RXD;             //接收到紅外線
    wire [31:0] oDATA;          //接收IR的資料
    wire oDATA_READY;               //IR確實收到資料
    //==============================

    input [17:0] SW;                //switch開關

    //==========<LCD>=================
    output LCD_EN;                  //LCD控制線
    output LCD_RW;                  //LCD控制線
    output LCD_RS;                  //LCD控制線
    inout [7:0] LCD_DATA;       //LCD資料
    //================================

    //==========<VGA>=================
    output VGA_HS, VGA_VS;
    output reg [7:0] VGA_R,VGA_G,VGA_B;
    output VGA_BLANK_N,VGA_CLOCK;
    //================================

    reg VGA_HS, VGA_VS;
    reg[10:0] counterHS;
    reg[9:0] counterVS;
    reg [2:0] valid;
    reg clk25M;


    reg [2:0] state, nextstate;
    parameter START = 3'd0;
    parameter  UP   = 3'd1;
    parameter DOWN  = 3'd2;
    parameter LEFT  = 3'd3;
    parameter RIGHT = 3'd4;
    parameter END   = 3'd5;

    IR_RECEIVE ir2(clk, rst, IRDA_RXD, oDATA_READY, oDATA);

    parameter H_FRONT = 16;
    parameter H_SYNC  = 96;
    parameter H_BACK  = 48;
    parameter H_ACT   = 640;//
    parameter H_BLANK = H_FRONT + H_SYNC + H_BACK;
    parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;
    reg [6:0] time_cnt;
    reg [6:0] score;
    reg [12:0] objY,objX;           //物體的座標
    reg [12:0] X,Y;
    wire clk10;                         //除頻訊號
    wire clk1s;
    counterDivider #(19, 250000) cnt1(clk25M, rst, clk10);
    counterDivider #(26, 50000000) cnt2(clk, rst, clk1s);


    parameter V_FRONT = 11;
    parameter V_SYNC  = 2;
    parameter V_BACK  = 32;
    parameter V_ACT   = 480;//
    parameter V_BLANK = V_FRONT + V_SYNC + V_BACK;
    parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;
    assign VGA_SYNC_N = 1'b0;
    assign VGA_BLANK_N = ~((counterHS<H_BLANK)||(counterVS<V_BLANK));
    assign VGA_CLOCK = ~clk25M;

    wire [6:0] wire_time;
    wire [6:0] wire_score;
    assign wire_score = score;
    assign wire_time = time_cnt;

    reg [1:0] gameState;
    always@(*)begin
        case(state)
            START : gameState = 0;
            UP    ,
            DOWN  ,
            LEFT  ,
            RIGHT : gameState = 1;
            END   : gameState = 2;
        endcase
    end
    reg [7:0]ssss;

    always@(posedge clk) begin

    end

    c_lcd lcd1(clk, rst, gameState, time_cnt, score, , LCD_DATA, LCD_EN, LCD_RW, LCD_RS, DATA_IN);
    //c_lcd(Clk, rst, gameState, timeNum, point, SW, LCD_DATA, LCD_EN, LCD_RW, LCD_RS, DATA_IN, LEDR, LEDG);
    always@(posedge clk)
        clk25M = ~clk25M;

    //===========<狀態選擇>===================
    always @(posedge clk10,negedge rst)begin
        if(!rst)begin
            state <= START;
        end
        else begin
            state <= nextstate;
        end
    end
    //============<食物>===================
    reg [8:0] food_x;
    reg [8:0] food_y;


    //============<狀態轉移>===================
    always @(*)begin
        case(state)
            START:begin
                if(!KEY_1)begin
                    nextstate = UP;
                end
                else begin
                    nextstate = START;
                end
            end
            UP:begin
                if(time_cnt==0)begin
                    nextstate = END;
                end
                else if(!oDATA_READY)begin
                    case(oDATA[23:16])
                        8'h02:begin         //up
                            nextstate = UP;
                        end
                        8'h08:begin         //down
                            nextstate = DOWN;
                        end
                        8'h04:begin         //left
                            nextstate = LEFT;
                        end
                        8'h06:begin         //right
                            nextstate = RIGHT;
                        end
                        default:begin
                            nextstate = UP;
                        end
                    endcase
                end
                else begin
                    nextstate = UP;
                end
            end
            DOWN:begin
                if(time_cnt==0)begin
                    nextstate = END;
                end
                else if(!oDATA_READY)begin
                    case(oDATA[23:16])
                        8'h02:begin         //up
                            nextstate = UP;
                        end
                        8'h08:begin         //down
                            nextstate = DOWN;
                        end
                        8'h04:begin         //left
                            nextstate = LEFT;
                        end
                        8'h06:begin         //right
                            nextstate = RIGHT;
                        end
                        default:begin
                            nextstate = DOWN;
                        end
                    endcase
                end
                else begin
                    nextstate = DOWN;
                end
            end
            LEFT:begin
                if(time_cnt==0)begin
                    nextstate = END;
                end
                else if(!oDATA_READY)begin
                    case(oDATA[23:16])
                        8'h02:begin         //up
                            nextstate = UP;
                        end
                        8'h08:begin         //down
                            nextstate = DOWN;
                        end
                        8'h04:begin         //left
                            nextstate = LEFT;
                        end
                        8'h06:begin         //right
                            nextstate = RIGHT;
                        end
                        default:begin
                            nextstate = LEFT;
                        end
                    endcase
                end
                else begin
                    nextstate = LEFT;
                end
            end
            RIGHT:begin
                if(time_cnt==0)begin
                    nextstate = END;
                end
                else if(!oDATA_READY)begin
                    case(oDATA[23:16])
                        8'h02:begin         //up
                            nextstate = UP;
                        end
                        8'h08:begin         //down
                            nextstate = DOWN;
                        end
                        8'h04:begin         //left
                            nextstate = LEFT;
                        end
                        8'h06:begin         //right
                            nextstate = RIGHT;
                        end
                        default:begin
                            nextstate = RIGHT;
                        end
                    endcase
                end
                else begin
                    nextstate = RIGHT;
                end
            end
            END:begin
                nextstate = END;
            end
            default:begin
                nextstate = START;
            end
        endcase
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


    //===========<上色>=================
    always@(posedge clk25M,negedge rst)begin
        if (!rst) begin
            {VGA_R,VGA_G,VGA_B}<=24'h0000ff;//blue
        end
        else
        begin
            if((Y+25)>objY && Y<(objY+25)&&(X+25)>objX && X<(objX+25))begin
                {VGA_R,VGA_G,VGA_B}<=color[0];
            end
            else if((Y+5)>food_y && Y<(food_y+5)&&(X+5)>food_x && X<(food_x+5))begin
                {VGA_R,VGA_G,VGA_B}<=color[1];
            end
            else begin
                {VGA_R,VGA_G,VGA_B}<=24'b0;
            end
        end
    end

    always @(posedge clk1s,negedge rst)begin
        if(!rst)begin
            time_cnt <= 7'd0;
        end
        else begin
            case(state)
                START:begin
                    case(SW[1:0])
                        2'b00:time_cnt <= 7'd10;
                        2'b01:time_cnt <= 7'd30;
                        2'b10:time_cnt <= 7'd60;
                        2'b11:time_cnt <= 7'd90;
                    endcase
                end
                UP    : time_cnt <= time_cnt - 7'd1;
                DOWN  : time_cnt <= time_cnt - 7'd1;
                LEFT  : time_cnt <= time_cnt - 7'd1;
                RIGHT : time_cnt <= time_cnt - 7'd1;
                END   : time_cnt <= 7'd0;
                default:time_cnt <= 7'd0;
            endcase
        end
    end

    //=============<人物移動選擇>============
    always @(posedge clk10,negedge rst)begin
        if (!rst) begin
            objX <= 13'd320;
            objY <= 13'd240;
            food_x <= 9'hF1;
            food_y <= 9'hB3;
            score <= 7'd0;
        end
        else begin
            if(objY+5>=food_y-25 &&objY-5<=food_y+25 && objX+5 >= food_x-25 && objX-5 <= food_x+25)begin
                food_x={food_x[8:0],food_x[0]^food_x[2]};
                food_y={food_y[8:0],food_y[0]^food_y[2]};
                score <= score + 7'd1;
            end
            case(state)
                UP:begin
                    if(objY==13'd0)begin
                        objY <= 13'd480;
                    end
                    else begin
                        objY <= objY - 13'd1;
                    end
                end
                DOWN:begin
                    if(objY==13'd480)begin
                        objY <= 13'd0;
                    end
                    else begin
                        objY <= objY + 13'd1;
                    end
                end
                LEFT:begin
                    if(objX==13'd0)begin
                        objX <= 13'd640;
                    end
                    else begin
                        objX <= objX - 13'd1;
                    end
                end
                RIGHT:begin
                    if(objX==13'd640)begin
                        objX <= 13'd0;
                    end
                    else begin
                        objX <= objX + 13'd1;
                    end
                end
            endcase
        end
    end



    always@(posedge clk,negedge rst)begin
        if(!rst)begin
            color[0]<=24'h0000ff;//blue
            color[1]<=24'h00ff00;//green
            color[2]<=24'hff0000;//red
            color[3]<=24'h003fff;//
        end else begin
            color[0]<=24'h0000ff;//blue
            color[1]<=24'h00ff00;//green
            color[2]<=24'hff0000;//red
            color[3]<=24'h003fff;//
        end
    end

endmodule

//===============<除頻器>=====================
module counterDivider(CLK, RST, CLK_Out);

    // 除頻設定 1kHz 1ms
    parameter size = 16;
    parameter countDivider = 16'd1_000;
    localparam countDivider_D2  = countDivider / 2;

    input CLK, RST;
    output reg CLK_Out;

    reg [size-1:0] Cnt = 0;

    always @(posedge CLK or negedge RST) begin
        if(!RST) begin
            Cnt <= 0;
            CLK_Out <= 0;
        end
        else if(Cnt == countDivider_D2) begin
            Cnt <= 0;
            CLK_Out <= ~CLK_Out;
        end
        else begin
            Cnt <= Cnt + 1'b1;
        end
    end

endmodule



