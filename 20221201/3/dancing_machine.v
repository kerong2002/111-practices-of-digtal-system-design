`define displayregLine2 {displayreg[16],displayreg[17],displayreg[18],displayreg[19],displayreg[20],displayreg[21],displayreg[22],displayreg[23],displayreg[24],displayreg[25],displayreg[26],displayreg[27],displayreg[28],displayreg[29],displayreg[30],displayreg[31]}
module dancing_machine(Clk, rst, IRDA_RXD, LEDR, LCD_EN, LCD_RW, LCD_RS, LCD_DATA, DATA_IN);
	input Clk;
	input rst;
	input IRDA_RXD;
	output LCD_EN;
	output LCD_RW;
	output LCD_RS;
	inout [7:0] LCD_DATA;
	input [3:0] DATA_IN;
	output reg [17:0] LEDR;
	wire [31:0] oDATA;
	wire oDATA_READY;
	IR_RECEIVE test(Clk, rst, IRDA_RXD,oDATA_READY, oDATA);
	LCD lcd1(Clk, rst, LCD_DATA, LCD_EN, LCD_RW, LCD_RS, DATA_IN,oDATA,oDATA_READY);
	
	always @(posedge Clk, negedge rst)begin
		if(!rst)begin
			LEDR <= 18'b0;
		end
		else begin
			if(!oDATA_READY)begin
				case(oDATA[23:16])
					8'h14:begin			//left
						LEDR <= 18'd8;
					end
					8'h18:begin			//right
						LEDR <= 18'd1;
					end
					8'h1B:begin			//up
						LEDR <= 18'd4;
					end
					8'h1F:begin			//down
						LEDR <= 18'd2;
					end
					default:begin
						LEDR <= 18'b0 ;
					end
				endcase
			end
			else begin
				LEDR <= 18'b0;
			end	
		end
	end
	
endmodule 

module IR_RECEIVE(iCLK,iRST_n,iIRDA,oDATA_READY,oDATA);
					
input iCLK;        //input clk,50MHz
input iRST_n;      //rst
input iIRDA;       //Irda RX output decoded data
output oDATA_READY; //data ready
output reg [31:0] oDATA; //output data,32bit 	
				
parameter IDLE = 2'b00;   //State Machine 
parameter GUIDANCE = 2'b01;    
parameter DATAREAD = 2'b10;    


parameter IDLE_DUR = 230000;  // idle_count    230000*0.02us = 4.60ms, threshold for IDLE--------->GUIDANCE
parameter GUIDANCE_DUR = 210000;  // guidance_count   210000*0.02us = 4.20ms, 4.5-4.2 = 0.3ms < BIT_AVAILABLE_DUR = 0.4ms,threshold for GUIDANCE------->DATAREAD
parameter DATAREAD_DUR = 262143;  // data_count    262143*0.02us = 5.24ms, threshold for DATAREAD-----> IDLE

parameter DATA_HIGH_DUR = 41500;	 // data_count    41500 *0.02us = 0.83ms, sample time from the posedge of iIRDA
parameter BIT_AVAILABLE_DUR = 20000;   // data_count    20000 *0.02us = 0.4ms,  the sample bit pointer,can inhibit the interference from iIRDA signal

reg [17:0] idle_count;           
reg idle_count_flag;       
reg [17:0] guidance_count;           
reg guidance_count_flag;      
reg [17:0] data_count;            
reg data_count_flag;    
  
reg [5:0] bitcount; //sample bit pointer
reg [1:0] state;   //state reg
reg [31:0] data;   //data reg
reg [31:0] data_buf; //data buf
reg data_ready; //data ready flag


assign oDATA_READY = data_ready;

//state change between IDLE,GUIDE,DATA_READ according to irda edge or counter
always @(posedge iCLK or negedge iRST_n)
begin 
	  if (!iRST_n)	     
	     state <= IDLE;
	  else 
			 case (state)
 			    IDLE     : if (idle_count > IDLE_DUR)  
			  	              state <= GUIDANCE; 
			    GUIDANCE : if (guidance_count > GUIDANCE_DUR)
			  	              state <= DATAREAD;
			    DATAREAD : if ((data_count >= DATAREAD_DUR) || (bitcount >= 33))
			  					      state <= IDLE;
	        default  : state <= IDLE; 
			 endcase
end
//idle counter switch when iIRDA is low under IDLE state
always @(posedge iCLK or negedge iRST_n)
begin	
	  if (!iRST_n)
		   idle_count_flag <= 1'b0;
	  else if ((state == IDLE) && !iIRDA)
			 idle_count_flag <= 1'b1;
		else                           
			 idle_count_flag <= 1'b0;		     		 	
 end  		  
//idle counter works on iclk under IDLE state only
always @(posedge iCLK or negedge iRST_n)
begin	
	  if (!iRST_n)
		   idle_count <= 0;
	  else if (idle_count_flag)    //the counter works when the flag is 1
			 idle_count <= idle_count + 1'b1;
		else  
			 idle_count <= 0;	         //the counter resets when the flag is 0		      		 	
end
   
//state counter switch when iIRDA is high under GUIDE state
always @(posedge iCLK or negedge iRST_n)	
begin
	  if (!iRST_n)
		   guidance_count_flag <= 1'b0;
	  else if ((state == GUIDANCE) && iIRDA)
			 guidance_count_flag <= 1'b1;
		else  
			 guidance_count_flag <= 1'b0;     		 	
end
//state counter works on iclk under GUIDE state only
always @(posedge iCLK or negedge iRST_n)	
begin
	  if (!iRST_n)
		   guidance_count <= 0;
	  else if (guidance_count_flag)    //the counter works when the flag is 1
			 guidance_count <= guidance_count + 1'b1;
		else  
			 guidance_count <= 0;	        //the counter resets when the flag is 0		      		 	
end
//data counter switch
always @(posedge iCLK or negedge iRST_n)
begin
	  if (!iRST_n) 
		   data_count_flag <= 0;	
	  else if ((state == DATAREAD) && iIRDA)
			 data_count_flag <= 1'b1;  
		else
			 data_count_flag <= 1'b0; 
end
//data read decode counter based on iCLK
always @(posedge iCLK or negedge iRST_n)	
begin
	  if (!iRST_n)
		   data_count <= 1'b0;
	  else if(data_count_flag)      //the counter works when the flag is 1
			 data_count <= data_count + 1'b1;
		else 
			 data_count <= 1'b0;        //the counter resets when the flag is 0
end
///////////////////////////////////////////////////////////////////////////////////////////////

//data reg pointer counter 
always @(posedge iCLK or negedge iRST_n)
begin
    if (!iRST_n)
       bitcount <= 6'b0;
	  else if (state == DATAREAD)
		begin
			if (data_count == BIT_AVAILABLE_DUR)
					bitcount <= bitcount + 1'b1; //add 1 when iIRDA posedge
		end   
	  else
	     bitcount <= 6'b0;
end	  
//data decode base on the value of data_count 	
always @(posedge iCLK or negedge iRST_n)
begin
	  if (!iRST_n)
	     data <= 0;
		else if (state == DATAREAD)
		begin
			 if (data_count >= DATA_HIGH_DUR) //2^15 = 32767*0.02us = 0.64us
			    data[bitcount-1'b1] <= 1'b1;  //>0.52ms  sample the bit 1
		end
		else
			 data <= 0;	
end		 
//set the data_ready flag 
always @(posedge iCLK or negedge iRST_n)
begin 
	  if (!iRST_n)
	     data_ready <= 1'b0;
    else if (bitcount == 32)   
		begin
			 if (data[31:24] == ~data[23:16])
			 begin		
					data_buf <= data;     //fetch the value to the databuf from the data reg
				  data_ready <= 1'b1;   //set the data ready flag
			 end	
			 else
				  data_ready <= 1'b0 ;  //data error
		end
		else
		   data_ready <= 1'b0 ;
end
//read data
always @(posedge iCLK or negedge iRST_n)
begin
	  if (!iRST_n)
		   oDATA <= 32'b0000;
	  else if (data_ready)
	     oDATA <= data_buf;  //output
end	  
endmodule

module LCD(Clk, rst, LCD_DATA, LCD_EN, LCD_RW, LCD_RS, DATA_IN,oDATA,oDATA_READY);
input 			Clk, rst;
input 	[3:0]  	DATA_IN;
inout 	[7:0]  	LCD_DATA;
input [31:0] oDATA;
input oDATA_READY;
output 			LCD_EN, LCD_RW, LCD_RS;

reg 	[3:0] 	state, next_command;
// Enter new ASCII hex data above for LCD Display
reg 	[7:0] 	DATA_BUS_VALUE;
wire	[7:0] 	Next_Char;
reg 	[19:0] 	CLK_COUNT_400HZ;
reg 	[4:0] 	CHAR_COUNT;
reg 			CLK_400HZ, LCD_RW, LCD_EN, LCD_RS;

reg 	[5:0] 	font_addr;
wire 	[7:0]	font_data;

parameter
	RESET 			= 4'h0,
	DROP_LCD_E 		= 4'h1,
	HOLD 			= 4'h2,
	DISPLAY_CLEAR 	= 4'h3,
	MODE_SET 		= 4'h4,
	Print_String 	= 4'h5,
	LINE2 			= 4'h6,
	RETURN_HOME 	= 4'h7,
	CG_RAM_HOME 	= 4'h8,
	write_CG 		= 4'h9;


assign LCD_DATA = LCD_RW ? 8'bZZZZZZZZ : DATA_BUS_VALUE;

Custom_font_ROM ROM_U(.addr(font_addr), .out_data(font_data));
LCD_display_string u1(.index(CHAR_COUNT), .out(Next_Char), .DATA_IN(DATA_IN), .clk(Clk), .rst(rst), .oDATA(oDATA), .oDATA_READY(oDATA_READY));


//=============================除頻===============================
	always @(posedge Clk or negedge rst)begin
		if (!rst)begin
			CLK_COUNT_400HZ <= 20'h00000;
			CLK_400HZ 		<= 1'b0;
		end
		else if (CLK_COUNT_400HZ < 20'h0F424)begin
			CLK_COUNT_400HZ <= CLK_COUNT_400HZ + 1'b1;
		end
		else begin
			CLK_COUNT_400HZ <= 20'h00000;
			CLK_400HZ 		<= ~CLK_400HZ;
		end
	end
 //============================================================
	always @(posedge CLK_400HZ or negedge rst)begin
		if (!rst)begin
			state <= RESET;
		end
		else begin
			case (state)
				RESET : begin  // Set Function to 8-bit transfer and 2 line display with 5x8 Font size
					LCD_EN 			<= 1'b1;
					LCD_RS 			<= 1'b0;
					LCD_RW 			<= 1'b0;
					DATA_BUS_VALUE 	<= 8'h38;
					state 			<= DROP_LCD_E;
					next_command 	<= DISPLAY_CLEAR;
					CHAR_COUNT 		<= 5'b00000;
				end

				// Clear Display (also clear DDRAM content)
				DISPLAY_CLEAR : begin
					LCD_EN 			<= 1'b1;
					LCD_RS 			<= 1'b0;
					LCD_RW 			<= 1'b0;
					DATA_BUS_VALUE 	<= 8'h01;
					state 			<= DROP_LCD_E;
					next_command 	<= MODE_SET;
				end

				// Set write mode to auto increment address and move cursor to the right
				MODE_SET : begin
					LCD_EN 			<= 1'b1;
					LCD_RS 			<= 1'b0;
					LCD_RW 			<= 1'b0;
					DATA_BUS_VALUE 	<= 8'h06;
					state 			<= DROP_LCD_E;
					next_command 	<= CG_RAM_HOME;
				end

				// Write ASCII hex character in first LCD character location
				Print_String : begin
					state 			<= DROP_LCD_E;
					LCD_EN 			<= 1'b1;
					LCD_RS 			<= 1'b1;
					LCD_RW 			<= 1'b0;
					DATA_BUS_VALUE 	<= Next_Char;
					
					// Loop to send out 32 characters to LCD Display  (16 by 2 lines)
					if (CHAR_COUNT < 31)
						CHAR_COUNT <= CHAR_COUNT + 1'b1;
					else
						CHAR_COUNT <= 5'b00000; 

					// Jump to second line?
					if (CHAR_COUNT == 15)
						next_command <= LINE2;
					// Return to first line?
					else if (CHAR_COUNT == 31)
						next_command <= RETURN_HOME;
					else
						next_command <= Print_String;
				end

				// Set write address to line 2 character 1
				LINE2 : begin
					LCD_EN 			<= 1'b1;
					LCD_RS 			<= 1'b0;
					LCD_RW 			<= 1'b0;
					DATA_BUS_VALUE 	<= 8'hC0; //line 2 character 2 ==> 8'hC1
					state 			<= DROP_LCD_E;
					next_command 	<= Print_String;
				end

				// Return write address to first character postion on line 1
				RETURN_HOME : begin
					LCD_EN 			<= 1'b1;
					LCD_RS 			<= 1'b0;
					LCD_RW 			<= 1'b0;
					DATA_BUS_VALUE 	<= 8'h80; //line 1 character 2 ==> 8'h81
					state 			<= DROP_LCD_E;
					next_command 	<= Print_String;
				end
				CG_RAM_HOME : begin
					LCD_EN 			<= 1'b1;
					LCD_RS 			<= 1'b0;
					LCD_RW 			<= 1'b0;
					DATA_BUS_VALUE 	<= 8'h40; //CGRAM begin address = 6'h00
					font_addr		<= 6'd0;//
					state 			<= DROP_LCD_E;
					next_command 	<= write_CG;
				end
				write_CG : begin
					state 			<= DROP_LCD_E;
					LCD_EN 			<= 1'b1;
					LCD_RS 			<= 1'b1;
					LCD_RW 			<= 1'b0;
					DATA_BUS_VALUE 	<= font_data;

					if(font_addr == 6'b111111)begin
						next_command 	<= RETURN_HOME;
					end else begin
						font_addr		<= font_addr + 1;
						next_command 	<= write_CG;
					end
				end

				DROP_LCD_E : begin
					LCD_EN 	<= 1'b0;
					state 	<= HOLD;
				end
				
				HOLD : begin
					state 	<= next_command;
				end
			endcase
		end
	end
endmodule

module LCD_display_string(index, out, DATA_IN, clk, rst,oDATA,oDATA_READY);
	input 			  clk, rst;
	input 		[4:0] index;
	input 		[3:0] DATA_IN;
	input oDATA_READY;
	input [31:0] oDATA;
	output reg 	[7:0] out;	
	
	reg [3:0] ans_data;
	reg [7:0] ans_num;
	reg [7:0] ASCII;
	reg [7:0] displayreg [31:0];
	reg [127:0] game_data;
	reg [3:0] cnt;
	//5E up
	//76 down
	//7F left
	//7E right
	wire clk18;
	counterDivider #(19, 50000000) cntD(clk, rst, clk18);
	reg state, next_state;
	parameter PLAY = 1'd0;
	parameter DONE = 1'd1;
	
	always @(posedge clk18, negedge rst)begin
		if(!rst)begin
			state <= PLAY;
		end
		else begin
			state <= next_state;
		end
	end
	
	always @(posedge clk18, negedge rst)begin
		if(!rst)begin
			cnt <= 4'd0;
		end
		else begin
			case(state)
				PLAY:begin
					cnt <= cnt + 4'd1;
				end
				DONE:begin
					cnt <= 4'd0;
				end
			endcase
		end
	end
	
	always @(*)begin
		case(state)
			PLAY:begin
				next_state = (cnt == 4'd14) ? DONE : PLAY;
			end
			DONE:begin
				next_state = DONE;
			end
			default:begin
				next_state = DONE;
			end
		endcase
	end
	
	always @( negedge oDATA_READY, negedge rst)begin
		if(!rst)begin
			ans_data <= 4'd0;
		end
		else if(!oDATA_READY)begin
			case(state)
				PLAY:begin
					case(oDATA[23:16])
						8'h14:begin			//left
							if(game_data[127:120]==8'h7F)begin
								ans_data <= ans_data + 4'd1;
							end
						end
						8'h18:begin			//right
							if(game_data[127:120]==8'h7E)begin
								ans_data <= ans_data + 4'd1;
							end
						end
						8'h1B:begin			//up
							if(game_data[127:120]==8'h5E)begin
								ans_data <= ans_data + 4'd1;
							end
						end
						8'h1F:begin			//down
							if(game_data[127:120]==8'h76)begin
								ans_data <= ans_data + 4'd1;
							end
						end
					endcase
				end
			endcase
		end
	end
	
	always @(posedge clk18, negedge rst)begin
		if(!rst)begin
			game_data <= 128'h20_20_5E_76_7E_7F_20_20_7E_76_20_20_20_7E_20_20;
		end
		else begin
			case(state)
				PLAY:begin
					game_data <= {game_data[119:0],8'h20};
				end
				DONE:begin
					game_data <=128'b0;
				end
			endcase
		end
	end
	
	always@(posedge clk18)begin
		displayreg[0] 	<= 8'h76; //v
		displayreg[1] 	<= 8'h20; //
		displayreg[2] 	<= 8'h20; //
		displayreg[3] 	<= 8'h20; //
		displayreg[4] 	<= 8'h53; //S
		displayreg[5] 	<= 8'h43; //C
		displayreg[6] 	<= 8'h4F; //O
		displayreg[7] 	<= 8'h52; //R
		displayreg[8] 	<= 8'h45; //E
		displayreg[9] 	<= 8'h3D; //=
		displayreg[10] 	<= ASCII; //num
		displayreg[11] 	<= ans_num; //num
		displayreg[12] 	<= 8'h20; //
		displayreg[13] 	<= 8'h20; //
		displayreg[14] 	<= 8'h01; //
		displayreg[15] 	<= 8'h02; //
		`displayregLine2  <= game_data;
		// Line 2
		/*
		displayreg[16] 	<= 8'h44; //D
		displayreg[17] 	<= 8'h45; //E
		displayreg[18] 	<= 8'h32; //2
		displayreg[19] 	<= 8'h20; //
		displayreg[20] 	<= 8'h31; //1
		displayreg[21] 	<= 8'h31; //1
		displayreg[22] 	<= 8'h35; //5
		displayreg[23] 	<= 8'h20; // 
		displayreg[24] 	<= 8'h53; //S
		displayreg[25] 	<= 8'h57; //W
		displayreg[26] 	<= 8'h00; //+-(自定義字形)
		displayreg[27] 	<= 8'h4c; //L
		displayreg[28] 	<= 8'h43; //C
		displayreg[29] 	<= 8'h44; //D*/
	end
	always@(*)begin
		out <= displayreg[index];
	end
	always@(*)begin
		case(ans_data)
			4'h0 	: ans_num = 8'h30;
			4'h1 	: ans_num = 8'h31;
			4'h2 	: ans_num = 8'h32;
			4'h3 	: ans_num = 8'h33;
			4'h4 	: ans_num = 8'h34;
			4'h5 	: ans_num = 8'h35;
			4'h6 	: ans_num = 8'h36;
			4'h7 	: ans_num = 8'h37;
			4'h8 	: ans_num = 8'h38;
			4'h9 	: ans_num = 8'h39;
			default : ans_num = 8'h20;
		endcase
	end
	
	always@(*)begin
		case(DATA_IN)/* 0 - 9 */
			4'h0 	: ASCII = 8'h30;
			4'h1 	: ASCII = 8'h31;
			4'h2 	: ASCII = 8'h32;
			4'h3 	: ASCII = 8'h33;
			4'h4 	: ASCII = 8'h34;
			4'h5 	: ASCII = 8'h35;
			4'h6 	: ASCII = 8'h36;
			4'h7 	: ASCII = 8'h37;
			4'h8 	: ASCII = 8'h38;
			4'h9 	: ASCII = 8'h39;
			default : ASCII = 8'h20;
		endcase
	end  		 
