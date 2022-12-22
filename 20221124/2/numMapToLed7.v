module numMapToLed7(
    input [3:0] value ,
    output [6:0] LED7
);

    wire [6:0] map_led7 [15:0] ;
    assign map_led7[0] =  7'b0111111;
    assign map_led7[1] =  7'b0000110;
    assign map_led7[2] =  7'b1011011;
    assign map_led7[3] =  7'b1001111;
    assign map_led7[4] =  7'b1100110;
    assign map_led7[5] =  7'b1101101;
    assign map_led7[6] =  7'b1111100;
    assign map_led7[7] =  7'b0000111;
    assign map_led7[8] =  7'b1111111;
    assign map_led7[9] =  7'b1100111;

    assign map_led7[10] = 7'b1110111;
    assign map_led7[11] = 7'b1111100;
    assign map_led7[12] = 7'b0111001;
    assign map_led7[13] = 7'b1011110;
    assign map_led7[14] = 7'b1111001;
    assign map_led7[15] = 7'b1110001;

    assign LED7 = ~map_led7[value];

endmodule
