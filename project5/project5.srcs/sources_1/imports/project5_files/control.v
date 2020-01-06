// Author: JHYeom (zhixian001)
`timescale 1ns/100ps

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
// `include "basics.v"

// `include "ALU.v"
// `include "regfile.v"
`ifdef CONTROL_V
`else
`define CONTROL_V

module Control_Unit(
    output [1:0] pcsource,
    output [3:0] alucontrol,
    output [1:0] alusrcA,
    output [1:0] alusrcB,
    output regwrite,
    output [1:0] regdst,
    output reg pclatch,
    output iord,
    output memread,
    output memwrite,
    output memtoreg,
    output irwrite,
    // additional control signals
    // output wwd_latch,
    // inputs
    output is_halted,
    input clk,
    input reset_n,
    input bcond,
    input [5:0] funct,
    input [3:0] opcode
);
    // Two conditional pc write gates
    wire pcwritecond, pcwrite;


    // interconnects
    wire [3:0] aluopcode;
    wire jumplink, itypeoperand;

    // PC Write Gates
    always @(*) begin
        pclatch = (pcwritecond & bcond) | pcwrite;
    end

    // microcode module
    microcode mc(
        .clk(clk),
        .reset_n(reset_n),
        .funct(funct),
        .opcode(opcode),
        .pcadd12pc(pcadd12pc),
        .conditionalpc(conditionalpc),
        .addpcimm2aluout(addpcimm2aluout),
        .alu2pc(alu2pc),
        .concat2pc(concat2pc),
        .meminstread(meminstread),
        .jumplink(jumplink),
        .itypeoperand(itypeoperand),
        .readmemory2mdr(readmemory2mdr),
        .writedatamemory(writedatamemory),
        .aluout2regrd(aluout2regrd),
        .aluout2regrt(aluout2regrt),
        .mdr2regrt(mdr2regrt),
        .aluopcode(aluopcode),
        .is_halted(is_halted)
    );

    // microcodeRom module
    microcodeROM mcRom(
        .clk(clk),
        .reset_n(reset_n),
        .pcadd12pc(pcadd12pc),
        .conditionalpc(conditionalpc),
        .alu2pc(alu2pc),
        .concat2pc(concat2pc),
        .meminstread(meminstread),
        .itypeoperand(itypeoperand),
        .addpcimm2aluout(addpcimm2aluout),
        .readmemory2mdr(readmemory2mdr),
        .writedatamemory(writedatamemory),
        .aluout2regrd(aluout2regrd),
        .aluout2regrt(aluout2regrt),
        .mdr2regrt(mdr2regrt),
        .aluopcode(aluopcode),
        .jumplink(jumplink),
        // control signals
        .pcsource(pcsource),
        .alusrcA(alusrcA),
        .alusrcB(alusrcB),
        .regwrite(regwrite),
        .regdst(regdst),
        .pcwritecond(pcwritecond),
        .pcwrite(pcwrite),
        .iord(iord),
        .memread(memread),
        .memwrite(memwrite),
        .memtoreg(memtoreg),
        .irwrite(irwrite),
        .alucontrol(alucontrol)
    );


endmodule



module microcode(
    input clk,
    input reset_n,
    input [5:0] funct,
    input [3:0] opcode,
    output reg pcadd12pc,
    output reg conditionalpc,
    output reg alu2pc,
    output reg concat2pc,
    output reg addpcimm2aluout,
    output reg meminstread,
    output reg itypeoperand,
    output reg readmemory2mdr,
    output reg writedatamemory,
    output reg aluout2regrd,
    output reg aluout2regrt,
    output reg mdr2regrt,
    output reg is_halted,
    output reg jumplink,
    output reg [3:0] aluopcode
);

    // Micro PC
    wire [2:0] mPC_current;
    reg [2:0] mPC_next;
    // microPC module
    Latch3 mPC(
        .clk(clk),
        .reset_n(reset_n),
        .in(mPC_next),
        .out(mPC_current)
    );


    // Reset signal
    always @(posedge clk) begin
        if (reset_n == 0) begin
            meminstread      <= 0;
            pcadd12pc        <= 0;
            conditionalpc    <= 0;
            alu2pc           <= 0;
            concat2pc        <= 0;
            itypeoperand   <= 0;
            addpcimm2aluout  <= 0;
            readmemory2mdr   <= 0;
            writedatamemory  <= 0;
            aluout2regrd     <= 0;
            aluout2regrt     <= 0;
            mdr2regrt        <= 0;
            jumplink         <= 0;
        end
    end



    always @(*) begin
        // IF stage
        if (mPC_current == `MICROOP_IF) begin
            meminstread      = 1;

            // Common
            pcadd12pc        = 0;
            conditionalpc    = 0;
            alu2pc           = 0;
            concat2pc        = 0;
            addpcimm2aluout  = 0;
            readmemory2mdr   = 0;
            writedatamemory  = 0;
            aluout2regrd     = 0;
            aluout2regrt     = 0;
            mdr2regrt        = 0;
            jumplink    = 0;

            // ALU_OPCODE
            aluopcode        = `ALUOP_ADD;

            // MicroPC Sequencing
            mPC_next         = `MICROOP_ID;
        end

        // ID stage
        else if (mPC_current == `MICROOP_ID) begin
            // Conditional PC operations
            // Relative Jump case
            if ((opcode == `OPCODE_JMP) || (opcode == `OPCODE_JAL) ) begin
                pcadd12pc       = 0;
                alu2pc          = 0;
                concat2pc       = 1;
                addpcimm2aluout = 0; 

                // jumplink signals
                if (opcode == `OPCODE_JAL) begin
                    jumplink    = 1;
                end
                else begin
                    jumplink    = 0;
                end

                
                // ALUOP
                aluopcode       = `ALUOP_ID;

                // MicroPC Sequencing
                mPC_next        = `MICROOP_IF;
            end

            // Absolute Jump Case
            else if ((opcode == 4'd15) && ((funct == `FUNC_JPR) || (funct == `FUNC_JRL))) begin
                pcadd12pc       = 0;
                alu2pc          = 1;
                concat2pc       = 0;
                addpcimm2aluout  = 0; 
                
                // jumplink signals
                if (funct == `FUNC_JRL) begin
                    jumplink    = 1;
                end
                else begin
                    jumplink    = 0;
                end
                


                // ALUOP
                aluopcode       = `ALUOP_ID;

                // MicroPC Sequencing
                mPC_next        = `MICROOP_IF;
            end

            // Other 2 stage Operations
            else if ((opcode == 4'd15) && ((funct == `FUNC_WWD) || (funct == `FUNC_HLT))) begin
                // TODO: WWd and HLT case
                pcadd12pc        = 1;
                alu2pc           = 0;
                concat2pc        = 0;
                addpcimm2aluout  = 0;

                jumplink    = 0;


                // ALUOP
                aluopcode        = `ALUOP_ID;

                // WWD MicroPC Sequencing
                if (funct == `FUNC_WWD) begin
                    mPC_next     = `MICROOP_IF;                    
                end
                // HALT mPC sequencing
                else begin
                    mPC_next     = `MICROOP_HALT;
                end
            end

            // Other operations
            else begin
                if ((opcode >= 0) && (opcode <= 3)) begin
                    addpcimm2aluout = 1; 
                end
                else begin
                    addpcimm2aluout = 0;
                end

                // Other operations (including Branch)
                pcadd12pc       = 1;   // will be latched ALUOUT for branch
                alu2pc          = 0;
                concat2pc       = 0;

                jumplink    = 0;

                // ALUOP
                aluopcode       = `ALUOP_ADD;
                if ((opcode >= 4'd0) && (opcode <= 4'd3)) begin
                    mPC_next        = `MICROOP_EX_BRANCH;
                end
                // Sequencing
                else begin
                    mPC_next        = `MICROOP_EX;
                end
            end

            // Common
            conditionalpc    = 0;
            meminstread      = 0;
            readmemory2mdr   = 0;
            writedatamemory  = 0;
            aluout2regrd     = 0;
            aluout2regrt     = 0;
            mdr2regrt        = 0;
        end

        // EX_Branch stages
        else if (mPC_current == `MICROOP_EX_BRANCH) begin
            // Conditional PC write
            conditionalpc   = 1;

            // ALU op
            if (opcode == `OPCODE_BNE) begin
                aluopcode = `ALUOP_NE;
            end
            else if (opcode == `OPCODE_BEQ) begin
                aluopcode = `ALUOP_EQ;
            end
            else if (opcode == `OPCODE_BGZ) begin
                aluopcode = `ALUOP_GZ;
            end
            else if (opcode == `OPCODE_BLZ) begin
                aluopcode = `ALUOP_LZ;
            end

            
            // mPC sequencing
            mPC_next = `MICROOP_IF;

            // Common
            pcadd12pc        = 0;
            alu2pc           = 0;
            concat2pc        = 0;
            meminstread      = 0;
            readmemory2mdr   = 0;
            writedatamemory  = 0;
            aluout2regrd     = 0;
            aluout2regrt     = 0;
            mdr2regrt        = 0;
            jumplink    = 0;

        end


        // EX stages
        else if (mPC_current == `MICROOP_EX) begin
            // Common
            pcadd12pc        = 0;
            conditionalpc    = 0;
            alu2pc           = 0;
            concat2pc        = 0;
            meminstread      = 0;
            readmemory2mdr   = 0;
            writedatamemory  = 0;
            aluout2regrd     = 0;
            aluout2regrt     = 0;
            mdr2regrt        = 0;
            jumplink    = 0;


            // select alu input
            // $rs, $rt case (R type)
            if (opcode == 4'd15) begin
                // rs, rt
                itypeoperand = 0;
            end

           
            else begin
                itypeoperand = 1;
            end

            // Decide ALUOP
            // ADD
            if (((opcode == 4'd15) && (funct == `FUNC_ADD)) || (opcode == `OPCODE_ADI) || (opcode == `OPCODE_LWD) || (opcode == `OPCODE_SWD)) begin
                aluopcode = `ALUOP_ADD;
            end

            // SUB
            else if ((opcode == 4'd15) && (funct == `FUNC_SUB)) begin
                aluopcode = `ALUOP_SUB;
            end

            // AND
            else if ((opcode == 4'd15) && (funct == `FUNC_AND)) begin
                aluopcode = `ALUOP_AND;
            end 

            // OR
            else if (((opcode == 4'd15) && (funct == `FUNC_ORR)) || (opcode == `OPCODE_ORI)) begin
                aluopcode = `ALUOP_OR;
            end

            // NOT
            else if ((opcode == 4'd15) && (funct == `FUNC_NOT)) begin
                aluopcode = `ALUOP_NOT;
            end

            // 2's Complement
            else if ((opcode == 4'd15) && (funct == `FUNC_TCP)) begin
                aluopcode = `ALUOP_2COMP;
            end

            // Shift left logical
            else if ((opcode == 4'd15) && (funct == `FUNC_SHL)) begin
                aluopcode = `ALUOP_SHL;
            end

            // Shift right 
            else if ((opcode == 4'd15) && (funct == `FUNC_SHR)) begin
                aluopcode = `ALUOP_SHR;
            end

            // Left High Immediate
            else if (opcode == `OPCODE_LHI) begin
                aluopcode = `ALUOP_LHI;
            end


            // decide next mPC
            // Next memory operation case
            if ((opcode == `OPCODE_LWD) || (opcode == `OPCODE_SWD)) begin
                // next WB
                mPC_next = `MICROOP_MEM;
            end

            // Next writeback case
            else begin
                mPC_next = `MICROOP_WB;
            end
        end

        // WB stages
        else if (mPC_current == `MICROOP_WB) begin
            // Itype
            if ((opcode <= 4'd6)&&(opcode >= 4'd4)) begin
                aluout2regrd     = 0;
                aluout2regrt     = 1;
                mdr2regrt        = 0;
            end

            // LWD
            else if (opcode == `OPCODE_LWD) begin
                aluout2regrd     = 0;
                aluout2regrt     = 0;
                mdr2regrt        = 1;
            end

            // Rtype
            else begin
                aluout2regrd     = 1;
                aluout2regrt     = 0;
                mdr2regrt        = 0;
            end
            
            // ALU opcode
            aluopcode = `ALUOP_ID;

            // mPC update
            mPC_next = `MICROOP_IF;

            // Common
            pcadd12pc        = 0;
            conditionalpc    = 0;
            alu2pc           = 0;
            concat2pc        = 0;
            meminstread      = 0;
            readmemory2mdr    = 0;
            writedatamemory      = 0;
            jumplink    = 0;

        end

        // MEM stages
        else if (mPC_current == `MICROOP_MEM) begin

            // alu opcode
            aluopcode = `ALUOP_ID;

            // mPC update & memory operations
            if (opcode == `OPCODE_SWD) begin
                readmemory2mdr    = 0;
                writedatamemory   = 1;
                mPC_next = `MICROOP_IF;
            end
            else begin
                readmemory2mdr    = 1;
                writedatamemory   = 0;
                mPC_next = `MICROOP_WB;
            end

            // Common
            itypeoperand = 1;
            pcadd12pc        = 0;
            conditionalpc    = 0;
            alu2pc           = 0;
            concat2pc        = 0;
            meminstread      = 0;
            aluout2regrd     = 0;
            aluout2regrt     = 0;
            mdr2regrt        = 0;
            jumplink         = 0;

        end

        else if (mPC_current == `MICROOP_HALT) begin
            // Common HALT
            readmemory2mdr   = 0;
            writedatamemory  = 0;
            pcadd12pc        = 0;
            conditionalpc    = 0;
            alu2pc           = 0;
            concat2pc        = 0;
            meminstread      = 0;
            itypeoperand   = 0;
            addpcimm2aluout  = 0;
            aluout2regrd     = 0;
            aluout2regrt     = 0;
            mdr2regrt        = 0;
            jumplink         = 0;

        end

        // Halt Condition CHK
        if (mPC_current == `MICROOP_HALT) begin
            is_halted = 1;
        end
        else begin
            is_halted = 0;
        end
    end

