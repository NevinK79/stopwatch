`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2026 10:02:33 PM
// Design Name: 
// Module Name: clkDiv
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


module clkDiv(
input clk,
output clk_10ms,
output clk_1ms
    );
reg [19:0] MSCOUNT = 20'd999999;
reg[16:0] MILICOUNT = 17'd99999;

assign clk_10ms = (MSCOUNT<=499999)? 1'b1:1'b0;
assign clk_1ms = (MILICOUNT<=49999)? 1'b1:1'b0;

always @(posedge clk) begin
if(MSCOUNT == 0)
    MSCOUNT <= 20'd999999;
else
  MSCOUNT <= MSCOUNT-1;
end

always @(posedge clk) begin
if(MILICOUNT == 0)
    MILICOUNT <= 17'd99999;
else
  MILICOUNT <= MILICOUNT-1;
end
endmodule
