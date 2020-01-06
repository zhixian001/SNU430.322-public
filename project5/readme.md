# Lab 05 Multicycle cpu

## MEMORY DUMP

```code
000 :	 JMP	35			# JUMP
001 :	 BNE	$0,	$0,	1	# BRANCH
002 :	 # Might Be Data(illegal funct): 1111111111111111
003 :	 # Might Be Data(ZERO): 0
004 :	 # Might Be Data(ZERO): 0
005 :	 # Might Be Data(ZERO): 0
006 :	 # Might Be Data(ZERO): 0
007 :	 # Might Be Data(ZERO): 0
008 :	 # Might Be Data(ZERO): 0
009 :	 # Might Be Data(ZERO): 0
010 :	 # Might Be Data(ZERO): 0
011 :	 # Might Be Data(ZERO): 0
012 :	 # Might Be Data(ZERO): 0
013 :	 # Might Be Data(ZERO): 0
014 :	 # Might Be Data(ZERO): 0
015 :	 # Might Be Data(ZERO): 0
016 :	 # Might Be Data(ZERO): 0
017 :	 # Might Be Data(ZERO): 0
018 :	 # Might Be Data(ZERO): 0
019 :	 # Might Be Data(ZERO): 0
020 :	 # Might Be Data(ZERO): 0
021 :	 # Might Be Data(ZERO): 0
022 :	 # Might Be Data(ZERO): 0
023 :	 # Might Be Data(ZERO): 0
024 :	 # Might Be Data(ZERO): 0
025 :	 # Might Be Data(ZERO): 0
026 :	 # Might Be Data(ZERO): 0
027 :	 # Might Be Data(ZERO): 0
028 :	 # Might Be Data(ZERO): 0
029 :	 # Might Be Data(ZERO): 0
030 :	 # Might Be Data(ZERO): 0
031 :	 # Might Be Data(ZERO): 0
032 :	 # Might Be Data(ZERO): 0
033 :	 # Might Be Data(ZERO): 0
034 :	 # Might Be Data(ZERO): 0
035 :	 LHI	$0,	$0,	0
036 :	 WWD	$0			# READVALUE!!!
037 :	 LHI	$1,	$0,	0
038 :	 WWD	$1			# READVALUE!!!
039 :	 LHI	$2,	$0,	0
040 :	 WWD	$2			# READVALUE!!!
041 :	 LHI	$3,	$0,	0
042 :	 WWD	$3			# READVALUE!!!
043 :	 ADI	$0,	$1,	1
044 :	 WWD	$0			# READVALUE!!!
045 :	 ADI	$0,	$0,	1
046 :	 WWD	$0			# READVALUE!!!
047 :	 ORI	$1,	$2,	1
048 :	 WWD	$1			# READVALUE!!!
049 :	 ORI	$1,	$1,	10
050 :	 WWD	$1			# READVALUE!!!
051 :	 ORI	$1,	$1,	11
052 :	 WWD	$1			# READVALUE!!!
053 :	 ADD	$3,	$0,	$2
054 :	 WWD	$3			# READVALUE!!!
055 :	 ADD	$3,	$1,	$2
056 :	 WWD	$3			# READVALUE!!!
057 :	 ADD	$3,	$0,	$1
058 :	 WWD	$3			# READVALUE!!!
059 :	 SUB	$3,	$0,	$2
060 :	 WWD	$3			# READVALUE!!!
061 :	 SUB	$3,	$2,	$0
062 :	 WWD	$3			# READVALUE!!!
063 :	 SUB	$3,	$1,	$2
064 :	 WWD	$3			# READVALUE!!!
065 :	 SUB	$3,	$2,	$1
066 :	 WWD	$3			# READVALUE!!!
067 :	 SUB	$3,	$0,	$1
068 :	 WWD	$3			# READVALUE!!!
069 :	 SUB	$3,	$1,	$0
070 :	 WWD	$3			# READVALUE!!!
071 :	 AND	$3,	$0,	$2
072 :	 WWD	$3			# READVALUE!!!
073 :	 AND	$3,	$1,	$2
074 :	 WWD	$3			# READVALUE!!!
075 :	 AND	$3,	$0,	$1
076 :	 WWD	$3			# READVALUE!!!
077 :	 ORR	$3,	$0,	$2
078 :	 WWD	$3			# READVALUE!!!
079 :	 ORR	$3,	$1,	$2
080 :	 WWD	$3			# READVALUE!!!
081 :	 ORR	$3,	$0,	$1
082 :	 WWD	$3			# READVALUE!!!
083 :	 NOT	$3,	$0
084 :	 WWD	$3			# READVALUE!!!
085 :	 NOT	$3,	$1
086 :	 WWD	$3			# READVALUE!!!
087 :	 NOT	$3,	$2
088 :	 WWD	$3			# READVALUE!!!
089 :	 TCP	$3,	$0
090 :	 WWD	$3			# READVALUE!!!
091 :	 TCP	$3,	$1
092 :	 WWD	$3			# READVALUE!!!
093 :	 TCP	$3,	$2
094 :	 WWD	$3			# READVALUE!!!
095 :	 SHL	$3,	$0
096 :	 WWD	$3			# READVALUE!!!
097 :	 SHL	$3,	$1
098 :	 WWD	$3			# READVALUE!!!
099 :	 SHL	$3,	$2
100 :	 WWD	$3			# READVALUE!!!
101 :	 SHR	$3,	$0
102 :	 WWD	$3			# READVALUE!!!
103 :	 SHR	$3,	$1
104 :	 WWD	$3			# READVALUE!!!
105 :	 SHR	$3,	$2
106 :	 WWD	$3			# READVALUE!!!
107 :	 LWD	$0,	1($2)
108 :	 WWD	$0			# READVALUE!!!
109 :	 LWD	$1,	10($2)
110 :	 WWD	$1			# READVALUE!!!
111 :	 SWD	$1,	1($2)
112 :	 SWD	$0,	10($2)
113 :	 LWD	$0,	1($2)
114 :	 WWD	$0			# READVALUE!!!
115 :	 LWD	$1,	10($2)
116 :	 WWD	$1			# READVALUE!!!
117 :	 JMP	118			# JUMP
118 :	 WWD	$0			# READVALUE!!!
119 :	 JMP	121			# JUMP
120 :	 HLT	
121 :	 WWD	$1			# READVALUE!!!
122 :	 BNE	$2,	$3,	1	# BRANCH
123 :	 JMP	125			# JUMP
124 :	 HLT	
125 :	 WWD	$0			# READVALUE!!!
126 :	 BNE	$1,	$2,	1	# BRANCH
127 :	 HLT	
128 :	 WWD	$1			# READVALUE!!!
129 :	 BEQ	$1,	$2,	1	# BRANCH
130 :	 JMP	132			# JUMP
131 :	 HLT	
132 :	 WWD	$0			# READVALUE!!!
133 :	 BEQ	$2,	$3,	1	# BRANCH
134 :	 HLT	
135 :	 WWD	$1			# READVALUE!!!
136 :	 BGZ	$0,	$0,	1	# BRANCH
137 :	 JMP	139			# JUMP
138 :	 HLT	
139 :	 WWD	$0			# READVALUE!!!
140 :	 BGZ	$1,	$0,	1	# BRANCH
141 :	 HLT	
142 :	 WWD	$1			# READVALUE!!!
143 :	 BGZ	$2,	$0,	1	# BRANCH
144 :	 JMP	146			# JUMP
145 :	 HLT	
146 :	 WWD	$0			# READVALUE!!!
147 :	 BLZ	$0,	$0,	1	# BRANCH
148 :	 HLT	
149 :	 WWD	$1			# READVALUE!!!
150 :	 BLZ	$1,	$0,	1	# BRANCH
151 :	 JMP	153			# JUMP
152 :	 HLT	
153 :	 WWD	$0			# READVALUE!!!
154 :	 BLZ	$2,	$0,	1	# BRANCH
155 :	 JMP	157			# JUMP
156 :	 HLT	
157 :	 WWD	$1			# READVALUE!!!
158 :	 JAL	175			# JUMP
159 :	 WWD	$0			# READVALUE!!!
160 :	 JAL	174			# JUMP
161 :	 HLT	
162 :	 WWD	$1			# READVALUE!!!
163 :	 LHI	$3,	$0,	0
164 :	 ORI	$3,	$3,	11
165 :	 LHI	$0,	$0,	0
166 :	 ADI	$0,	$0,	101
167 :	 JAL	178			# JUMP
168 :	 WWD	$0			# READVALUE!!!
169 :	 JMP	177			# JUMP
170 :	 ADI	$1,	$2,	0
171 :	 JRL	$1			# JUMP REG
172 :	 WWD	$0			# READVALUE!!!
173 :	 HLT	
174 :	 ADI	$2,	$2,	1
175 :	 JPR	$2			# JUMP REG
176 :	 HLT	
177 :	 JAL	170			# JUMP
178 :	 ADI	$1,	$0,	-1
179 :	 BGZ	$1,	$0,	100	# BRANCH
180 :	 LHI	$0,	$0,	0
181 :	 ORI	$0,	$0,	1
182 :	 JPR	$2			# JUMP REG
183 :	 HLT	
184 :	 SWD	$2,	0($3)
185 :	 SWD	$0,	1($3)
186 :	 ADI	$3,	$3,	10
187 :	 ADI	$0,	$0,	-2
188 :	 JAL	178			# JUMP
189 :	 LWD	$1,	-1($3)
190 :	 SWD	$0,	-1($3)
191 :	 ADI	$0,	$1,	-1
192 :	 JAL	178			# JUMP
193 :	 LWD	$1,	-1($3)
194 :	 LWD	$2,	-2($3)
195 :	 ADD	$0,	$0,	$1
196 :	 ADI	$3,	$3,	-2
197 :	 JPR	$2			# JUMP REG
198 :	 HLT	
```

