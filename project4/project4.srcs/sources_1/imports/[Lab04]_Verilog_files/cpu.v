///////////////////////////////////////////////////////////////////////////
// MODULE: CPU for TSC microcomputer: cpu.v
// Author: JHYeom (zhixian001)
// Description:

// DEFINITIONS
`define WORD_SIZE 16    // data and address word size

// INCLUDE files
`include "opcodes.v"    // "opcode.v" consists of "define" statements for
// the opcodes and function codes for all instructions
`include "ALU.v"
`include "regfile.v"

// MODULE DECLARATION
module cpu (
    output reg readM,                           // read from memory
    output [`WORD_SIZE-1:0] address,            // current address for data
    inout [`WORD_SIZE-1:0] data,                // data being input or output
    input inputReady,                           // indicates that data is ready from the input port
    input reset_n,                              // active-low RESET signal
    input clk,                                  // clock signal
    output reg [`WORD_SIZE-1:0] num_inst,       // number of instruction during execution
    output reg [`WORD_SIZE-1:0] output_port     // this will be used for a "WWD" instruction
    );
    
    // Variables
    reg [15:0] instruction_reg;                 // Instruction reg to catch memory input
    wire [`WORD_SIZE-1:0] output_port_wire;     
    // Variables for interconnect control module and data module
    wire regdst, jump, bcond, anded_branch, memread, memtoreg, memwrite, alusrc, regwrite;
    wire [5:0] aluop;
    // Variable for connect current pc value to address
    wire [`WORD_SIZE-1:0] current_address;
    assign address = current_address >> 2;

    // always @(address) begin
        // $display("PC>>2 : %d", address);
    // end

    // output_port
    always @(*) begin
        // My implementation does not float value
        output_port = output_port_wire;
    end

    // Memory Controller(Asynchronous read?)
    always @(posedge inputReady) begin          // add sensitivity list to avoid doing job twice
        if ((readM == 1) && (inputReady == 1)) begin
            readM = 0;
            instruction_reg = data;             // latch data
            num_inst = num_inst + 1;
            // $display("Instruction: %d, %h", num_inst, instruction_reg);
        end
    end

    // Synchronous sequential logic
    always @(posedge clk) begin
        if (reset_n == 0) begin
            // reset
            num_inst <= 0;
            readM <= 1'b1;
            // $display("RESET, NUMINST: %d", num_inst);
        end
        else begin
            readM <= 1'b1;                      // always clock posedge set readM = 1
            // $display("CLOCK, NUMINST: %d", num_inst);
        end
        // $display("%h", data);
    end


    DATAPATH datapath (
        .reset_n(reset_n),
        .clk(clk),
        .instruction(instruction_reg[11:0]),     // TOCHK:
        .regdst(regdst),
        .jump(jump),
        .anded_branch(anded_branch),
        .memread(memread),
        .memtoreg(memtoreg),
        .decoded_alu_op(aluop), 
        .memwrite(memwrite),
        .alusrc(alusrc),
        .regwrite(regwrite),
        .bcond(bcond),
        .current_pc(current_address),      // TOCHK:
        .data_out(output_port_wire),
        .wb_address(),
        .memwrite_data()               // TOCHK:
    );
    
    CONTROL_UNIT controlunit (
        .instruction_f(instruction_reg[15:12]),   // TOCHK:
        .funct(instruction_reg[5:0]),           // TOCHK:
        .bcond(bcond),
        .regdst(regdst),
        .jump(jump),
        .anded_branch(anded_branch),
        .memread(memread),
        .memtoreg(memtoreg),
        .aluop(aluop),
        .memwrite(memwrite),
        .alusrc(alusrc),
        .regwrite(regwrite) 
    );
    
endmodule

