`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SNU
// Engineer: JHYeom (zhixian001)
// 
// Create Date: 2019/03/25 17:14:38
// Design Name: Register file for computer organization class
// Module Name: RF
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


module RF(
    input write,
    input clk,
    input reset_n,
    input [1:0] addr1,
    input [1:0] addr2,
    input [1:0] addr3,
    input [15:0] data3,
    output [15:0] data1,
    output [15:0] data2
    );


    // Registers (4)
    reg [15:0] registers [0:3];

    // data1 output selection mux.
    MUX16_4_1 mux1(
        .inp1(registers[0]),
        .inp2(registers[1]),
        .inp3(registers[2]),
        .inp4(registers[3]),
        .sel(addr1),
        .out(data1)
    );
    // data2 output selection mux.
    MUX16_4_1 mux2(
        .inp1(registers[0]),
        .inp2(registers[1]),
        .inp3(registers[2]),
        .inp4(registers[3]),
        .sel(addr2),
        .out(data2)
    );

    always @ (posedge clk) begin
        // reset all registers
        if (~reset_n) begin
            registers[0] <= 16'h0000;
            registers[1] <= 16'h0000;
            registers[2] <= 16'h0000;
            registers[3] <= 16'h0000;
        end
        // write enabled case
        else if (write) begin
            registers[addr3] <= data3;
        end
    end


endmodule

module MUX16_4_1(
    input [15:0] inp1,
    input [15:0] inp2,
    input [15:0] inp3,
    input [15:0] inp4,
    input [1:0] sel,
    output [15:0] out
);
    /* 4 to 1 MUX
    INPUT:
        inp1   : (unsigned wire)   [16]    option
        inp2   : (unsigned wire)   [16]    option
        inp3   : (unsigned wire)   [16]    option
        inp4   : (unsigned wire)   [16]    option
        sel : (unsigned wire)   [2]     select
    
    OUTPUT:
        out : [16]    output chosen
    */
    assign out = sel[1:1]? (sel[0:0]? inp4 : inp3) : (sel[0:0]? inp2 : inp1);

endmodule
