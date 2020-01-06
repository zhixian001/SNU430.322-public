`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SNU
// Engineer: JH Yeom (zhixian001)
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
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    /* Main module of ALU.v */
    input [15:0] A,
    input [15:0] B,
    input Cin,
    input [3:0] OP,
    output [15:0] C,
    output Cout
    );
    
    // Wire for each operation type.
    wire [15:0] AR, RO, SH, LO;
    // Wire for carry out.
    wire ARC;

    // Arithmetic Operations(OP_ADD, OP_SUB)
    ARITHMETIC ar(
        .A(A),
        .B(B),
        .Cin(Cin),
        .MOD(OP[0:0]),
        .C(AR),
        .Cout(ARC)
    );

    // Rotate operations (OP_RL, OP_RR)
    ROTATE ro(
        .A(A),
        .MOD(OP[0:0]),
        .C(RO)
    );

    // Shift operations (OP_LRS, OP_ARS, OP_LLS, OP_ALS)
    SHIFT sh(
        .A(A),
        .MOD(OP[1:0]),
        .C(SH)
    );

    // Logical operations (OP_ID, OP_NAND, OP_NOR, OP_XNOR, OP_NOT, OP_AND, OP_OR, OP_XOR)
    LOGICAL lo(
        .A(A),
        .B(B),
        .MOD(OP[2:0]),
        .C(LO)
    );

    // assign output port according to OPCODE
    assign C = OP[3:3] ? (OP[2:2] ? (OP[1:1] ? AR : RO) : SH) : LO;
    // assign carry out port according to OPCODE
    assign Cout = OP[3:3] ? (OP[2:2] ? (OP[1:1] ? ARC : 1'b0) : 1'b0) : 1'b0;

endmodule


module ARITHMETIC(
    input signed [15:0] A,
    input signed [15:0] B,
    input Cin,
    input MOD,
    output [15:0] C,
    output Cout
);
    /* Module for arrithmetic operations. (OP_ADD, OP_SUB)
    INPUT:
        A   : (signed wire)     [16]    first operand
        B   : (signed wire)     [16]    second operand
        Cin : (unsigned wire)   [1]     carry in
        MOD : (unsigned wire)   [1]     decoded opcode
            0   : OP_ADD
            1   : OP_SUB
    
    OUTPUT:
        C   : [16]    output
        Cout: [1]     carry out
            - 0 : normal operation
            - 1 : overflow or underflow while sequencial operation
    */

    // Cin bit extend to 16bit signed number
    wire signed [15:0] Cin_W;
    assign Cin_W = {15'b000000000000000, Cin};

    // output of add and sub
    wire [15:0] ADO, SUBO;
    // carry out of add and sub
    wire ADC, SUBC;

    // add operation submodule
    ADDER adder1(
        .A(A),
        .B(B),
        .CI(Cin_W),
        .CO(ADO),
        .CRO(ADC)
    );

    // sub operation submodule
    SUBTER subter(
        .A(A),
        .B(B),
        .CI(Cin_W),
        .CO(SUBO),
        .CRO(SUBC)
    );

    // assign output according to MOD
    assign C = MOD ? SUBO : ADO;
    // assign carry out according to MOD
    assign Cout = MOD ? SUBC : ADC;

endmodule

module ADDER(
    input signed [15:0] A,
    input signed [15:0] B,
    input signed [15:0] CI,
    output [15:0] CO,
    output CRO
);
    /* Module for add. (OP_ADD)
    INPUT:
        A   : (signed wire)     [16]    first operand
        B   : (signed wire)     [16]    second operand
        CI  : (signed wire)     [16]    carry in
    
    OUTPUT:
        CO   : [16]     output
        CRO  : [1]      carry out
            - 0 : normal operation
            - 1 : overflow
    */

    // carry out wire for two operations
    wire cr1, cr2;

    // first add
    wire signed [15:0] TEMP;
    assign TEMP = A + B;

    // second add, and assign output
    assign CO = TEMP + CI;

    // first add's overflow detection
    OVFESTIMATOR ovf1(
        .A(A),
        .B(B),
        .Cout(cr1)
    );
    // second add's overflow detection
    OVFESTIMATOR ovf2(
        .A(TEMP),
        .B(CI),
        .Cout(cr2)
    );
    // assign overflow
    assign CRO = cr1 | cr2;
endmodule

module SUBTER(
    input signed [15:0] A,
    input signed [15:0] B,
    input signed [15:0] CI,
    output [15:0] CO,
    output CRO
);
    /* Module for sub. (OP_SUB)
    INPUT:
        A   : (signed wire)     [16]    first operand
        B   : (signed wire)     [16]    second operand
        CI  : (signed wire)     [16]    carry in
    
    OUTPUT:
        CO   : [16]     output
        CRO  : [1]      carry out
            - 0 : normal operation
            - 1 : underflow
    */

    // carry out wire for two operations
    wire cr1, cr2;

    // first sub
    wire signed [15:0] TEMP;
    assign TEMP = A - B;

    // second sub and assign output
    assign CO = TEMP - CI;
    
    // first sub's underflow detection
    SUBOVFESTIMATOR subovf1(
        .A(A),
        .B(B),
        .Cout(cr1)
    );
    // second sub's underflow detection
    SUBOVFESTIMATOR subovf2(
        .A(TEMP),
        .B(CI),
        .Cout(cr2)
    );
    // assign underflow
    assign CRO = cr1 | cr2;

endmodule

module OVFESTIMATOR(
    input [15:0] A,
    input [15:0] B,
    output Cout
);
    /* Module for overflow check.
    INPUT:
        A   : (unsigned wire)     [16]    first operand
        B   : (unsigned wire)     [16]    second operand
    
    OUTPUT:
        Cout: [1]      carry out
            - 0 : normal operation
            - 1 : overflow
    */
    // 17bit unsigned wire
    wire [16:0] EST;
    assign EST = {1'b0, A} + {1'b0, B};
    // if MSB of EST is 1, overflow!
    assign Cout = EST[16:16];

endmodule

module SUBOVFESTIMATOR(
    input [15:0] A,
    input [15:0] B,
    output Cout
);
    /* Module for underflow check.
    INPUT:
        A   : (unsigned wire)     [16]    first operand
        B   : (unsigned wire)     [16]    second operand
    
    OUTPUT:
        Cout: [1]      carry out
            - 0 : normal operation
            - 1 : underflow
    */
    // 17bit unsigned wire
    wire [16:0] EST;
    // left operand's MSB should be 1
    assign EST = {1'b1, A} - {1'b0, B};
    // if MSB of EST is not 1, underflow!
    assign Cout = ~EST[16:16];

endmodule

module ROTATE(
    input [15:0] A,
    input MOD,
    output [15:0] C
);
    /* Module for rotate operations. (OP_RL, OP_RR)
    INPUT:
        A   : (unsigned wire)     [16]      first operand
        MOD : (unsigned wire)     [1]       decoded opcode
            0     : left rotate    (OP_RL)
            1     : right rotate   (OP_RR)
    OUTPUT:
        C   : [16]      output
    */

    // change LSB to MSB or MSB to LSB
    assign C = MOD ? {A[0:0], A[15:1]} : {A[14:0], A[15:15]};

endmodule

module SHIFT(
    input signed [15:0] A,
    input [1:0] MOD,
    output [15:0] C
);
    /* Module for shift operations. (OP_LRS, OP_ARS, OP_LLS, OP_ALS)
    INPUT:
        A   : (unsigned wire)     [16]      first operand
        MOD : (unsigned wire)     [2]       decoded opcode
            00      : OP_LLS
            01      : OP_ALS
            10      : OP_LRS
            11      : OP_ARS

            - MOD[1:1]      : 0 for left,     1 for right
            - MOD[0:0]      : 0 for unsigned, 1 for signed
    OUTPUT:
        C   : [16]      output
    */

    // logical or arithmetical shift according to MOD
    assign C = MOD[0:0] ? (MOD[1:1] ? A >>> 1 : A <<< 1) : (MOD[1:1] ? A >> 1 : A << 1 );

endmodule

module LOGICAL(
    input [15:0] A,
    input [15:0] B,
    input [2:0] MOD,
    output [15:0] C 
);
    /* Module for shift operations. (OP_LRS, OP_ARS, OP_LLS, OP_ALS)
    INPUT:
        A   : (unsigned wire)     [16]      first operand
        B   : (unsigned wire)     [16]      second operand
        MOD : (unsigned wire)     [3]       decoded opcode
            000      : OP_AND
            001      : OP_OR
            010      : OP_ID
            011      : OP_XOR
            100      : OP_NAND
            101      : OP_NOR
            110      : OP_NOT
            111      : OP_XNOR

            - MOD[2:2]      : 0 for normal output,     1 for negated output
            - MOD[1:0]      : 
                            00      : AND
                            01      : OR
                            10      : IDENT
                            11      : XOR
    OUTPUT:
        C   : [16]      output
    */

    // Do each operations
    wire [15:0] AND;
    wire [15:0] OR;
    wire [15:0] IDENT;
    wire [15:0] XOR;
    assign AND = A & B;
    assign OR = A | B;
    assign IDENT = A;
    assign XOR = A ^ B;

    // wire to solve bit size mismatching problem when negating
    wire [15:0] MID;

    // mux submodule to coose operations
    MUX4 mx4(
        .a(AND),
        .b(OR),
        .c(IDENT),
        .d(XOR),
        .sel(MOD[1:0]),
        .out(MID)
    );

    // decide negate the value or not according to MOD[2:2] and assign to output
    assign C = MOD[2:2] ? MID^16'b1111111111111111 : MID^'b0000000000000000;

endmodule

module MUX4 ( 
    input [15:0] a,    
    input [15:0] b,    
    input [15:0] c,    
    input [15:0] d,    
    input [1:0] sel,  
    output [15:0] out
);
    /* 4 to 1 MUX
    INPUT:
        A   : (unsigned wire)   [16]    option
        B   : (unsigned wire)   [16]    option
        C   : (unsigned wire)   [16]    option
        D   : (unsigned wire)   [16]    option
        sel : (unsigned wire)   [2]     select
    
    OUTPUT:
        out : [16]    output chosen
    */

    // 4:1 MUX
    assign out = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a); 
 
endmodule