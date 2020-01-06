// Author: JHYeom (zhixian001)
`timescale 1ns/1ns

`ifdef WORD_SIZE
`else
`define WORD_SIZE 16    // data and address word size
`endif

`include "opcodes.v"
`include "control.v"
`include "memorycontroller.v"
`include "config.v"
`include "basics.v"

`include "id.v"
`include "ex.v"

`include "pipelinecontroller.v"
`include "branchpredictor.v"

`include "forwardunit.v"


`ifdef CPU_V
`else
`define CPU_v

module cpu(
    // Basic Seq
        input Clk, 
        input Reset_N, 

	// Instruction memory interface
        output i_readM, 
        output i_writeM, 
        output [`WORD_SIZE-1:0] i_address, 
        inout [`WORD_SIZE-1:0] i_data, 

	// Data memory interface
        output d_readM, 
        output d_writeM, 
        output [`WORD_SIZE-1:0] d_address, 
        inout [`WORD_SIZE-1:0] d_data, 

        output [`WORD_SIZE-1:0] num_inst, 
        output [`WORD_SIZE-1:0] output_port, 
        output reg is_halted
);

    // Control Signals for Pipeline registers
    wire enable_if_id, enable_id_ex, enable_ex_mem, enable_mem_wb;
    wire valid_if_id, valid_id_ex, valid_ex_mem, valid_mem_wb;


    wire [`WORD_SIZE-1:0] predicted_pc;    

    // wire interconnects 
    wire [`WORD_SIZE-1:0] current_pc;
    wire control_instruction_read;

    wire control_pcsrccond;
    wire control_memread, control_memwrite;

    wire [`WORD_SIZE-1:0] out_memtoreg_mux;


    wire [11:0] ex_j_instruction;


    // pipeline Registers

    // interconnects
        wire [`WORD_SIZE-1:0] instruction, id_next_pc, id_instruction;
        wire [`WORD_SIZE-1:0] ex_next_pc, id_regout1, id_regout2, id_sign_ext, ex_regout1, ex_regout2, ex_sign_ext;

        wire [`WORD_SIZE-1:0] ex_calculated_next_pc, mem_calculated_next_pc, mem_next_pc, ex_alu_result, mem_alu_result, mem_regout2, mem_memory_read_output, wb_memory_read_output, wb_alu_result;


        wire [`EX_SIGNAL_SIZE-1:0] id_ex_control_signal, ex_ex_control_signal;
        wire [`MEM_SIGNAL_SIZE-1:0] id_mem_control_signal, ex_mem_control_signal, mem_mem_control_signal;
        wire [`WB_SIGNAL_SIZE-1:0] id_wb_control_signal, ex_wb_control_signal, mem_wb_control_signal, wb_wb_control_signal;

        wire [`REG_ADDR_SIZE-1:0] id_regaddr_rt, id_regaddr_rd, ex_regaddr_rt, ex_regaddr_rd, ex_regdst_out, mem_regdst_out, wb_regdst_out;
        

        wire ex_branch_condition, mem_branch_condition;

        

        wire [1:0] control_next_addr;

    wire [`WORD_SIZE-1:0] if_next_pc_add_1, id_next_pc_add_1, ex_next_pc_add_1, mem_next_pc_add_1, wb_next_pc_add_1;
    wire [`WORD_SIZE-1:0] pc_to_bp;

    REG_PIPELINE_IF_ID if_id_reg(
    	.clk            (Clk            ),
        .reset_n        (Reset_N        ),
        .enable_if_id   (enable_if_id   ),
        .next_pc        (predicted_pc   ),
        .instruction    (instruction    ),
        .id_next_pc     (id_next_pc     ),
        .id_instruction (id_instruction ),
        .valid_if_id(valid_if_id),
        .if_next_pc_add_1(if_next_pc_add_1),
        .id_next_pc_add_1(id_next_pc_add_1),
        .if_id_this_inst_pc(current_pc),
        .id_this_inst_pc(pc_to_bp)
    );


    // Wire regouts for on/off data forwarding
    wire [`WORD_SIZE-1:0] id_to_ex_regout1, id_to_ex_regout2;
    assign id_to_ex_regout1 = `FORWARDING_UNIT_ENABLED ? id_fwd_regout1 : id_regout1;
    assign id_to_ex_regout2 = `FORWARDING_UNIT_ENABLED ? id_fwd_regout2 : id_regout2;

    REG_PIPELINE_ID_EX id_ex_reg(
    	.clk                      (Clk                      ),
        .reset_n                  (Reset_N                  ),
        .enable_id_ex             (enable_id_ex             ),
        .id_next_pc               (id_next_pc               ),
        .ex_next_pc               (ex_next_pc               ),
        .id_ex_control_signal     (id_ex_control_signal     ),
        .id_mem_control_signal    (id_mem_control_signal    ),
        .id_wb_control_signal     (id_wb_control_signal     ),
        .ex_ex_control_signal     (ex_ex_control_signal     ),
        .ex_mem_control_signal    (ex_mem_control_signal    ),
        .ex_wb_control_signal     (ex_wb_control_signal     ),
        .id_regout1               (id_to_ex_regout1),
        .id_regout2               (id_to_ex_regout2),
        .id_sign_ext              (id_sign_ext              ),
        .id_regaddr_rt            (id_regaddr_rt            ),
        .id_regaddr_rd            (id_regaddr_rd            ),
        .ex_regout1               (ex_regout1               ),
        .ex_regout2               (ex_regout2               ),
        .ex_sign_ext              (ex_sign_ext              ),
        .ex_regaddr_rt            (ex_regaddr_rt            ),
        .ex_regaddr_rd            (ex_regaddr_rd            ),
        .id_j_instruction (id_instruction[11:0]),
        .ex_j_instruction(ex_j_instruction),
        .valid_id_ex(valid_id_ex),
        .id_next_pc_add_1(id_next_pc_add_1),
        .ex_next_pc_add_1(ex_next_pc_add_1)
    );

    REG_PIPELINE_EX_MEM ex_mem_reg(
    	.clk                      (Clk                      ),
        .reset_n                  (Reset_N                  ),
        .enable_ex_mem            (enable_ex_mem            ),
        .ex_calculated_next_pc    (ex_calculated_next_pc    ),
        .ex_next_pc               (ex_next_pc               ),
        .mem_calculated_next_pc   (mem_calculated_next_pc   ),
        .mem_next_pc              (mem_next_pc              ),
        .ex_mem_control_signal    (ex_mem_control_signal    ),
        .ex_wb_control_signal     (ex_wb_control_signal     ),
        .mem_mem_control_signal   (mem_mem_control_signal   ),
        .mem_wb_control_signal    (mem_wb_control_signal    ),
        .ex_branch_condition      (ex_branch_condition      ),
        .ex_alu_result            (ex_alu_result            ),
        .ex_regout2               (ex_regout2               ),
        .ex_regdst_out            (ex_regdst_out            ),
        .mem_branch_condition     (mem_branch_condition     ),
        .mem_alu_result           (mem_alu_result           ),
        .mem_regout2              (mem_regout2              ),
        .mem_regdst_out           (mem_regdst_out           ),
        .valid_ex_mem(valid_ex_mem),
        .ex_next_pc_add_1(ex_next_pc_add_1),
        .mem_next_pc_add_1(mem_next_pc_add_1)
    );
    REG_PIPELINE_MEM_WB mem_wb_reg(
    	.clk                      (Clk                      ),
        .reset_n                  (Reset_N                  ),
        .enable_mem_wb            (enable_mem_wb            ),
        .mem_wb_control_signal    (mem_wb_control_signal    ),
        .wb_wb_control_signal     (wb_wb_control_signal     ),
        .mem_memory_read_output   (mem_memory_read_output   ),
        .mem_alu_result           (mem_alu_result           ),
        .mem_regdst_out           (mem_regdst_out           ),
        .wb_memory_read_output    (wb_memory_read_output    ),
        .wb_alu_result            (wb_alu_result            ),
        .wb_regdst_out            (wb_regdst_out            ),
        .valid_mem_wb(valid_mem_wb),
        .mem_next_pc_add_1(mem_next_pc_add_1),
        .wb_next_pc_add_1(wb_next_pc_add_1)
    );
    
    // Memorycontroller unit
    Memcontroller memorycontroller(
    	.reset_n                  (Reset_N),
        .clk                      (Clk),
        .control_memread          (mem_mem_control_signal[1:1]),
        .control_memwrite         (mem_mem_control_signal[2:2]),
        .control_instruction_read (control_instruction_read),
        .address_instruction      (current_pc), 
        .address_data             (mem_alu_result),    // ex/mem
        // .data_instruction_write   (data_instruction_write   ),      TOCHK: inst write?
        .data_data_write          (mem_regout2),    // ex/mem
        .output_instruction       (instruction),         // if/id
        .output_data              (mem_memory_read_output),       // mem/wb
        .i_readM                  (i_readM   ),
        .i_writeM                 (i_writeM  ),
        .i_address                (i_address ),
        .i_data                   (i_data    ),
        .d_readM                  (d_readM   ),
        .d_writeM                 (d_writeM  ),
        .d_address                (d_address ),
        .d_data                   (d_data    )
    );
    
    wire [`WORD_SIZE-1:0] out_pcsrc_mux;

    wire control_pcsrc;

    wire [`WORD_SIZE-1:0] ex_mem_pc_add_1;
    branchpredictor branch_predictor(
    	.clk                    (Clk                    ),
        .reset_n                (Reset_N                ),
        .current_pc             (current_pc             ),
        .enable_if_id           (enable_if_id           ),
        .mem_branch_condition   (mem_branch_condition   ),
        .mem_next_pc_add_1 (mem_next_pc_add_1),
        .mem_calculated_next_pc (mem_calculated_next_pc ),
        .mem_pcwritecond        (mem_mem_control_signal[3:3]),
        .mem_pcwrite            (mem_mem_control_signal[0:0]),
        .mem_predict_miss       (mem_predict_miss       ),
        .bp_pc_latch            (bp_pc_latch            ),
        .predicted_pc           (predicted_pc           ),
        .pc_to_bp(pc_to_bp),
        .valid_ex_mem(valid_ex_mem),
        .ex_mem_pc_add_1(ex_mem_pc_add_1),
        .if_next_pc_add_1(if_next_pc_add_1),
        .id_instruction(id_instruction),
        .valid_if_id(valid_if_id),
        .i_address(i_address)
    );
    

    // IF stage
    Latch16 PC(
    	.clk     (Clk     ),
        .in      (predicted_pc),
        .enable  (bp_pc_latch),
        .reset_n (Reset_N ),
        .out     (current_pc)
    );

    
    // always read instruction memory
    assign control_instruction_read = 1;
    
    
    // ID stage: control with external module
    
    Control_Unit control_signal_gen(
    	.opcode     (id_instruction[15:12]),
        .funct      (id_instruction[5:0]),
        .ex_signal  (id_ex_control_signal),
        .mem_signal (id_mem_control_signal),
        .wb_signal  (id_wb_control_signal)
    );

    ID id_stage(
    	.reset_n               (Reset_N               ),
        .clk                   (Clk                   ),
        .id_instruction        (id_instruction        ),
        .id_regout1            (id_regout1            ),
        .id_regout2            (id_regout2            ),
        .id_sign_ext           (id_sign_ext           ),
        .id_regaddr_rt         (id_regaddr_rt         ),
        .id_regaddr_rd         (id_regaddr_rd         ),
        .control_regwrite      (wb_wb_control_signal[1:1]),
        .out_memtoreg_mux      (out_memtoreg_mux      ),
        .wb_regdst (wb_regdst_out)
    );

    // For data forwarding
    wire [`WORD_SIZE-1:0] id_fwd_regout1, id_fwd_regout2;

    // Forwarding Unit
    forwardunit dataforward(
    	.id_instruction         (id_instruction),
        .ex_regdst_addr         (ex_regdst_out),
        .ex_alu_result          (ex_alu_result),
        .ex_control_regwrite    (ex_wb_control_signal[1:1]),    // control_regwrite
        .ex_control_memread     (ex_mem_control_signal[1:1]),   // control_memread
        .mem_regdst_addr        (mem_regdst_out),
        .mem_alu_result         (mem_alu_result),
        .mem_memory_read_output (mem_memory_read_output),
        .mem_control_regwrite   (mem_wb_control_signal[1:1]),
        .mem_control_memread    (mem_mem_control_signal[1:1]),
        .wb_regdst_addr         (wb_regdst_out),
        .wb_memtoreg_mux        (out_memtoreg_mux),
        .wb_control_regwrite    (wb_wb_control_signal[1:1]),
        .id_regout1             (id_regout1),
        .id_regout2             (id_regout2),
        .id_fwd_regout1         (id_fwd_regout1),
        .id_fwd_regout2         (id_fwd_regout2)
    );
    
    

    // EX stage: external module
    

    EX ex_stage(
    	.ex_next_pc            (ex_next_pc),
        .ex_ex_control_signal  (ex_ex_control_signal),
        .ex_mem_control_signal (ex_mem_control_signal),
        .ex_wb_control_signal  (ex_wb_control_signal),
        .ex_regout1            (ex_regout1),
        .ex_regout2            (ex_regout2),
        .ex_sign_ext           (ex_sign_ext),
        .ex_regaddr_rt         (ex_regaddr_rt),
        .ex_regaddr_rd         (ex_regaddr_rd),
        .ex_calculated_next_pc (ex_calculated_next_pc),
        .ex_branch_condition   (ex_branch_condition),
        .ex_alu_result         (ex_alu_result),
        .ex_regdst_out         (ex_regdst_out),
        .j_instruction (ex_j_instruction),
        .ex_mem_pc_add_1(ex_mem_pc_add_1),
        .ex_next_pc_add_1(ex_next_pc_add_1)
    );
    
    

    // MEM stage
    // assign control_pcsrc = mem_branch_condition & mem_mem_control_signal[3:3];
    // mem_mem_control_signal[3:3] = pcwritecond
    




    

    // WB stage
    MUX16_2_1 memtoreg_Mux(
    	.inp0 (wb_alu_result),
        .inp1 (wb_memory_read_output),
        .sel  (wb_wb_control_signal[0:0]),
        .out  (out_memtoreg_mux)
    );
    // wb_wb_control_signal[0:0] = control_memtoreg

    // WWD output port assignment
    reg [`WORD_SIZE-1:0] latched_wwd;
    always @(negedge Clk) begin
        if (Reset_N == 0) begin
            latched_wwd <= 0;
        end
        else begin
            if(wb_wb_control_signal[3:3]) begin
               // enable wwd latch
               latched_wwd <= out_memtoreg_mux; 
            end
        end
    end
    assign output_port = latched_wwd;

    

    pipelinecontroller pipeline_controller(
    	.clk              (Clk              ),
        .reset_n          (Reset_N          ),
        .id_instruction   (id_instruction   ),
        .mem_predict_miss (mem_predict_miss ),
        .enable_if_id     (enable_if_id     ),
        .enable_id_ex     (enable_id_ex     ),
        .enable_ex_mem    (enable_ex_mem    ),
        .enable_mem_wb    (enable_mem_wb    ),
        .valid_if_id      (valid_if_id      ),
        .valid_id_ex      (valid_id_ex      ),
        .valid_ex_mem     (valid_ex_mem     ),
        .valid_mem_wb     (valid_mem_wb     ),
        .is_halted(is_halted),
        .ex_mem_control_memread(ex_mem_control_signal[1:1])
    );

    // TOFIX: HLT is halted chk
    always @(posedge Clk) begin
        if(Reset_N == 0) begin
            is_halted <= 0; 
        end
        else begin
            if (wb_wb_control_signal[2:2]) begin
                is_halted <= 1; 
            end
        end
    end
    /* always @(posedge wb_wb_control_signal[2:2]) begin
        is_halted <= 1; 
    end */
    
    // count number of instructions
    reg [`WORD_SIZE-1:0] num_inst;
    always @(posedge Clk) begin
        if (Reset_N == 0) begin
            num_inst <= 0; 
        end
        // TOCHK: Correct Method?
        else begin
            if (valid_mem_wb) begin
                num_inst <= num_inst + 1; 
            end 
        end
    end


