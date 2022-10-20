`timescale 1ns/10ps
`define cycle 10
`define PAT "./IN2.DAT"
`define ANS_SIZE 1033
module tb;
	reg CLK, RESET_;
	reg[7:0] Xi, Yi;
	wire READY_;
	reg[3:0] Wi;
	wire[7:0] Xc, Yc;
	reg [39:0]DATA[0:1033];
	initial $readmemh(`PAT, DATA);
	integer k;
	integer ansCnt, errCnt, cnt, cnt2;

GCC t1(
	.CLK(CLK),
	.RESET_(RESET_),
	.Xi(Xi),
	.Yi(Yi),
	.READY_(READY_),
	.Wi(Wi),
	.Xc(Xc),
	.Yc(Yc)
	);

initial begin
	cnt = 0;
	CLK = 1;
	RESET_ = 1;
	#5
	RESET_ = 0;
	#10
	RESET_ = 1;
end
initial begin
	#17.5
	forever begin
		cnt = cnt + 1;
		Xi = DATA[cnt][39:32];
		Yi = DATA[cnt][31:24];
		Wi = DATA[cnt][23:16];
		#10;
	end
end

always #(`cycle/2) CLK = ~CLK;


initial begin
	cnt2 = 1;
	ansCnt = 0;
	errCnt = 0;
	while(ansCnt < `ANS_SIZE) begin
		wait (READY_ === 0) begin
			@(negedge CLK);
				if (Xc !== DATA[cnt2][15:8] || Yc !== DATA[cnt2][7:0]) begin
					errCnt = errCnt + 1;
					$display("Correct answer is Xc : %h, Yc : %h", DATA[cnt2][15:8], DATA[cnt2][7:0]);
					$display("Your answer is Xc : %h, Yc : %h", Xc, Yc);
					$display("Pattern %d is Error", ansCnt);
				end else begin
					$display("Pattern %d is PA55", ansCnt);
				end
			# `cycle
				ansCnt = ansCnt + 1;
				cnt2 = cnt2 + 1;
		end
	end
	# `cycle
		$display("Simulation is done");
		$display("There were %d errors", errCnt);
		$finish;
end

endmodule