`timescale 1ns/100ps

//`include "addrMap.vh"
`define LASTWORD                            16'habcd
module HKbyteIngress (
    input   wire          ClkIngress,
    input   wire          ARst,
    input   wire  [7:0]   Data,
    input   wire          DataValid,
    output  reg           Rdyn,
    output  reg           RWn,
    input   wire          HostWriteValid,
    output  reg   [23:0]  CmdAddr,
    output  wire  [31:0]  WriteData,
    output  reg           WriteDataValid,
    output  reg           EValid,
    output  reg   [7:0]   ED
);
    // Receive and pack four bytes into 32-bit words
    // Pass words to the command interpreter
    reg [1:0]   rxByteCntr;
    reg [31:0]  rxWord;
    reg         rxWordValid;

    reg [1:0]   edByteCnt;
    //always @(posedge ClkIngress or posedge ARst) begin
        //if (ARst == 1'b1) begin
            //Rdyn <= 1'b1;
            //rxByteCntr <= 2'b00;
            //rxWordValid <= 1'b0;
        //end else begin
            //Rdyn <= 1'b0;
            //rxWordValid <= 1'b0;

            //if (DataValid && ~Rdyn) rxByteCntr <= rxByteCntr + 1;

            //case (rxByteCntr)
                //2'b00: if (DataValid) rxWord[7:0] <= Data;
                //2'b01: if (DataValid) rxWord[15:8] <= Data;
                //2'b10: if (DataValid) rxWord[23:16] <= Data;
                //2'b11: begin
                    //if (DataValid) begin
                        //rxWord[31:24] <= Data;
                        //rxWordValid <= 1'b1;
                    //end
                //end
            //endcase
        //end
    //end
    
    // ------------------------------------------------------------------------
    // Command Processing
    // ------------------------------------------------------------------------

    localparam STATE_CMD_IDLE   = 0;
    localparam STATE_LEN        = 1;
    localparam STATE_DATA       = 2;
    localparam STATE_EOF        = 3;
    localparam STATE_RD         = 4;

    reg [2:0]   cmd_state;
    reg         errInvalidCmd;
    reg         errFrame;
    reg [31:0]  cmdData;
    reg [31:0]  cmdLen;
    reg [7:0]   cmd;
    
    reg [7:0]   data_d1;
    reg [7:0]   data_d2;
    reg [7:0]   data_d3;
    reg [7:0]   data_d4;
    reg [7:0]   data_d5;
    reg         dataValid_d1;
    reg         scpCmdValid;

    assign WriteData = cmdData;
    //assign WriteAddr = CmdAddr;

    // - Command Word
    //  * [31:8] - Address
    //  * [7:0] - Command
    // - Length Word (number of words to follow in this transaction)
    // - 0..N words
    // - Terminating Word
    //  * [31:16] - Stop Sequence
    //  * [15:0] - CRC16/8/?
    always @(posedge ClkIngress or posedge ARst) begin
        if (ARst == 1'b1) begin
            // byte packing
            Rdyn <= 1'b1;
            rxByteCntr <= 2'b00;
            rxWordValid <= 1'b0;

            edByteCnt <= 2'b00;

            // command processing
            cmd_state <= STATE_CMD_IDLE;
            errInvalidCmd <= 1'b0;
            errFrame <= 1'b0;
            WriteDataValid <= 1'b0;
            RWn <= 1'b1;
            dataValid_d1 <= 1'b0;
            scpCmdValid <= 1'b0;
            EValid <= 1'b0;
        end else begin
            // byte packing
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

            // command processing
            errInvalidCmd <= 1'b0;
            errFrame <= 1'b0;
            WriteDataValid <= 1'b0;

            if (DataValid) begin
                data_d1 <= Data;
                data_d2 <= data_d1;
                data_d3 <= data_d2;
                data_d4 <= data_d3;
                data_d5 <= data_d4;
            end
            //ED <= data_d1;
            dataValid_d1 <= DataValid;
            //EValid <= dataValid_d1 & scpCmdValid;

            case (edByteCnt)
                2'b00: begin
                    ED <= rxWord[7:0];
                    if (scpCmdValid || ((cmd_state == STATE_CMD_IDLE) &&
                                              (rxWordValid == 1'b1) &&
                                              (rxWord[7:0] == 8'h01)
                                          )) begin
                        edByteCnt <= edByteCnt + 1;
                        EValid <= 1'b1;
                    end else begin
                        EValid <= 1'b0;
                    end
                end
                2'b01: begin
                    ED <= rxWord[15:8];
                    edByteCnt <= edByteCnt + 1;
                end
                2'b10: begin
                    ED <= rxWord[23:16];
                    edByteCnt <= edByteCnt + 1;
                end
                2'b11: begin
                    ED <= rxWord[31:24];
                    edByteCnt <= edByteCnt + 1;
                end
            endcase

            RWn <= 1'b1;
            case (cmd_state)
                STATE_CMD_IDLE: begin
                    CmdAddr <= rxWord[31:8];
                    cmd <= rxWord[7:0];
                    scpCmdValid <= 1'b0;

                    if (rxWordValid == 1'b1) begin
                        // Check to see if SCP Command to be passed on
                        if (rxWord[7:0] == 8'h01) begin
                            //EValid <= 1'b1;
                            //edByteCnt <= edByteCnt + 1;
                            scpCmdValid <= 1'b1;
                            cmd_state <= STATE_LEN;
                        end else if (   (rxWord[7:0] == 8'h81)
                                    ||  (rxWord[7:0] == 8'h82)
                                  ) begin
                            cmd_state <= STATE_LEN;
                        end else begin
                            errInvalidCmd <= 1'b1;
                        end
                    end
                end
                STATE_LEN: begin
                    if (rxWordValid == 1'b1) begin
                        cmdLen <= rxWord - 1;

                        if (    (cmd == 8'h81)
                            ||  (cmd == 8'h01)
                        ) begin
                            cmd_state <= STATE_DATA;
                        end else if (cmd == 8'h82) begin
                            cmd_state <= STATE_EOF;
                        end
                    end
                end
                STATE_DATA: begin
                    if (WriteDataValid == 1'b1) CmdAddr <= CmdAddr + 4;
                    if (rxWordValid == 1'b1) begin
                        // Only write for actual HK commands
                        WriteDataValid <= ~scpCmdValid;
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

                        scpCmdValid <= 1'b0;

                        if (cmd == 8'h82) begin
                            cmd_state <= STATE_RD;
                            RWn <= 1'b0;
                            cmdLen <= cmdLen << 2;
                        end else begin
                            cmd_state <= STATE_CMD_IDLE;
                            //EValid <= DataValid;
                        end

                        if (rxWord[31:16] != `LASTWORD) begin
                            errFrame <= 1'b1;
                        end
                    end
                end
                STATE_RD: begin
                    cmd_state <= STATE_CMD_IDLE;
                    //if (cmdLen == 1) begin
                        //cmd_state <= STATE_CMD_IDLE;
                        //RWn <= 1'b1;
                    //end else begin
                        //RWn <= 1'b0;
                        //if (HostWriteValid) begin
                            //cmdLen <= cmdLen - 1;
                        //end
                        //cmd_state <= STATE_RD;
                    //end
                end
                default: begin
                    cmd_state <= STATE_CMD_IDLE;
                end
            endcase
        end
    end
endmodule