시뮬레이터에 돌아가면...

```assembly
JMP	35			# JUMP
BNE	$0,	$0,	1	# BRANCH
# Might Be Data(illegal funct): 1111111111111111
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
# Might Be Data(ZERO): 0
LHI	$0,	$0,	0
WWD	$0			# READVALUE!!!
LHI	$1,	$0,	0
WWD	$1			# READVALUE!!!
LHI	$2,	$0,	0
WWD	$2			# READVALUE!!!
LHI	$3,	$0,	0
WWD	$3			# READVALUE!!!
ADI	$0,	$1,	1
WWD	$0			# READVALUE!!!
ADI	$0,	$0,	1
WWD	$0			# READVALUE!!!
ORI	$1,	$2,	1
WWD	$1			# READVALUE!!!
ORI	$1,	$1,	10
WWD	$1			# READVALUE!!!
ORI	$1,	$1,	11
WWD	$1			# READVALUE!!!
ADD	$3,	$0,	$2
WWD	$3			# READVALUE!!!
ADD	$3,	$1,	$2
WWD	$3			# READVALUE!!!
ADD	$3,	$0,	$1
WWD	$3			# READVALUE!!!
SUB	$3,	$0,	$2
WWD	$3			# READVALUE!!!
SUB	$3,	$2,	$0
WWD	$3			# READVALUE!!!
SUB	$3,	$1,	$2
WWD	$3			# READVALUE!!!
SUB	$3,	$2,	$1
WWD	$3			# READVALUE!!!
SUB	$3,	$0,	$1
WWD	$3			# READVALUE!!!
SUB	$3,	$1,	$0
WWD	$3			# READVALUE!!!
AND	$3,	$0,	$2
WWD	$3			# READVALUE!!!
AND	$3,	$1,	$2
WWD	$3			# READVALUE!!!
AND	$3,	$0,	$1
WWD	$3			# READVALUE!!!
ORR	$3,	$0,	$2
WWD	$3			# READVALUE!!!
ORR	$3,	$1,	$2
WWD	$3			# READVALUE!!!
ORR	$3,	$0,	$1
WWD	$3			# READVALUE!!!
NOT	$3,	$0
WWD	$3			# READVALUE!!!
NOT	$3,	$1
WWD	$3			# READVALUE!!!
NOT	$3,	$2
WWD	$3			# READVALUE!!!
TCP	$3,	$0
WWD	$3			# READVALUE!!!
TCP	$3,	$1
WWD	$3			# READVALUE!!!
TCP	$3,	$2
WWD	$3			# READVALUE!!!
SHL	$3,	$0
WWD	$3			# READVALUE!!!
SHL	$3,	$1
WWD	$3			# READVALUE!!!
SHL	$3,	$2
WWD	$3			# READVALUE!!!
SHR	$3,	$0
WWD	$3			# READVALUE!!!
SHR	$3,	$1
WWD	$3			# READVALUE!!!
SHR	$3,	$2
WWD	$3			# READVALUE!!!
LWD	$0,	1($2)
WWD	$0			# READVALUE!!!
LWD	$1,	10($2)
WWD	$1			# READVALUE!!!
SWD	$1,	1($2)
SWD	$0,	10($2)
LWD	$0,	1($2)
WWD	$0			# READVALUE!!!
LWD	$1,	10($2)
WWD	$1			# READVALUE!!!
JMP	118			# JUMP
WWD	$0			# READVALUE!!!
JMP	121			# JUMP
HLT	
WWD	$1			# READVALUE!!!
BNE	$2,	$3,	1	# BRANCH
JMP	125			# JUMP
HLT	
WWD	$0			# READVALUE!!!
BNE	$1,	$2,	1	# BRANCH
HLT	
WWD	$1			# READVALUE!!!
BEQ	$1,	$2,	1	# BRANCH
JMP	132			# JUMP
HLT	
WWD	$0			# READVALUE!!!
BEQ	$2,	$3,	1	# BRANCH
HLT	
WWD	$1			# READVALUE!!!
BGZ	$0,	$0,	1	# BRANCH
JMP	139			# JUMP
HLT	
WWD	$0			# READVALUE!!!
BGZ	$1,	$0,	1	# BRANCH
HLT	
WWD	$1			# READVALUE!!!
BGZ	$2,	$0,	1	# BRANCH
JMP	146			# JUMP
HLT	
WWD	$0			# READVALUE!!!
BLZ	$0,	$0,	1	# BRANCH
HLT	
WWD	$1			# READVALUE!!!
BLZ	$1,	$0,	1	# BRANCH
JMP	153			# JUMP
HLT	
WWD	$0			# READVALUE!!!
BLZ	$2,	$0,	1	# BRANCH
JMP	157			# JUMP
HLT	
WWD	$1			# READVALUE!!!
JAL	175			# JUMP
WWD	$0			# READVALUE!!!
JAL	174			# JUMP
HLT	
WWD	$1			# READVALUE!!!
LHI	$3,	$0,	0
ORI	$3,	$3,	11
LHI	$0,	$0,	0
ADI	$0,	$0,	101
JAL	178			# JUMP
WWD	$0			# READVALUE!!!
JMP	177			# JUMP
ADI	$1,	$2,	0
JRL	$1			# JUMP REG
WWD	$0			# READVALUE!!!
HLT	
ADI	$2,	$2,	1
JPR	$2			# JUMP REG
HLT	
JAL	170			# JUMP
ADI	$1,	$0,	-1
BGZ	$1,	$0,	100	# BRANCH
LHI	$0,	$0,	0
ORI	$0,	$0,	1
JPR	$2			# JUMP REG
HLT	
SWD	$2,	0($3)
SWD	$0,	1($3)
ADI	$3,	$3,	10
ADI	$0,	$0,	-2
JAL	178			# JUMP
LWD	$1,	-1($3)
SWD	$0,	-1($3)
ADI	$0,	$1,	-1
JAL	178			# JUMP
LWD	$1,	-1($3)
LWD	$2,	-2($3)
ADD	$0,	$0,	$1
ADI	$3,	$3,	-2
JPR	$2			# JUMP REG
HLT
```

