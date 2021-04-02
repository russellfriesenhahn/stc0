//------------------------------------------------------------------------------
// byteEgress.v
//
// This module receives a 32b signal and transmits the signal a byte at
// a time. This module does not accept or provide backpressure in either
// direction. Data will be lost if the upstream module attempts to write a 32b
// value more than once per 4 clocks.
//
//------------------------------------------------------------------------------
`timescale 1ns/100ps
`default_nettype none
module byteEgress (
    input wire          ClkEngress,
    input wire          ARst,
    input wire [31:0]   WriteData,
    input wire          WriteDataValid,
    output reg [7:0]    Data,
    output reg          DataValid,
    output reg          Ready
);
    reg [1:0] byteNum;
    reg [31:0] writeDataSave;

    always @(posedge ClkEngress or posedge ARst) begin
        if (ARst == 1'b1) begin
            byteNum <= 0;
            DataValid <= 0;
            Ready <= 1'b1;
        end else begin

            if (Ready && WriteDataValid) begin
                writeDataSave <= WriteData;
                Ready <= 0;
            end

            if (WriteDataValid || (byteNum > 0) || ~Ready) begin
                DataValid <= 1'b1;
                byteNum <= byteNum + 1;
            end else begin
                DataValid <= 1'b0;
            end
            case (byteNum)
                2'b00: begin
                    if (Ready) begin
                        Data <= WriteData[7:0];
                    end else begin
                        byteNum <= byteNum + 1;
                        Data <= writeDataSave[7:0];
                    end
                end
                2'b01: begin
                    Data <= writeDataSave[15:8];
                end
                2'b10: begin
                    Data <= writeDataSave[23:16];
                    Ready <= 1'b1;
                end
                2'b11: begin
                    Data <= writeDataSave[31:24];
                end
            endcase
        end
    end
endmodule
`default_nettype wire
