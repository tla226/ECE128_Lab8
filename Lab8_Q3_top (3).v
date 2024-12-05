`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2024 01:54:33 PM
// Design Name: 
// Module Name: Lab8_Q3_top
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


module Lab8_Q3_top(
input clk,
output wire [6:0] seg,
output wire [3:0] anode
    );
reg [15:0] stat_bcd = 16'b0;    
    
wire en;
wire [11:0] bin_in;
wire [15:0] bcd_out;
wire rdy;
wire clk_out;

clk_divider uut1(clk, clk_out);
// give divided clock to all other functions
upCounter uut2(clk_out, en, bin_in);
Lab8_Q2_Bin2BCD uut3(clk_out,en, bin_in, bcd_out,rdy);
multi_seg_driver uut4(clk_out,stat_bcd,anode,seg); // 


always @(posedge clk)
begin
    if(rdy) 
    begin
        stat_bcd <= bcd_out;
    end
end
    
    
endmodule


// upcounter 
module upCounter(

input clk,
output done,
output [11:0] bin_cnt);

parameter c_reg_size = 34;

reg [c_reg_size -1:0] count = 0;
reg fin = 0;
reg old_b = 0;


 always @(posedge clk)
    begin
    count <= count+1;
        if((old_b && !count[c_reg_size-12]) || (!old_b && count[c_reg_size-12]))
            begin
            fin <=1;
            end
        else
            begin
            fin <=0;
            end
         old_b <=count[c_reg_size-12];
         end
     
assign bin_cnt =  count[c_reg_size-1: c_reg_size-12];
assign done = fin;   
    
    
    
endmodule





module clk_divider(clock_in,clock_out
    );
input clock_in; // input clock on FPGA
output reg clock_out; // output clock after dividing the input clock by divisor
reg[27:0] counter=28'd0;
parameter DIVISOR = 28'd2;

always @(posedge clock_in)
begin
 counter <= counter + 28'd1;
 if(counter>=(DIVISOR-1))
  counter <= 28'd0;
 clock_out <= (counter<DIVISOR/2)?1'b1:1'b0;
end
endmodule




module Lab8_Q2_Bin2BCD(
    input clk,
    input en,
    input[11:0] bin_d_in,
    output[15:0] bcd_d_out,
   output rdy
    );
    
parameter IDLE = 3'b000;
parameter SETUP = 3'b001;
parameter ADD= 3'b010;
parameter SHIFT = 3'b011;
parameter DONE  = 3'b100;
    
    //reg [11:0]  bin_data    = 0;
reg [27:0] bcd_data = 0;
reg [2:0] state= 0;
reg busy = 0;
reg [3:0] sh_counter  = 0;
reg [1:0] add_counter = 0;
reg result_rdy  = 0;
    
    
  always @(posedge clk)
        begin
        if(en)
            begin
                if(~busy)
                    begin
                    bcd_data <= {16'b0, bin_d_in};
                    state <= SETUP;
                    end
            end
        
        case(state)
        
            IDLE:
                begin
                    result_rdy <= 0;
                    busy <= 0;
                end
                
            SETUP:
                begin
                busy <= 1;
                state <= ADD;
                end
                    
            ADD:
                begin
                case(add_counter)
                    0:
                        begin
                        if(bcd_data[15:12] > 4)
                            begin
                                bcd_data[27:12] <= bcd_data[27:12] + 3;
                            end
                            add_counter <= add_counter + 1;
                        end
                    
                    1:
                        begin
                        if(bcd_data[19:16] > 4)
                            begin
                                bcd_data[27:16] <= bcd_data[27:16] + 3;
                            end
                            add_counter <= add_counter + 1;
                        end
                        
                    2:
                        begin
                        if((add_counter == 2) && (bcd_data[23:20] > 4))
                            begin
                                bcd_data[27:20] <= bcd_data[27:20] + 3;
                            end
                            add_counter <= add_counter + 1;
                        end
                        
                    3:
                        begin
                        if((add_counter == 3) && (bcd_data[27:24] > 4))
                            begin
                                bcd_data[27:24] <= bcd_data[27:24] + 3;
                            end
                            add_counter <= 0;
                            state   <= SHIFT;
                        end
                    endcase
                end
                
            SHIFT:
                begin
                sh_counter  <= sh_counter + 1;
                bcd_data    <= bcd_data << 1;
                
                if(sh_counter == 11)
                    begin
                    sh_counter  <= 0;
                    state       <= DONE;
                    end
                else
                    begin
                    state   <= ADD;
                    end
                end
            DONE:
                begin
                result_rdy  <= 1;
                state       <= IDLE;
                end
            default:
                begin
                state <= IDLE;
                end
            endcase
        end
    assign bcd_d_out = bcd_data[27:12];
   assign rdy = result_rdy;
endmodule



module multi_seg_driver(
input clk,
 input [15:0] bcd_in,
 output [3:0] sseg_a_o,
 output [6:0] sseg_c_o);

wire [6:0] sseg_o;
wire [3:0] anode;
wire en;
wire [3:0] bcd_seg;

//Seven_seg_decoder uut1(clk, bcd_seg,sseg_o);
anode_generator uut1(clk, en, anode);
mux uut2(anode, bcd_seg, en, bcd_in, sseg_a_o);
BCD_7seg ss_dec(clk, bcd_seg, sseg_c_o);

endmodule

module anode_generator(clk,en,anode);
input clk;
output reg en;
output [3:0] anode = 4'b0001;
reg [3:0] bcd_seg = 4'b0000;
reg [3:0] anode = 4'b0001;

parameter g_s = 5;
parameter gt = 4;
reg [g_s-1:0] g_count = 0;



always @(posedge clk)
    begin
    g_count = g_count+1;
        if(g_count == 0)
            begin
            if(anode == 4'b0001)
                begin
                anode = 4'b1000;
                end  
            else
                begin
                anode = anode >>1;
                end
             end
             end
        always @(posedge clk)
        begin
        if (&g_count[g_s-1:gt])
        begin
        en = 1'b1;
        end
        else
        en = 1'b0;
      end
  endmodule
 
module mux(anode, bcd_seg,en,bcd_in,sseg_a_o);
input [15:0] bcd_in;
 output [3:0] sseg_a_o;
 input [3:0] anode;
 output reg [3:0] bcd_seg;
 input en;
 
    always @(*)
    begin
        if (en)
            begin
            case(anode)
                4'b1000: bcd_seg = bcd_in[15:12];
                4'b0100: bcd_seg = bcd_in[11:8];
                4'b0010: bcd_seg = bcd_in[7:4];
                4'b0001: bcd_seg = bcd_in[3:0];
                default : bcd_seg = 4'b1111;
            endcase
            end
          end
assign sseg_a_o = ~anode;
       
endmodule          


module BCD_7seg(
    input clk,
    input [3:0] num,
    output reg [6:0] out
    );
   
    always @(posedge clk)
    begin
        case (num)
            4'b0000: out = 7'b1000000; // 0
            4'b0001: out = 7'b1111001; // 1
            4'b0010: out = 7'b0100100; // 2
            4'b0011: out = 7'b0110000; // 3
            4'b0100: out = 7'b0011001; // 4
            4'b0101: out = 7'b0010010; // 5
            4'b0110: out = 7'b0000010; // 6
            4'b0111: out = 7'b1111000; // 7
            4'b1000: out = 7'b0000000; // 8
            4'b1001: out = 7'b0010000; // 9
            default: out = 7'b1111111; // turn it off
            endcase
         end
                     
endmodule



 