순서대로 하면

```assembly
000 :	 JMP	35			# JUMP

035 :	 LHI	$0,	$0,	0
036 :	 WWD	$0			# READVALUE!!!
037 :	 LHI	$1,	$0,	0
038 :	 WWD	$1			# READVALUE!!!
039 :	 LHI	$2,	$0,	0
040 :	 WWD	$2			# READVALUE!!!
041 :	 LHI	$3,	$0,	0
042 :	 WWD	$3			# READVALUE!!!
043 :	 ADI	$0,	$1,	1
044 :	 WWD	$0			# READVALUE!!!
045 :	 ADI	$0,	$0,	1
046 :	 WWD	$0			# READVALUE!!!
047 :	 ORI	$1,	$2,	1
048 :	 WWD	$1			# READVALUE!!!
049 :	 ORI	$1,	$1,	10
050 :	 WWD	$1			# READVALUE!!!
051 :	 ORI	$1,	$1,	11
052 :	 WWD	$1			# READVALUE!!!
053 :	 ADD	$3,	$0,	$2
054 :	 WWD	$3			# READVALUE!!!
055 :	 ADD	$3,	$1,	$2
056 :	 WWD	$3			# READVALUE!!!
057 :	 ADD	$3,	$0,	$1
058 :	 WWD	$3			# READVALUE!!!
059 :	 SUB	$3,	$0,	$2
060 :	 WWD	$3			# READVALUE!!!
061 :	 SUB	$3,	$2,	$0
062 :	 WWD	$3			# READVALUE!!!
063 :	 SUB	$3,	$1,	$2
064 :	 WWD	$3			# READVALUE!!!
065 :	 SUB	$3,	$2,	$1
066 :	 WWD	$3			# READVALUE!!!
067 :	 SUB	$3,	$0,	$1
068 :	 WWD	$3			# READVALUE!!!
069 :	 SUB	$3,	$1,	$0
070 :	 WWD	$3			# READVALUE!!!
071 :	 AND	$3,	$0,	$2
072 :	 WWD	$3			# READVALUE!!!
073 :	 AND	$3,	$1,	$2
074 :	 WWD	$3			# READVALUE!!!
075 :	 AND	$3,	$0,	$1
076 :	 WWD	$3			# READVALUE!!!
077 :	 ORR	$3,	$0,	$2
078 :	 WWD	$3			# READVALUE!!!
079 :	 ORR	$3,	$1,	$2
080 :	 WWD	$3			# READVALUE!!!
081 :	 ORR	$3,	$0,	$1
082 :	 WWD	$3			# READVALUE!!!
083 :	 NOT	$3,	$0
084 :	 WWD	$3			# READVALUE!!!
085 :	 NOT	$3,	$1
086 :	 WWD	$3			# READVALUE!!!
087 :	 NOT	$3,	$2
088 :	 WWD	$3			# READVALUE!!!
089 :	 TCP	$3,	$0
090 :	 WWD	$3			# READVALUE!!!
091 :	 TCP	$3,	$1
092 :	 WWD	$3			# READVALUE!!!
093 :	 TCP	$3,	$2
094 :	 WWD	$3			# READVALUE!!!
095 :	 SHL	$3,	$0
096 :	 WWD	$3			# READVALUE!!!
097 :	 SHL	$3,	$1
098 :	 WWD	$3			# READVALUE!!!
099 :	 SHL	$3,	$2
100 :	 WWD	$3			# READVALUE!!!
101 :	 SHR	$3,	$0
102 :	 WWD	$3			# READVALUE!!!
103 :	 SHR	$3,	$1
104 :	 WWD	$3			# READVALUE!!!
105 :	 SHR	$3,	$2
106 :	 WWD	$3			# READVALUE!!!

107 :	 LWD	$0,	1($2)                     # <- PROBLEM HERE: CONTROLSIG
108 :	 WWD	$0			# READVALUE!!!
109 :	 LWD	$1,	10($2)                    # <- PROBLEM HERE: CONTROLSIG
110 :	 WWD	$1			# READVALUE!!!
111 :	 SWD	$1,	1($2)
112 :	 SWD	$0,	10($2)
113 :	 LWD	$0,	1($2)
114 :	 WWD	$0			# READVALUE!!!
115 :	 LWD	$1,	10($2)
116 :	 WWD	$1			# READVALUE!!!

117 :	 JMP	118			# JUMP
118 :	 WWD	$0			# READVALUE!!!
119 :	 JMP	121			# JUMP

121 :	 WWD	$1			# READVALUE!!!
122 :	 BNE	$2,	$3,	1	# BRANCH
~~~~~~~

```

