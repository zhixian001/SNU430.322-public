// Author: JHYeom (zhixian001)
`timescale 1ns/100ps

// `include "constants.v"
`ifdef ALU_V
`else
`include "ALU.v"
`endif
`ifdef REGFILE_V
`else
`include "regfile.v"
`endif
// `include "basics.v"
`ifdef OPCODES_V
`else
`include "opcodes.v"
`endif
`ifdef CONSTANTS_V
`else
`include "constants.v"
`endif
`ifdef BASICS_V
`else
`include "basics.v"
`endif

`ifdef DATAPATH_V
`else
`define DATAPATH_V

// Datapath module
module Datapath(
    input clk,
    input reset_n,
    // about memcontroller
    inout [15:0] data,
    output [15:0] address,
    output readM,
    output writeM,
    // control signals
    input [1:0] pcsource,
    input [3:0] alucontrol,
    input [1:0] alusrcA,
    input [1:0] alusrcB,
    input regwrite,
    input [1:0] regdst,
    input pclatch,
    input iord,
    input memread,
    input memwrite,
    input memtoreg,
    input irwrite,
    input inputReady,
    // other special ports
    output [15:0] wwd_output,
    // to control module
    output bcond,
    output reg [5:0] funct,
    output reg [3:0] opcode,
    output reg [15:0] num_inst
);
    // wire declarations (by naming output of each module)
    wire [`WORD_SIZE-1:0] out_pc, out_memaddrmux, out_memdata, out_memedatareg, out_instreg, out_wbmux, out_regfile1, out_regfile2, out_sign_extend, out_areg, out_breg, out_alusrcamux, out_alusrcbmux, out_alu, out_aluout, out_pcnextmux;
    wire [1:0] out_wrmux;

    // pc concat to jump
    wire [`WORD_SIZE-1:0] jumpaddr_concat;
    assign jumpaddr_concat = {out_pc[15:12], out_instreg[11:0]};

    // assign wwd_output = out_areg;
    

    assign wwd_output = out_regfile1;

    // num_inst
    
    always @(posedge clk) begin
        if (reset_n == 1'b0) begin
            num_inst <= 0;
        end
        else if (irwrite == 1) begin
           num_inst <= num_inst + 1;
        end
        // $display("DEBUG>> Inst Reg (value): %b", out_instreg);

    end

    always @(*) begin
        opcode = out_instreg[15:12];
        // $display("DEBUG>> Memory Read (value): %b", opcode);
        if (opcode == 16'd15) begin
            funct = out_instreg[5:0];
        end
        else begin
            funct = 6'b111111;
        end
    end

    // Sequencial module declaration.
    Latch16 PC(
        .clk(clk),
        .enable(pclatch),
        .reset_n(reset_n),
        .in(out_pcnextmux),
        .out(out_pc)
    );
    Latch16 InstReg(
        .clk(clk),
        .enable(irwrite),
        .reset_n(reset_n),
        .in(out_memdata),
        .out(out_instreg)
    );
    Latch16 MemdataReg(
        .clk(clk),
        .enable(1'b1),
        .reset_n(reset_n),
        .in(out_memdata),
        .out(out_memedatareg)
    );    
    Latch16 AReg(
        .clk(clk),
        .enable(1'b1),
        .reset_n(reset_n),
        .in(out_regfile1),
        .out(out_areg)
    );
    Latch16 BReg(
        .clk(clk),
        .enable(1'b1),
        .reset_n(reset_n),
        .in(out_regfile2),
        .out(out_breg)
    );        
    Latch16 ALUOut(
        .clk(clk),
        .enable(1'b1),
        .reset_n(reset_n),
        .in(out_alu),
        .out(out_aluout)
    );
    RF regfile (
        .write(regwrite),
        .clk(clk),
        .reset_n(reset_n),
        .addr1(out_instreg[11:10]),
        .addr2(out_instreg[9:8]),
        .addr3(out_wrmux),
        .data3(out_wbmux),
        .data1(out_regfile1),
        .data2(out_regfile2)
    );

    // Combinational module declarations
    ALU alu (
        .A(out_alusrcamux),
        .B(out_alusrcbmux),
        .OP(alucontrol),
        .C(out_alu),
        .BCond(bcond)
    );

    SIGN_EXTEND8_16 sign_extend(
        .inp(out_instreg[7:0]),
        .out(out_sign_extend)
    );

    MUX16_2_1 MemaddrMux(
        .inp0(out_pc),
        .inp1(out_aluout),
        .sel(iord),
        .out(out_memaddrmux)
    );
    MUX16_2_1 WBMux(
        .inp0(out_aluout),
        .inp1(out_memedatareg),
        .sel(memtoreg),
        .out(out_wbmux)
    );
    MUX16_4_1 ALUsrcAMUX(
        .inp0(out_pc),
        .inp1(out_areg),
        .inp2(out_aluout),
        .sel(alusrcA),
        .out(out_alusrcamux)
    );
    MUX16_4_1 ALUsrcBMUX(
        .inp0(out_breg),
        .inp1(16'h1),
        .inp2(out_sign_extend),
        .sel(alusrcB),
        .out(out_alusrcbmux)
    );
    MUX16_4_1 PCnextMux(
        .inp0(out_alu),
        .inp1(out_aluout),
        .inp2(jumpaddr_concat),
        .inp3(out_regfile1),
        .sel(pcsource),
        .out(out_pcnextmux)        
    );
    MUX2_3_1 WRMux(
        .inp0(out_instreg[9:8]),
        .inp1(out_instreg[7:6]),
        .inp2(2'b10),
        .sel(regdst),
        .out(out_wrmux)
    );

    // Memory Controller
    Memcontroller memcontroller(
        .memread(memread),   
        .memwrite(memwrite),
        .inputReady(inputReady),
        .clk(clk),
        .reset_n(reset_n),
        .address(out_memaddrmux),
        .writedata(out_breg),
        .data(data), 
        .readM(readM),
        .writeM(writeM),
        .addressout(address),
        .memdata(out_memdata)
    );


endmodule

module Memcontroller(
    input memread,                  // control signal
    input memwrite,                 // control signal
    input inputReady,
    input clk,
    input reset_n,
    input [15:0] address,
    input [15:0] writedata,
    inout [15:0] data,    
    output reg readM,
    output reg writeM,
    output [15:0] addressout,
    output reg [15:0] memdata
);
    assign addressout = address;

    assign data = writeM ? writedata : `WORD_SIZE'bz;

    reg [15:0] latchedRead;

    always @(*) begin
        if (memread == 1) begin
            readM = 1;  
            writeM = 0;
        end
        else if (memwrite == 1) begin
            writeM = 1;
            readM = 0;
        end
        else begin
            writeM = 0;
            readM = 0;
        end
    end

    always @(posedge inputReady) begin
        memdata = data;
    end

    always @(posedge clk) begin
        // Reset
        if (reset_n == 0) begin
            readM <= 0;
            writeM <= 0;
            memdata <= 0;
        end
        else begin          
            if((readM == 1) && (inputReady == 1) && (reset_n == 1)) begin
                // memdata <= data;
                readM <= 0;
            end
            else if ((writeM == 1) && (reset_n == 1)) begin
                writeM <= 0;
            end
        end
    end


endmodule
`endif
