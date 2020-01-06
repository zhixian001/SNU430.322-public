# -*- coding: utf-8 -*-
# Author: JHYeom (zhixian001)

import sys

def original_hex2tsc(value):
    return original_bin16decode(hex2bin(value))

def original_bin16decode(binval):
    # print(binval)
    opcode = int(binval[0:4], 2)
    rs = int(binval[4:6], 2)
    rt = int(binval[6:8], 2)
    rd = int(binval[8:10], 2)
    
    funct = int(binval[10:16], 2)
    
    imm = binval[8:16]
    # print(binval[0:4])

    jump = int(binval[4:16], 2)
    
    imm = signed8conv(imm)
    # print(imm)
    
    if int(binval,2) == 0:
        return "# Might Be Data(ZERO): 0"
    
    operation_decode = {"op":"", "type":""}
    
    opcode_ref = {4:"ADI",5:"ORI",6:"LHI",7:"LWD",8:"SWD",0:"BNE",1:"BEQ",2:"BGZ",3:"BLZ",9:"JMP",10:"JAL"}
    
    funct_ref = {0:"ADD", 1:"SUB", 2:"AND", 3:"ORR", 4:"NOT", 5:"TCP", 6:"SHL", 7:"SHR", 28:"WWD", 25:"JPR", 26:"JRL", 29:"HLT"}
    
    #opcode
    if opcode == 15:
        
        if funct in [0,1,2,3,4,5,6,7,8,28,25,26,29]:
            operation_decode["op"] = funct_ref[funct]
        else:
            return "# Might Be Data(illegal funct): {}".format(str(binval))

    
    elif opcode in [4,5,6,7,8,0,1,2,3,9,10]:
        operation_decode["op"] = opcode_ref[opcode]
    
    else:
        # Nothing
        return "# Might Be Data(illegal opcode): {}".format(str(binval))

        
    # type
    if operation_decode["op"] in ["ADI", "ORI", "LHI", "LWD", "SWD", "BNE", "BEQ", "BGZ", "BLZ"]:
        operation_decode["type"] = "I"
    elif operation_decode["op"] in ["JMP", "JAL"]:
        operation_decode["type"] = "J"
    else:
        operation_decode["type"] = "R"
        
    
    #typewise code gen
    code = operation_decode["op"] + "\t"
    
    if operation_decode["type"] == "R":
        
        if operation_decode["op"] in ["JPR", "JRL", "WWD"]:
            code += "$"+str(rs)
            if operation_decode["op"] in ["JPR", "JRL"]:
                code += "\t\t\t# JUMP REG"
            else:
                code += "\t\t\t# READVALUE!!!"
        elif operation_decode["op"] in ["NOT", "TCP", "SHL", "SHR"]:
            code += "$"+str(rd)+",\t" + "$"+str(rs)
        elif operation_decode["op"] in ["HLT"]:
            pass
        else:
            code += "$"+str(rd)+",\t" + "$"+str(rs)+",\t" + "$"+str(rt)
        
       
        
    elif operation_decode["type"] == "I":
        if operation_decode["op"] in ["LWD", "SWD"]:
            code += "$"+str(rt)+",\t" + str(imm) + "($" + str(rs) + ")"
        
        elif operation_decode["op"] in ["BNE", "BEQ", "BGZ", "BLZ"]:
            code += "$"+str(rs)+",\t" + "$"+str(rt) + ",\t" + str(imm) + "\t# BRANCH"
            
#             if operation_decode["op"] == "BGZ":
#                 print(binval)
            
            
        
        else:
            code += "$"+str(rt)+",\t" + "$"+str(rs) + ",\t" + str(imm)
            
#             if operation_decode["op"] == "ADI":
#                 print(binval)
            
    
    else:
        code += str(jump) + "\t\t\t# JUMP"
        
    return code

def hex2bin(value):
    return "{0:016b}".format(int(str(value), 16))