122줄 이후로는 모름


## Problems

1. Instruction Register latch failure
    1. memory timing?


## Microcode Outputs

고칠 것: IF스테이지에서 PC+1, ID스테이지에서 JUMP, EX_Branch스테이지에서 B-cond 비교하기

### meminstread

```code
Instruction_Register <- memdata
ALUOUT <- PC+1
```

- **IF**

- States
  - IRWrite = 1 (Instruction Register Write)
  - Memaddrmux = 0 (read PC)


### pcadd12pc

```code
PC <- ALUOUT
```

주의

- **ID**
- PC <- ALUOUT

- States
  - ALUsrcAMux = 0 (PC)
  - ALUsrcBMux = 1 (+1)
  - PCWrite = 1?
  - PCnextmux = 0 (nextPC = PC + 1)
  - ALU MODE: ADD


### alu2pc

```code
PC <- ALU
```

- **ID**
- Jump Absolute

- states

### concat2pc

```code
PC <- {PC[15:12], J[11:0]}
```

- **ID**
- Jump Relative

- states

### addpcimm2aluout

```code
ALUOUT(ALU_Result) = ALU($pc, imm)
```

- **ID (branch)**

<!-- ### aluout2pc -->
### conditionalpc

```code
PC <- ALUOUT
```

**중요: 반드시 비교할 alu의 operand를 골라야 함**

