`timescale 1ns/10ps
`define cycle 10
`define terminateCycle 1000000

`define DATA_FILE "./Pattern.dat"
`define ANS_FILE "./Answer.dat"

`define DATA_SIZE 13870
`define ANS_SIZE 1000
`define DATA_LEN 7
`define ANS_LEN 10

module tb;

    reg clk = 0;
    reg rst = 0;
    reg en = 0;
    reg [6:0] variable;

    wire req;
    wire valid;
    wire [9:0] answer;

    reg [20:0] clkCnt = 0;

    integer errCnt, datCnt, ansCnt;

    reg [`DATA_LEN - 1:0] datMem [0:`DATA_SIZE - 1];
    reg [`ANS_LEN - 1:0] ansMem [0:`ANS_SIZE - 1];

    initial begin
        $fsdbDumpfile("stack.fsdb");
        $fsdbDumpvars("+all");
    end

    hw U1(.clk(clk), .rst(rst), .en(en), .variable(variable), .req(req), .valid(valid), .answer(answer));

    initial begin
        $timeformat(-9, 1, " ns", 9);
        $readmemb(`DATA_FILE, datMem);
        $readmemb(`ANS_FILE, ansMem);
    end

    always #(`cycle / 2) clk = ~clk;

    always @(posedge clk) begin
        clkCnt = clkCnt + 1;
        if (clkCnt * 2 > `terminateCycle) begin
            $display("==========================");
            $display("| Failed for simulation! |");
            $display("| Please check your code |");
            $display("==========================");
            $finish;
        end
    end

    initial begin
        rst = 0;
        datCnt = 0;
        $display("Start Simulation");
        # `cycle
        rst = 1;
        # `cycle
        rst = 0;
        while(datCnt < `DATA_SIZE) begin
            wait (req === 1) begin
                @(negedge clk);
                variable = datMem[datCnt];
                en = 1;
                # `cycle
                en = 0;
                variable = 7'd0;
                datCnt = datCnt + 1;
            end
        end
    end

    initial begin
        ansCnt = 0;
        errCnt = 0;
        # `cycle
        # `cycle
        while(ansCnt < `ANS_SIZE) begin
            wait (valid === 1) begin
                @(negedge clk);
                if (answer !== ansMem[ansCnt]) begin
                    errCnt = errCnt + 1;
                    $display("Correct answer is %d", ansMem[ansCnt]);
                    $display("Your answer is %d", answer);
                    $display("Pattern %d is Error", ansCnt);
                end else begin
                    $display("Pattern %d is PA55", ansCnt);
                end
                # `cycle
                ansCnt = ansCnt + 1;
            end
        end
        # `cycle
        $display("Simulation is done");
        $display("There were %d errors", errCnt);
        $finish;
    end

endmodule
