// Author: JHYeom (zhixian001)
`timescale 1ns/100ps

`ifdef WORD_SIZE
`else
`define WORD_SIZE 16
`endif

`include "opcodes.v"
`include "basics.v"
`include "config.v"


`ifdef CONTROL_V
`else
`define CONTROL_V

module Control_Unit(
    input [3:0] opcode,
    input [5:0] funct,

    output [`EX_SIGNAL_SIZE-1:0] ex_signal,
    output [`MEM_SIGNAL_SIZE-1:0] mem_signal,
    output [`WB_SIGNAL_SIZE-1:0] wb_signal
);
    

    // EX
    reg control_aluout;
    reg [1:0] control_next_addr;
    reg control_alusrc;
    reg [3:0] control_aluop;
    reg [1:0] control_regdst;

    assign ex_signal = {control_aluout, control_next_addr, control_alusrc, control_aluop, control_regdst};

    // MEM
    reg control_pcwritecond;
    reg control_memwrite;
    reg control_memread;
    reg control_pcwrite;        // TODO: jump

    assign mem_signal = {control_pcwritecond, control_memwrite, control_memread, control_pcwrite};

    // WB
    reg wwd_latch;
    reg is_halted;
    reg control_regwrite;
    reg control_memtoreg;

    assign wb_signal = {wwd_latch, is_halted, control_regwrite, control_memtoreg};
    
    

    // EX stage signals
    always @(*) begin
        // Decide ALUOP
        // ADD
        if (((opcode == 4'd15) && (funct == `FUNC_ADD)) || (opcode == `OPCODE_ADI) || (opcode == `OPCODE_LWD) || (opcode == `OPCODE_SWD)) begin
            control_aluop = `ALUOP_ADD;
        end

        // SUB
        else if ((opcode == 4'd15) && (funct == `FUNC_SUB)) begin
            control_aluop = `ALUOP_SUB;
        end

        // AND
        else if ((opcode == 4'd15) && (funct == `FUNC_AND)) begin
            control_aluop = `ALUOP_AND;
        end 

        // OR
        else if (((opcode == 4'd15) && (funct == `FUNC_ORR)) || (opcode == `OPCODE_ORI)) begin
            control_aluop = `ALUOP_OR;
        end

        // NOT
        else if ((opcode == 4'd15) && (funct == `FUNC_NOT)) begin
            control_aluop = `ALUOP_NOT;
        end

        // 2's Complement
        else if ((opcode == 4'd15) && (funct == `FUNC_TCP)) begin
            control_aluop = `ALUOP_2COMP;
        end

        // Shift left logical
        else if ((opcode == 4'd15) && (funct == `FUNC_SHL)) begin
            control_aluop = `ALUOP_SHL;
        end

        // Shift right 
        else if ((opcode == 4'd15) && (funct == `FUNC_SHR)) begin
            control_aluop = `ALUOP_SHR;
        end

        // Left High Immediate
        else if (opcode == `OPCODE_LHI) begin
            control_aluop = `ALUOP_LHI;
        end 

        // WWD, HLT
        else if ((opcode == 4'd15)&& ((funct == `FUNC_WWD) || (funct == `FUNC_HLT))) begin
            control_aluop = `ALUOP_ID; 
        end


        else if ((opcode == 4'd15)&& ((funct == `FUNC_JPR) || (funct == `FUNC_JRL))) begin
            control_aluop = `ALUOP_ID;
        end

        else if ((opcode == `OPCODE_JMP) || (opcode == `OPCODE_JAL)) begin
            control_aluop = `ALUOP_ID;
        end

        else if (opcode == `OPCODE_BNE) begin
            control_aluop = `ALUOP_NE; 
        end
        else if (opcode == `OPCODE_BEQ) begin
            control_aluop = `ALUOP_EQ; 
        end
        else if (opcode == `OPCODE_BGZ) begin
            control_aluop = `ALUOP_GZ; 
        end
        else if (opcode == `OPCODE_BLZ) begin
            control_aluop = `ALUOP_LZ; 
        end

        // control_alusrc
        if ((opcode >= `OPCODE_ADI) && (opcode <= `OPCODE_SWD)) begin
            // operand imm
            control_alusrc = 1; 
        end
        else begin
            // operand $rt
            control_alusrc = 0; 
        end

        // control_regdst
        if ((opcode >= `OPCODE_ADI) && (opcode <= `OPCODE_SWD)) begin
            // I type : $rt
            control_regdst = 0;
        end
        else if ((opcode == `OPCODE_JAL) || ((opcode == 4'd15) && (funct == `FUNC_JRL))) begin
            control_regdst = 2;
        end
        else begin
            // else type : $rd
            control_regdst = 1;
        end

        // control_next_addr
        if ((opcode == `OPCODE_JMP) || (opcode == `OPCODE_JAL)) begin
            // jump
            control_next_addr = 1; 
        end
        else if ((opcode == 4'd15)&& ((funct == `FUNC_JPR) || (funct == `FUNC_JRL))) begin
            // jump reg
            control_next_addr = 2; 
        end
        else if ((opcode >= `OPCODE_BNE) && (opcode <= `OPCODE_BLZ)) begin
            // branch addr
            control_next_addr = 3; 
        end
        else begin
            // pc+1
            control_next_addr = 0; 
        end

        // control_aluout for $2 <- PC+1
        if ((opcode == `OPCODE_JAL) || ((opcode == 4'd15) && (funct == `FUNC_JRL))) begin
            control_aluout = 1; 
        end
        else begin
            control_aluout = 0; 
        end

    end

    // Mem stage signals
    always @(*) begin
        // control_pcwritecond: branch
        if ((opcode >= `OPCODE_BNE) && (opcode <= `OPCODE_BLZ)) begin
            control_pcwritecond = 1;
        end
        else begin
            control_pcwritecond = 0;
        end

        // control_memwrite
        if (opcode == `OPCODE_SWD) begin
            control_memwrite = 1; 
        end
        else begin
            control_memwrite = 0;
        end

        // control_memread
        if (opcode == `OPCODE_LWD) begin
            control_memread = 1; 
        end
        else begin
            control_memread = 0;
        end

        // control_pcwrite
        if ((opcode == `OPCODE_JMP) || (opcode == `OPCODE_JAL) || ((opcode == 4'd15) && ((funct == `FUNC_JRL) || (funct == `FUNC_JPR)))) begin
            control_pcwrite = 1;
        end
        else begin
            control_pcwrite = 0; 
        end
    end

    // WB stage signals
    always @(*) begin
        // control_memtoreg
        if (opcode == `OPCODE_LWD) begin
            control_memtoreg = 1;
        end
        else begin
            control_memtoreg = 0; 
        end

        // control_regwrite
        if ((opcode == `OPCODE_SWD) || ((opcode >= `OPCODE_BNE) && (opcode <= `OPCODE_BLZ)) || (opcode == `OPCODE_JMP)) begin
            // Not update register file
            control_regwrite = 0;
        end
        else if ((opcode == 4'd15) && ((funct == `FUNC_WWD) || (funct == `FUNC_JPR) || (funct == `FUNC_HLT))) begin
            // Not update regfile
            control_regwrite = 0;
        end
        else begin
            control_regwrite = 1;
        end

        // WB stage's is halted signal
        if ((opcode == 4'd15) && (funct == `FUNC_HLT)) begin
            is_halted = 1; 
        end
        else begin
            is_halted = 0; 
        end

        // wwd latch signal
        if (((opcode == 4'd15) && (funct == `FUNC_WWD)) || ((opcode == 4'd15) && (funct == `FUNC_HLT))) begin
            wwd_latch = 1;
        end
        else begin
            wwd_latch = 0; 
        end
    end


endmodule

`endif