- **EX_Branch**
- Branch

### rfinstread2a

```code
A_Register($rs) <- RegFile[Inst_reg[11:10]]
```

- **ID**

### rfinstread2b

```code
B_Register($rt) <- RegFile[Inst_reg[9:8]]
```

- **ID**

### useab2aluout

```code
ALU_Result = ALU($rs, $rt)
```

- **EX**

### useaimm2aluout

```code
ALU_Result = ALU($rs, imm)
```

- **EX**

### readmemory2mdr

```code
Memory_Data_Register <- Memory[ALUOUT]
```

- **MEM**

Memory Read Operation

### writedatamemory

```code
Memory[ALUOUT] <- B_Register
```

- **MEM**

Memory Write Operation

### aluout2regrd

```code
RegFile[Inst_Reg[7:6]($rd)] <- ALUOUT
```

- **WB**

### aluout2regrt

```code
RegFile[Inst_Reg[9:8]($rt)] <- ALUOUT
```

- **WB**

### mdr2regrt

```code
Regfile[Inst_Reg[9:8]($rt)] <- Memory_Data_Register
```

- **WB**


## Control Signals

### PCWriteCond

> Ex_Branch

조건부 PC Write

- 0: 비활성화
- 1: 활성화

### PCWrite

> ID

PC 변화

