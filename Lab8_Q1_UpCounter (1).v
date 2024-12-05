`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2024 01:37:01 PM
// Design Name: 
// Module Name: Lab8_Q1_UpCounter
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


module Lab8_Q1_UpCounter(
input clk,
output reg [11:0] counter
    );

initial begin
counter = 0;
end

always @(posedge clk) begin
// for overall design: use enable:
// if (en)
    if (counter == 12'b111111111111) 
        counter <= 1'b0;
        
    else
        counter <= counter+1;
end    
endmodule