def signed8conv(binval):
    if binval[0] == "1":
        # - case
        # 2 comp
        new_binval = ""
        temp0 = binval.replace("0", "Z")
        temp1 = binval.replace("1", "O")
        for i in range(len(binval)):
            if temp0[i] == "Z":
                new_binval += "1"
            else:
                new_binval += "0"

        
        
        return -(int(str(new_binval))+1)
    else:
        return int(str(binval), 2)

def bin16decode(binval):
    # print(binval)
    opcode = int(binval[0:4], 2)
    rs = int(binval[4:6], 2)
    rt = int(binval[6:8], 2)
    rd = int(binval[8:10], 2)
    
    funct = int(binval[10:16], 2)
    
    imm = binval[8:16]
    # print(binval[0:4])

    jump = int(binval[4:16], 2)
    
    imm = signed8conv(imm)
    # print(imm)
    
    if int(binval,2) == 0:
        return "# Might Be Data(ZERO): 0"
    
    operation_decode = {"op":"", "type":""}

    
    opcode_ref = {4:"ADI",5:"ORI",6:"LHI",7:"LWD",8:"SWD",0:"BNE",1:"BEQ",2:"BGZ",3:"BLZ",9:"JMP",10:"JAL"}
    
    funct_ref = {0:"ADD", 1:"SUB", 2:"AND", 3:"ORR", 4:"NOT", 5:"TCP", 6:"SHL", 7:"SHR", 28:"WWD", 25:"JPR", 26:"JRL", 29:"HLT"}
    
    #opcode
    if opcode == 15:
        
        if funct in [0,1,2,3,4,5,6,7,8,28,25,26,29]:
            operation_decode["op"] = funct_ref[funct]
        else:
            return "# Might Be Data(illegal funct): {}".format(str(binval))

    
    elif opcode in [4,5,6,7,8,0,1,2,3,9,10]:
        operation_decode["op"] = opcode_ref[opcode]
    
    else:
        # Nothing
        return "# Might Be Data(illegal opcode): {}".format(str(binval))

    operations = {"oper":operation_decode["op"], "rs":rs, "rt":rt, "rd":rd, "imm":imm, "jump": jump}
        
    # type
    if operation_decode["op"] in ["ADI", "ORI", "LHI", "LWD", "SWD", "BNE", "BEQ", "BGZ", "BLZ"]:
        operation_decode["type"] = "I"
    elif operation_decode["op"] in ["JMP", "JAL"]:
        operation_decode["type"] = "J"
    else:
        operation_decode["type"] = "R"
        
    
    #typewise code gen
    code = operation_decode["op"] + "\t"
    
    if operation_decode["type"] == "R":
        
        if operation_decode["op"] in ["JPR", "JRL", "WWD"]:
            code += "$"+str(rs)
            if operation_decode["op"] in ["JPR", "JRL"]:
                code += "\t\t\t# JUMP REG"
            else:
                code += "\t\t\t# READVALUE!!!"
        elif operation_decode["op"] in ["NOT", "TCP", "SHL", "SHR"]:
            code += "$"+str(rd)+",\t" + "$"+str(rs)
        elif operation_decode["op"] in ["HLT"]:
            pass
        else:
            code += "$"+str(rd)+",\t" + "$"+str(rs)+",\t" + "$"+str(rt)
        
       
        
    elif operation_decode["type"] == "I":
        if operation_decode["op"] in ["LWD", "SWD"]:
            code += "$"+str(rt)+",\t" + str(imm) + "($" + str(rs) + ")"
        
        elif operation_decode["op"] in ["BNE", "BEQ", "BGZ", "BLZ"]:
            code += "$"+str(rs)+",\t" + "$"+str(rt) + ",\t" + str(imm) + "\t# BRANCH"
            
#             if operation_decode["op"] == "BGZ":
#                 print(binval)
            
            
        
        else:
            code += "$"+str(rt)+",\t" + "$"+str(rs) + ",\t" + str(imm)
            
#             if operation_decode["op"] == "ADI":
#                 print(binval)
            
    
    else:
        code += str(jump) + "\t\t\t# JUMP"
        
    return operations
    
    
    
