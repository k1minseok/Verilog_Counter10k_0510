`timescale 1ns / 1ps


module fndContorller (
    input reset,
    input clk,
    input [13:0] digit,
    input [1:0] fndSel,

    output [7:0] fndFont,
    output [3:0] fndCom

);

    wire [3:0] w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [3:0] w_digit;
    wire [1:0] w_count;
    wire w_clk_1khz;


    clkDiv #(
        .MAX_COUNT(100_000)
    ) U_ClkDiv (
        .reset(reset),
        .clk(clk),

        .o_clk(w_clk_1khz)
    );


    counter #(
        .MAX_COUNT(4)
    ) U_Counter_2bit (
        .reset(reset),
        .clk  (w_clk_1khz),
        .count(w_count)
    );


    Adder_Decoder U_Decoder_2x4 (
        .fndSel(w_count),
        .fndCom(fndCom)
    );


    digitSplitter U_DigitSplitter (
        .i_digit(digit),

        .o_digit_1(w_digit_1),
        .o_digit_10(w_digit_10),
        .o_digit_100(w_digit_100),
        .o_digit_1000(w_digit_1000)
    );


    mux U_Mux_4x1 (

        .sel(w_count),
        .x0 (w_digit_1),
        .x1 (w_digit_10),
        .x2 (w_digit_100),
        .x3 (w_digit_1000),

        .y(w_digit)
    );

    BCDtoSEG U_BcdToSeg (
        .bcd(w_digit),
        .seg(fndFont)
    );

endmodule


module digitSplitter (
    input [13:0] i_digit,

    output [3:0] o_digit_1,
    output [3:0] o_digit_10,
    output [3:0] o_digit_100,
    output [3:0] o_digit_1000
);
    assign o_digit_1 = i_digit % 10;
    assign o_digit_10 = i_digit / 10 % 10;
    assign o_digit_100 = i_digit / 100 % 10;
    assign o_digit_1000 = i_digit / 1000 % 10;

endmodule


module mux (

    input [1:0] sel,
    input [3:0] x0,
    input [3:0] x1,
    input [3:0] x2,
    input [3:0] x3,

    output reg [3:0] y
);
    always @(*) begin  // * : 모든 변수 감시
        case (sel)
            2'b00:   y = x0;
            2'b01:   y = x1;
            2'b10:   y = x2;
            2'b11:   y = x3;
            default: y = x0;
        endcase
    end

endmodule


module BCDtoSEG (
    input      [3:0] bcd,
    output reg [7:0] seg
);

    always @(bcd) begin
        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hf9;
            4'h2: seg = 8'ha4;
            4'h3: seg = 8'hb0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'ha: seg = 8'h88;
            4'hb: seg = 8'h83;
            4'hc: seg = 8'hc6;
            4'hd: seg = 8'ha1;
            4'he: seg = 8'h86;
            4'hf: seg = 8'h8e;
            default: seg = 8'hff;
        endcase
    end

endmodule


module Adder_Decoder (
    input [1:0] fndSel,
    output reg [3:0] fndCom
);

    always @(fndSel) begin
        case (fndSel)
            2'b00:   fndCom = 4'b1110;
            2'b01:   fndCom = 4'b1101;
            2'b10:   fndCom = 4'b1011;
            2'b11:   fndCom = 4'b0111;
            default: fndCom = 4'b1111;
        endcase
    end

endmodule


module counter #(
    parameter MAX_COUNT = 4  // define
) (
    input clk,
    input reset,
    output [$clog2(MAX_COUNT)-1:0] count
);
    reg [$clog2(MAX_COUNT)-1:0] counter = 0;

    assign count = counter;

    always @(posedge clk, posedge reset) begin  // 리셋 버튼 누르면?
        if (reset == 1'b1) begin
            counter <= 0;
        end else begin
            if (counter == MAX_COUNT - 1) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule


module clkDiv #(
    parameter MAX_COUNT = 100
) (
    input  clk,
    input  reset,
    output o_clk
);

    reg [$clog2(
MAX_COUNT
)-1:0] counter = 0;  // 17bit <- clog : 2의 n승 : 100000, n : 17(0부터 시작이므로 17-1) 
    reg r_tick = 0;
    assign o_clk = r_tick;

    always @(posedge clk, posedge reset) begin  // 리셋 버튼 누르면?
        if (reset == 1'b1) begin
            counter <= 0;
        end else begin
            if (counter == (MAX_COUNT - 1)) begin
                counter <= 0;
                r_tick  <= 1'b1;  // clk이 100 000 000 일때 1, 나머지는 0
            end else begin
                counter <= counter + 1;
                r_tick  <= 1'b0;
            end
        end
    end

endmodule
