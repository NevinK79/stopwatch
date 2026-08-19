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
output reg tick_10ms = 1'b0, tick_1ms = 1'b0
    );
reg [19:0] MSCOUNT = 20'd999999;
reg[16:0] MILICOUNT = 17'd99999;

always @(posedge clk) begin
if(MSCOUNT == 0)begin
    MSCOUNT <= 20'd999999;
    tick_10ms <= 1'b1;
  end
else begin
  MSCOUNT <= MSCOUNT-1;
  tick_10ms <=1'b0;
  end
end

always @(posedge clk) begin
if(MILICOUNT == 0) begin
    MILICOUNT <= 17'd99999;
    tick_1ms <= 1'b1;
 end
else begin
  MILICOUNT <= MILICOUNT-1;
  tick_1ms <= 1'b0;
  end
end
endmodule