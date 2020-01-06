// Author: JHYeom (zhixian001)
`timescale 1ns/100ps

`ifdef WORD_SIZE
`else
`define WORD_SIZE 16
`endif

`include "basics.v"
`include "predictor.v"

`ifdef BRANCHPREDICTOR_V
`else
`define BRANCHPREDICTOR_V

/* 
PC+1 Branch Predictor
detects branch hazard too

branch misprediction signal will work conmbinational as combinational logic.



*/

module branchpredictor(
    input clk,
    input reset_n,
    // input [`WORD_SIZE-1:0] id_opcode,
    input [`WORD_SIZE-1:0] current_pc,
    input valid_if_id,
    input [`WORD_SIZE-1:0] id_instruction,

    // Control signal from pipeline controller. instruction fetch handler
    input enable_if_id,

    input [`WORD_SIZE-1:0] i_address,

    input mem_branch_condition,
    input [`WORD_SIZE-1:0] mem_next_pc_add_1,
    input [`WORD_SIZE-1:0] mem_calculated_next_pc,

    // control signals
    input mem_pcwritecond,
    input mem_pcwrite,
    input [`WORD_SIZE-1:0] pc_to_bp,        // current instruction's address
    input valid_ex_mem,

    // input feedback,  // feedback will evaluated insde BP
    output reg mem_predict_miss,
    
    output reg bp_pc_latch,
    output [`WORD_SIZE-1:0] predicted_pc,
    output [`WORD_SIZE-1:0] ex_mem_pc_add_1,
    output reg [`WORD_SIZE-1:0] if_next_pc_add_1
);

    reg [`WORD_SIZE-1:0] predicted_pc_internal;
    wire [`WORD_SIZE-1:0] predicted_pc_inout;

    // pc+1?
    wire [`WORD_SIZE-1:0] option_pc_1;
    assign current_pc_add_1 = option_pc_1;

    ADD16 PC_Adder(
    	.n1  (current_pc),
        .n2  (16'h1),
        .out (option_pc_1)
    );
    reg [`WORD_SIZE-1:0] id_ex_pc_add_1, ex_mem_pc_add_1;
    reg [`WORD_SIZE-1:0] mem_wb_pc_add_1, wb_end_pc_add_1;
    reg [`WORD_SIZE-1:0] id_pc_to_bp, ex_pc_to_bp;



    reg internal_bp_pc_latch;
    reg [`WORD_SIZE-1:0] internal_predicted_from_bf;

    /* OLD Predictor// always predict pc+1
    always @(*) begin
        internal_predicted_from_bf = option_pc_1;
    end */

    reg [`WORD_SIZE-1:0] feedback_pc;

    // inout port usage
    assign predicted_pc = mem_predict_miss ? predicted_pc_internal : predicted_pc_inout;
    assign predicted_pc_inout = mem_predict_miss ? predicted_pc_internal : `WORD_SIZE'hz;

    // Real Branch Predictor
    predictor mypredictor(
    	.clk                 (clk),
        .reset_n             (reset_n),
        .previous_pc         (pc_to_bp),
        .if_stage_pc (i_address),
        .enable_pc           (bp_pc_latch),
        .mispredict_feedback (mem_predict_miss),
        .predicted_pc_inout  (predicted_pc_inout),
        .id_instruction      (id_instruction),
        .valid_if_id(valid_if_id)
    );

    // current pc + 1?
    always @(*) begin
        if_next_pc_add_1 = current_pc + 1;
    end

    // Sequential part
    always @(posedge clk) begin
        if (reset_n == 0) begin
            mem_predict_miss <= 0;
            id_ex_pc_add_1 <= 0;
            ex_mem_pc_add_1 <= 0;
            mem_wb_pc_add_1 <= 0;
            wb_end_pc_add_1 <= 0;
            predicted_pc_internal <= 0;
            // internal_predicted_from_bf <= 0;
            id_pc_to_bp <= 0;
            ex_pc_to_bp <= 0;
            feedback_pc <= 0;
        end
        else begin
            id_ex_pc_add_1 <= if_next_pc_add_1;
            ex_mem_pc_add_1 <= id_ex_pc_add_1;
            mem_wb_pc_add_1 <= ex_mem_pc_add_1;
            wb_end_pc_add_1 <= mem_wb_pc_add_1;
            feedback_pc <= pc_to_bp;
            id_pc_to_bp <= pc_to_bp + 1; 
            ex_pc_to_bp <= id_pc_to_bp;

            /* if (BTag[current_pc_hash:current_pc_hash] == 1) begin
                // prediction table exist 
            end  */
            // TODO: BTB
        end
    end

    // PC update logic
    always @(*) begin
        if (enable_if_id || internal_bp_pc_latch) begin
            bp_pc_latch = 1; 
        end
        else begin
            bp_pc_latch = 0; 
        end
    end


    

    // PC predict evaluation logic
    always @(*) begin

        if (valid_ex_mem) begin
            if (mem_pcwritecond) begin
                if (mem_branch_condition) begin
                    if (mem_calculated_next_pc == feedback_pc) begin
                        // correct
                        mem_predict_miss = 0;
                        predicted_pc_internal = predicted_pc_inout;
                        internal_bp_pc_latch = 0;
                    end
                    else begin
                        // wrong
                        // if (valid_if_id) begin 
                            mem_predict_miss = 1;
                            predicted_pc_internal = mem_calculated_next_pc;
                            internal_bp_pc_latch = 1;
                        // end
                        /* else begin
                            mem_predict_miss = 0;
                        end */
                    end
                end
                else begin
                    if (mem_calculated_next_pc == mem_next_pc_add_1) begin
                    // if (mem_calculated_next_pc == pc_to_bp) begin

                        // correct
                        mem_predict_miss = 0;
                        predicted_pc_internal = predicted_pc_inout;
                        internal_bp_pc_latch = 0;
                    end
                    else begin
                        // wrong
                        // if (valid_if_id) begin 
                            mem_predict_miss = 1;
                            predicted_pc_internal = mem_next_pc_add_1;
                            internal_bp_pc_latch = 1;
                        // end
                        /* else begin
                            mem_predict_miss = 0;
                        end */
                    end
                    
                end
            end
            else begin
                if (mem_pcwrite) begin
                    if (mem_calculated_next_pc == feedback_pc) begin
                        // correct
                        mem_predict_miss = 0;
                        predicted_pc_internal = predicted_pc_inout;
                        internal_bp_pc_latch = 0;
                    end
                    else begin
                        // wrong
                        // if (valid_if_id) begin 
                            mem_predict_miss = 1;
                            predicted_pc_internal = mem_calculated_next_pc;
                            internal_bp_pc_latch = 1;
                        // end
                        /* else begin
                            mem_predict_miss = 0;
                        end */
                    end
                end
                else begin
                    if (mem_calculated_next_pc == feedback_pc) begin
                        // correct
                        mem_predict_miss = 0;
                        predicted_pc_internal = predicted_pc_inout;
                        internal_bp_pc_latch = 0;
                    end
                    else begin
                        // wrong
                        // if (valid_if_id) begin 
                            mem_predict_miss = 1;
                            predicted_pc_internal = mem_next_pc_add_1;
                            internal_bp_pc_latch = 1;
                        // end
                        /* else begin
                            mem_predict_miss = 0;
                        end */
                    end
                end
            end
        end
        else begin
            mem_predict_miss = 0;
            predicted_pc_internal = predicted_pc_inout;
            internal_bp_pc_latch = 0; 
        end





    end

endmodule

`endif
