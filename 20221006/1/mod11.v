module mod11(clk_in,rst,clk_out);
 
input clk_in;
input rst;
output clk_out;
 
reg [3:0] pos_count, neg_count;
 
always @(posedge clk_in, posedge rst)
if (rst)
pos_count <=0;
else if (pos_count ==10) pos_count <= 0;
else pos_count<= pos_count +1;
 
always @(negedge clk_in, posedge rst)
if (rst)
neg_count <=0;
else  if (neg_count ==10) neg_count <= 0;
else neg_count<= neg_count +1;

assign clk_out = ((pos_count > 5) | (neg_count > 5));
endmodule