endmodule

// IF/ID register
module REG_PIPELINE_IF_ID(
    input clk,
    input reset_n,
    input enable_if_id,

    input valid_if_id,
    input [`WORD_SIZE-1:0] if_next_pc_add_1,


    input  [`WORD_SIZE-1:0] next_pc,
    input  [`WORD_SIZE-1:0] instruction,
    input  [`WORD_SIZE-1:0] if_id_this_inst_pc,

    output reg [`WORD_SIZE-1:0] id_this_inst_pc,

    output reg [`WORD_SIZE-1:0] id_next_pc,
    output reg [`WORD_SIZE-1:0] id_instruction,
    output reg [`WORD_SIZE-1:0] id_next_pc_add_1
);
    always @(posedge clk) begin
        if (reset_n == 0) begin
            id_next_pc <= 0;
            id_instruction <= 0;
            id_next_pc_add_1 <= 0;
            id_this_inst_pc <= 0;
        end
        else begin
            if (enable_if_id == 1) begin
                id_next_pc <= next_pc;
                id_instruction <= instruction;
                id_next_pc_add_1 <= if_next_pc_add_1;
                id_this_inst_pc <= if_id_this_inst_pc;

            end 
        end 
    end
endmodule

// ID/EX register
module REG_PIPELINE_ID_EX(
    input clk,
    input reset_n,
    input enable_id_ex,

    input valid_id_ex,

    // Address Calculated
    input [`WORD_SIZE-1:0] id_next_pc,

    output reg [`WORD_SIZE-1:0] ex_next_pc,


    // Control Signals
    input [`EX_SIGNAL_SIZE-1:0]  id_ex_control_signal   ,
    input [`MEM_SIGNAL_SIZE-1:0] id_mem_control_signal   ,
    input [`WB_SIGNAL_SIZE-1:0]  id_wb_control_signal   ,

    output reg [`EX_SIGNAL_SIZE-1:0]  ex_ex_control_signal,
    output reg [`MEM_SIGNAL_SIZE-1:0] ex_mem_control_signal,
    output reg [`WB_SIGNAL_SIZE-1:0]  ex_wb_control_signal,


    // Data lines
    input [`WORD_SIZE-1:0] id_regout1,
    input [`WORD_SIZE-1:0] id_regout2,
    input [`WORD_SIZE-1:0] id_sign_ext,
    input [`REG_ADDR_SIZE-1:0] id_regaddr_rt,
    input [`REG_ADDR_SIZE-1:0] id_regaddr_rd,

    output reg [`WORD_SIZE-1:0] ex_regout1,
    output reg [`WORD_SIZE-1:0] ex_regout2,
    output reg [`WORD_SIZE-1:0] ex_sign_ext,
    output reg [`REG_ADDR_SIZE-1:0] ex_regaddr_rt,
    output reg [`REG_ADDR_SIZE-1:0] ex_regaddr_rd,


    input [`WORD_SIZE-1:0] id_next_pc_add_1,
    output reg [`WORD_SIZE-1:0] ex_next_pc_add_1,


    // for next addr mux
    input [11:0] id_j_instruction,
    output reg [11:0] ex_j_instruction
);

    // internal control signals
    reg [`EX_SIGNAL_SIZE-1:0]  internal_ex_ex_control_signal;
    reg [`MEM_SIGNAL_SIZE-1:0] internal_ex_mem_control_signal;
    reg [`WB_SIGNAL_SIZE-1:0]  internal_ex_wb_control_signal;
    // validity signal chk
    always @(*) begin
        if (valid_id_ex) begin
           ex_ex_control_signal = internal_ex_ex_control_signal;
           ex_mem_control_signal = internal_ex_mem_control_signal;
           ex_wb_control_signal = internal_ex_wb_control_signal;
        end
        else begin
            ex_ex_control_signal = 0;
            ex_mem_control_signal= 0;
            ex_wb_control_signal = 0;
        end
    end

    always @(posedge clk) begin
        if (reset_n == 0) begin
            ex_next_pc <= 0;
            internal_ex_ex_control_signal <= 0;
            internal_ex_mem_control_signal <= 0;
            internal_ex_wb_control_signal <= 0;
            ex_regout1 <= 0;
            ex_regout2 <= 0;
            ex_sign_ext <= 0;
            ex_regaddr_rt <= 0;
            ex_regaddr_rd <= 0;
            ex_j_instruction <= 0;
            ex_next_pc_add_1 <= 0;
        end
        else begin
            if (enable_id_ex == 1) begin
                ex_next_pc <= id_next_pc;
                internal_ex_ex_control_signal <= id_ex_control_signal   ;
                internal_ex_mem_control_signal <= id_mem_control_signal   ;
                internal_ex_wb_control_signal <= id_wb_control_signal   ;
                ex_regout1 <= id_regout1;
                ex_regout2 <= id_regout2;
                ex_sign_ext <= id_sign_ext;
                ex_regaddr_rt <= id_regaddr_rt;
                ex_regaddr_rd <= id_regaddr_rd;
                ex_j_instruction <= id_j_instruction;
                ex_next_pc_add_1 <= id_next_pc_add_1;
            end 
        end 
    end
endmodule

// EX/MEM register
module REG_PIPELINE_EX_MEM(
    input clk,
    input reset_n,
    input enable_ex_mem,

    input valid_ex_mem,

    // Address Calculated
    input [`WORD_SIZE-1:0] ex_calculated_next_pc,
    input [`WORD_SIZE-1:0] ex_next_pc,
    output reg [`WORD_SIZE-1:0] mem_calculated_next_pc,
    output reg [`WORD_SIZE-1:0] mem_next_pc,

    // Control Signals
    input [`MEM_SIGNAL_SIZE-1:0] ex_mem_control_signal   ,
    input [`WB_SIGNAL_SIZE-1:0]  ex_wb_control_signal   ,
    output reg [`MEM_SIGNAL_SIZE-1:0] mem_mem_control_signal,
    output reg [`WB_SIGNAL_SIZE-1:0]  mem_wb_control_signal,

    
    // Data lines
    input ex_branch_condition,
    input [`WORD_SIZE-1:0] ex_alu_result,
    input [`WORD_SIZE-1:0] ex_regout2,
    input [`REG_ADDR_SIZE-1:0] ex_regdst_out,
    
    output reg mem_branch_condition,
    output reg [`WORD_SIZE-1:0] mem_alu_result,
    output reg [`WORD_SIZE-1:0] mem_regout2,
    output reg [`REG_ADDR_SIZE-1:0] mem_regdst_out,


    input [`WORD_SIZE-1:0] ex_next_pc_add_1,
    output reg [`WORD_SIZE-1:0] mem_next_pc_add_1
    

);

    // internal control signals
    reg [`MEM_SIGNAL_SIZE-1:0] internal_mem_mem_control_signal;
    reg [`WB_SIGNAL_SIZE-1:0]  internal_mem_wb_control_signal;
    // validity signal chk
    always @(*) begin
        if (valid_ex_mem) begin
           mem_mem_control_signal = internal_mem_mem_control_signal;
           mem_wb_control_signal = internal_mem_wb_control_signal;
        end
        else begin
            mem_mem_control_signal= 0;
            mem_wb_control_signal = 0;
        end
    end

    always @(posedge clk) begin
        if (reset_n == 0) begin
            mem_calculated_next_pc <= 0;
            mem_next_pc <= 0;
            internal_mem_mem_control_signal <= 0;
            internal_mem_wb_control_signal <= 0;
            mem_branch_condition <= 0;
            mem_alu_result <= 0;
            mem_regout2 <= 0;
            mem_regdst_out <= 0;
            mem_next_pc_add_1 <= 0;
        end
        else begin
            if (enable_ex_mem == 1) begin
                mem_calculated_next_pc <= ex_calculated_next_pc;
                mem_next_pc <= ex_next_pc;
                internal_mem_mem_control_signal <= ex_mem_control_signal   ;
                internal_mem_wb_control_signal <= ex_wb_control_signal   ;
                mem_branch_condition <= ex_branch_condition;
                mem_alu_result <= ex_alu_result;
                mem_regout2 <= ex_regout2;
                mem_regdst_out <= ex_regdst_out;
                mem_next_pc_add_1 <= ex_next_pc_add_1;
                
            end 
        end 
    end
endmodule

// MEM/WB register
module REG_PIPELINE_MEM_WB(
    input clk,
    input reset_n,
    input enable_mem_wb,
    input valid_mem_wb,

    input [`WORD_SIZE-1:0] mem_next_pc_add_1,
    output reg [`WORD_SIZE-1:0] wb_next_pc_add_1,

    // Control Signals
    input [`WB_SIGNAL_SIZE-1:0] mem_wb_control_signal   ,

    output reg [`WB_SIGNAL_SIZE-1:0] wb_wb_control_signal,
    
    // Data lines
    input [`WORD_SIZE-1:0] mem_memory_read_output,
    input [`WORD_SIZE-1:0] mem_alu_result,
    input [`REG_ADDR_SIZE-1:0] mem_regdst_out,
    
    output reg [`WORD_SIZE-1:0] wb_memory_read_output,
    output reg [`WORD_SIZE-1:0] wb_alu_result,
    output reg [`REG_ADDR_SIZE-1:0] wb_regdst_out

);

    // internal control signals
    reg [`WB_SIGNAL_SIZE-1:0]  internal_wb_wb_control_signal;
    // validity signal chk
    always @(*) begin
        if (valid_mem_wb) begin
            wb_wb_control_signal = internal_wb_wb_control_signal;
        end
        else begin
            wb_wb_control_signal = 0;
        end
    end

    always @(posedge clk) begin
        if (reset_n == 0) begin
            internal_wb_wb_control_signal <= 0;
            wb_memory_read_output <= 0;
            wb_alu_result <= 0;
            wb_regdst_out <= 0;
            wb_next_pc_add_1 <= 0;
        end
        else begin
            if (enable_mem_wb == 1) begin
                internal_wb_wb_control_signal <= mem_wb_control_signal   ;
                wb_memory_read_output <= mem_memory_read_output;
                wb_alu_result <= mem_alu_result;
                wb_regdst_out <= mem_regdst_out;
                wb_next_pc_add_1 <= mem_next_pc_add_1;
            end 
        end 
    end
endmodule

`endif