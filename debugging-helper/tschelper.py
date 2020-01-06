# -*- coding: utf-8 -*-
# Author: JHYeom (zhixian001)


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
    
    
    
def hex2tsc(value):
    return bin16decode(hex2bin(value))



if __name__ == "__main__":
    hw5_memory =  ["9023", "1", "ffff", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "6000", "f01c", "6100", "f41c", "6200", "f81c", "6300", "fc1c", "4401", "f01c", "4001", "f01c", "5901", "f41c", "5502", "f41c", "5503", "f41c", "f2c0", "fc1c", "f6c0", "fc1c", "f1c0", "fc1c", "f2c1", "fc1c", "f8c1", "fc1c", "f6c1", "fc1c", "f9c1", "fc1c", "f1c1", "fc1c", "f4c1", "fc1c", "f2c2", "fc1c", "f6c2", "fc1c", "f1c2", "fc1c", "f2c3", "fc1c", "f6c3", "fc1c", "f1c3", "fc1c", "f0c4", "fc1c", "f4c4", "fc1c", "f8c4", "fc1c", "f0c5", "fc1c", "f4c5", "fc1c", "f8c5", "fc1c", "f0c6", "fc1c", "f4c6", "fc1c", "f8c6", "fc1c", "f0c7", "fc1c", "f4c7", "fc1c", "f8c7", "fc1c", "7801", "f01c", "7902", "f41c", "8901", "8802", "7801", "f01c", "7902", "f41c", "9076", "f01c", "9079", "f01d", "f41c", "b01", "907d", "f01d", "f01c", "601", "f01d", "f41c", "1601", "9084", "f01d", "f01c", "1b01", "f01d", "f41c", "2001", "908b", "f01d", "f01c", "2401", "f01d", "f41c", "2801", "9092", "f01d", "f01c", "3001", "f01d", "f41c", "3401", "9099", "f01d", "f01c", "3801", "909d", "f01d", "f41c", "a0af", "f01c", "a0ae", "f01d", "f41c", "6300", "5f03", "6000", "4005", "a0b2", "f01c", "90b1", "4900", "f41a", "f01c", "f01d", "4a01", "f819", "f01d", "a0aa", "41ff", "2404", "6000", "5001", "f819", "f01d", "8e00", "8c01", "4f02", "40fe", "a0b2", "7dff", "8cff", "44ff", "a0b2", "7dff", "7efe", "f100", "4ffe", "f819", "f01d"]

    memaddr = 0
    for D in hw5_memory:

        print("{0:03d}".format(memaddr), ":\t", hex2tsc(D))
        memaddr += 1