def hex2tsc(value):
    return bin16decode(hex2bin(value))

class TSCvm:
    def __init__(self):
        self.memory = ["9023", "1", "ffff", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "6000", "f01c", "6100", "f41c", "6200", "f81c", "6300", "fc1c", "4401", "f01c", "4001", "f01c", "5901", "f41c", "5502", "f41c", "5503", "f41c", "f2c0", "fc1c", "f6c0", "fc1c", "f1c0", "fc1c", "f2c1", "fc1c", "f8c1", "fc1c", "f6c1", "fc1c", "f9c1", "fc1c", "f1c1", "fc1c", "f4c1", "fc1c", "f2c2", "fc1c", "f6c2", "fc1c", "f1c2", "fc1c", "f2c3", "fc1c", "f6c3", "fc1c", "f1c3", "fc1c", "f0c4", "fc1c", "f4c4", "fc1c", "f8c4", "fc1c", "f0c5", "fc1c", "f4c5", "fc1c", "f8c5", "fc1c", "f0c6", "fc1c", "f4c6", "fc1c", "f8c6", "fc1c", "f0c7", "fc1c", "f4c7", "fc1c", "f8c7", "fc1c", "7801", "f01c", "7902", "f41c", "8901", "8802", "7801", "f01c", "7902", "f41c", "9076", "f01c", "9079", "f01d", "f41c", "b01", "907d", "f01d", "f01c", "601", "f01d", "f41c", "1601", "9084", "f01d", "f01c", "1b01", "f01d", "f41c", "2001", "908b", "f01d", "f01c", "2401", "f01d", "f41c", "2801", "9092", "f01d", "f01c", "3001", "f01d", "f41c", "3401", "9099", "f01d", "f01c", "3801", "909d", "f01d", "f41c", "a0af", "f01c", "a0ae", "f01d", "f41c", "6300", "5f03", "6000", "4005", "a0b2", "f01c", "90b1", "4900", "f41a", "f01c", "f01d", "4a01", "f819", "f01d", "a0aa", "41ff", "2404", "6000", "5001", "f819", "f01d", "8e00", "8c01", "4f02", "40fe", "a0b2", "7dff", "8cff", "44ff", "a0b2", "7dff", "7efe", "f100", "4ffe", "f819", "f01d"]

        self.regfile = [0,0,0,0]
        self.current_pc = 0
        self.is_halted = False
        self.wwd_output = 0
        self.total_pc_updates = 0
        self.current = None
        self.count = 0

    def reset(self):
        self.regfile = [0,0,0,0]
        self.current_pc = 0
        self.is_halted = False
        self.wwd_output = 0

    def execute(self):
        # Read instruction
        self.current = self.memory[self.current_pc]
        
        self.count += 1
        print("{0:03x}".format(self.count), "\t", self.current, "\t" , self.current_pc, " :\t", original_hex2tsc(self.memory[self.current_pc]))

        # decode
        self.current = hex2tsc(self.current)


        if self.current["oper"] is "ADD":
            self._writeRegfile(self.rtypeRegWrtieAddr(self.current), self._readRegfile(self.rtypeRegRead(self.current)[0]) + self._readRegfile(self.rtypeRegRead(self.current)[1]))
            self._addPC()

        elif self.current["oper"] is "SUB":
            self._writeRegfile(self.rtypeRegWrtieAddr(self.current), self._readRegfile(self.rtypeRegRead(self.current)[0]) - self._readRegfile(self.rtypeRegRead(self.current)[1]))
            self._addPC()


        elif self.current["oper"] is "AND":
            self._writeRegfile(self.rtypeRegWrtieAddr(self.current), self._readRegfile(self.rtypeRegRead(self.current)[0]) & self._readRegfile(self.rtypeRegRead(self.current)[1]))
            self._addPC()

        elif self.current["oper"] is "ORR":
            self._writeRegfile(self.rtypeRegWrtieAddr(self.current), self._readRegfile(self.rtypeRegRead(self.current)[0]) | self._readRegfile(self.rtypeRegRead(self.current)[1]))
            self._addPC()

        elif self.current["oper"] is "NOT":
            self._writeRegfile(self.rtypeRegWrtieAddr(self.current), ~self._readRegfile(self.rtypeRegRead(self.current)[0]))
            self._addPC()

        elif self.current["oper"] is "TCP":
            self._writeRegfile(self.rtypeRegWrtieAddr(self.current), ~self._readRegfile(self.rtypeRegRead(self.current)[0]) + 1)
            self._addPC()

        elif self.current["oper"] is "SHL":
            self._writeRegfile(self.rtypeRegWrtieAddr(self.current), self._readRegfile(self.rtypeRegRead(self.current)[0]) << 1)
            self._addPC()

        elif self.current["oper"] is "SHR":
            # TOCHK: sign extended automatically?
            self._writeRegfile(self.rtypeRegWrtieAddr(self.current), self._readRegfile(self.rtypeRegRead(self.current)[0]) >> 1)
            self._addPC()
            
        elif self.current["oper"] is "WWD":
            self.wwd_output = self._readRegfile(self.itypeRegRead(self.current))
            self._addPC()
            # print("\t\tWWDOUTPUT!!!\t\t\t\t", self.wwd_output)

        elif self.current["oper"] is "JPR":
            self._jumpPC(self._readRegfile(self.rtypeRegRead(self.current)[0]))

        elif self.current["oper"] is "JRL":
            temp = self.current_pc+1
            self._jumpPC(self._readRegfile(self.rtypeRegRead(self.current)[0]))
            self._writeRegfile(2, temp)

        elif self.current["oper"] is "HLT":
            self._addPC()
            self.is_halted = True

        elif self.current["oper"] is "ADI":
            self._writeRegfile(self.itypeRegWrtieAddr(self.current), self._readRegfile(self.itypeRegRead(self.current)) + self.current["imm"])
            self._addPC()

        elif self.current["oper"] is "ORI":
            self._writeRegfile(self.itypeRegWrtieAddr(self.current), self._readRegfile(self.itypeRegRead(self.current)) | self.current["imm"])
            self._addPC()

        elif self.current["oper"] is "LHI":
            if bin(self.current["imm"])[0] == "-":
                im = bin(self.current["imm"])[3:] + "00000000"
            else:
                im = bin(self.current["imm"])[2:] + "00000000"
            lhi = int(im, 2)

            self._writeRegfile(self.itypeRegWrtieAddr(self.current), lhi)
            self._addPC()


        elif self.current["oper"] is "LWD":
            offset = self._readRegfile(self.itypeRegRead(self.current)) + self.current["imm"]

            memread = self._readDataMemory(offset)
            self._writeRegfile(self.itypeRegWrtieAddr(self.current), memread)
            self._addPC()
            # print("MEM REG:\t ", self.regfile)


        elif self.current["oper"] is "SWD":
            offset = self._readRegfile(self.itypeRegRead(self.current)) + self.current["imm"]

            towrite = self._readRegfile(self.itypeRegWrtieAddr(self.current))

            self._writeDataMemory(offset, towrite)

            self._addPC()
            # print("MEM REG:\t ", self.regfile)



        elif self.current["oper"] is "BNE":
            a = self._readRegfile(self.rtypeRegRead(self.current)[0])
            b = self._readRegfile(self.rtypeRegRead(self.current)[1])
            # print("BRANCH REG:\t ", self.regfile)
            if a != b:
                self._branchPC(self.current["imm"])
            else:
                self._addPC()

        elif self.current["oper"] is "BEQ":
            a = self._readRegfile(self.rtypeRegRead(self.current)[0])
            b = self._readRegfile(self.rtypeRegRead(self.current)[1])
            # print("BRANCH REG:\t ", self.regfile)

            if a == b:
                self._branchPC(self.current["imm"])
            else:
                self._addPC()

            
        elif self.current["oper"] is "BGZ":
            a = self._readRegfile(self.rtypeRegRead(self.current)[0])
 
            # print("BRANCH REG:\t ", self.regfile)

            if a > 0:
                self._branchPC(self.current["imm"])
                
            else:
                self._addPC()

        elif self.current["oper"] is "BLZ":
            a = self._readRegfile(self.rtypeRegRead(self.current)[0])
            
            # print("BRANCH REG:\t ", self.regfile)

            if a < 0:
                self._branchPC(self.current["imm"])

            else:
                self._addPC()
        
        elif self.current["oper"] is "JMP":
            self._jumpPC(self.current["jump"])

        elif self.current["oper"] is "JAL":
            temp = self.current_pc + 1
            self._jumpPC(self.current["jump"])
            self._writeRegfile(2, temp)

        else:
            raise ValueError(str)


        # do something

    def rtypeRegRead(self, current):
        return (current["rs"], current["rt"])

    def rtypeRegWrtieAddr(self, current):
        return current["rd"]

    def itypeRegRead(self, current):
        return current["rs"]

    def itypeRegWrtieAddr(self, current):
        return current["rt"]


    def _writeRegfile(self, address, value):
        self.regfile[address] = int(value)

    def _readRegfile(self, address):
        return self.regfile[address]

    def _readDataMemory(self, address):
        if bin(int(self.memory[address], 16))[0] == "-":
            ret = bin(int(self.memory[address], 16))[3:]
        else:
            ret = bin(int(self.memory[address], 16))[2:]
            
        
        ret = "{0:016b}".format(int(ret, 2))

        ret = int(self.memory[address], 16)
        if ret > 32767:
            ret = ~ret + 1

        return ret

    def _writeDataMemory(self, address, value):
        self.memory[address] = "{0:04x}".format(value)


    def _addPC(self):
        self.current_pc += 1
        self.total_pc_updates += 1

    def _jumpPC(self, addr):
        self.current_pc = int(addr)
        self.total_pc_updates += 1


    def _branchPC(self, branchaddr):
        self.current_pc = self.current_pc + int(branchaddr) + 1
        self.total_pc_updates += 1


    

    """ def _executeALU(self, opcode, funct, operand_A, operand_B):
        branch = 0
        result = 0
        return (result, branch)
    """


    

