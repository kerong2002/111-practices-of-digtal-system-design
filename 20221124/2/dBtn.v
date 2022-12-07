//will output logic "HIGH" when press the button.
//
////==============<防彈跳>==================
module KEY_Debounce(CLK, RST, KEY_In, KEY_Out); 
	parameter DeB_Num = 4; 		// 取樣次數
	parameter DeB_SET = 4'b0000; // 設置
	parameter DeB_RST = 4'b1111; // 重置 

	input CLK, RST;
	input KEY_In;
	output KEY_Out; 
	reg rKEY_Out = 1'b1;
	reg [DeB_Num-1:0] Bounce = 4'b1111; // 初始化 
	integer i;
	always @(posedge CLK or negedge RST) begin // 一次約200Hz 5ms
		if(!RST)begin
			Bounce <= DeB_RST; // Bounce重置
		end
		else begin // 取樣4次
			Bounce[0] <= KEY_In;
			for(i=0;i<DeB_Num-1;i=i+1)begin
				Bounce[i+1] <= Bounce[i];
			end
		end
		case(Bounce)
			DeB_SET: rKEY_Out = 1'b0;
			default: rKEY_Out = 1'b1;
		endcase
	end 
	
	assign KEY_Out = rKEY_Out; 
	
endmodule 

module dBtn(clk50M, rst_, KEY, pKEY);
    input clk50M, rst_, KEY;
    output pKEY;
    wire clk;
    assign clk = clk50M;
    wire rst;
    assign rst = rst_;
    reg _KEY;
    assign pKEY = _KEY;
    reg [9:0] count;
    always@(posedge clk, negedge rst)begin
        if (!rst)begin
            count <= 0;
            _KEY <= 1;
        end else begin
            if (count>=1000)begin
                count<=0;
                _KEY<=KEY;
            end
            else if(_KEY^KEY) count<=count+1;
            else count<=0;
        end
    end
endmodule
