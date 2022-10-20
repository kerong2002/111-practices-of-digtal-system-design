
module hw (
    input clk,
    input rst,
    input en ,
    input [6:0] variable,
    output reg req,
    output reg valid,
    output reg [9:0] answer
);

    localparam op_read   = 3'd0;
    localparam op_Lshift = 3'd1;
    localparam op_Rshift = 3'd2;
    localparam op_mul    = 3'd3;
    localparam op_add    = 3'd4;
    localparam op_sub    = 3'd5;
    localparam op_eq     = 3'd6;

    reg [9:0] stack[0:4];

    reg [2:0] cmd;
    reg [3:0] num;
    always @(posedge clk, posedge rst) begin
        if (rst)
            { cmd, num } = 7'd0;
        else
            { cmd, num } = variable;
    end

    reg [9:0] top1, top2;
    always @(*) begin
        { top1, top2 } = { stack[4], stack[3] };
    end

    reg [9:0] cal_Lshift ;
    reg [9:0] cal_Rshift ;
    reg [9:0] cal_mul    ;
    reg [9:0] cal_add    ;
    reg [9:0] cal_sub    ;
    always @(*) begin
        cal_Lshift = top2 << top1;
        cal_Rshift = top2 >> top1;
        cal_mul    = top2  * top1;
        cal_add    = top2  + top1;
        cal_sub    = top2  - top1;
    end

    localparam s_t      = 3'd7;

    localparam s_read   = 3'd0;
    localparam s_Lshift = 3'd1;
    localparam s_Rshift = 3'd2;
    localparam s_mul    = 3'd3;
    localparam s_add    = 3'd4;
    localparam s_sub    = 3'd5;
    localparam s_eq     = 3'd6;
    reg [3:0] cstate, nstate;
    always @(posedge clk, posedge rst)
        cstate = (rst)? s_t:nstate;
    always @(*) begin
        case (cstate)
            s_t      : nstate = s_read;
            s_read   : begin
                case (cmd)
                    s_read   : nstate = s_read  ;
                    s_Lshift : nstate = s_Lshift;
                    s_Rshift : nstate = s_Rshift;
                    s_mul    : nstate = s_mul   ;
                    s_add    : nstate = s_add   ;
                    s_sub    : nstate = s_sub   ;
                    s_eq     : nstate = s_eq    ;
                endcase
            end
            s_Lshift : nstate = s_read;
            s_Rshift : nstate = s_read;
            s_mul    : nstate = s_read;
            s_add    : nstate = s_read;
            s_sub    : nstate = s_read;
            s_eq     : nstate = s_read;

        endcase
    end

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            req <= 0;
        end else case (cstate)
            s_t      : req <= 0;
            s_read   : req <= 1;
            s_Lshift : req <= 0;
            s_Rshift : req <= 0;
            s_mul    : req <= 0;
            s_add    : req <= 0;
            s_sub    : req <= 0;
            s_eq     : req <= 0;
        endcase
    end

    integer ia;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            for ( ia = 0; ia < 5; ia = ia + 1) begin
                stack[ia] <= 0;
            end
        end else if (en) begin
            case (cmd)
                op_read   : begin
                    if (en) begin
                        stack[0] <= stack[1];
                        stack[1] <= stack[2];
                        stack[2] <= stack[3];
                        stack[3] <= stack[4];
                        stack[4] <= num;
                    end
                end
                op_Lshift : begin
                    stack[0] <= 10'd0      ;
                    stack[1] <= stack[0]   ;
                    stack[2] <= stack[1]   ;
                    stack[3] <= stack[2]   ;
                    stack[4] <= cal_Lshift ;
                end
                op_Rshift : begin
                    stack[0] <= 10'd0      ;
                    stack[1] <= stack[0]   ;
                    stack[2] <= stack[1]   ;
                    stack[3] <= stack[2]   ;
                    stack[4] <= cal_Rshift ;
                end
                op_mul    : begin
                    stack[0] <= 10'd0      ;
                    stack[1] <= stack[0]   ;
                    stack[2] <= stack[1]   ;
                    stack[3] <= stack[2]   ;
                    stack[4] <= cal_mul ;
                end
                op_add    : begin
                    stack[0] <= 10'd0      ;
                    stack[1] <= stack[0]   ;
                    stack[2] <= stack[1]   ;
                    stack[3] <= stack[2]   ;
                    stack[4] <= cal_add ;
                end
                op_sub    :begin
                    stack[0] <= 10'd0      ;
                    stack[1] <= stack[0]   ;
                    stack[2] <= stack[1]   ;
                    stack[3] <= stack[2]   ;
                    stack[4] <= cal_sub ;
                end
            endcase
        end
    end

    always @(*) begin
        answer = top1;
    end

    always @(*) begin
        if (cmd == op_eq)
            valid = 1;
        else
            valid = 0;
    end


endmodule

