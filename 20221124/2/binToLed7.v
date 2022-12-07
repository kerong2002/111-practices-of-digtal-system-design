`include "./binToBcd.v"
`include "./numMapToLed7.v"

module binToLed7_4 (
    input [15:0] bin,
    output [27:0] hex7_4
);

    wire [3:0] bcd[3:0];
    binToBcd4 c(bin, {bcd[3], bcd[2], bcd[1], bcd[0]});
    wire [6:0] hex[3:0];
    numMapToLed7 hex0(bcd[0], hex[0]);
    numMapToLed7 hex1(bcd[1], hex[1]);
    numMapToLed7 hex2(bcd[2], hex[2]);
    numMapToLed7 hex3(bcd[3], hex[3]);

    assign hex7_4 = {hex[3], hex[2], hex[1], hex[0]};

endmodule
