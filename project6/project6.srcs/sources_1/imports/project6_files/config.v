// Author: JHYeom (zhixian001)
`timescale 1ns/100ps

`ifdef CONFIG_V
`else
`define CONFIG_V

// Pipeline Congrol Signal Size
// For scalable pipeline register management
`define EX_SIGNAL_SIZE  10
`define MEM_SIGNAL_SIZE 4
`define WB_SIGNAL_SIZE  4

`define REG_ADDR_SIZE   2



// SINULATION CONFIGS
// Enable or Disable Forwarding Unit
`define FORWARDING_UNIT_ENABLED 1
`define BRANCH_PREDICTION_ENABLED 1
// 1 for hysteresis
// 0 for saturation
`define BRANCH_PREDICTOR_COUNTER_TYPE 1


`endif