module DATAPATH (
    input reset_n,                  // active-low reset signal
    input clk,                      // Clock signal
    input [11:0] instruction,       // [12] Instruction
    input regdst,                   // Control signal
    input jump,                     // Control signal
    input anded_branch,             // Control signal
    input memread,                  // Control signal
    input memtoreg,                 // Control signal
    input [5:0] decoded_alu_op,     // [6] Control signal
    input memwrite,                 // Control signal
    input alusrc,                   // Control signal
    input regwrite,                 // Control signal

    output bcond,                           // Branch Control signal calculated from ALU
    output [`WORD_SIZE-1:0] current_pc,     // [16] Current PC address.
    output [`WORD_SIZE-1:0] data_out,       // [16] Data output Port 
    output [`WORD_SIZE-1:0] wb_address,     // [16] MemWriteback address (Not Used) 
    output [`WORD_SIZE-1:0] memwrite_data   // [16] MemWriteback data (Not Used)

);
    // Wire Variables (detailed explanation is in my report)
    wire [1:0] out_rimux;
    wire [`WORD_SIZE-1:0] out_regfile1, out_regfile2;
    wire [`WORD_SIZE-1:0] out_signextend;
    wire [`WORD_SIZE-1:0] out_branchshift;
    wire [`WORD_SIZE-1:0] out_branchadd;
    wire [`WORD_SIZE-1:0] out_add4;
    wire [`WORD_SIZE-1:0] out_jumpshift;
    wire [`WORD_SIZE-1:0] out_jumpshift_concat;
    wire [`WORD_SIZE-1:0] out_jumpmux;      // = next_pc
    wire [`WORD_SIZE-1:0] out_branchmux;
    wire [`WORD_SIZE-1:0] out_alu;
    wire [`WORD_SIZE-1:0] out_regwbdatamux;
    // wire [`WORD_SIZE-1:0] out_pc;           // = current_pc
    wire [`WORD_SIZE-1:0] out_branchcondmux;

    // wire assignment according to my report's design
    assign out_jumpshift_concat = {out_add4[15:14], out_jumpshift[13:0]};   // concate two wires
    assign data_out = out_regwbdatamux;     // data out part
    assign wb_address = out_alu;       // FIXME: wb_address
    assign memwrite_data = memwrite? out_regfile2 : 15'bz;

    // PC
    PC pc(
        .next_pc(out_jumpmux),
        .reset_n(reset_n),
        .clk(clk),
        .current_pc(current_pc)
    );

    ALU alu (
        .A(out_regfile1),
        .B(out_branchcondmux),
        .Cin(1'b0),     // TOCHK: see etl board
        .OP(decoded_alu_op),
        .C(out_alu),
        .Cout(),        // TOCHK: see etl
        .BCond(bcond)
    );

    RF regfile (
        .write(regwrite),
        .clk(clk),
        .reset_n(reset_n),
        .addr1(instruction[11:10]),
        .addr2(instruction[9:8]),
        .addr3(out_rimux),
        .data3(out_regwbdatamux),
        .data1(out_regfile1),
        .data2(out_regfile2)
    );

    // MUX declarations
    MUX2_2_1 RI_MUX(
        .inp0(instruction[9:8]), 
        .inp1(instruction[7:6]),
        .sel(regdst),
        .out(out_rimux)
    );
    
    MUX16_2_1 BRANCHCOND_MUX(
        .inp0(out_regfile2),
        .inp1(out_signextend),
        .sel(alusrc),
        .out(out_branchcondmux)
    );
    MUX16_2_1 REGWBDATA_MUX(
        .inp0(out_alu),
        .inp1(),        // TOCHK: Not implemented yet
        .sel(memtoreg),
        .out(out_regwbdatamux)
    );
    MUX16_2_1 BRANCH_MUX(
        .inp0(out_add4),
        .inp1(out_branchadd),
        .sel(anded_branch),
        .out(out_branchmux)
    );
    MUX16_2_1 JUMP_MUX(
        .inp0(out_branchmux),
        .inp1(out_jumpshift_concat),
        .sel(jump),
        .out(out_jumpmux)
    );

    // Sign extend module
    SIGN_EXTEND8_16 SIGN_EXTEND(
        .inp(instruction[7:0]),
        .out(out_signextend)
    );

    // shift left 2 modules
    SHIFTLEFT2_16 BRANCHSHIFT(
        .inp(out_signextend),
        .out(out_branchshift)
    );

    SHIFTLEFT2_16 JUMPSHIFT(
        .inp({4'b0000, instruction[11:0]}),
        .out(out_jumpshift)
    );

    // add modules
    ADD16 add4 (
        .n1(current_pc),
        .n2(16'd4),
        .out(out_add4)
    );

    ADD16 branchadd(
        .n1(out_add4),
        .n2(out_branchshift),
        .out(out_branchadd)
    );

endmodule

module CONTROL_UNIT (
    input [3:0] instruction_f,      // [4] instruction opcode
    input [5:0] funct,              // [6] least 6bits of opcode to generate alu control code
    input bcond,                    // branch condition calculated from ALU
    output reg regdst,              // Control Signal
    output reg jump,                // Control Signal
    output anded_branch,            // Control Signal
    output reg memread,             // Control Signal
    output reg memtoreg,            // Control Signal
    output [5:0] aluop,             // [6] Control Signal
    output reg memwrite,            // Control Signal
    output reg alusrc,              // Control Signal
    output reg regwrite             // Control Signal
);

    // reg for store original aluop
    reg [5:0] aluop;

    // reg for branch control signal
    reg branch;
    // branch condition and gate.
    assign anded_branch = bcond & branch;

    // ALU_CONTROL alu_cont (
    //     .funct(funct),
    //     .aluop(aluop),
    //     .decoded_aluop(decoded_aluop)
    // );

    always @(*) begin
        if(instruction_f == 4'd15) begin
            // R type
            regdst = 1;
            jump = 0;
            branch = 0; 
            memread = 0;
            memtoreg = 0; 
            aluop = funct;
            memwrite = 0;
            alusrc = 0;
            if (funct == 6'b011100) begin
                // WWD case
                regwrite = 0;
            end
            else begin
                regwrite = 1;
            end
            // regwrite = 1;
        end
        else if(instruction_f <= 4'd8) begin
            // I type including branch instructions
            regdst = 0;
            jump = 0;
            branch = 1;    // TOCHK: How to handle branch? Not sure 
            memread = 0;
            memtoreg = 0;
            if (instruction_f == `OPCODE_ADI) begin
                aluop = `OP_ADI;
            end
            else if (instruction_f == `OPCODE_ORI) begin
                aluop = `OP_ORI;
            end
            else if (instruction_f == `OPCODE_LHI) begin
                aluop = `OP_LHI;
            end
            //TODO: More cases including brach instructions.
            
            memwrite = 0; 
            alusrc = 1;
            regwrite = 1;
        end
        else if((instruction_f == 4'd9) || (instruction_f == 4'd10)) begin
            // J type
            regdst = 0;
            jump = 1;
            branch = 0;
            memread = 0;
            memtoreg = 0; 
            aluop = 0;
            memwrite = 0;
            alusrc = 0;
            regwrite = 0;
        end
        else begin
            // Unhandled case
            regdst = 0;
            jump = 0;
            branch = 0;
            memread = 0;
            memtoreg = 0; 
            aluop = 0;
            memwrite = 0;
            alusrc = 0;
            regwrite = 0; 
        end
    end

endmodule

module MUX2_2_1(
    input [1:0] inp0,
    input [1:0] inp1,
    input sel,
    output [1:0] out
);
    // 2 bit wide 2:1 mux
    assign out = sel? inp1 : inp0;

endmodule

module MUX16_2_1(
    input [`WORD_SIZE-1:0] inp0,
    input [`WORD_SIZE-1:0] inp1,
    input sel,
    output [`WORD_SIZE-1:0] out 
);
    // 16 bit wide 2:1 mux
    assign out = sel? inp1 : inp0;

