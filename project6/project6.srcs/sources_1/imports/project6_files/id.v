// Author: JHYeom (zhixian001)
`timescale 1ns/100ps

`ifdef WORD_SIZE
`else
`define WORD_SIZE 16
`endif

`include "ALU.v"
`include "regfile.v"
`include "opcodes.v"
`include "basics.v"
`include "memorycontroller.v"
`include "config.v"
`include "control.v"

`ifdef ID_V
`else
`define ID_V

module ID(
    input reset_n,
    input clk,

    input [`WORD_SIZE-1:0] id_instruction,


    output [`WORD_SIZE-1:0] id_regout1,
    output [`WORD_SIZE-1:0] id_regout2,
    output [`WORD_SIZE-1:0] id_sign_ext,
    output [`REG_ADDR_SIZE-1:0] id_regaddr_rt,
    output [`REG_ADDR_SIZE-1:0] id_regaddr_rd,

    input control_regwrite,

    input [`REG_ADDR_SIZE-1:0] wb_regdst,

    input [`WORD_SIZE-1:0] out_memtoreg_mux



);

    // Register File here
    RF regfile(
    	.write   (control_regwrite),
        .clk     (clk),
        .reset_n (reset_n),
        .addr1   (id_instruction[11:10]),
        .addr2   (id_instruction[9:8]),
        .addr3   (wb_regdst),
        .data1   (id_regout1),
        .data2   (id_regout2),
        .data3   (out_memtoreg_mux)
    );

    SIGN_EXTEND8_16 Sign_Ext(
    	.inp (id_instruction[7:0]),
        .out (id_sign_ext)
    );

    assign id_regaddr_rt = id_instruction[9:8];
    assign id_regaddr_rd = id_instruction[7:6];
    

endmodule //   ID

`endif