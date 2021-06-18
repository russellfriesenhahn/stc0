`timescale 1ns/100ps

module rstSync#(
    parameter NUM_SYNC_CLKS = 5
) (
    input   Clk,
    input   ARstb,
    output  Rst
);
    reg [NUM_SYNC_CLKS-1:0] sync;

    assign Rst = sync[0];

    always @(posedge Clk or negedge ARstb) begin
        if (ARstb == 1'b0) sync <= ~0;
        else      sync <= {1'b0, sync[NUM_SYNC_CLKS-1:1]};
    end
endmodule
