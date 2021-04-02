`timescale 1ns/100ps

`default_nettype none
module multiplier #(
    parameter DATA_WIDTHA=17,
    parameter DATA_WIDTHB=17
) (
    input                                   Clk,
    input                                   ARst,
    input   [DATA_WIDTHA-1:0]               A,
    input   [DATA_WIDTHB-1:0]               B,
    input                                   ValidIn,
    output  [DATA_WIDTHA+DATA_WIDTHB-1:0]   P,
    output                                  ValidOut
);
    assign P = A * B;
    assign ValidOut = ValidIn;

endmodule
`default_nettype wire
