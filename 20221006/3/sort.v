module sort(clk,rst,en,num,valid,out);
input clk,rst,en;
input [3:0] num;
output reg valid;
output reg [39:0] out;

reg [3:0] even[9:0];
reg [3:0] data[9:0];
reg [3:0] counter,run,temp,add_to_ten,even_counter;
reg [3:0] even_run;
integer x,y;
always @(posedge clk)begin
	if(rst)begin
		out=40'd0;
		valid=1'b0;
		for(y=0;y<=9;y=y+1)begin
			data[y]=4'b0000;
			even[y]=4'b0000;
		end
		even_run=4'b0000;
		counter=4'b0000;
		run=4'b0000;
		add_to_ten=4'b1010;
		even_counter<=4'b0000;
	end
	else begin
		if(en)begin
			data[counter]=num;
			if(num[0]==0)begin
				even[even_counter]=num;
				//out={out[35:0],num};
				even_counter=even_counter+1'b1;
				add_to_ten=add_to_ten-1'b1;
			end
			counter=counter+1'b1;
		end
		else begin
			if(run==0)begin
				for(y=0;y<10;y=y+1)begin
					for(x=y+1;x<10;x=x+1)begin
						if(even[y]>even[x])begin
							temp=even[y];
							even[y]=even[x];
							even[x]=temp;
						end
					end
				end
				run=run+1;
			end
			else if(run==1)begin
				if(add_to_ten)begin
					even[0]=even[1];
					even[1]=even[2];
					even[2]=even[3];
					even[3]=even[4];
					even[4]=even[5];
					even[5]=even[6];
					even[6]=even[7];
					even[7]=even[8];
					even[8]=even[9];
					even[9]=4'b0000;
					add_to_ten=add_to_ten-1'b1;
				end
				else begin
					run=run+1;
					
				end
			end
			else if(run==2)begin
				for(y=0;y<=9;y=y+1)begin
					if(data[y][0]==0)begin
						out={out[35:0],even[even_run]};
						even_run=even_run+1;
					end
					else begin
						out={out[35:0],data[y]};
					end
				end
				valid=1'b1;
				run=run+1;
			end
		end
	end
end

endmodule 