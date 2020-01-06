`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SNU
// Engineer: JHYeom (zhixian001)
// 
// Create Date: 2019/03/25 17:14:38
// Design Name: 010 detector for computer organization class
// Module Name: detector
// Project Name: Project2 RTL sequential logic
// Target Devices: Vivado simulation
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

// Define States
`define INIT    2'b00
`define ZERO    2'b01
`define ONE     2'b10
`define MATCH   2'b11

module detector(
    input in,
    input clk,
    input reset_n,
    output out
    );
    
    reg [1:0] statereg;

    statedecoder statedecoder1(
        .state(statereg),
        .out(out)
    );
/* 
    initial begin
        statereg[1:0] = 2'b00;
    end
 */
    always @ (posedge clk) begin
        // TODO: logic in RTL
        statereg[1:1] <= ((statereg[0:0] & in) | (statereg[1:1] & (~statereg[0:0]) & (~in))) & reset_n;
        statereg[0:0] <= (~in) & reset_n;
    end

endmodule

module statedecoder(
    input [1:0] state,
    output out
);
    /* Module state code decoder(moore)
    INPUT:
        state   : (unsigned wire)     [2]    state
    
    OUTPUT:
        out   : [1]    output
    */

    assign out = state[1:1] & state[0:0];

endmodule