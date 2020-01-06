// Author: JHYeom (zhixian001)
`timescale 1ns/100ps

`ifdef WORD_SIZE
`else
`define WORD_SIZE 16
`endif
// `include "constants.v"
`include "ALU.v"
`include "regfile.v"
`include "opcodes.v"
`include "basics.v"

`ifdef MEMORYCONTROLLER_V
`else
`define MEMORYCONTROLLER_V

module Memcontroller(
    // seq signals
    input reset_n,
    input clk,

    // Control Signals
    input control_memread,
    input control_memwrite,
    input control_instruction_read,

    // read or write data
    input [`WORD_SIZE-1:0] address_instruction,     // instruction address
    input [`WORD_SIZE-1:0] address_data,            // data address
    input [`WORD_SIZE-1:0] data_instruction_write,  // instruction to write
    input [`WORD_SIZE-1:0] data_data_write,         // data to write
    
    output [`WORD_SIZE-1:0] output_instruction,     // instruction read from mem
    output [`WORD_SIZE-1:0] output_data,            // data read from mem
    
    // instruction memory interface
    output reg i_readM,
    output reg i_writeM,
    output [`WORD_SIZE-1:0] i_address,
    inout [`WORD_SIZE-1:0] i_data,

    // data memory interface
    output reg d_readM,
    output reg d_writeM,
    output [`WORD_SIZE-1:0] d_address,
    inout [`WORD_SIZE-1:0] d_data
);
    // Var for reading data
    reg [`WORD_SIZE-1:0] d_latch, i_latch;
    assign output_instruction = i_latch;
    assign output_data = d_latch;

    // Assignments
    assign output_instruction = i_latch;
    assign output_data = d_latch;

    assign i_address = address_instruction;
    assign d_address = address_data;

    assign i_data = i_writeM ? data_instruction_write : `WORD_SIZE'bz;
    assign d_data = d_writeM ? data_data_write : `WORD_SIZE'bz;

    // reset signal
    always @(posedge clk) begin
        if (reset_n == 0) begin
            d_readM <= 0;
            d_writeM <= 0;
            d_latch <= 0;
            i_readM <= 1;       // always start reading instruction
            i_writeM <= 0;
            i_latch <= 0;
        end
        else begin

            // // FIXME:
            // if (control_memread) begin
            //     d_readM <= 1;
            //     d_writeM <= 0;
            //     d_latch <= d_data;
            // end
            // else if (control_memwrite) begin
            //     d_readM <= 0;
            //     d_writeM <= 1;
            // end
            // else begin
            //     d_readM <= 0;
            //     d_writeM <= 0; 
            // end


        end
    end

    always @(*) begin
        if (control_memread) begin
            d_readM = 1;
            d_writeM = 0;
            d_latch = d_data;
        end
        else if (control_memwrite) begin
            d_readM = 0;
            d_writeM = 1;
        end
        else begin
            d_readM = 0;
            d_writeM = 0; 
        end

        if (control_instruction_read) begin
            i_readM = 1;
            i_writeM = 0;
        end
        else begin
            i_readM = 0;
            i_writeM = 0;
        end
        if (i_data) begin
            i_latch = i_data; 
        end
    end

endmodule

`endif