- 0: 비활섷화
- 1: 활성화

### IorD

> IF | Mem

메모리 읽어오는/쓰는 주소 선택

- 0: I (PC 주소값 데이터 읽어오기)
- 1: D (데이터 주소값 읽기 / 쓰기)

### MemRead

> If | Mem

메모리 읽기 활성화

- 0: 읽기 비활성화
- 1: 읽기 활성화

### Memwrite

> Mem

메모리 쓰기 활성화

- 0: 쓰기 비활성화
- 1: 쓰기 활성화

### MemtoReg

> WB

RegFile WB

- 0: Writeback from ALUOUT
- 1: Writeback from Memory Data Register

### IRWrite

> IF

Instruction Register 에 쓰기

- 0: IR latch 비활성화
- 1: IR latch 활성화

### PCSource (2)

> ID | EX_Branch

PC에 쓸 값 고르기

- 0: PC+1 | Absolute Jump (ID, EX_Branch)
- 1: Branch Take or Not? (EX_Branch)
- 2: Relataive Jump (ID)

### ALUControl (4)

> ID | EX | EX_Branch

- ID: 주소를 더하거나, PC+1하거나 그대로 값을 내보냄
- EX: 시킨 명령대로
- EX_Branch: 조건 평가

### AluSrcB (2)

> ID | EX | EX_Branch

- 0: Register B의 값을 가져옴 (R Type)
- 1: PC+1
- 2: immediate # 8'b00000000

### AluSrcA

> ID | EX | EX_Branch

- 0: PC
- 1: Register A

### RegWrite

> ID(jump) | WB

- 0: 비활성화
- 1: 활성화

### RegDst

> ID(jump) | WB

- 0: I타입 및 그 외 다른 명령어들의 WB
- 1: R타입 명령어의 WB