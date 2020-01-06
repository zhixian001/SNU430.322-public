// Author: JHYeom (zhixian001)
`timescale 1ns/100ps

`include "basics.v"
`include "config.v"
`include "opcodes.v"

`ifdef FORWARDUNIT_V
`else
`define FORWARDUNIT_V

module forwardunit(

    // input from id stage
    input [`WORD_SIZE-1:0] id_instruction,

    // Forward from Ex stage's output
    input [`REG_ADDR_SIZE-1:0] ex_regdst_addr,
    input [`WORD_SIZE-1:0] ex_alu_result,
    input ex_control_regwrite,
    input ex_control_memread,

    // Forword from MEM stage's output
    input [`REG_ADDR_SIZE-1:0] mem_regdst_addr,
    input [`WORD_SIZE-1:0] mem_alu_result,
    input [`WORD_SIZE-1:0] mem_memory_read_output,
    input mem_control_regwrite,
    input mem_control_memread,

    // Forward from WB stage's output
    input [`REG_ADDR_SIZE-1:0] wb_regdst_addr,
    input [`WORD_SIZE-1:0] wb_memtoreg_mux,
    input wb_control_regwrite,


    // inputs from ID stage regfile to on/off fwd unit easily
    input [`WORD_SIZE-1:0] id_regout1,
    input [`WORD_SIZE-1:0] id_regout2,

    // output of forwarding unit
    output reg [`WORD_SIZE-1:0] id_fwd_regout1,
    output reg [`WORD_SIZE-1:0] id_fwd_regout2
);
    // To find hazard register
    reg [`REG_ADDR_SIZE-1:0] id_rs_addr;
    reg [`REG_ADDR_SIZE-1:0] id_rt_addr;
    // additional signals to chk hazard
    reg id_read_rs;
    reg id_read_rt;

    wire [3:0] opcode;
    wire [5:0] funct;
    assign opcode = id_instruction[15:12];
    assign funct = id_instruction[5:0];

    // decide id stage's read registers
    always @(*) begin
        if ((opcode == 4'd15) && (funct >= `FUNC_ADD) && (funct <= `FUNC_SHR)) begin
            // read $rs, $rt
            id_read_rs = 1;
            id_read_rt = 1;
            id_rs_addr = id_instruction[11:10];
            id_rt_addr = id_instruction[9:8];
        end
        else if ((opcode >= `OPCODE_BNE) && (opcode <= `OPCODE_BLZ)) begin
            // read $rs, $rt
            id_read_rs = 1;
            id_read_rt = 1;
            id_rs_addr = id_instruction[11:10];
            id_rt_addr = id_instruction[9:8];
        end
        else if ((opcode >= `OPCODE_ADI) && (opcode <= `OPCODE_LWD)) begin
            if (opcode == `OPCODE_LHI) begin
                // read $rt
                id_read_rs = 0;
                id_read_rt = 1;
                id_rt_addr = id_instruction[9:8];
            end
            else begin
                // read $rs
                id_read_rs = 1;
                id_read_rt = 0;
                id_rs_addr = id_instruction[11:10];
            end
        end
        else if ((opcode == `OPCODE_JAL) || ((opcode == 4'd15) && (funct == `FUNC_JRL))) begin
            if ((opcode == 4'd15) && (funct == `FUNC_JRL)) begin
                // read $rs
                id_read_rs = 1;
                id_read_rt = 0;
                id_rs_addr = id_instruction[11:10];
            end
            else begin
                // read nothing
                id_read_rs = 0;
                id_read_rt = 0;
            end
        end
        else if (((opcode == 4'd15) && (funct == `FUNC_JPR))) begin
            // read $rs
            id_read_rs = 1;
            id_read_rt = 0;
            id_rs_addr = id_instruction[11:10];
        end

        else if (((opcode == 4'd15) && (funct == `FUNC_WWD))) begin
            // read $rs
            id_read_rs = 1;
            id_read_rt = 0;
            id_rs_addr = id_instruction[11:10];
        end

        else if(opcode == `OPCODE_SWD) begin
            // read $rs $rt
            id_read_rs = 1;
            id_read_rt = 1;
            id_rs_addr = id_instruction[11:10];
            id_rt_addr = id_instruction[9:8];
        end

        else begin
            // No hazard regs (HLT)
            id_read_rs = 0;
            id_read_rt = 0;
        end
    end

    // Decide forwarding logic
    // Youngest first
    always @(*) begin
        
        // RS Forwarding Check (to id_fwd_regout1)

        if (id_read_rs) begin
            // a. instruction should read $RS
            if ((ex_control_regwrite) && (id_rs_addr == ex_regdst_addr)) begin
                // 1.1 forward from EX stage(youngest relation is EX)
                // b. EX instruction contains $rs regwrite: RAW dep
                if (ex_control_memread) begin
                    // TOCHK:Should stall to wait memread
                    id_fwd_regout1 = id_regout1;
                end
                else begin
                    // Forward to $rt
                    id_fwd_regout1 = ex_alu_result;
                end
            end
            else if ((mem_control_regwrite) && (id_rs_addr == mem_regdst_addr)) begin
                // 1.2 forward from MEM stage(youngest relation is MEM)
                // c. MEM instruction contains $rs regwrite: RAW dep
                if (mem_control_memread) begin
                    // FWD memoryoutput to $rs
                    id_fwd_regout1 = mem_memory_read_output;
                end
                else begin
                    // FWD aluresult to $rs
                    id_fwd_regout1 = mem_alu_result;
                end

            end
            else if ((wb_control_regwrite) && (id_rs_addr == wb_regdst_addr)) begin
                // 1.3 forward from WB stage(youngest relation is WB)
                // 1.3 forward from WB stage (younges relation is WB)
                id_fwd_regout1 = wb_memtoreg_mux;
            end
            else begin
                // NO DEP 
                id_fwd_regout1 = id_regout1;

            end
        end
        else begin
            // `a. nothing to forward. because inst doesn't use $rs
            id_fwd_regout1 = id_regout1;

        end

        // RT Forwarding Check (to id_fwd_regout2)
        if(id_read_rt) begin
            if ((ex_control_regwrite) && (id_rt_addr == ex_regdst_addr)) begin
                    // 1.1 forward from EX stage(youngest relation is EX)
                    // b. EX instruction contains $rt regwrite: RAW dep
                    if (ex_control_memread) begin
                        // TOCHK:Should stall to wait memread
                        id_fwd_regout2 = id_regout2;
                    end
                    else begin
                        // Forward to $rt
                        id_fwd_regout2 = ex_alu_result;
                    end
                end
                else if ((mem_control_regwrite) && (id_rt_addr == mem_regdst_addr)) begin
                    // 1.2 forward from MEM stage(youngest relation is MEM)
                    // c. MEM instruction contains $rt regwrite: RAW dep
                    if (mem_control_memread) begin
                        // FWD memoryoutput to $rt
                        id_fwd_regout2 = mem_memory_read_output;
                    end
                    else begin
                        // FWD aluresult to $rt
                        id_fwd_regout2 = mem_alu_result;
                    end

                end
                else if ((wb_control_regwrite) && (id_rt_addr == wb_regdst_addr)) begin
                    // 1.3 forward from WB stage(youngest relation is WB)
                    id_fwd_regout2 = wb_memtoreg_mux;
                end
                else begin
                    // NO DEP 
                    id_fwd_regout2 = id_regout2;

                end
            end
            else begin
                // `a. nothing to forward. because inst doesn't use $rt
                id_fwd_regout2 = id_regout2;
            end
        end

endmodule
`endif
