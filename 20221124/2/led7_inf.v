module led7_inf (
    input clk,
    input [3:0] idx,
    output reg [6:0] led7_h,
    output reg [6:0] led7_l
);

    //reg [3:0] count;
    //always @(posedge clk, posedge rst) begin
    //if (rst)
    //count <= 0;
    //else if (count == 11)
    //count <= 0;
    //else
    //count <= counter + 1;
    //end

    always @(*) begin
        case (idx)
            4'd0 : {led7_h, led7_l} = {7'b1111110, 7'b1111111};
            4'd1 : {led7_h, led7_l} = {7'b1111101, 7'b1111111};
            4'd2 : {led7_h, led7_l} = {7'b1111111, 7'b1101111};
            4'd3 : {led7_h, led7_l} = {7'b1111111, 7'b1110111};
            4'd4 : {led7_h, led7_l} = {7'b1111111, 7'b1111011};
            4'd5 : {led7_h, led7_l} = {7'b1111111, 7'b1111101};
            4'd6 : {led7_h, led7_l} = {7'b1111111, 7'b1111110};
            4'd7 : {led7_h, led7_l} = {7'b1111111, 7'b1011111};
            4'd8 : {led7_h, led7_l} = {7'b1111011, 7'b1111111};
            4'd9 : {led7_h, led7_l} = {7'b1110111, 7'b1111111};
            4'd10: {led7_h, led7_l} = {7'b1101111, 7'b1111111};
            4'd11: {led7_h, led7_l} = {7'b1011111, 7'b1111111};
            default:
                {led7_h, led7_l} = {7'b1111111, 7'b1111111};
        endcase
    end
endmodule