endmodule

module Custom_font_ROM(addr, out_data);//8個自定義字形 
	input 	[5:0] addr;//8*8
	output 	[7:0] out_data;

	wire 	[7:0] data[63:0];

	assign out_data = data[addr];
	//0
	assign data[00] = 8'b000_00100;//+-
	assign data[01] = 8'b000_00100;
	assign data[02] = 8'b000_11111;
	assign data[03] = 8'b000_00100;
	assign data[04] = 8'b000_00100;
	assign data[05] = 8'b000_00000;
	assign data[06] = 8'b000_11111;
	assign data[07] = 8'b000_00000;//游標位置
	//1
	assign data[08] = 8'b000_00000;//
	assign data[09] = 8'b000_00100;
	assign data[10] = 8'b000_01110;
	assign data[11] = 8'b000_10101;
	assign data[12] = 8'b000_00100;
	assign data[13] = 8'b000_00100;
	assign data[14] = 8'b000_00100;
	assign data[15] = 8'b000_00000;//游標位置
	//2
	assign data[16] = 8'b000_00000;//
	assign data[17] = 8'b000_00100;
	assign data[18] = 8'b000_00100;
	assign data[19] = 8'b000_00100;
	assign data[20] = 8'b000_10101;
	assign data[21] = 8'b000_01110;
	assign data[22] = 8'b000_00100;
	assign data[23] = 8'b000_00000;//游標位置
	//3
	assign data[24] = 8'b000_00000;//
	assign data[25] = 8'b000_00000;
	assign data[26] = 8'b000_00000;
	assign data[27] = 8'b000_00000;
	assign data[28] = 8'b000_00000;
	assign data[29] = 8'b000_00000;
	assign data[30] = 8'b000_00000;
	assign data[31] = 8'b000_00000;//游標位置
	//4
	assign data[32] = 8'b000_00000;//
	assign data[33] = 8'b000_00000;
	assign data[34] = 8'b000_00000;
	assign data[35] = 8'b000_00000;
	assign data[36] = 8'b000_00000;
	assign data[37] = 8'b000_00000;
	assign data[38] = 8'b000_00000;
	assign data[39] = 8'b000_00000;//游標位置
	//5
	assign data[40] = 8'b000_00000;//
	assign data[41] = 8'b000_00000;
	assign data[42] = 8'b000_00000;
	assign data[43] = 8'b000_00000;
	assign data[44] = 8'b000_00000;
	assign data[45] = 8'b000_00000;
	assign data[46] = 8'b000_00000;
	assign data[47] = 8'b000_00000;//游標位置
	//6
	assign data[48] = 8'b000_00000;//
	assign data[49] = 8'b000_00000;
	assign data[50] = 8'b000_00000;
	assign data[51] = 8'b000_00000;
	assign data[52] = 8'b000_00000;
	assign data[53] = 8'b000_00000;
	assign data[54] = 8'b000_00000;
	assign data[55] = 8'b000_00000;//游標位置
	//7
	assign data[56] = 8'b000_00000;//
	assign data[57] = 8'b000_00000;
	assign data[58] = 8'b000_00000;
	assign data[59] = 8'b000_00000;
	assign data[60] = 8'b000_00000;
	assign data[61] = 8'b000_00000;
	assign data[62] = 8'b000_00000;
	assign data[63] = 8'b000_00000;//游標位置
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