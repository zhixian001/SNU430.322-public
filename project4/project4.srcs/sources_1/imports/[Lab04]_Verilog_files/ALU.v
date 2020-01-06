`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SNU
// Engineer: JHYeom (zhixian001)
// 
// Create Date: 2019/03/12 11:00:00
// Design Name: ALU for Computer Organization Class.
// Module Name: ALU
// Project Name: Project1 ALU
// Target Devices: Vivado Simulation
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision 0.20
// Additional Comments: Extended version of my ALU. OPCODE extended 4 to 6 bit. bcond output port added.
// 
//////////////////////////////////////////////////////////////////////////////////

// TOCHK: All operations keep their operand's bit-width.

// OPCODE Definitions
// RType [5:4] = 2'b00      // OP   F
`define OP_ADD 6'b000000    // 15   0 
`define OP_SUB 6'b000001    // 15   1
`define OP_AND 6'b000010    // 15   2
`define OP_ORR 6'b000011    // 15   3
`define OP_NOT 6'b000100    // 15   4
`define OP_TCP 6'b000101    // 15   5
`define OP_SHL 6'b000110    // 15   6       // shift left one bit. insert lsb 0
`define OP_SHR 6'b000111    // 15   7       // shift right one bit. keep sign
`define OP_RWD 6'b011011    // 15   27
`define OP_WWD 6'b011100    // 15   28
`define OP_JPR 6'b011001    // 15   25
`define OP_JRL 6'b011010    // 15   26
`define OP_HLT 6'b011101    // 15   29
`define OP_ENI 6'b011110    // 15   30
`define OP_DSI 6'b011111    // 15   31      Unn?
// Itype
`define OP_ADI 6'b100100    // 4            Unnecessary?
`define OP_ORI 6'b100101    // 5            Unnecessary?
`define OP_LHI 6'b100110    // 6            8bit concat
`define OP_LWD 6'b100111    // 7
`define OP_SWD 6'b101000    // 8
`define OP_BNE 6'b100000    // 0
`define OP_BEQ 6'b100001    // 1
`define OP_BGZ 6'b100010    // 2
`define OP_BLZ 6'b100011    // 3
// Jtype
`define OP_JMP 6'b101001    // 9
`define OP_JAL 6'b101010    // 10

module ALU(
    /* Main module of ALU.v
    INPUT:
        A   :    [16]    first operand
        B   :    [16]    second operand
        Cin :    [1]     carry in (Not Used)
        OP  :    [6]     opcode or ALU control code
    
    OUTPUT:
        C   : [16]      output
        Cout:  [1]      carry out (Not Used)
        BCond: [1]      Branch condition
    */

    input [15:0] A,
    input [15:0] B,
    input Cin,
    input [5:0] OP,
    output reg [15:0] C,
    output reg Cout,
    output reg BCond
    );

    // Signed Wire for add and sub

    always @(*) begin
        // R-Type OPCODEs
        if ((OP == `OP_ADD) || OP == `OP_ADI) begin
            // Addition
            C = A + B;     // TODO: Cin
            Cout = 0;      // TODO: OVF check later
            BCond = 0;  
            // if (OP == `OP_ADI) begin
                // $display("ADI Result = %d", C);
            // end   
        end
        else if (OP == `OP_SUB) begin
            // Subtraction
            C = A - B;     // TODO: Ci
            Cout = 0;      // TODO: OVF (underflow) check later
            BCond = 0; 
        end
        else if (OP == `OP_AND) begin
            // And operation
            C = A & B;
            Cout = 0;
            BCond = 0; 
        end
        else if ((OP == `OP_ORR) || (OP == `OP_ORI)) begin
            // Or operation
            C = A | B;
            Cout = 0;
            BCond = 0;     
        end
        else if (OP == `OP_NOT) begin
            // Not operation
            C = ~A;    
            Cout = 0;
            BCond = 0;
        end
        else if (OP == `OP_TCP) begin
            // Two's complemet operation
            C = ~A + 1'b1;     // TOCHK: correct?
            Cout = 0;
            BCond = 0; 
        end
        else if (OP == `OP_SHL) begin
            // Shift Left 1
            C = A << 1;
            Cout = 0;
            BCond = 0; 
        end
        else if (OP == `OP_SHR) begin
            // Shift right 1 arithmetic
            C = A >>> 1;
            Cout = 0;
            BCond = 0; 
        end
        else if (OP == `OP_RWD) begin
            // TOCHK: Consider Remove
        end
        else if (OP == `OP_WWD) begin
            // Same to OP_ID in previous ALU implementation
            // pass $rs to output.
            C = A;
            Cout = 0;
            BCond = 0; 
        end
        else if (OP == `OP_JPR) begin
            // TODO: How to load $rs to PC
        end
        else if (OP == `OP_JRL) begin
            // TODO: ?
        end
        else if (OP == `OP_HLT) begin
            // TOCHK: Remove?
        end
        else if (OP == `OP_ENI) begin
            // TOCHK: Not in manual
        end
        else if (OP == `OP_DSI) begin
            // TOCHK: Remove?
        end

        // I-Type opcodes
        else if (OP == `OP_LHI) begin
            // imm7..0 ## 8
            // B is sign extended value of imm. -> Slice least 8 bits.
            C = {B[7:0], 8'b00000000};
            Cout = 0;
            BCond = 0;
        end
        else if (OP == `OP_LWD) begin
            // $rs + imm
        end
        else if (OP == `OP_SWD) begin
            // $rs + imm
        end
        // I-Type Branch instructions
        else if (OP == `OP_BNE) begin
            if (A != B) begin
                C = 0;
                Cout = 0;
                BCond = 1; 
            end
            else begin
                C = 0;
                Cout = 0;
                BCond = 0; 
            end
        end
        else if (OP == `OP_BEQ) begin
            if (A == B) begin
                C = 0;
                Cout = 0;
                BCond = 1; 
            end
            else begin
                C = 0;
                Cout = 0;
                BCond = 0; 
            end
        end
        else if (OP == `OP_BGZ) begin
            if (A > 0) begin
                C = 0;
                Cout = 0;
                BCond = 1; 
            end
            else begin
                C = 0;
                Cout = 0;
                BCond = 0; 
            end
        end
        else if (OP == `OP_BLZ) begin
            if (A < 0) begin
                C = 0;
                Cout = 0;
                BCond = 1; 
            end
            else begin
                C = 0;
                Cout = 0;
                BCond = 0; 
            end
        end

        // J-Type instructions
        else if (OP == `OP_JMP) begin
            // TODO: remove
        end
        else if (OP == `OP_JAL) begin
            // ?
        end
        else begin
            // Unhandled case
            C = 0;
            Cout = 0;
            BCond = 0;
        end
    end
endmodule
