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


`include "opcodes.v"
// OPCODE Definitions
// ALU OPCODES 4bit


`ifdef ALU_V
`else
`define ALU_V
module ALU(
    /* Main module of ALU.v
    INPUT:
        A   :    [16]    first operand
        B   :    [16]    second operand
        OP  :    [6]     opcode or ALU control code
    
    OUTPUT:
        C   : [16]      output
        BCond: [1]      Branch condition
    */

    input [15:0] A,
    input [15:0] B,
    input [3:0] OP,
    output reg [15:0] C,
    output reg BCond
    );

    wire signed [15:0] sA, sB;
    assign sA = $signed(A);
    assign sB = $signed(B);

    always @(*) begin
        if(OP == `ALUOP_ADD) begin
            C = sA + sB;
            BCond = 0;
        end
        else if(OP == `ALUOP_SUB) begin
            C = sA - sB;
            BCond = 0;
        end   
        else if(OP == `ALUOP_AND) begin
            C = A & B;
            BCond = 0;
        end   
        else if(OP == `ALUOP_OR) begin
            C = A | B;
            BCond = 0;
        end    
        else if(OP == `ALUOP_NOT) begin
            // for input A
            C = ~A;
            BCond = 0;
        end   
        else if(OP == `ALUOP_2COMP) begin
            C = ~A + 1'b1;
            BCond = 0;
        end 
        else if(OP == `ALUOP_SHL) begin
            // for input A
            C = A << 1;
            BCond = 0;
        end   
        else if(OP == `ALUOP_SHR) begin
            // for input A
            C = A >>> 1;
            BCond = 0;
        end   
        else if(OP == `ALUOP_LHI) begin
            // for input B
            C = B << 8;
            BCond = 0;
        end   
        else if(OP == `ALUOP_ID) begin
            // for input A
            C = A;
            BCond = 0;
        end    
        // else if(OP == `ALUOP_WDADDR) begin
        //    C = A + 
        // end
        else if(OP == `ALUOP_NE) begin
            C = 0;
            if (sA != sB) begin
                BCond = 1;
            end else begin
                BCond = 0;
            end  
        end    
        else if(OP == `ALUOP_EQ) begin
            C = 0;
            if (sA == sB) begin
                BCond = 1;
            end else begin
                BCond = 0;
            end  
            
        end    
        else if(OP == `ALUOP_GZ) begin
            C = 0;
            if (sA > 0) begin
                BCond = 1;
            end else begin
                BCond = 0;
            end              
        end    
        else if(OP == `ALUOP_LZ) begin
            C = 0;
            if (sA < 0) begin
                BCond = 1;
            end else begin
                BCond = 0;
            end      
        end
        else begin
            C = 0;
            BCond = 0;
        end
    end
endmodule
`endif
