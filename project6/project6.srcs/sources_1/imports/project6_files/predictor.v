// Author: JHYeom (zhixian001)
`timescale 1ns/100ps

`ifdef WORD_SIZE
`else
`define WORD_SIZE 16
`endif

`include "basics.v"
`include "config.v"
`include "opcodes.v"

`ifdef PREDICTOR_V
`else
`define PREDICTOR_V

module predictor(
    input clk,
    input reset_n,
    input [`WORD_SIZE-1:0] if_stage_pc,     // if stage instruction's pc
    input [`WORD_SIZE-1:0] previous_pc,     // id stage instruction's pc
    input [`WORD_SIZE-1:0] id_instruction,
    input enable_pc,
    input valid_if_id,


    input mispredict_feedback,
    
    inout [`WORD_SIZE-1:0] predicted_pc_inout
);

    // History
    reg [`WORD_SIZE-1:0] history    ;

    // prediction result
    reg [`WORD_SIZE-1:0] predicted_pc;
    // if feedback is negative take actual value
    assign predicted_pc_inout = mispredict_feedback ? `WORD_SIZE'hz : predicted_pc;



    // Decode instruction for branch tags
    wire [3:0] op;
    wire [5:0] funct;
    assign op = id_instruction[15:12];
    assign funct = id_instruction[5:0];
    reg id_stage_is_branch;
    always @(*) begin
        if ((op == 4'd15) && ((funct == `FUNC_JPR) || (funct == `FUNC_JRL))) begin
            id_stage_is_branch = 1; 
        end
        else if (((op >= `OPCODE_BNE) && (op <= `OPCODE_BLZ)) || ((op >= `OPCODE_JMP) && (op <= `OPCODE_JAL))) begin
            id_stage_is_branch = 1;
        end
        else begin
            id_stage_is_branch = 0;
        end
    end


    



    
    
    // PC Hash
    wire [7:0] if_stage_pc_hash;
    wire [7:0] id_stage_pc_hash;
    // Hash history
    reg [7:0] wb_stage_pc_hash, mem_stage_pc_hash, ex_stage_pc_hash;



    // FIXME:
    assign if_stage_pc_hash = if_stage_pc[7:0];
    assign id_stage_pc_hash = previous_pc[7:0];



    // assign id_stage_pc_hash = updated_pc[7:0];


    // BRANCH PREDICTION METHODS!
    // history exist or not table
    reg [255:0] history_exist_table;

    // 2bit BHT of size 2^8
    // I will use hysteresis counter. initial value is 2'b10 or 2'b01
    reg [1:0] branch_history_table [0:255];

    // Tags table (1: branch or jump, 0: no)
    reg [255:0] branch_tags_table;

    // Branch Target Buffer
    reg [`WORD_SIZE-1:0] branch_target_buffer [0:255];



    



    // Prediction of Table
    reg [`WORD_SIZE-1:0] table_prediction_result;

    // T BHT BTB combinational logic: table_prediction_result. 
    always @(*) begin
        // predict correct
        if (mispredict_feedback == 0) begin
            // Histroy exist
            if (history_exist_table[if_stage_pc_hash+:1]) begin
                
                // CHECK hysteresis
                if (branch_history_table[if_stage_pc_hash] >= 2'b10) begin
                    // taken
                    table_prediction_result = branch_target_buffer[if_stage_pc_hash];
                end
                else begin
                    // Not taken
                    table_prediction_result = history + 1; 
                end
                
            end
            // History Not Exist. Need to predict pc + 1
            // and update table
            else begin
                // predict pc+1
                table_prediction_result = history + 1;
            end

        end

        // TOCHK: predict wrong
        else begin
            table_prediction_result = history + 1;
        end

        // BP switch
        if (`BRANCH_PREDICTION_ENABLED) begin
            predicted_pc = table_prediction_result;
        end
    end






    // Sequential logic for Tables
    always @(posedge clk) begin
        // predict correct and advancing PC. Can update tables
            if(valid_if_id) begin
                // update tables
                history_exist_table[ex_stage_pc_hash+:1] <= 1;

                // branch_tags_table[ex_stage_pc_hash+:1] <= id_stage_is_branch;

                if (history_exist_table[ex_stage_pc_hash+:1] == 0) begin
                    branch_history_table[ex_stage_pc_hash] <= 2'b01;
                    branch_target_buffer[ex_stage_pc_hash] <= previous_pc;
                end
            end

                // branch_target_buffer[id_stage_pc_hash] <= table_prediction_result;
            // end            
        // end


        // Feedbacks
        if(reset_n && history_exist_table[mem_stage_pc_hash+:1] && enable_pc) begin

            // hysteresis
            if (`BRANCH_PREDICTOR_COUNTER_TYPE) begin
                // Correct Prediction feedback
                if (mispredict_feedback == 0) begin
                    if (branch_history_table[mem_stage_pc_hash] == 2'b11) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b11;
                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b10) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b11;
                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b01) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b00;
                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b00) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b00;
                    end
                end

                // Wrong Prediction Feedback (hysteresis method)
                else begin      // enable PC ?? condition
                    // Counter update
                    if (branch_history_table[mem_stage_pc_hash] == 2'b11) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b10;
                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b10) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b00;
                        branch_target_buffer[mem_stage_pc_hash] <= predicted_pc_inout;
                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b01) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b11;
                        branch_target_buffer[mem_stage_pc_hash] <= predicted_pc_inout;

                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b00) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b01;    

                    end

                    // Update BTB
                    // branch_target_buffer[mem_stage_pc_hash] <= predicted_pc_inout;
                end
            end
            // hysteresis
            else begin
                // Correct Prediction feedback
                if (mispredict_feedback == 0) begin
                    if (branch_history_table[mem_stage_pc_hash] == 2'b11) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b11;
                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b10) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b11;
                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b01) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b00;
                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b00) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b00;
                    end
                end

                // Wrong Prediction Feedback (hysteresis method)
                else begin      // enable PC ?? condition
                    // Counter update
                    if (branch_history_table[mem_stage_pc_hash] == 2'b11) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b10;
                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b10) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b01;
                        branch_target_buffer[mem_stage_pc_hash] <= predicted_pc_inout;
                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b01) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b10;
                        branch_target_buffer[mem_stage_pc_hash] <= predicted_pc_inout;

                    end
                    else if (branch_history_table[mem_stage_pc_hash] == 2'b00) begin
                        branch_history_table[mem_stage_pc_hash] <= 2'b01;    

                    end

                    // Update BTB
                    // branch_target_buffer[mem_stage_pc_hash] <= predicted_pc_inout;
                end
            end

        end

    end

    
    

    always @(posedge clk) begin
        // reset
        if (reset_n == 0) begin
            predicted_pc <= 0;
            history <= 0;
            history_exist_table <= 256'b0;
            // initialize branch tags table
            branch_tags_table <= 256'b0;
            mem_stage_pc_hash <= 0;
            ex_stage_pc_hash <= 0;
            wb_stage_pc_hash <= 0;

        end 
        else if (enable_pc) begin
            // Correct predict case
            ex_stage_pc_hash <= id_stage_pc_hash;
            mem_stage_pc_hash <= ex_stage_pc_hash;
            wb_stage_pc_hash <= mem_stage_pc_hash;
            // mem_stage_pc_hash <= id_stage_pc_hash;


            if (mispredict_feedback == 0) begin
                // Branch Prediction Enabled!
                if (`BRANCH_PREDICTION_ENABLED) begin
                    if (valid_if_id) begin
                        history <= table_prediction_result;
                    end
                    else begin
                        history <= history + 1; 
                    end
                        
                    // predicted_pc <= table_prediction_result;
                end

                // Branch Prediction Disabled! (always predict PC+1)
                else begin
                    history <= history + 1;
                    predicted_pc <= history + 1;
                end
            end

            // prediction wrong feedback
            else begin
                if (`BRANCH_PREDICTION_ENABLED) begin
                    // TODO: TOCHK: FIXME:
                    // history <= predicted_pc_inout;
                    // predicted_pc <= table_prediction_result;

                    if (valid_if_id) begin
                        history <= predicted_pc_inout;
                    end
                    
                    
                end
                else begin
                    // if (valid_if_id) begin
                    history <= predicted_pc_inout + 1;
                    predicted_pc <= predicted_pc_inout + 1;
                    // end
                end
                
            end
        end
    end

endmodule

`endif
