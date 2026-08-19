`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2026 09:55:33 PM
// Design Name: 
// Module Name: hexto7segment
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hexto7segment(
input [3:0] x,
input decimal,
output reg [7:0] sseg
 );

always @(*) begin
    case(x)
    4'b0000: sseg[6:0] = 7'b0000001;
    4'b0001: sseg[6:0] = 7'b1001111;
    4'b0010: sseg[6:0] = 7'b0010010;
    4'b0011: sseg[6:0] = 7'b0000110;
    4'b0100: sseg[6:0] = 7'b1001100;
    4'b0101: sseg[6:0] = 7'b0100100;
    4'b0110: sseg[6:0] = 7'b0100000;
    4'b0111: sseg[6:0] = 7'b0001111;
    4'b1000: sseg[6:0] = 7'b0000000;
    4'b1001: sseg[6:0] = 7'b0000100;
    4'b1010: sseg[6:0] = 7'b0001000;
    4'b1011: sseg[6:0] = 7'b1100000;
    4'b1100: sseg[6:0] = 7'b0110001;
    4'b1101: sseg[6:0] = 7'b1000010;
    4'b1110: sseg[6:0] = 7'b0110000;
    4'b1111: sseg[6:0] = 7'b0111000;
    default: sseg[6:0] = 7'b0111000;
endcase
sseg[7] = decimal;
end
endmodule