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

`ifdef EX_V
`else
`define EX_V

module EX(
    input [`WORD_SIZE-1:0] ex_next_pc,

    input [`EX_SIGNAL_SIZE-1:0]  ex_ex_control_signal,
    input [`MEM_SIGNAL_SIZE-1:0] ex_mem_control_signal,
    input [`WB_SIGNAL_SIZE-1:0]  ex_wb_control_signal,

    input [`WORD_SIZE-1:0] ex_regout1,
    input [`WORD_SIZE-1:0] ex_regout2,
    input [`WORD_SIZE-1:0] ex_sign_ext,
    input [`REG_ADDR_SIZE-1:0] ex_regaddr_rt,
    input [`REG_ADDR_SIZE-1:0] ex_regaddr_rd,

    input [11:0] j_instruction,

    output [`WORD_SIZE-1:0] ex_calculated_next_pc,

    output ex_branch_condition,
    output [`WORD_SIZE-1:0] ex_alu_result,

    output [`REG_ADDR_SIZE-1:0] ex_regdst_out,

    input [`WORD_SIZE-1:0] ex_mem_pc_add_1,
    input [`WORD_SIZE-1:0] ex_next_pc_add_1
);

    wire [`WORD_SIZE-1:0] out_branch_addr_add;

    wire [`WORD_SIZE-1:0] out_alu;

    ADD16 branch_addr_add(
    	.n1  (ex_next_pc_add_1),
        .n2  (ex_sign_ext),
        .out (out_branch_addr_add)
    );

    wire [`WORD_SIZE-1:0] alusrcB;

    MUX16_2_1 Alusrc_Mux(
    	.inp0 (ex_regout2),
        .inp1 (ex_sign_ext),
        .sel  (ex_ex_control_signal[6:6]),      // ex_ex_control_signal[6:6] = control_alusrc
        .out  (alusrcB)
    );

    ALU alu(
    	.A     (ex_regout1),
        .B     (alusrcB),
        .OP    (ex_ex_control_signal[5:2]),             // ex_ex_control_signal[5:2] = control_aluop
        .C     (out_alu),
        .BCond (ex_branch_condition)
    );

    MUX2_3_1 Regdst_Mux(
    	.inp0 (ex_regaddr_rt),
        .inp1 (ex_regaddr_rd),
        .inp2 (2'b10),
        .sel  (ex_ex_control_signal[1:0]),     // ex_ex_control_signal[1:0] = control_regdst
        .out  (ex_regdst_out)
    );

    wire [`WORD_SIZE-1:0] jump_concat;
    assign jump_concat = {ex_next_pc[15:12], j_instruction};

    MUX16_4_1 Nextaddr_mux(
    	.inp0 (ex_next_pc_add_1),
        .inp1 (jump_concat),
        .inp2 (ex_regout1),
        .inp3 (out_branch_addr_add),
        .sel  (ex_ex_control_signal[8:7]),  // ex_ex_control_signal[8:7] = control_next_addr
        .out  (ex_calculated_next_pc)
    );
    
    
    // ALUOUT(to store pc+1 to $2)
    MUX16_2_1 Aluout_Mux(
    	.inp0 (out_alu),
        .inp1 (ex_next_pc_add_1),
        .sel  (ex_ex_control_signal[9:9]),  // ex_ex_control_signal[9:9] = control_aluout
        .out  (ex_alu_result)
    );
    

endmodule //   EX

`endif