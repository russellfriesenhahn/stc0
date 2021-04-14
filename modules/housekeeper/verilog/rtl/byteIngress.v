//------------------------------------------------------------------------------
// UART Receiver
//
//------------------------------------------------------------------------------
`timescale 1ns/100ps
`default_nettype none
module byteIngress (
    input   wire        Clk,
    input   wire        ARst,
    input   wire [7:0]  Data,
    input   wire        DataValid,
    output  reg         Rdyn,
    output  reg [7:0]   RxD,
    output  reg         RxDValid
);
    reg [1:0]   rxByteCntr;
    reg [31:0]  rxWord;
    reg         rxWordValid;

    always @(posedge Clk or posedge ARst) begin
        if (ARst == 1'b1) begin
            Rdyn <= 1'b1;
            rxByteCntr <= 2'b00;
            rxWordValid <= 1'b0;
        end else begin
            Rdyn <= 1'b0;
            rxWordValid <= 1'b0;

            if (DataValid && ~Rdyn) rxByteCntr <= rxByteCntr + 1;

            case (rxByteCntr)
                2'b00: if (DataValid) rxWord[7:0] <= Data;
                2'b01: if (DataValid) rxWord[15:8] <= Data;
                2'b10: if (DataValid) rxWord[23:16] <= Data;
                2'b11: begin
                    if (DataValid) begin
                        rxWord[31:24] <= Data;
                        rxWordValid <= 1'b1;
                    end
                end
            endcase
        end
    end
    
endmodule
`default_nettype wire 
