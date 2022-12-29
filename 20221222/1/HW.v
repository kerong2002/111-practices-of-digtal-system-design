
module HW(clk, rst, SW, LEDR_0, KEY, VGA_HS, VGA_VS ,VGA_R, VGA_G, VGA_B,VGA_BLANK_N,VGA_CLOCK, IRDA_RXD);

	input clk, rst, IRDA_RXD;		clk 50MHz
	input [10] SW;
	input [30] KEY;
	output VGA_HS, VGA_VS;
	output reg [70] VGA_R,VGA_G,VGA_B;
	output VGA_BLANK_N,VGA_CLOCK;
	output LEDR_0;
	assign LEDR_0 = KEY[1];
	reg VGA_HS, VGA_VS;
	reg[100] counterHS;
	reg[90] counterVS;
	reg [20] valid;
	reg clk25M;
	
	reg [120] objY,objX;			物體的座標
	reg [120] leftX=13'd20, leftY= 13'd240, rightX=13'd620, rightY= 13'd240;
	reg [120] X,Y;
	reg p1;
	wire pKEY1, pKEY2, pKEY3;
	wire [120] objTop, objBottom, objLeft, objRight, lTop, lRight, lLeft, lBottom, rTop, rRight, rLeft, rBottom;
	wire clk10;
	wire oDATA_READY;
	wire [310] oDATA;
	IR_RECEIVE u1(clk, rst, IRDA_RXD, oDATA_READY, oDATA);
	wire clk18;
	counterDivider #(50, 5000000018) cntD(clk, rst, clk18);
	KEY_Debounce btn1(clk18, rst, KEY[1], pKEY1);
	KEY_Debounce btn2(clk18, rst, KEY[2], pKEY2);
	KEY_Debounce btn3(clk18, rst, KEY[3], pKEY3);
	reg [20] state ,nextstate;
	reg [20] color_choose;
	reg READY;
	
	parameter right_top    = 3'd0;
	parameter right_bottom = 3'd1;
	parameter left_bottom  = 3'd2;
	parameter left_top     = 3'd3;
	parameter stop 		  = 3'd4;
	
	parameter H_FRONT = 16;
	parameter H_SYNC  = 96;
	parameter H_BACK  = 48;
	parameter H_ACT   = 640;
	parameter H_BLANK = H_FRONT + H_SYNC + H_BACK;
	parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

	parameter V_FRONT = 11;
	parameter V_SYNC  = 2;
	parameter V_BACK  = 32;
	parameter V_ACT   = 480;
	parameter V_BLANK = V_FRONT + V_SYNC + V_BACK;
	parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;
	assign VGA_SYNC_N = 1'b0;
	assign VGA_BLANK_N = ~((counterHSH_BLANK)(counterVSV_BLANK));
	assign VGA_CLOCK = ~clk25M;
	
	assign objTop = objY-13'd30;
	assign objBottom = objY+13'd30;
	assign objLeft = objX-13'd30;
	assign objRight = objX+13'd30;
	assign lTop = leftY-13'd70;
	assign lBottom = leftY+13'd70;
	assign lLeft = leftX-13'd20;
	assign lRight = leftX+13'd20;
	assign rTop = rightY-13'd70;
	assign rBottom = rightY+13'd70;
	assign rLeft = rightX-13'd20;
	assign rRight = rightX+13'd20;

	wire game_clk;
reg take_clk;
assign game_clk = take_clk;

reg speed_choose;
always @()begin
  case(speed_choose)
    1'd0 take_clk = first_clk_10;
    1'd1 take_clk = second_clk_10;
  endcase
