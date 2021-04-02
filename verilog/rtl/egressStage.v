
`include "stc0_addrMap.vh"
`default_nettype none
module egressStage #(
    parameter DATA_WIDTH=16,
    parameter CTRL_STAGE=15
) (
    input wire                      Clk,
    input wire                      ARst,
    // Control
    input wire [3:0]                CtrlAddr,
    input wire [`CTRLWRD_SZ-1:0]    CtrlWord,
    input wire                      CtrlValid,
    output reg [3:0]                CtrlAddrOut,
    output reg [`CTRLWRD_SZ-1:0]    CtrlWordOut,
    output reg                      CtrlValidOut,
    // Data
    input wire [DATA_WIDTH*2-1:0]   C,
    input wire [DATA_WIDTH*2-1:0]   D,
    input wire                      IngressValid,
    output wire [DATA_WIDTH*2-1:0]  EgressData,
    output wire                     EgressValid,
    input wire                      Ready
);


    reg [DATA_WIDTH*2-1:0] Creg0;
    reg [DATA_WIDTH*2-1:0] Dreg0;
    reg Creg0Valid;
    reg Dreg0Valid;
    wire [DATA_WIDTH*2-1:0] Creg0crc;
    wire [DATA_WIDTH*2-1:0] Dreg0crc;
    wire Creg0crcValid;
    wire Dreg0crcValid;
    wire [DATA_WIDTH*2-1:0] CBypassMuxOut;
    wire [DATA_WIDTH*2-1:0] DBypassMuxOut;
    reg CDMuxSel;
    wire [DATA_WIDTH*2-1:0] Cfinal;
    wire [DATA_WIDTH*2-1:0] Dfinal;

    wire cRd, cEty, cFull, cUnf, cOvf, dRd, dEty, dFull, dUnf, dOvf;

    //-----------------------------------------------------
    // Control Register
    //-----------------------------------------------------
    reg [`CTRLWRD_SZ-1:0]    ctrlWordReg;
    always @(posedge Clk or posedge ARst) begin
        if (ARst == 1'b1) begin
            CtrlValidOut <= 1'b0;
            ctrlWordReg <= 0;
        end else begin
            CtrlValidOut <= 1'b0;
            if (CtrlValid == 1'b1) begin
                if (CtrlAddr == CTRL_STAGE) begin
                    ctrlWordReg <= CtrlWord;
                end else begin
                    CtrlWordOut <= CtrlWord;
                    CtrlAddrOut <= CtrlAddr;
                    CtrlValidOut <= CtrlValid;
                end
            end
        end
    end
    // Local Control assignments
    //-----------------------------------------------------

    always @(posedge Clk or posedge ARst) begin
        if (ARst == 1'b1) begin
            Creg0Valid <= 0;
            Dreg0Valid <= 0;
            CDMuxSel <= 0;
        end else begin
            Creg0Valid <= IngressValid;
            Dreg0Valid <= IngressValid;

            Creg0 <= C;
            Dreg0 <= D;

            case (ctrlWordReg[`RB_EGRESSCTRL_OUTPUTMUX+1:`RB_EGRESSCTRL_OUTPUTMUX])
                2'b00: CDMuxSel <= (~CDMuxSel && cRd) || (CDMuxSel && ~dRd);
                2'b01: CDMuxSel <= 1'b0;
                2'b10: CDMuxSel <= 1'b1;
                default: CDMuxSel <= (~CDMuxSel && cRd) || (CDMuxSel && ~dRd);
            endcase
        end
    end

    crc32reg crc32reg_c (
        .Clk(Clk),
        .ARst(ARst),
        .Enable(IngressValid),
        .Data(C),
        .CrcOut(Creg0crc),
        .CrcOutValid(Creg0crcValid)
    );

    crc32reg crc32reg_d (
        .Clk(Clk),
        .ARst(ARst),
        .Enable(IngressValid),
        .Data(D),
        .CrcOut(Dreg0crc),
        .CrcOutValid(Dreg0crcValid)
    );

    assign CBypassMuxOut = ctrlWordReg[`RB_EGRESSCTRL_CRCBYPASS] ? Creg0 : Creg0crc;
    assign DBypassMuxOut = ctrlWordReg[`RB_EGRESSCTRL_CRCBYPASS] ? Dreg0 : Dreg0crc;
    wire CBypassMuxOutValid = ctrlWordReg[`RB_EGRESSCTRL_CRCBYPASS] ? Creg0Valid : Creg0crcValid;
    wire DBypassMuxOutValid = ctrlWordReg[`RB_EGRESSCTRL_CRCBYPASS] ? Dreg0Valid : Dreg0crcValid;

    assign cRd = ctrlWordReg[`RB_EGRESSCTRL_OUTPUTEN] ? (~CDMuxSel ? (Ready && cFull) : 1'b0) : 1'b0;
    assign dRd = ctrlWordReg[`RB_EGRESSCTRL_OUTPUTEN] ? (CDMuxSel ? (Ready && dFull) : 1'b0) : 1'b0;

    oneWordFifo #(
        .DW(DATA_WIDTH*2)
    ) oneWordFifo_C (
        .Clk(Clk),
        .ARst(ARst),
        .WriteData(CBypassMuxOut),
        .ReadData(Cfinal),
        .Wr(CBypassMuxOutValid),
        .Rd(cRd),
        .Ety(cEty),
        .Full(cFull),
        .Ovf(cOvf),
        .Unf(cUnf)
    );

    oneWordFifo #(
        .DW(DATA_WIDTH*2)
    ) oneWordFifo_D (
        .Clk(Clk),
        .ARst(ARst),
        .WriteData(DBypassMuxOut),
        .ReadData(Dfinal),
        .Wr(DBypassMuxOutValid),
        .Rd(dRd),
        .Ety(dEty),
        .Full(dFull),
        .Ovf(dOvf),
        .Unf(dUnf)
    );

    assign EgressData = CDMuxSel ? Dfinal : Cfinal;
    assign EgressValid = ctrlWordReg[`RB_EGRESSCTRL_OUTPUTEN] ? (CDMuxSel ? dFull : cFull) : 1'b0;

endmodule
`default_nettype wire
