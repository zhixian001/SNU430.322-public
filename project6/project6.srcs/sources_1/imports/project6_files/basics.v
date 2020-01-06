// Author: JHYeom (zhixian001)
`timescale 1ns/100ps

`ifdef WORD_SIZE
`else
`define WORD_SIZE 16
`endif



// 16 bit latching module
`ifdef BASICS_V
`else

`define BASICS_V
module Latch16(
    input clk,
    input [`WORD_SIZE-1:0] in,
    input enable,
    input reset_n,
    output reg [`WORD_SIZE-1:0] out
);
    always @(posedge clk) begin
        if (reset_n == 0) begin
            out <= 0;
        end
        else if (enable == 1'b1) begin
            out <= in; 
        end
    end

endmodule

// 3 bit latching module
module Latch3(
    input clk,
    input [2:0] in,
    input reset_n,
    output reg [2:0] out
);
    always @(posedge clk) begin
        if (reset_n == 0) begin
            out <= 0;
        end
        else begin
            out <= in; 
        end
    end

endmodule

// 4 bit latching module
module Latch4(
    input clk,
    input [3:0] in,
    input reset_n,
    output reg [3:0] out
);
    always @(posedge clk) begin
        if (reset_n == 0) begin
            out <= 0;
        end
        else begin
            out <= in; 
        end
    end

endmodule

// Combinational Modules for basic tasks
module MUX2_2_1(
    input [1:0] inp0,
    input [1:0] inp1,
    input sel,
    output [1:0] out
);
    // 2 bit wide 2:1 mux
    assign out = sel? inp1 : inp0;

endmodule

module MUX2_3_1(
    input [1:0] inp0,
    input [1:0] inp1,
    input [1:0] inp2,
    input [1:0] sel,    
    output [1:0] out
);
    // 2 bit wide 2:1 mux
    assign out = sel[1]? inp2 : (sel[0]? inp1 : inp0);


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

module MUX16_4_1(
    input [`WORD_SIZE-1:0] inp0,
    input [`WORD_SIZE-1:0] inp1,
    input [`WORD_SIZE-1:0] inp2,
    input [`WORD_SIZE-1:0] inp3,
    input [1:0] sel,
    output [`WORD_SIZE-1:0] out 
);
    // 16 bit wide 3:1 mux
    assign out = sel[1]? (sel[0]? inp3 : inp2): (sel[0]? inp1 : inp0);

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

`endif