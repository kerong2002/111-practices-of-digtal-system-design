//testbench
`timescale 1ns /10ps
`define cycle 10
`define terminateCycle 100000000

`define A_FILE "./A.txt"
`define B_FILE "./B.txt"
`define C_FILE "./C.txt"
`define SEL_FILE "./sel.txt"
`define ANS_FILE "./ans.txt"

`define DATA_SIZE 20000
`define ANS_SIZE  20000
`define DATA8_LEN 8
`define DATA5_LEN 5
`define DATA2_LEN 2
`define ANS_LEN 9

module tb;

reg clk = 0;
reg rst = 0;
reg en = 0;
wire req;
reg [20:0] clkCnt = 0;
reg [7:0] A,B;
reg [4:0] C;
reg [1:0] sel;
wire [8:0] alu;

integer errCnt,datCnt,ansCnt;

reg [`DATA8_LEN - 1 : 0] datA   [0:`DATA_SIZE - 1];
reg [`DATA8_LEN  -1 : 0] datB   [0:`DATA_SIZE - 1];
reg [`DATA5_LEN  -1 : 0] datC   [0:`DATA_SIZE - 1];
reg [`DATA2_LEN  -1 : 0] dat_sel[0:`DATA_SIZE - 1];
reg [`ANS_LEN    -1 : 0] ansMem [0:`DATA_SIZE - 1];

initial begin
	$timeformat(-9, 1, " ns", 9);
	$readmemb(`A_FILE   , datA);
	$readmemb(`B_FILE   , datB);
	$readmemb(`C_FILE   , datC);
	$readmemb(`SEL_FILE , dat_sel);
	$readmemb(`ANS_FILE , ansMem);
end

always #(`cycle / 2) clk = ~clk;

alu U1(.A(A),.B(B),.C(C),.sel(sel),.alu(alu));
/*
always @(posedge clk) begin
	clkCnt = clkCnt + 1;
	if (clkCnt * 2 > `terminateCycle) begin
		$display("==========================");
		$display("| Failed for simulation! |");
		$display("| Please check your code |");
		$display("==========================");
		$finish;
	end
end*/
/*
initial begin
	
	
	while(datCnt < `DATA_SIZE) begin
		@(negedge clk);
		# `cycle
			
			datCnt = datCnt + 1;
	end
end*/
initial begin
	datCnt = 0;
	$display("Start Simulation");
	ansCnt = 0;
	errCnt = 0;
	A = 0;
	B = 0;
	C = 0;
	# `cycle
	while(ansCnt < `ANS_SIZE) begin
		A		 = datA[datCnt];
		B		 = datB[datCnt];
		C        = datC[datCnt];
		sel 	 = dat_sel[datCnt];
		# (`cycle/2)
		if (alu!== ansMem[ansCnt]) begin
			errCnt = errCnt + 1;
			$display("Correct answer is %d", ansMem[ansCnt]);
			$display("Your answer is %d", alu);
			//$display("Pattern %d is Error", ansCnt);
		end else begin
			$display("Pattern %d is PASS", ansCnt);
		end
		
			ansCnt = ansCnt + 1;
			datCnt = datCnt + 1;
	end
	# `cycle
		$display("Simulation is done");
		$display("There were %d errors", errCnt);
		$finish;
end

endmodule 