// Author: JHYeom (zhixian001)
`timescale 1ns/1ns

`ifdef WORD_SIZE
`else
`define WORD_SIZE 16    // data and address word size
`endif
`include "opcodes.v"
`include "control.v"
`include "config.v"
`include "basics.v"

// This module handles stall, hazard detection
// equal to hazard detection unit
// Location: ID

// Branch will evaluated in MEM stage
// Vaild Instruction


// IF/ID ID/EX EX/MEM MEM/WB
//   ?     ?     B      O

//   O     X     X      B

//   O     Y     X      X       stall
//   O     Y     Y      X       stall
//   O     Y     Y      Y       stall

//   O     O     Y      Y



module pipelinecontroller (
    input clk,
    input reset_n,
    
    input [`WORD_SIZE-1:0] id_instruction,
    input mem_predict_miss,
    input is_halted,

    input ex_mem_control_memread,   // if memread, forward stall 1

    output reg enable_if_id, enable_id_ex, enable_ex_mem, enable_mem_wb,

    // Valid signals wiil make architectural control signals to 0 to keep state.
    output reg valid_if_id, valid_id_ex, valid_ex_mem, valid_mem_wb
);


    // hazard registers address
    reg [`REG_ADDR_SIZE-1:0] hazard_if_id_addr, hazard_id_ex_addr, hazard_ex_mem_addr, hazard_mem_wb_addr;
    // valid chk of hazard detection registers
    reg hazard_if_id, hazard_id_ex, hazard_ex_mem, hazard_mem_wb;


    // for opcode and funct condition chk
    wire [3:0] opcode;
    wire [5:0] funct;

    assign opcode = id_instruction[15:12];
    assign funct = id_instruction[5:0];

    reg [`REG_ADDR_SIZE-1:0] if_id_read_reg_addr_1, if_id_read_reg_addr_2;
    reg if_id_read_exist_1, if_id_read_exist_2;


    // resolve instructions
    always @(*) begin
        // Decide if stage's hazard register (assign if, id)
        if ((opcode == 4'd15) && (funct >= `FUNC_ADD) && (funct <= `FUNC_SHR)) begin
            // $rd hazard
            hazard_if_id = 1;
            hazard_if_id_addr = id_instruction[7:6];
            // read $rs, $rt
            if_id_read_exist_1 = 1;
            if_id_read_exist_2 = 1;
            if_id_read_reg_addr_1 = id_instruction[11:10];
            if_id_read_reg_addr_2 = id_instruction[9:8];
        end
        else if ((opcode >= `OPCODE_BNE) && (opcode <= `OPCODE_BLZ)) begin
            // No write hazard
            hazard_if_id = 0;
            hazard_if_id_addr = 0;

            // read $rs, $rt
            if_id_read_exist_1 = 1;
            if_id_read_exist_2 = 1;
            if_id_read_reg_addr_1 = id_instruction[11:10];
            if_id_read_reg_addr_2 = id_instruction[9:8];
        end
        else if ((opcode >= `OPCODE_ADI) && (opcode <= `OPCODE_LHI)) begin
            // $rt hazard
            hazard_if_id = 1;
            hazard_if_id_addr = id_instruction[9:8];
            // read $rs
            if_id_read_exist_1 = 1;
            if_id_read_exist_2 = 0;
            if_id_read_reg_addr_1 = id_instruction[11:10];
        end
        else if (opcode == `OPCODE_LWD) begin
            // $rt rt write hazard
            hazard_if_id = 1;
            hazard_if_id_addr = id_instruction[9:8];
            // read $rs
            if_id_read_exist_1 = 1;
            // if_id_read_exist_2 = ;
            if_id_read_exist_2 = 0;

            if_id_read_reg_addr_1 = id_instruction[11:10];
            // if_id_read_reg_addr_2 = id_instruction[9:8];

        end
        else if ((opcode == `OPCODE_JAL) || ((opcode == 4'd15) && (funct == `FUNC_JRL))) begin
            // $2 hazard
            hazard_if_id = 1;
            hazard_if_id_addr = 2'b10;
            if ((opcode == 4'd15) && (funct == `FUNC_JRL)) begin
                // read $rs
                if_id_read_exist_1 = 1;
                if_id_read_exist_2 = 0;
                if_id_read_reg_addr_1 = id_instruction[11:10];
            end
            else begin
                if_id_read_exist_1 = 0;
                if_id_read_exist_2 = 0;
            end
        end
        else if (((opcode == 4'd15) && (funct == `FUNC_JPR))) begin
            // No hazard regs
            hazard_if_id = 0;
            hazard_if_id_addr = 0;

            // read $rs
            if_id_read_exist_1 = 1;
            if_id_read_exist_2 = 0;
            if_id_read_reg_addr_1 = id_instruction[11:10];
        end

        else if (((opcode == 4'd15) && (funct == `FUNC_WWD))) begin
            // No hazard regs
            hazard_if_id = 0;
            hazard_if_id_addr = 0;

            // read $rs
            if_id_read_exist_1 = 1;
            if_id_read_exist_2 = 0;
            if_id_read_reg_addr_1 = id_instruction[11:10];
        end

        else if (opcode == `OPCODE_SWD) begin
            // No hazard regs
            hazard_if_id = 0;
            hazard_if_id_addr = 0;

            // read $rs $rt
            if_id_read_exist_1 = 1;
            if_id_read_exist_2 = 1;
            if_id_read_reg_addr_1 = id_instruction[11:10];
            if_id_read_reg_addr_2 = id_instruction[9:8];
        end

        else begin
            // No hazard regs (HLT)
            hazard_if_id = 0;
            hazard_if_id_addr = 0;
            if_id_read_exist_1 = 0;
            if_id_read_exist_2 = 0;
        end
    end

    // stall counter (== bubble size) (0 for no bubbles)
    reg [1:0] num_stall;
    reg [1:0] num_stall_candidate;


    reg [1:0] temporary_num_stall_1;
    reg [1:0] temporary_num_stall_2;

    // Find data hazard
    always @(*) begin
        if (if_id_read_exist_1 || if_id_read_exist_2) begin
            // Need to check Hazard
            if (if_id_read_exist_1 && if_id_read_exist_2) begin
                // Need to check both
                // Check read addr 1
                if ((hazard_id_ex) && (hazard_id_ex_addr == if_id_read_reg_addr_1)) begin
                    // Stall 3 case
                    if (`FORWARDING_UNIT_ENABLED) begin
                        if (ex_mem_control_memread) begin
                            temporary_num_stall_1 = 1;
                        end
                        else begin
                            temporary_num_stall_1 = 0; 
                        end
                    end
                    else begin
                        temporary_num_stall_1 = 3; 
                    end
                end
                else if ((hazard_ex_mem) && (hazard_ex_mem_addr == if_id_read_reg_addr_1)) begin
                    // Stall 2 case
                    if (`FORWARDING_UNIT_ENABLED) begin
                        temporary_num_stall_1 = 0; 
                    end
                    else begin
                        temporary_num_stall_1 = 2; 
                    end
                end
                else if ((hazard_mem_wb) && (hazard_mem_wb_addr == if_id_read_reg_addr_1)) begin
                    // Stall 1 case
                    if (`FORWARDING_UNIT_ENABLED) begin
                        temporary_num_stall_1 = 0; 
                    end
                    else begin
                        temporary_num_stall_1 = 1; 
                    end
                end
                else begin
                   temporary_num_stall_1 = 0; 
                end

                // Check read addr 2
                if ((hazard_id_ex) && (hazard_id_ex_addr == if_id_read_reg_addr_2)) begin
                    // Stall 3 case
                    if (`FORWARDING_UNIT_ENABLED) begin
                        if (ex_mem_control_memread) begin
                            temporary_num_stall_2 = 1;
                        end
                        else begin
                            temporary_num_stall_2 = 0; 
                        end
                    end
                    else begin
                        temporary_num_stall_2 = 3; 
                    end
                end
                else if ((hazard_ex_mem) && (hazard_ex_mem_addr == if_id_read_reg_addr_2)) begin
                    // Stall 2 case
                    if (`FORWARDING_UNIT_ENABLED) begin
                        temporary_num_stall_2 = 0; 
                    end
                    else begin
                        temporary_num_stall_2 = 2; 
                    end
                end
                else if ((hazard_mem_wb) && (hazard_mem_wb_addr == if_id_read_reg_addr_2)) begin
                    // Stall 1 case
                    if (`FORWARDING_UNIT_ENABLED) begin
                        temporary_num_stall_2 = 0; 
                    end
                    else begin
                        temporary_num_stall_2 = 1; 
                    end
                end
                else begin
                    temporary_num_stall_2 = 0; 
                end

                //  Decide number of stall
                if (temporary_num_stall_1 > temporary_num_stall_2) begin
                    num_stall_candidate = temporary_num_stall_1;
                end
                else begin
                    num_stall_candidate = temporary_num_stall_2;
                end

            end
            else begin
                // Need to Check if_id_read_reg_addr_1
                if ((hazard_id_ex) && (hazard_id_ex_addr == if_id_read_reg_addr_1)) begin
                    // Stall 3 case
                    if (`FORWARDING_UNIT_ENABLED) begin
                        if (ex_mem_control_memread) begin
                            num_stall_candidate = 1;
                        end
                        else begin
                            // $display("HERE???");
                            num_stall_candidate = 0; 
                        end
                    end
                    else begin
                        num_stall_candidate = 3;
                    end
                end
                else if ((hazard_ex_mem) && (hazard_ex_mem_addr == if_id_read_reg_addr_1)) begin
                    // Stall 2 case
                    if (`FORWARDING_UNIT_ENABLED) begin
                        num_stall_candidate = 0;
                    end
                    else begin
                        num_stall_candidate = 2;
                    end 
                end
                else if ((hazard_mem_wb) && (hazard_mem_wb_addr == if_id_read_reg_addr_1)) begin
                    // Stall 1 case
                    if (`FORWARDING_UNIT_ENABLED) begin
                        num_stall_candidate = 0;
                    end
                    else begin
                        num_stall_candidate = 1;
                    end 
                end
                else begin
                    num_stall_candidate = 0; 
                end
            end
        end
        else begin
            // No need to check Hazard
            num_stall_candidate = 0;
        end

        if ((num_stall == 0) && (mem_predict_miss == 0)) begin
            num_stall = num_stall_candidate; 
        end

        

    end

    // Flush flags
    // reg num_flush;
    // Detect control hazard(branch prediction miss)
    /* always @(*) begin
        if (mem_predict_miss) begin
            num_flush = 1;
        end
    end */

    reg valid_before_if_id;     // inject if_id pipeline register distance

    always @(*) begin

        if (is_halted) begin
            // If halted -> stop
            enable_if_id = 0;  
            enable_id_ex = 0;
            enable_ex_mem = 0;
            enable_mem_wb = 0;
        end
        else begin
            // if (num_flush) begin
            if (mem_predict_miss) begin

                // Flush won't stop pipelining
                enable_if_id = 1;  
                enable_id_ex = 1;
                enable_ex_mem = 1;
                enable_mem_wb = 1;

                // Insert one more bubble
                valid_before_if_id = 0;
                // reset number of stall;
                num_stall = 0;
            end
            
            else if (num_stall != 0) begin
                enable_if_id = 0;       // stop laching if/id reg and PC
                enable_id_ex = 1;
                enable_ex_mem = 1;
                enable_mem_wb = 1; 

                valid_before_if_id = 1;
            end
            else begin
                // pipeline keep going
                enable_if_id = 1;  
                enable_id_ex = 1;
                enable_ex_mem = 1;
                enable_mem_wb = 1;

                valid_before_if_id = 1;
            end
        end
    end

    always @(posedge clk) begin
        if (reset_n == 0) begin
            enable_if_id <= 1;
            enable_id_ex <= 1;
            enable_ex_mem <= 1;
            enable_mem_wb <= 1;

            valid_if_id <= 0;
            valid_id_ex <= 0;
            valid_ex_mem <= 0;
            valid_mem_wb <= 0;

            hazard_id_ex_addr <= 0;
            hazard_id_ex_addr <= 0;
            hazard_ex_mem_addr <= 0;
            hazard_mem_wb_addr <= 0;
            hazard_id_ex <= 0;
            hazard_id_ex <= 0;
            hazard_ex_mem <= 0;
            hazard_mem_wb <= 0;

            num_stall <= 0;
            // num_stall <= 0;
            // num_flush <= 0;

            if_id_read_reg_addr_1 <= 0;
            if_id_read_reg_addr_2 <= 0;
            if_id_read_exist_1 <= 0;
            if_id_read_exist_2 <=0;

        end

        else begin
            // if (num_flush) begin
            if (mem_predict_miss) begin

                // Flush case
                // Insert Three bubbles
                valid_if_id <= valid_before_if_id;
                valid_id_ex <= 0;
                valid_ex_mem <= 0;
                // Keep Branch instruction advance
                valid_mem_wb <= valid_ex_mem;
                // Insert Three bubbles to protect register validation
                hazard_if_id <= 0;
                hazard_id_ex <= 0;
                hazard_ex_mem <= 0;
                // There will be no data dependancy 
                num_stall <= 0;
                // flush flag reset
                // num_flush <= 0;
            end
            else begin
                // Data hazard chk
                if (num_stall > 0) begin
                    // stall case
                    // Stop advancing and latching pc in if/id

                    // insert bubbles in id/ex register
                    valid_id_ex <= 0;
                    hazard_id_ex <= 0;
                    // and other validity will keep advance
                    valid_ex_mem <= valid_id_ex;
                    valid_mem_wb <= valid_ex_mem;
                    hazard_ex_mem <= hazard_id_ex;
                    hazard_ex_mem_addr <= hazard_id_ex_addr;
                    hazard_mem_wb <= hazard_ex_mem;
                    hazard_mem_wb_addr <= hazard_ex_mem_addr;

                    // decrease stall counter
                    num_stall <= num_stall - 1;
                end
                else begin
                    // Shift Valid Signals
                    valid_if_id <= valid_before_if_id;
                    valid_id_ex <= valid_if_id;
                    valid_ex_mem <= valid_id_ex;
                    valid_mem_wb <= valid_ex_mem;

                    // Shift hazard registers
                    hazard_id_ex <= hazard_if_id;
                    hazard_id_ex_addr <= hazard_if_id_addr;
                    hazard_ex_mem <= hazard_id_ex;
                    hazard_ex_mem_addr <= hazard_id_ex_addr;
                    hazard_mem_wb <= hazard_ex_mem;
                    hazard_mem_wb_addr <= hazard_ex_mem_addr;
                end
            end
            
        end
    end




    

endmodule // 