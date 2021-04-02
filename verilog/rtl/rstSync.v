`timescale 1ns/100ps

module rstSync#(
    parameter NUM_SYNC_CLKS = 3
) (
    input   Clk,
    input   ARst,
    output  Rst
);
    reg [NUM_SYNC_CLKS-1:0] sync;

    assign Rst = sync[0];

    always @(posedge Clk or posedge ARst) begin
        if (ARst) sync <= ~0;
        else      sync <= {1'b0, sync[NUM_SYNC_CLKS-1:1]};
    end
endmodule
