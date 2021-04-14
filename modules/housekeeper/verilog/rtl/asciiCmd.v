//------------------------------------------------------------------------------
// ASCII-Based command interpreter
//
// Commands of the following form:
//
// w <addr> <data>
// w 00000000 BADC0FEE
//
// Will write data. Upper nibble value of 4'h0 will access registers within
// this module. This module provides a plain and simple control and status
// capability to any design but will also support larger use-cases since the
// control signals go outside the modules as well
//------------------------------------------------------------------------------
`timescale 1ns/100ps
`default_nettype none
module asciiCmd (
    input   wire          Clk,
    input   wire          ARst,
    input   wire  [7:0]   Char,
    input   wire          CharValid,
    output  reg   [3:0]   Cmd,
    output  reg   [31:0]  CmdAddr,
    output  reg   [31:0]  CmdData,
    output  reg           CmdValid,
    output  reg   [31:0]  ctrl0
);
    localparam STATE_CMD_IDLE   = 4;
    localparam STATE_CMD_SP0    = 1;
    localparam STATE_CMD_SP1    = 2;
    localparam STATE_CMD_ADDR   = 3;
    localparam STATE_CMD_DATA   = 0;

    localparam SPACE = 8'h20;

    reg   [2:0]   cmd_state;
    reg   [4:0]   nibble;
    //reg   [3:0]   cmd;
    //reg   [31:0]  cmdAddr;
    //reg   [31:0]  cmdData;
    reg   [3:0]   charCntr;
    
    // FSM to decode command sequences
    // - Command Examples
    // Valid Hex Chars - [0-9A-F]
    // w 00000001 BADC0FEE
    // r 00000001
    //assign state = cmd_state;
    always @(posedge Clk or posedge ARst) begin
        if (ARst == 1'b1) begin
            cmd_state <= STATE_CMD_IDLE;
            CmdValid <= 1'b0;
        end else begin
            CmdValid <= 1'b0;
            case (cmd_state)
                STATE_CMD_IDLE: begin
                    charCntr <= 0;
                    Cmd <= 4'h0;
                    if (Char == "r") Cmd <= 4'h1;
                    if (Char == "w") Cmd <= 4'h2;
                    if (CharValid && 
                        ((Char == "r") || (Char == "w"))
                    ) begin
                        cmd_state <= STATE_CMD_SP0;
                    end
                end
                STATE_CMD_SP0: begin
                    if (CharValid) begin
                        if (Char == SPACE)  cmd_state <= STATE_CMD_ADDR;
                        else                cmd_state <= STATE_CMD_IDLE;
                    end
                end
                STATE_CMD_ADDR: begin
                    if (CharValid) begin
                        charCntr <= charCntr + 1;
                        CmdAddr <= {CmdAddr[27:0], nibble[3:0]};

                        if (nibble[4]) begin
                            cmd_state <= STATE_CMD_IDLE;
                        end else begin
                            if (charCntr == 7) begin
                                cmd_state <= STATE_CMD_SP1;
                                charCntr <= 0;
                            end
                        end
                    end
                end
                STATE_CMD_SP1: begin
                    if (CharValid) begin
                        if (Char == SPACE)  cmd_state <= STATE_CMD_DATA;
                        else                cmd_state <= STATE_CMD_IDLE;
                    end
                end
                STATE_CMD_DATA: begin
                    if (CharValid) begin
                        charCntr <= charCntr + 1;
                        CmdData <= {CmdData[27:0], nibble[3:0]};

                        if (nibble[4]) begin
                            cmd_state <= STATE_CMD_IDLE;
                        end else begin
                            if (charCntr == 3'b111) begin
                                cmd_state <= STATE_CMD_IDLE;
                                CmdValid <= 1'b1;
                            end
                        end
                    end
                end
                default: begin
                    cmd_state <= STATE_CMD_IDLE;
                end
            endcase
        end
    end
    
    // Decode for internal address space
    always @(posedge Clk or posedge ARst) begin
        if (ARst == 1'b1) begin
            ctrl0 <= 0;
        end else begin
            if (CmdValid) begin
                if ((Cmd == 4'h2) && (CmdAddr[31:28] == 0)) begin
                    if (CmdAddr[3:0] == 0) ctrl0 <= CmdData;
                end
            end
        end
    end

    // Combinatorial ASCII to binary conversion. MSB (bit 4) provides an
    // invalid character flag
    always @(*) begin
        case(Char)
            "0": nibble = 5'h00;
            "1": nibble = 5'h01;
            "2": nibble = 5'h02;
            "3": nibble = 5'h03;
            "4": nibble = 5'h04;
            "5": nibble = 5'h05;
            "6": nibble = 5'h06;
            "7": nibble = 5'h07;
            "8": nibble = 5'h08;
            "9": nibble = 5'h09;
            "A": nibble = 5'h0A;
            "B": nibble = 5'h0B;
            "C": nibble = 5'h0C;
            "D": nibble = 5'h0D;
            "E": nibble = 5'h0E;
            "F": nibble = 5'h0F;
            default: nibble = 5'h10;
        endcase
    end
endmodule
`default_nettype wire 