endmodule

module SIGN_EXTEND8_16(
    input [7:0] inp,
    output [`WORD_SIZE-1:0] out
);
    // 8 bit -> 16 bit sign extension module
    assign out = inp[7:7]? {8'hff, inp[7:0]} : {8'h00, inp[7:0]};
endmodule

module ADD16(
    input signed [`WORD_SIZE-1:0] n1,
    input signed [`WORD_SIZE-1:0] n2,
    output signed [`WORD_SIZE-1:0] out
);
    // two input 16 bit add module
    assign out = n1 + n2;
endmodule

module SHIFTLEFT2_16(
    input [`WORD_SIZE-1:0] inp,
    output [`WORD_SIZE-1:0] out
);
    // 16bit shift left 2 module
    assign out = inp << 2; 
endmodule

module PC (
    input [`WORD_SIZE-1:0] next_pc,
    input clk,
    input reset_n,
    output reg [`WORD_SIZE-1:0] current_pc
);
    // 16 bit PC
    always @(posedge clk) begin
        if (reset_n == 1'b0) begin
            current_pc <= 0;
        end
        else begin
            current_pc <= next_pc;
        end
        // $display("PC: %d", current_pc);
    end
endmodule

// module ALU_CONTROL(
//     input [5:0] funct,
//     input [5:0] aluop,
//     output reg [5:0] decoded_aluop
// );
//     always @(*) begin
//         if (aluop == 6'd0) begin
//             // R type case
//             decoded_aluop = funct;
//             // $display("r type %b", funct);
//         end
//         else begin
//             // I and j type case (j might be unhandled)
//             decoded_aluop = aluop;
//             // $display("i or j type %b", aluop);
//         end
//     end
// endmodule