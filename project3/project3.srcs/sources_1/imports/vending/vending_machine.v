// Title         : vending_machine.v
// Author      : Hunjun Lee (hunjunlee7515@snu.ac.kr), Suheon Bae (suheon.bae@snu.ac.kr)

`include "vending_machine_def.v"

module vending_machine (

    clk,                        // Clock signal
    reset_n,                    // Reset signal (active-low)

    i_input_coin,               // (3bit) coin is inserted.
    i_select_item,              // (4bit) item is selected.
    i_trigger_return,           // change-return is triggered

    o_available_item,			// (4bit) Sign of the item availability
    o_output_item,              // (4bit) Sign of the item withdrawal
    o_return_coin,              // (10bit)Sign of the coin return
    o_current_total             // (32bit)
);

    // Ports Declaration
    input clk;
    input reset_n;

    input [`kNumCoins-1:0] i_input_coin;
    input [`kNumItems-1:0] i_select_item;
    input i_trigger_return;

    output [`kNumItems-1:0] o_available_item;
    output [`kNumItems-1:0] o_output_item;
    output [`kReturnCoins-1:0] o_return_coin;
    output [`kTotalBits-1:0] o_current_total;

    // Net constant values (prefix kk & CamelCase)
    // Decimal values, unsigned 32bit integer!
    wire [31:0] kkItemPrice [`kNumItems-1:0];	// Price of each item
    wire [31:0] kkCoinValue [`kNumCoins-1:0];	// Value of each coin
    assign kkItemPrice[0] = 400;
    assign kkItemPrice[1] = 500;
    assign kkItemPrice[2] = 1000;
    assign kkItemPrice[3] = 2000;
    assign kkCoinValue[0] = 100;
    assign kkCoinValue[1] = 500;
    assign kkCoinValue[2] = 1000;

    // register in state registers
    reg [`kTotalBits-1:0] current_total_in;
    reg [`kNumItems-1:0] sell_sig_in;
    reg [`kReturnCoins-1:0] return_coin_in;

    // register out state registers
    reg [`kTotalBits-1:0] current_total_out;
    reg [`kNumItems-1:0] sell_sig_out;
    reg [`kReturnCoins-1:0] return_coin_out;

    // output reg
    reg [`kReturnCoins-1:0] return_coin;
    reg [`kNumItems-1:0] available_item;
    reg [`kNumItems-1:0] output_item;
    reg [`kTotalBits-1:0] current_total;

    // Output port Mapping
    assign o_available_item = available_item;
    assign o_current_total = current_total;
    assign o_return_coin = return_coin;
    assign o_output_item = output_item;

    // Combinational circuit for the next states
    always @(*) begin
        // f(i_input_coin, i_select_item, i_trigger_return, current_total) -> 4 + 1 + 32 bit state

        // sell signal
        if ((i_select_item[0:0] == 1'b1) && (current_total_out >= kkItemPrice[0])) begin
            // sell_sig_in[0:0] <= 1'b1;
            sell_sig_in <= 4'b0001;
            current_total_in <= current_total_out - kkItemPrice[0];
            return_coin_in <= 0;
        end
        else if ((i_select_item[1:1] == 1'b1) && (current_total_out >= kkItemPrice[1])) begin
            // sell_sig_in[1:1] <= 1'b1;
            sell_sig_in <= 4'b0010;
            current_total_in <= current_total_out - kkItemPrice[1];
            return_coin_in <= 0;
        end
        else if ((i_select_item[2:2] == 1'b1) && (current_total_out >= kkItemPrice[2])) begin
            // sell_sig_in[2:2] <= 1'b1;
            sell_sig_in <= 4'b0100;
            current_total_in <= current_total_out - kkItemPrice[2];
            return_coin_in <= 0;
        end
        else if ((i_select_item[3:3] == 1'b1) && (current_total_out >= kkItemPrice[3])) begin
            // sell_sig_in[3:3] <= 1'b1;
            sell_sig_in <= 4'b1000;
            current_total_in <= current_total_out - kkItemPrice[3];
            return_coin_in <= 0;    
        end

        // No sell signal and coin input | return case
        // if (i_select_item == 4'b0000) begin
        else begin
            sell_sig_in <= 4'b0000;
            // Return signal
            if (i_trigger_return == 1'b1) begin
                return_coin_in <= current_total_out / kkCoinValue[2]
                        + (current_total_out % kkCoinValue[2]) / kkCoinValue[1] 
                        + (current_total_out % kkCoinValue[1]) / kkCoinValue[0];
                current_total_in <= 0;
            end
            else begin
                return_coin_in <= 0;
                // Coin input
                // $display("%b", current_total_out);
                current_total_in <= current_total_out
                                    + kkCoinValue[2] * i_input_coin[2:2]
                                    + kkCoinValue[1] * i_input_coin[1:1]
                                    + kkCoinValue[0] * i_input_coin[0:0];
            end
        end
    end

    // Combinational circuit for the output
    always @(*) begin
        // f(currrent, kkItemPrice) -> available_item
        // g(current, return_sig) -> return_coin

        // Logic for available items output.
        if (current_total_out >= kkItemPrice[3]) begin
            available_item <= 4'b1111;
        end
        else if (current_total_out >= kkItemPrice[2]) begin
            available_item <= 4'b0111;
        end
        else if (current_total_out >= kkItemPrice[1]) begin
            available_item <= 4'b0011;
        end
        else if (current_total_out >= kkItemPrice[0]) begin
            available_item <= 4'b0001;
        end
        else begin
            available_item <= 4'b0000;
        end

        // return coin
        return_coin <= return_coin_out;

        // output item(passthrough)
        output_item <= sell_sig_out;

        // output current total (passthrough)
        current_total <= current_total_out;
        
    end

    // Sequential circuit to reset or update the states
    always @(posedge clk) begin
    	if (!reset_n) begin
            current_total_out <= 0;
            return_coin_out <= 0;
            sell_sig_out <= 0;

    	end
    	else begin
            current_total_out <= current_total_in;
            return_coin_out <= return_coin_in;
            sell_sig_out <= sell_sig_in;
    	end

    end
endmodule
