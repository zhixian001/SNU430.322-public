// Author: JHYeom (zhixian001)
`timescale 1ns/100ps

// `include "opcodes.v"
// `include "constants.v"
// `include "ALU.v"
// `include "regfile.v"
`ifdef DATAPATH_V
`else
`include "datapath.v"
`endif
`ifdef CONTROL_V
`else
`include "control.v"
`endif
// `include "basics.v"
`ifdef OPCODES_V
`else
`include "opcodes.v"
`endif
`ifdef CONSTANTS_V
`else
`include "constants.v"
`endif
`ifdef BASICS_V
`else
`include "basics.v"
`endif

`ifdef CPU_V
`else
`define CPU_V

module cpu (
    output readM, // read from memory
    output writeM, // write to memory
    output [`WORD_SIZE-1:0] address, // current address for data
    inout [`WORD_SIZE-1:0] data, // data being input or output
    input inputReady, // indicates that data is ready from the input port
    input reset_n, // active-low RESET signal
    input clk, // clock signal
    
    // for debuging/testing purpose
    output [`WORD_SIZE-1:0] num_inst, // number of instruction during execution
    output [`WORD_SIZE-1:0] output_port, // this will be used for a "WWD" instruction
    output is_halted // 1 if the cpu is halted
);
    // ... fill in the rest of the code
    
    wire [15:0] wwd_output;
    wire [1:0] pcsource, alusrcA, alusrcB;
    wire [3:0] alucontrol, opcode;
    wire [5:0] funct;


    wire regwrite, pclatch, iord, memread, memwrite, memtoreg, irwrite, bcond;
    wire [1:0] regdst;

    // wire wwd_latch;

    // Debug
    // always @(posedge clk) begin
        // if (irwrite == 1) begin
            // $display("DEBUG >> Instruction Latched: %0b", data);
        // end
    // end

/*     Latch16 wwd_reg(
    	.clk     (clk     ),
        .in      (wwd_output),
        .enable  (wwd_latch),
        .reset_n (reset_n ),
        .out     (output_port)
    ); */
    
    
    assign output_port = wwd_output;


    Datapath datapath(
        .clk(clk),
        .reset_n(reset_n),
        .data(data),
        .address(address),
        .readM(readM),
        .writeM(writeM),
        .pcsource(pcsource),
        .alucontrol(alucontrol),
        .alusrcA(alusrcA),
        .alusrcB(alusrcB),
        .regwrite(regwrite),
        .regdst(regdst),
        .pclatch(pclatch),
        .iord(iord),
        .memread(memread),
        .memwrite(memwrite),
        .memtoreg(memtoreg),
        .irwrite(irwrite),
        .inputReady(inputReady),
        .wwd_output(wwd_output),
        .bcond(bcond),
        .funct(funct),
        .opcode(opcode),
        .num_inst(num_inst)
    );


    Control_Unit controlunit(
        .pcsource(pcsource),
        .alucontrol(alucontrol),
        .alusrcA(alusrcA),
        .alusrcB(alusrcB),
        .regwrite(regwrite),
        .regdst(regdst),
        .pclatch(pclatch),
        .iord(iord),
        .memread(memread),
        .memwrite(memwrite),
        .memtoreg(memtoreg),
        .irwrite(irwrite),
        // additional control signals
        // .wwd_read(wwd_read),
        // inputs
        .clk(clk),
        .reset_n(reset_n),
        .bcond(bcond),
        .funct(funct),
        .opcode(opcode),
        // .wwd_latch(wwd_latch),
        .is_halted(is_halted)
    );

endmodule

`endif