endmodule

module microcodeROM(
    input clk,
    input reset_n,
    input pcadd12pc,        // PC = PC + 1 (alusrcA = alusrcB = 1)
    input conditionalpc,        // PC = ALUout
    input alu2pc,           // PC = ALU
    input concat2pc,        // PC : JUMP
    input meminstread,      // INSTRUCTION READ
    input itypeoperand,   // alusrcB = 1, alusrcB = 2
    input addpcimm2aluout,
    input readmemory2mdr,    // memaddrmux = 1, memread = 1
    input writedatamemory,      // memaddrmux = 1, memwrite = 1
    input aluout2regrd,     // wrmux = 1, wbmux = 0
    input aluout2regrt,     // wrmux = 0, wbmux = 0
    input mdr2regrt,        // wrmux = 0, wbmux = 1
    input jumplink,
    input [3:0] aluopcode,
    // decoded microcode
    output reg [1:0] pcsource,
    output reg [1:0] alusrcA,
    output reg [1:0] alusrcB,
    output reg regwrite,        // archi
    output reg [1:0] regdst,
    output reg pcwritecond,     // archi
    output reg pcwrite,         // archi
    output reg iord,
    output reg memread,
    output reg memwrite,        // archi
    output reg memtoreg,
    output reg irwrite,         // archi
    output [3:0] alucontrol
);
    assign alucontrol = aluopcode;
    
    always @(posedge clk) begin
       if (reset_n ==0) begin
            pcsource       <= 0;
            alusrcA        <= 0;
            alusrcB        <= 0;
            regwrite       <= 0;
            regdst         <= 0;
            pcwritecond    <= 0;
            pcwrite        <= 0;
            iord           <= 0;
            memread        <= 0;
            memwrite       <= 0;
            memtoreg       <= 0;
            irwrite        <= 0;
       end 
    end


    always @(*) begin
        // Archi state change instruction 
        // IF stage Instruction Read & PC+1 to ALUOUT
        if (meminstread == 1) begin
            // Latch Instruction
            memread     = 1;    // Memory Read
            iord        = 0;    // Select PC
            irwrite     = 1;    // latch to InstReg
        end
        else begin
            irwrite     = 0;    // latch to InstReg
        end

        // Archi state change instructions
        // ID stage PC+1
        if (pcadd12pc == 1) begin
            pcsource    = 1;
            pcwrite     = 1;
            pcwritecond = 0;
        end
        // ID stage Jump Abs
        else if (alu2pc == 1) begin
            pcsource    = 3;
            pcwrite     = 1;
            pcwritecond = 0;
        end
        // ID stage Jump relative
        else if (concat2pc == 1) begin
            pcsource    = 2;
            pcwrite     = 1;
            pcwritecond = 0;
        end

        // restore write signal
        else begin
            pcsource    = 1;
            pcwrite     = 0;
        end

        // Archi
        // ID stage Jumplink register store
        // $2 <- $next inst
        if (jumplink == 1) begin
            regwrite    = 1;
            memtoreg    = 0;
            regdst      = 2;
        end
        
        // Archi state change instruction
        // EX_BRANCH
        if (conditionalpc == 1) begin
            pcsource    = 1;    // Select Branch Address
            pcwrite     = 0;
            pcwritecond = 1;    // conditional write
        end
        // restore write cond
        else begin
            pcwritecond = 0;
        end

        // MEM: READ MEMORY
        if (readmemory2mdr == 1) begin
            iord = 1;
            memread = 1;
            memwrite = 0;
        end

        // MEM: Write Memory
        // Archi state change instruction
        if (writedatamemory == 1) begin
            iord = 1;
            memread = 0;
            memwrite = 1;
        end
        else begin
            memwrite = 0;
        end

        // Archi state change instructions
        // WB: R type
        if (aluout2regrd == 1) begin
            regwrite = 1;
            regdst = 1;
            memtoreg = 0;
        end

        // WB: I type
        else if(aluout2regrt == 1) begin
            regwrite = 1;
            regdst = 0;
            memtoreg = 0;
        end

        // WB: Memory to reg store
        else if(mdr2regrt == 1) begin
            regwrite = 1;
            regdst = 0;
            memtoreg = 1;
        end

        // Manage regwrite signal
        if ((jumplink == 0) && (mdr2regrt == 0) && (aluout2regrt == 0) && (aluout2regrd == 0)) begin
            regwrite = 0;
        end

        // ALUSRCA problem resolve
        if (meminstread == 1) begin
            alusrcA = 0;
        end

        else if ((addpcimm2aluout == 1) && (conditionalpc == 0)) begin
            alusrcA = 2;
        end
        else begin
            alusrcA = 1;
        end

        // ALUSRCB problem resolve
        if (meminstread == 1) begin
            alusrcB = 1;
        end
        else if ((itypeoperand == 1) && (conditionalpc == 0)) begin
            alusrcB = 2;
        end
        else if (itypeoperand == 0) begin
            alusrcB = 0;
        end
        else if((addpcimm2aluout == 1) && (conditionalpc == 0)) begin
            alusrcB = 2;
        end
        else if (conditionalpc == 1) begin
            alusrcB = 0;
        end
        


        
        // Special Memory Signals
        if ((meminstread == 0) && (readmemory2mdr == 0)) begin
            memread = 0;
        end
    end
endmodule

`endif