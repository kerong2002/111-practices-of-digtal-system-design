module signed_mult(
	input clk,
	input reset,
	input [10:0] m,
	input [10:0] r,
	output [21:0] out,
	output valid
	);

	reg [22:0] p;
	reg [3:0] cnt;
	reg [1:0] state, nstate;
	
	wire [10:0] add;
	wire [10:0] minus;
	wire [10:0] m_2;
	assign m_2 = ~m + 11'd1;
	
	assign minus = p[22:12] + m_2;
	assign add = p[22:12] + m;

	parameter IDLE  = 2'd0;
	parameter CAL   = 2'd1;
	parameter SHIFT = 2'd2;
	parameter DONE  = 2'd3;
	
	assign valid = (state == DONE) ? 1'b1 : 1'b0;
	assign out = p[22:1];

	always@(posedge clk, posedge reset)begin
		if(reset)begin
			state <= IDLE;
		end
		else begin
			state <= nstate;
		end
	end
	
	always@(*)begin
		case(state)
			IDLE:	nstate = CAL;
			CAL: 	nstate = SHIFT;
			SHIFT:	nstate = (cnt == 4'd10) ? DONE : CAL;
			DONE:   nstate = DONE;
			default:nstate = IDLE;
		endcase
	end

	always@(posedge clk, posedge reset)begin
		if(reset)begin
			p <= 23'd0;
		end
		else begin
			case(state)
				IDLE: p <= {11'd0, r, 1'b0};
				CAL:begin
					case(p[1:0])
						2'b01:begin
							p <= {add, p[11:0]};
						end
						2'b10:begin
							p <= {minus, p[11:0]};
						end
					endcase
				end
				SHIFT: p <= {p[22], p[22:1]};
			endcase
		end
	end

	always@(posedge clk, posedge reset)begin
		if(reset)begin
			cnt <= 4'd0;
		end
		else begin
			case(state)
				IDLE:	cnt <= 4'd0;
				SHIFT:  cnt <= cnt + 4'd1;
			endcase
		end
	end
	
endmodule
