`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2024 03:05:43 PM
// Design Name: 
// Module Name: Lab8_Q2_Bin2Bcd_tb
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


module Lab8_Q2_Bin2Bcd_tb;
reg clk;
reg [11:0] bcd_in;
reg en;
wire [15:0] bcd_out;
wire rdy;


Lab8_Q2_Bin2Bcd uut1(clk, bcd_in, en, bcd_out, rdy);

initial begin
    clk = 1'b0;
    bcd_in = 12'b010101010101;
    en = 1;
    #1500;
    bcd_in = 12'b000100100011;
    #1500;
end


always #10 clk = ~clk;
/*
initial begin
bcd_in = 12'b000000011111;
end
*/
endmodule