if __name__ == "__main__":
    # print(hex2tsc("9079"))
    # try:
    #     while True:
    #         vm = TSCvm()

    #         num_inst = 0

    #         num_inst_str = str(input("\nInstruction Number(hex): "))

    #         num_inst = int(num_inst_str, 16)

    #         while vm.is_halted == False:
    #             vm.execute()

    #             if (num_inst != 0) and (vm.total_pc_updates > num_inst):
    #                 break


    #         # report
    #         print("\nREGISTER FILE")
    #         print("$0 :\t{0:04x}".format(vm.regfile[0]))
    #         print("$1 :\t{0:04x}".format(vm.regfile[1]))
    #         print("$2 :\t{0:04x}".format(vm.regfile[2]))
    #         print("$3 :\t{0:04x}".format(vm.regfile[3]))

    #         print("\nNumber of Instructions\t {0:04x}".format(vm.total_pc_updates-1))

    #         print("\nNextPC:\t {0:04x}".format(vm.current_pc))
            
    #         print("\nNext Inst:\t " + vm.memory[vm.current_pc])

    # except KeyboardInterrupt as e:
    #     print("EXIT!")
    #     sys.exit(0)


    vm = TSCvm()


    while vm.is_halted == False:
        vm.execute()


    # report
    print("\nREGISTER FILE")
    print("$0 :\t{0:04x}".format(vm.regfile[0]))
    print("$1 :\t{0:04x}".format(vm.regfile[1]))
    print("$2 :\t{0:04x}".format(vm.regfile[2]))
    print("$3 :\t{0:04x}".format(vm.regfile[3]))

    print("\nNumber of Instructions\t {0:04x}".format(vm.total_pc_updates-1))

    print("\nNextPC:\t {0:04x}".format(vm.current_pc))
    
    print("\nNext Inst:\t " + vm.memory[vm.current_pc])