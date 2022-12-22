module hw (
    input clk,
    input rst,
    input en,
    input [7:0] a,
    input [7:0] b,

    output reg [7:0] au,
    output reg [7:0] bu,
    output [2:0] state,

    output reg valid,
    output reg [7:0] outcome
);

    reg [2:0] cstate, nstate;
    //reg [7:0] au, bu;
    assign state = cstate;

    localparam St   = 3'd0;
    localparam Sab  = 3'd1;
    localparam Sba  = 3'd2;
    localparam Send = 3'd3;

    always @(posedge clk, posedge rst) begin
        cstate <= (rst)? St:nstate;
    end

    always @(*) begin
        if (rst)
            nstate = St;
        //else if (au == 0 )
        //nstate = Send;
        //else if (bu == 0)
        //nstate = Send;
        else begin
            case (cstate)
                St : nstate = (en)?    Sab:St  ;
                Sab:     begin
                    if (au == 0 )
                        nstate = Send;
                    else if (bu == 0)
                        nstate = Send;
                    else
                        nstate = (au<bu*2)? Sba:Sab ;
                end
                Sba:  begin
                    if (au == 0 )
                        nstate = Send;
                    else if (bu == 0)
                        nstate = Send;
                    else
                        nstate = (bu<au*2)? Sab:Sba ;
                end
                Send: nstate = St;
                default: nstate = St;
            endcase
        end
    end

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            au <= 0;
            bu <= 0;
            //qu <= 0;
        end else begin
            case (cstate)
                St:     begin
                    au <= a;
                    bu <= b;
                end

                Sab:     begin
                    au <= au - bu;
                end

                Sba:     begin
                    bu <= bu - au;
                end

                Send:     begin
                    outcome <= (au == 0)? bu:au;
                end
            endcase
        end
    end

    always @(posedge clk, posedge  rst) begin
        if (rst) begin
            valid <= 0;
        end else if (cstate == Send) begin
            valid <= 1;
        end else     begin
            valid <= 0;
        end
    end

endmodule
