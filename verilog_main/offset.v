module OFFSET(addr, cnt, y);
    input signed [12:0] addr;
    input [1:0] cnt;
    output signed [12:0] y;
    
    reg signed [12:0] reg_y;
    assign y =  reg_y;
    
    always@(*)begin
        if(addr < 12'd0)begin
            reg_y = addr;
        end
        else begin
            case(cnt)
                2'd0: reg_y = addr;
                2'd1: reg_y = addr + 13'd64;
                2'd2: reg_y = addr + 13'd128;
                2'd3: reg_y = addr + 13'd128;
                default: reg_y = addr;
            endcase
        end
    end
    
endmodule