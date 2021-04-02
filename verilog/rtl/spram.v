// OpenRAM SRAM model
// Words: 512
// Word size: 32

//module sram_32_512_scn4m_subm(
`timescale 1ns/100ps
module spram#(
    parameter DW = 32,
    parameter AW = 9,
    parameter RAM_DEPTH = 1 << AW
) (
    input wire          Clk,
    input wire          Csb0,
    input wire          Web0,
    input wire [AW-1:0] ADDR0,
    input wire [DW-1:0] DIN0,
    output reg [DW-1:0] DOUT0
);
    reg [DW-1:0]    mem [0:RAM_DEPTH-1];
    wire [DW-1:0] dout0_int;
    
    assign dout0_int = mem[ADDR0];

    always @(posedge Clk) begin

        if (!Csb0) begin
            if (!Web0)
                mem[ADDR0] <= DIN0;
            else
                DOUT0 <= dout0_int;
        end 
    end
endmodule
