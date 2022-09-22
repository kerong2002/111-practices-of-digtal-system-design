module counter(CLK,en,count);
input CLK,en ; 
output [3:0] count; 
reg [3:0] count; 

always@(posedge CLK)
	begin 
	if(!en) 
		count<=4'b0; //nonblocking 
	else 
		count<=count+ 1;
	end 
	
endmodule 
