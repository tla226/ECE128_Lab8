`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2024 01:45:19 PM
// Design Name: 
// Module Name: Lab8_Q1_UpCounter_tb
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


module Lab8_Q1_UpCounter_tb;
reg clk;
wire [11:0] counter;

Lab8_Q1_UpCounter uut1(clk, counter);



initial begin
clk = 0;
end

always #10 clk = ~clk;

endmodule
