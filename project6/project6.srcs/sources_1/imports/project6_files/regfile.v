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
`include "basics.v"

`ifdef REGFILE_V
`else
`define REGFILE_V

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

   /*  // Internal forwarding logic
    wire [15:0] read_data1, read_data2;

    always @(*) begin
        if (write) begin
            if (addr1 == addr3) begin
                // forward to data1
                data1 = data3;
            end
            else begin
                data1 = read_data1;
            end

            if (addr2 == addr3) begin
                // forward to data2
                data2 = data3;
            end
            else begin
                data2 = read_data2; 
            end
        end
        else begin
            data1 = read_data1;
            data2 = read_data2;
        end
    end */

    // data1 output selection mux.
    MUX16_4_1 mux1(
        .inp0(registers[0]),
        .inp1(registers[1]),
        .inp2(registers[2]),
        .inp3(registers[3]),
        .sel(addr1),
        .out(data1)
    );
    // data2 output selection mux.
    MUX16_4_1 mux2(
        .inp0(registers[0]),
        .inp1(registers[1]),
        .inp2(registers[2]),
        .inp3(registers[3]),
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

            // data1 <= 0;
            // data2 <= 0;
        end
        // write enabled case
        else if (write) begin
            registers[addr3] <= data3;
        end
    end


endmodule

`endif