end
=============速度調節=================
    always@(posedge clk, negedge rst)begin
        if (!rst)begin
            speed_choose = 1'd0;
        end 
        else begin
            case(SW[0])
                1'd0speed_choose=1'd0;
                                1'd1speed_choose=1'd1;
            endcase
        end
    end
    
    wire first_clk_10;
    ======================第一組速度=====================
    counterDivider #(26, 200_0000) cnt_first_10(clk  , rst, first_clk_10);        除頻5000萬
    
    wire second_clk_10;
    ======================第二組速度=====================
    counterDivider #(25, 100_0000) cnt_sceond_10(clk  , rst, second_clk_10);    除頻2500萬
	
	always@(negedge clk) READY = oDATA_READY;
	always@(posedge clk18, negedge rst)begin
		if (!rst)begin
			rightX = 13'd620;
			rightY = 13'd240;
		end else begin
			if (!pKEY2)begin
				if (rightY = 13'd105)begin
					rightY = 13'd70;
				end
				else begin
					rightY = rightY-13'd35;
				end
			end
			if (!pKEY3)begin
				if (rightY = 13'd375)begin
					rightY = 13'd410;
				end
				else begin
					rightY = rightY + 13'd35;
				end
			end
		end
			
	end
	always@(negedge clk, negedge rst)begin
		if (!rst)begin
			leftX = 13'd20;
			leftY = 13'd240;

		end else begin
			
			if (READY == 1 && oDATA_READY == 0)begin
				case(oDATA[2316])
					8'h1Abegin
						if (leftY = 13'd105)begin
							leftY = 13'd70;
						end
						else begin
							leftY = leftY-13'd35;
						end
					end
					8'h1Ebegin
						if (leftY = 13'd375)begin
							leftY = 13'd410;
						end
						else begin
							leftY = leftY + 13'd35;
						end
					end
					defaultbegin
						leftX = leftX;
						leftY = leftY;
					end
				endcase
			end
		end
	end
	
	always@(posedge clk)
		clk25M = ~clk25M;
	counterDivider #(19, 250000) cntD1(clk25M, rst, clk10);
	always @(posedge clk10,negedge rst)begin
		if(!rst)begin
			state = stop;
		end
		else begin
			state = nextstate;
		end
	end

	
	always @()begin
		case(state)
			right_topbegin
				if (objY = 13'd30)begin
					nextstate = right_bottom;
				end
				else if (objX = 13'd610)begin
					nextstate = stop;
				end
				else if ((objY = rTop && objY = rBottom) && objRight = rLeft)begin hit right board
					nextstate = left_top;
				end
				
				else if (objRight = rLeft && objTop = rBottom && objLeft = rRight)begin hit under right board
					nextstate = right_bottom;
				end
				
				else begin
					nextstate = right_top;
				end	
			end
			right_bottombegin
				if (objY = 13'd450)begin
					nextstate = right_top;
				end
				else if ((objY = rTop && objY = rBottom) && objRight = rLeft)begin
					nextstate = left_bottom;
				end
				
				else if (objRight = rLeft && objBottom = rTop && objLeft = rRight)begin
					nextstate = right_bottom;
				end
				
				else if (objX = 13'd610)begin
					nextstate = stop;
				end
				else begin
					nextstate = right_bottom;
				end	

			end
			left_bottombegin
				if (objY = 13'd450)begin
					nextstate = left_top;
				end
				else if ((objY = lTop && objY = lBottom) && objLeft = lRight)begin
					nextstate = right_bottom;
				end
				
				else if (objLeft = lRight && objBottom = lTop  && objLeft = lRight)begin
					nextstate = left_top;
				end
				
				else if (objX = 13'd30)begin
					nextstate = stop;
				end
				else begin
					nextstate = left_bottom;
				end	

			end
			left_topbegin
				if (objY = 13'd30)begin
					nextstate = left_bottom;
				end
				else if ((objY = lTop && objY = lBottom) && objLeft = lRight)begin
					nextstate = right_top;
				end
				
				else if (objLeft = rRight && objTop = rBottom && objLeft = lRight)begin
					nextstate = left_top;
				end
				
				else if (objX = 13'd30)begin
					nextstate = stop;
				end
				else begin
					nextstate = left_top;
				end	
			end
			stopbegin
				if (!KEY[1])
					nextstate = right_top;
				else
					nextstate = stop;
			end
			defaultbegin
				nextstate = right_top;
			end
		endcase
	end
	
	always@(posedge clk25M)
	begin
		if(!rst) 
			counterHS = 0;
		else begin
		
			if(counterHS == H_TOTAL) 
				counterHS = 0;
			else 
				counterHS = counterHS + 1'b1;
			
			if(counterHS == H_FRONT-1)
				VGA_HS = 1'b0;
			if(counterHS == H_FRONT + H_SYNC -1)
				VGA_HS = 1'b1;
				
			if(counterHS = H_BLANK)
				X = counterHS-H_BLANK;
			else
				X = 0;	
		end
	end

	always@(posedge clk25M)
	begin
		if(!rst) 
			counterVS = 0;
		else begin
			if(counterVS == V_TOTAL) 
				counterVS = 0;
			else if(counterHS == H_TOTAL) 
				counterVS = counterVS + 1'b1;
				
			if(counterVS == V_FRONT-1)
				VGA_VS = 1'b0;
			if(counterVS == V_FRONT + V_SYNC -1)
				VGA_VS = 1'b1;
			if(counterVS = V_BLANK)
				Y = counterVS-V_BLANK;
			else
				Y = 0;
		end
	end

	reg [230]color[30];

	always@(posedge clk25M,negedge rst)
	begin
		if (!rst) begin
			{VGA_R,VGA_G,VGA_B}=24'h0000ff;blue
		end
		else begin
			if(((X-objX)(X-objX) + (Y-objY)(Y-objY)) = 26'd900)begin
				{VGA_R,VGA_G,VGA_B}=color[3]; 
			end
			else if (X=lLeft && X = lRight && Y = lTop && Y = lBottom)begin
				{VGA_R,VGA_G,VGA_B}=color[0];
			end
			else if (X=rLeft && X = rRight && Y = rTop && Y = rBottom)begin
				{VGA_R,VGA_G,VGA_B}=color[2];
			end
			else begin
				{VGA_R,VGA_G,VGA_B}=0;
			end
		
			if(X  320 && Y  240) begin
				{VGA_R,VGA_G,VGA_B}=color[0]; 
			end else if(X  320 && Y = 240) begin
				{VGA_R,VGA_G,VGA_B}=color[1];
			end else if(X = 320 && Y  240) begin
				{VGA_R,VGA_G,VGA_B}=color[2];
			end	else begin
				{VGA_R,VGA_G,VGA_B}=color[3];
			end
		
		end
	end

	always @(posedge game_clk,negedge rst)begin
		if (!rst) begin
			objX = 13'd100;
			objY = 13'd300;
		end
		else begin
			case(state)
				right_topbegin
					objY = objY - 13'd1;
					objX = objX + 13'd1;
				end
				right_bottombegin
					objY = objY + 13'd1;
					objX = objX + 13'd1;
				end
				left_bottombegin
					objY = objY + 13'd1;
					objX = objX - 13'd1;
				end
				left_topbegin
					objY = objY - 13'd1;
					objX = objX - 13'd1;
				end
				stopbegin
					objY = objY;
					objX = objX;
				end
			endcase
		end
	end
	
	
	always@(posedge clk,negedge rst)begin
		if(!rst)begin
			color[0]=24'h0000ff;blue
			color[1]=24'h00ff00;green
			color[2]=24'hff0000;red
			color[3]=24'hFFFFFF;
		end else begin
			color[0]=24'h0000ff;blue
			color[1]=24'h00ff00;green
			color[2]=24'hff0000;red
			color[3]=24'hFFFFFF;
		end
	end

endmodule


module KEY_Debounce(CLK, RST, KEY_In, KEY_Out); 
	parameter DeB_Num = 4; 		 取樣次數
	parameter DeB_SET = 4'b0000;  設置
	parameter DeB_RST = 4'b1111;  重置 

	input CLK, RST;
	input KEY_In;
	output KEY_Out; 
	reg rKEY_Out = 1'b1;
	reg [DeB_Num-10] Bounce = 4'b1111;  初始化 
	integer i;
	always @(posedge CLK or negedge RST) begin  一次約200Hz 5ms
		if(!RST)begin
			Bounce = DeB_RST;  Bounce重置
		end
		else begin  取樣4次
			Bounce[0] = KEY_In;
			for(i=0;iDeB_Num-1;i=i+1)begin
				Bounce[i+1] = Bounce[i];
			end
		end
		case(Bounce)
			DeB_SET rKEY_Out = 1'b0;
			default rKEY_Out = 1'b1;
		endcase
	end 
	
	assign KEY_Out = rKEY_Out; 
	
endmodule 

===============除頻器=====================
module counterDivider(CLK, RST, CLK_Out); 

     除頻設定 1kHz 1ms
	parameter size = 16;
	parameter countDivider = 16'd1_000;
	localparam countDivider_D2  = countDivider  2;

	input CLK, RST;
	output reg CLK_Out;

	reg [size-10] Cnt = 0;

	always @(posedge CLK or negedge RST) begin
		if(!RST) begin
			Cnt = 0;
			CLK_Out = 0;
		end 
		else if(Cnt == countDivider_D2) begin
			Cnt = 0;
			CLK_Out = ~CLK_Out;
		end 
		else begin
			Cnt = Cnt + 1'b1;
		end
	end
	
endmodule 