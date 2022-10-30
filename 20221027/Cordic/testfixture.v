
`timescale 1ns/10ps
`define X_FILE "../2/x.dat"
`define Y_FILE "../2/y.dat"
`define THETA_FILE "../2/theta.dat"
`define GAP 10
`define datasize 200
module testfixture;
    reg  signed [31:0] inx, iny;

    wire signed [31:0] out;
    reg  signed [31:0] ans;
    reg  clk, rst;
    integer err, pass;

    arctan u1(inx,iny,out);

    reg [31:0] datxMem [0:`datasize - 1];
    reg [31:0] datyMem [0:`datasize - 1];
    reg [31:0] ansMem  [0:`datasize - 1];

    initial begin
        $timeformat(-9, 1, " ns", 9);
        $readmemb(`X_FILE, datxMem);
        $readmemb(`Y_FILE, datyMem);
        $readmemb(`THETA_FILE, ansMem);
    end

    initial begin
        $display("\n");
        $display("                                     _____          ");
        $display("    **************************      /     \\         ");
        $display("    *                        *      vvvvvvv  /|__/|  ");
        $display("    *       START      !!    *         I   / O.O  | ");
        $display("    *                        *         I /_____   | ");
        $display("    *  Simulation Start!!    *        J|/^ ^ ^ \\  |");
        $display("    *                        *         |^ ^ ^ ^ |w| ");
        $display("    **************************          \\m___m__|_|");
        $display("\n");
    end

    initial begin
        err  <= 0;
        pass <= 0;

        clk <= 0;
        rst <= 1;
        #5;
        rst <= 0;
    end

    always #2 clk = ~clk;

    integer i;
    always @(posedge clk, rst) begin
        if (rst) begin
            inx <= 32'd0;
            iny <= 32'd0;
            i   <=     0;
            ans <=     0;
        end else begin
            for ( ; i < `datasize; i = i + 1) begin
                { inx, iny, ans } <= { datxMem[i], datyMem[i], ansMem[i]};

                #1;
                if ((ans - `GAP) <= out && out <= (ans + `GAP)) begin
                    $display("pass %d",i+1);
                    pass = pass + 1;
                end else begin
                    $display("err %d",i+1);
                    err  = err  + 1;
                end
                #1;
            end
        end
    end

    always @(posedge clk) begin
        if( i >= `datasize ) begin //times == `TIMES + 1
            if(err == 0)begin
                $display("\n");
                $display("        **************************               ");
                $display("        *                        *        /|__/|  ");
                $display("        *     Successful !!      *      / O.O  | ");
                $display("        *                        *    /_____   | ");
                $display("        *  Simulation PASS!!     *   /^ ^ ^ \\  |");
                $display("        *                        *  |^ ^ ^ ^ |w| ");
                $display("        **************************   \\m___m__|_|");
                $display("\n");
            end else begin
                $display("\n");
                $display("        **************************               ");
                $display("        *                        *        /|__/|  ");
                $display("        *  OOPS!!                *      / X,X  | ");
                $display("        *                        *    /_____   | ");
                $display("        *  Simulation Failed!!   *   /^ ^ ^ \\  |");
                $display("        *                        *  |^ ^ ^ ^ |w| ");
                $display("        **************************   \\m___m__|_|");
                $display("         Totally has %d errors                     ", err);
                $display("\n");
            end
            $finish;
        end
    end

endmodule

