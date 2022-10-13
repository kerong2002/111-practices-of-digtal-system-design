module square(clk, rst, en, order, valid, sum);
	input clk, rst, en;
	input[3:0] order;
	output reg valid;
	output reg [10:0] sum;
	reg[4:0] now_state;
	reg[4:0] next_state;
	reg[1:0] v_nowState;
	reg[1:0] v_nextState;
	reg[4:0] store;
	reg[10:0] prev_data;
	always@(posedge clk, posedge rst)begin
		if(rst)begin
			now_state <= 0;
			end
		else begin
			now_state <= next_state;
		end
	end
	always@(posedge en, posedge rst)begin
		if (rst)begin
			store <= 0;
		end
		else if (en)begin
			store <= {1'b0, order};
		end
	end
	
	always@(*)begin
		if (v_nowState != 2'd1) begin
			case(now_state)
				5'd0:next_state=5'd1;
				5'd1:next_state=5'd2;
				5'd2:next_state=5'd3;
				5'd3:next_state=5'd4;
				5'd4:next_state=5'd5;
				5'd5:next_state=5'd6;
				5'd6:next_state=5'd7;
				5'd7:next_state=5'd8;
				5'd8:next_state=5'd9;
				5'd9:next_state=5'd10;
				5'd10:next_state=5'd11;
				5'd11:next_state=5'd12;
				5'd12:next_state=5'd13;
				5'd13:next_state=5'd14;
				5'd14:next_state=5'd15;
				5'd15:next_state=5'd16;
				default:next_state=5'd16;
			endcase
		end
		else begin
			next_state <= 5'd16;
		end
		
	end
	
	always@(posedge clk, posedge rst)begin
		if (rst)begin
			prev_data <= 0;
		end
		else begin
			prev_data <= sum;
		end
	end
	
	always@(now_state)begin
		if (now_state != 5'd16)begin
			sum = prev_data + (now_state * now_state);
		end
		else if (valid)begin
			sum = prev_data;
		end
		else begin
			sum = 0;
		end
	end
	/*
	always@(*)begin
		case(now_state)
        5'd1:sum=11'd1;
        5'd2:sum=11'd5;
        5'd3:sum=11'd14;
        5'd4:sum=11'd30;
        5'd5:sum=11'd55;
        5'd6:sum=11'd91;
        5'd7:sum=11'd140;
        5'd8:sum=11'd204;
        5'd9:sum=11'd285;
        5'd10:sum=11'd385;
        5'd11:sum=11'd506;
        5'd12:sum=11'd650;
        5'd13:sum=11'd819;
        5'd14:sum=11'd1015;
        5'd15:sum=11'd1240;
		  default:sum=11'd0;
		endcase
	end
	*/
	
	always@(posedge clk, posedge rst)begin
		if (rst)begin
			v_nowState <= 0;
		end
		else begin
			v_nowState <= v_nextState;
		end
	end
	
	always@(*)begin
	
		case(v_nowState)
			2'd0:v_nextState = (now_state==store) ? 2'd1 : 2'd0;
			2'd1:v_nextState = 2'd2;
			2'd2:v_nextState = 2'd2;
			default:v_nextState = 2'd0;
		endcase
		
	end
	
	always@(*)begin
		case(v_nowState)
			2'd0:valid=0;
			2'd1:valid=1;
			2'd2:valid=0;
			default:valid=0;
		endcase
	end
endmodule