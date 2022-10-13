module LFSR_sort(clk,rst,num_temp,out0,out1,out2,out3,out4,out5,out6,out7);
input clk,rst;
output reg [7:0] num_temp;
output reg [7:0] out0,out1,out2,out3,out4,out5,out6,out7;
reg [1:0]state,nextstate;
reg [3:0] count;
reg sort_done;
reg [7:0] save [7:0];
reg [7:0] temp;
reg [7:0] tempY;
reg [7:0] tempX;
reg [3:0] x_pos;
reg [3:0] y_pos;
reg [3:0] sort_counter;
reg sort_valid ;
reg change_ok;
parameter input_data=2'b00;
parameter sort_data=2'b01;
parameter output_data=2'b10;

//previous_state
always@(posedge clk, posedge rst)begin
	if(rst)begin
		state<=input_data;
	end
	else begin
		state<=nextstate;
	end
end
//next_state
always @(*)begin
	case(state)
		input_data:begin
			if(count<4'd8)begin
				nextstate=input_data;
			end
			else begin
				nextstate=sort_data;
			end
		end
		sort_data:begin
			if(sort_valid)begin
				nextstate=sort_data;
			end
			else begin
				nextstate=output_data;
			end
		end
		output_data:begin
			nextstate=output_data;
		end
		default:begin
			nextstate=input_data;
		end
	endcase
end
integer y,x;
//data
always @(posedge clk,posedge rst)begin
	if(rst)begin
		num_temp<=8'hF1;
		count<=4'b0000;
		for(y=0;y<8;y=y+1)begin
			save[y]<=7'd0;
		end
		sort_valid<=1'b1;
	end
	else if(state==input_data)begin
		num_temp={num_temp[6:0],num_temp[0]^num_temp[2]};
		save[count]<=num_temp;
		count<=count+1'b1;
	end
	else if(state==sort_data)begin
		for(x=0;x<7;x=x+1) begin
			if(save[x]>save[x+1]) begin
				save[x]<=save[x+1];
				save[x+1]<=save[x];
			end
	  end
	  if(sort_counter==0) begin
        sort_valid<=1'b0;
    end
	end
	else if(state==output_data)begin
		out0<=save[0];
		out1<=save[1];
		out2<=save[2];
		out3<=save[3];
		out4<=save[4];
		out5<=save[5];
		out6<=save[6];
		out7<=save[7];
	end
end
always @(posedge clk,posedge rst)begin
	if(rst)begin
		sort_counter<=4'b1000;
	end
	else begin
		if(sort_valid == 1) begin
			sort_counter <= sort_counter - 1;
		end
	end
end
endmodule 