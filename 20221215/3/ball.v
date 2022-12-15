/*module ball(clk, rst, VGA_HS, VGA_VS ,VGA_R, VGA_G, VGA_B,VGA_BLANK_N,VGA_CLOCK);
	input clk, rst;				//clk 50MHz
	output VGA_HS, VGA_VS;
	output reg [7:0] VGA_R,VGA_G,VGA_B;
	output VGA_BLANK_N,VGA_CLOCK;
	wire clk10;						//0.1s
	VGA vga1(clk,rst,VGA_HS, VGA_VS ,VGA_R, VGA_G, VGA_B,VGA_BLANK_N,VGA_CLOCK);
	counterDivider #(19, 5000000) cntD(clk, rst, clk10);
	
	
endmodule  */

module ball(clk, rst, VGA_HS, VGA_VS ,VGA_R, VGA_G, VGA_B,VGA_BLANK_N,VGA_CLOCK);

	input clk, rst;		//clk 50MHz
	output VGA_HS, VGA_VS;
	output reg [7:0] VGA_R,VGA_G,VGA_B;
	output VGA_BLANK_N,VGA_CLOCK;

	reg VGA_HS, VGA_VS;
	reg[10:0] counterHS;
	reg[9:0] counterVS;
	reg [2:0] valid;
	reg clk25M;
	
	reg [12:0] objY,objX;			//物體的座標
	reg [12:0] X,Y;
	wire clk10;
	
	reg [1:0] state ,nextstate;
	reg [1:0] color_choose;

	parameter right_top    = 2'd0;
	parameter right_button = 2'd1;
	parameter left_button  = 2'd2;
	parameter left_top     = 2'd3;
	
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
	counterDivider #(19, 250000) cntD(clk25M, rst, clk10);
	
	always @(posedge clk10,negedge rst)begin
		if(!rst)begin
			state <= right_top;
		end
		else begin
			state <= nextstate;
		end
	end

	always @(*)begin
		case(state)
			right_top:begin
				if(objX>=13'd610)begin
					nextstate = left_top;
				end
				else if(objY<=13'd30)begin
					nextstate = right_button;
				end
				else begin
					nextstate = right_top;
				end
			end
			right_button:begin
				if(objY>=13'd450)begin
					nextstate = right_top;
				end
				else if(objX>=13'd610)begin
					nextstate = left_button;
				end
				else begin
					nextstate = right_button;
				end
			end
			left_button:begin
				if(objX<=13'd30)begin
					nextstate = right_button;
				end
				else if(objY>=13'd450)begin
					nextstate = left_top;
				end
				else begin
					nextstate = left_button;	
				end
			end
			left_top:begin
				if(objY<=13'd30)begin
					nextstate = left_button;
				end
				else if(objX<=13'd30)begin
					nextstate = right_top;
				end
				else begin
					nextstate = left_top;
				end
			end
			default:begin
				nextstate = right_top;
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

	always@(posedge clk25M,negedge rst)
	begin
		if (!rst) begin
			{VGA_R,VGA_G,VGA_B}<=24'h0000ff;//blue
		end
		else 
		begin
			if(((X-objX)*(X-objX) + (Y-objY)*(Y-objY)) <= 26'd900)begin
				{VGA_R,VGA_G,VGA_B}<=color[color_choose]; 
			end
			else begin
				{VGA_R,VGA_G,VGA_B}<=0;
			end
		/*
			if(X < 320 && Y < 240) begin
				{VGA_R,VGA_G,VGA_B}<=color[0]; 
			end else if(X < 320 && Y >= 240) begin
				{VGA_R,VGA_G,VGA_B}<=color[1];
			end else if(X >= 320 && Y < 240) begin
				{VGA_R,VGA_G,VGA_B}<=color[2];
			end	else begin
				{VGA_R,VGA_G,VGA_B}<=color[3];
			end
		*/
		end
	end

	always @(posedge clk10,negedge rst)begin
		if (!rst) begin
			objX <= 13'd150;
			objY <= 13'd400;
		end
		else begin
			case(state)
				right_top:begin
					objY <= objY - 13'd1;
					objX <= objX + 13'd1;
				end
				right_button:begin
					objY <= objY + 13'd1;
					objX <= objX + 13'd1;
				end
				left_button:begin
					objY <= objY + 13'd1;
					objX <= objX - 13'd1;
				end
				left_top:begin
					objY <= objY - 13'd1;
					objX <= objX - 13'd1;
				end
			endcase
		end
	end
	
	always @(posedge clk10 ,negedge rst)begin
		if(!rst)begin
			color_choose <= 2'd0;
		end
		else begin
			case(state)
				right_top:begin
					if(objX>=13'd610)begin
						color_choose <= color_choose + 2'd1;
					end
					else if(objY<=13'd30)begin
						color_choose <= color_choose + 2'd1;
					end
					
				end
				right_button:begin
					if(objY>=13'd450)begin
						color_choose <= color_choose + 2'd1;
					end
					else if(objX>=13'd610)begin
						color_choose <= color_choose + 2'd1;
					end
					
				end
				left_button:begin
					if(objX<=13'd30)begin
						color_choose <= color_choose + 2'd1;
					end
					else if(objY>=13'd450)begin
						color_choose <= color_choose + 2'd1;
					end
				end
				left_top:begin
					if(objY<=13'd30)begin
						color_choose <= color_choose + 2'd1;
					end
					else if(objX<=13'd30)begin
						color_choose <= color_choose + 2'd1;
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
