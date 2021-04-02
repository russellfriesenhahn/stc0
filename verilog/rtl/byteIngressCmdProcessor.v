`timescale 1ns/100ps
`include "stc0_addrMap.vh"

`default_nettype none
module byteIngressCmdProcessor (
    input           ClkIngress,
    input           ARst,
    input   [7:0]   Data,
    input           DataValid,
    output reg      Rdyn,
    output [23:0]   WriteAddr,
    output [31:0]   WriteData,
    output reg      WriteDataValid
);
    // Receive and pack four bytes into 32-bit words
    // Pass words to the command interpreter
    reg [1:0]   rxByteCntr;
    reg [31:0]  rxWord;
    reg         rxWordValid;

    always @(posedge ClkIngress or posedge ARst) begin
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
    
    // ------------------------------------------------------------------------
    // Command Processing
    // ------------------------------------------------------------------------

    localparam STATE_CMD_IDLE   = 0;
    localparam STATE_LEN        = 1;
    localparam STATE_DATA       = 2;
    localparam STATE_EOF        = 3;

    reg [2:0]   cmd_state;
    reg         errInvalidCmd;
    reg         errFrame;
    reg [23:0]  cmdAddr;
    reg [31:0]  cmdData;
    reg [31:0]  cmdLen;

    assign WriteData = cmdData;
    assign WriteAddr = cmdAddr;

    // - Command Word
    //  * [31:24] - Type
    //  * [23:0] - Address
    // - Length Word (number of words to follow in this transaction)
    // - 0..N words
    // - Terminating Word
    //  * [31:16] - Stop Sequence
    //  * [15:0] - CRC16/8/?
    always @(posedge ClkIngress or posedge ARst) begin
        if (ARst == 1'b1) begin
            cmd_state <= STATE_CMD_IDLE;
            errInvalidCmd <= 1'b0;
            errFrame <= 1'b0;
            WriteDataValid <= 1'b0;
        end else begin
            errInvalidCmd <= 1'b0;
            errFrame <= 1'b0;
            WriteDataValid <= 1'b0;

            case (cmd_state)
                STATE_CMD_IDLE: begin
                    if (rxWordValid == 1'b1) begin
                        if (rxWord[7:0] != 8'h01) begin
                            errInvalidCmd <= 1'b1;
                        end else begin
                            cmdAddr <= rxWord[31:8];
                            cmd_state <= STATE_LEN;
                        end
                    end
                end
                STATE_LEN: begin
                    if (rxWordValid == 1'b1) begin
                        cmdLen <= rxWord - 1;
                        cmd_state <= STATE_DATA;
                    end
                end
                STATE_DATA: begin
                    if (WriteDataValid == 1'b1) cmdAddr <= cmdAddr + 4;
                    if (rxWordValid == 1'b1) begin
                        WriteDataValid <= 1'b1;
                        cmdData <= rxWord;


                        if (cmdLen == 0) begin
                            cmd_state <= STATE_EOF;
                        end else begin
                            cmdLen <= cmdLen - 1;
                            cmd_state <= STATE_DATA;
                        end
                    end
                end
                STATE_EOF: begin
                    if (rxWordValid == 1'b1) begin

                        cmd_state <= STATE_CMD_IDLE;

                        if (rxWord[31:16] != `LASTWORD) begin
                            errFrame <= 1'b1;
                        end
                    end
                end
                default: begin
                    cmd_state <= STATE_CMD_IDLE;
                end
            endcase
        end
    end
endmodule
`default_nettype wire
