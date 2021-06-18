`timescale 1ns/100ps
`default_nettype none
module oneWordFifo #(
    parameter DW=32
) (
    input wire          Clk,
    input wire          ARst,
    input wire [DW-1:0] WriteData,
    output reg [DW-1:0] ReadData,
    input wire          Wr,
    input wire          Rd,
    output wire         Ety,
    output wire         Full,
    output wire         Ovf,
    output wire         Unf
);
    reg             dataValid;

    assign Ety = ~dataValid;
    assign Full = dataValid;
    assign Unf = Ety & Rd;
    assign Ovf = Full & Wr & ~Rd;

    always @(posedge Clk or posedge ARst) begin
        if (ARst == 1'b1) begin
            ReadData <= 32'hDEADC0DE;
            dataValid <= 0;
        end else begin
            if (Wr || (dataValid && ~Rd)) begin
                dataValid <= 1'b1;
            end else begin
                dataValid <= 0;
            end
            if (Wr) begin
                ReadData <= WriteData;
            end
        end
    end
endmodule
