`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2024 02:05:32 PM
// Design Name: 
// Module Name: Lab8_Q2_Bin2Bcd
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


module Lab8_Q2_Bin2Bcd(
input clk,
input [11:0] bcd_in,
input en,
output [15:0] bcd_out,
output rdy
    );

reg [27:0] bcd_data = 0;

parameter IDLE = 3'b000;
parameter SETUP = 3'b001;
parameter ADD = 3'b010;
parameter SHIFT = 3'b011;
parameter DONE = 3'b100;
reg [2:0] PS, NS;
reg busy = 0;
reg [3:0] shift_counter = 0;
reg [1:0] add_counter = 0;
reg out_rdy = 0;
reg sh_enable = 1;

reg latch_bcd = 0;





always@(posedge clk)
begin
/*
In sequential block, send output signals of counters and shifts to update the value in memory,
then sends it back to the combinational block 
*/

if (~busy)
begin
    PS = IDLE;
end

if (latch_bcd) begin
    bcd_data <= {16'b0, bcd_in};
end

PS <= NS;
case(add_counter)
        0: begin
          if(bcd_data[15:12] > 4)begin // on LHS : bcd_data[27:12] 
                 bcd_data[27:12] = bcd_data [27:12] + 3; 
                end
                add_counter <= add_counter + 1;
                latch_bcd = 0; 
            end
        1: begin
           if (bcd_data[19:16] > 4) begin // LHS: bcd_data [27:16]
                bcd_data [27:16] = bcd_data[27:16] + 3;
                end
                add_counter <= add_counter + 1; 
        end
        2: begin
           if (bcd_data[23:20] > 4)begin // bcd_data [27:20]
                bcd_data [27:20] = bcd_data[27:20] + 3;
                end
                add_counter <= add_counter + 1; 
        end
        3: begin
           if (bcd_data[27:24] > 4)begin // bcd_data[27:24]
                bcd_data[27:24] = bcd_data[27:24] + 3;
                end
                add_counter <= 0;
           end
       endcase

if (sh_enable == 1) begin
    //if gets enable signal
    // do the shift 
    // change value of shfit counter
    shift_counter <= shift_counter + 1;
    bcd_data <= bcd_data<<1;
    sh_enable <= 0;
    if (shift_counter == 11)begin
        shift_counter <= 0;
     end
end




/*
case(add_counter)
    0:begin
        bcd_data_sum[15:0] <= bcd_data_sum[15:0];
        add_counter <= add_counter + 1; 
    end
    1: begin
        bcd_data_sum[15:0] <= {bcd_data_sum[15:4], bcd_data[15:12]};
        add_counter <= add_counter + 1;         
    end
    2: begin
        bcd_data_sum[15:0] <= {bcd_data_sum[15:8], bcd_data[15:8]};
        add_counter <= add_counter + 1; 

    end
    3:begin
        bcd_data_sum[15:0] <= {bcd_data_sum[15:12], bcd_data[15:4]};
        add_counter <= 0;
    end
endcase
*/


    
end

// Combinational block should do 1 clock cycles worth of work at a time.
always @(*) begin


        case (PS)
            IDLE : out_rdy = 0;
            SETUP : out_rdy = 0;
            ADD : out_rdy = 0;
            SHIFT : out_rdy = 0;
            DONE : out_rdy = 1;
        endcase
    

        case (PS)
            IDLE: begin
                if(en)
                    begin
                        latch_bcd = 1;
                        NS = SETUP;
                    end
                 busy = 1;
            end
            SETUP: begin
                //busy = 1;
                latch_bcd = 0;
                NS = ADD;
                end
            ADD: begin
                latch_bcd = 0;
                 case(add_counter)
                    0:begin
                    end
                    1:begin
                    end
                    2:begin
                    end
                    3:begin
                        NS = SHIFT;
                    end
                    endcase
                   /*
                    case(add_counter)
                        0: begin
                          if(bcd_data[15:12] > 4)begin // on LHS : bcd_data [27:12] 
                                bcd_data_sum[15:0] = bcd_data [27:12] + 3; 
                                end
                                //add_counter = add_counter + 1;
                            end
                        1: begin
                           if (bcd_data[19:16] > 4) begin // LHS: bcd_data [27:16]
                                bcd_data_sum[15:4] = bcd_data[27:16] + 3;
                                end
                                //add_counter = add_counter + 1;
                        end
                        2: begin
                           if (bcd_data[23:20] > 4)begin // bcd_data [27:20]
                                bcd_data_sum[15:8] = bcd_data[27:20] + 3;
                                end
                                //add_counter = add_counter + 1;
                        end
                        3: begin
                           if (bcd_data[27:24] > 4)begin // bcd-data [27:24]
                                bcd_data_sum[15:12] = bcd_data[27:24] + 3;
                                end
                                //add_counter = 0;
                                NS = SHIFT;
                           end
                       endcase*/
                      end
                     
            SHIFT: begin
                latch_bcd = 0;
            /*
               shift_counter = shift_counter + 1;
               bcd_data = bcd_data << 1;
              */
               sh_enable = 1; 
               // send enable signal from here
               if (shift_counter == 11)
               begin
                    NS = DONE;
                    //shift_counter = 0;
               end     
                    else 
                    begin
                    NS = ADD;
                    end
            end
            DONE: begin
                latch_bcd = 0;
                //bcd_out = bcd_data[27:12];
                out_rdy = 1;
                NS = IDLE;
                end
            default:
            begin
            NS = IDLE;
            end         
            
       endcase         
    end

assign bcd_out = bcd_data[27:12];
assign rdy = out_rdy;

            
endmodule
