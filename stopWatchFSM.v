`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2026 10:42:30 PM
// Design Name: 
// Module Name: stopWatchFSM
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


module stopWatchFSM(
input clk_10ms,
input clk_1ms,
input reset,
input startstop,
input [3:0] inTens,
input [3:0] inOnes,
input [1:0] sw_mode,
output reg [3:0] an,
output [7:0] sseg
);


reg[3:0] ms_2;
reg[3:0] ms;
reg[3:0] s;
reg[3:0] s_2;

reg start = 1'b0;
reg startStop_prev;



always @(posedge clk_10ms) begin
startStop_prev <=startstop;
if ((startstop == 1'b1)&&(startStop_prev==1'b0))
    start <= !(start);
else
    start <= start;
if(reset == 1'b1) begin
    if(sw_mode == 2'b00) begin
    s_2 <= 4'b0000; s <= 4'b0000; ms <= 4'b0000; ms_2 <= 4'b0000;
    end
    else if(sw_mode ==2'b01) begin
    s_2 <= 4'b1001; s <= 4'b1001; ms <= 4'b1001; ms_2 <= 4'b1001;
    end
    else if(sw_mode == 2'b10) begin
    s_2 <= inTens; s <= inOnes; ms <= 4'b0000; ms_2 <= 4'b0000;
    end
    else if(sw_mode ==2'b11) begin
    s_2 <= inTens; s <= inOnes; ms <= 4'b0000; ms_2 <= 4'b0000;
    end
end
else if(((sw_mode == 2'b00)||(sw_mode == 2'b10))&&(start == 1'b1)) begin
    if({s_2,s,ms,ms_2}!=16'h9999) begin
        if (ms_2 == 4'd9) begin
            ms_2 <= 4'd0;
            if (ms == 4'd9) begin
                ms <= 4'd0;
                if (s == 4'd9) begin
                    s <= 4'd0;
                    s_2 <= s_2 + 1'b1;
                end else s <= s + 1'b1;
            end else ms <= ms + 1'b1;
        end else ms_2 <= ms_2 + 1'b1;   
    end
    else begin
        ms_2 <= ms_2;
        ms <= ms;
        s <= s;
        s_2 <= s_2;
    end
end
else if(((sw_mode == 2'b01)||(sw_mode ==2'b11))&&(start == 1'b1)) begin
    if({s_2,s,ms,ms_2}!=16'h0000) begin
        if (ms_2 == 4'd0) begin
            ms_2 <= 4'd9;
            if (ms == 4'd0) begin
                ms <= 4'd9;
                if (s == 4'd0) begin
                    s <= 4'd9;
                    s_2 <= s_2 - 1;
                end else s <= s - 1;
            end else ms <= ms - 1;
        end else ms_2 <= ms_2 - 1;      
    end
    else begin
        ms_2 <= ms_2;
        ms <= ms;
        s <= s;
        s_2 <= s_2;
    end
end
end





reg[1:0] select = 2'b00;

always@(posedge clk_1ms) begin
select <= select+1;
end
reg[3:0] current_bcd;
reg decimal;

always @(*) begin
    case(select)
    2'b00: begin
        current_bcd = ms_2;
        an = 4'b1110;
        decimal = 1;
    end
    2'b01: begin
        current_bcd = ms;
        an = 4'b1101;
        decimal = 1;
    end
    2'b10: begin
        current_bcd = s;
        an = 4'b1011;
        decimal = 0;
    end
    2'b11: begin
        current_bcd = s_2;
        an = 4'b0111;
        decimal = 1;
    end
    endcase
end

hexto7segment seg(.x(current_bcd), .sseg(sseg), .decimal(decimal));



endmodule
