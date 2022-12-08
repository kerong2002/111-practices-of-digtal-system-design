module memory(mode, input_data, input_address, SRAM_ADDR, SRAM_DQ, SRAM_LB_N, SRAM_OE_N, SRAM_UB_N,  SRAM_WE_N, SRAM_CE_N);
	inout [15:0] SRAM_DQ;
	input [15:0] input_data;
	input [19:0] input_address;
	input mode;
	output SRAM_LB_N;
	output SRAM_OE_N;
	output SRAM_UB_N;
	output SRAM_WE_N;
	output SRAM_CE_N;
	output [19:0] SRAM_ADDR;
	assign SRAM_ADDR = input_address;
	wire H_or_L;
	assign SRAM_CE_N = SW[0];    //智能控制
	assign mod    = SW[1];		  //讀寫開關
	assign H_or_L = ~SW[2];       //高低選擇
	assign SRAM_WE_N =  mod;    //寫(開)
	assign SRAM_OE_N =  !mod;    //讀(關)

	assign SRAM_UB_N = mod ? 1'b0 : H_or_L; 
	assign SRAM_LB_N = mod ? 1'b0 : (!H_or_L);
	    
	assign SRAM_ADDR = {{16'b0},{SW[6:3]}};
	
	wire [15:0] data_in;
	wire [15:0] data_out;
	assign data_out = {SW[14:7],SW[14:7]} ;
	assign data_in  = SRAM_DQ;
	assign SRAM_DQ = mod ? 16'hzzzz : data_out;
	assign LEDR[15:0] = mod ? data_in : 16'hzzzz;

endmodule 