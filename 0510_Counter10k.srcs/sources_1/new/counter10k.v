`timescale 1ns / 1ps

module UpCounter_10k #(
    parameter MAX_COUNT = 9999
) (
    input clk,
    input reset,

    output [3:0] fndCom,
    output [7:0] fndFont
);

    wire w_clk_10hz;
    wire [13:0] w_count_10k;

    clkDiv #(
        .MAX_COUNT(100_000_00)      // 10Hz, 0.1s
    ) U_ClkDiv_10Hz (
        .reset(reset),
        .clk(clk),

        .o_clk(w_clk_10hz)
    );

    counter #(
        .MAX_COUNT(10_000)      // 10k count
    ) U_Counter_2bit_10Hz (
        .reset(reset),
        .clk  (w_clk_10hz),
        .count(w_count_10k)
    );

    fndContorller U_FndController (
        .reset(reset),
        .clk  (clk),
        .digit(w_count_10k),

        .fndFont(fndFont),
        .fndCom (fndCom)

    );
endmodule




