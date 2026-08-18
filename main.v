`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2026 10:01:26 PM
// Design Name: 
// Module Name: main
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


module main(
input clk,
input reset,
input startstop,
input [9:0] sw,
output [7:0] sseg,
output [3:0] an
);

wire clk_10ms;
wire clk_1ms;
clkDiv clock(.clk(clk),.clk_10ms(clk_10ms),.clk_1ms(clk_1ms));



stopWatchFSM fsm( 
.clk_10ms(clk_10ms),
.clk_1ms(clk_1ms),
.reset(reset), 
.startstop(startstop),
.inTens(sw[9:6]),
.inOnes(sw[5:2]),
.sw_mode(sw[1:0]),
.an(an), 
.sseg(sseg));




endmodule
