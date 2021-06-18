// scp_phase0.v
//
`timescale 1ns/100ps
`include "stc0_addrMap.vh"

`default_nettype none
module stc0_core#(
    parameter DATA_WIDTH=16,
    parameter NUM_POINTS=1024,
    parameter NUM_POINTS_LOG2 = 10,
    parameter TW_WIDTH = 16
) (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif
    input wire          ClkIngress,
    input wire          ARstb,
    input wire  [7:0]   ID,
    input wire          IValid,
    output wire [7:0]   ED,
    output wire         EValid
    //output wire         EClk
);

    wire [23:0] waddr;
    wire [31:0] wdata;
    wire        dataValid;

    wire [31:0] AEgress;
    wire [31:0] BEgress;
    wire        AEgressValid;
    wire        BEgressValid;
    wire [3:0]              CtrlAddr [2:0];
    wire [`CTRLWRD_SZ-1:0]  CtrlWord [2:0];
    wire                    CtrlValid [2:0];
    wire [16*2-1:0] C;
    wire [16*2-1:0] D;
    wire bf0EgressValid;
    wire [16*2-1:0] egressData;
    wire egressValid;
    wire byteEgressReady;
    wire ARst;

    assign EClk = ClkIngress;


    rstSync #(.NUM_SYNC_CLKS(5)) rstSync_clk (.Clk(ClkIngress),.ARstb(ARstb),.Rst(ARst));

    byteIngressCmdProcessor byteIngressCmdProcessor_0 (
        .ClkIngress(ClkIngress),
        .ARst(ARst),
        .Data(ID),
        .DataValid(IValid),
        .Rdyn(),
        .WriteAddr(waddr),
        .WriteData(wdata),
        .WriteDataValid(dataValid)
    );
    stc0Ctrl#(
        .DATA_WIDTH(16)
    ) stc0Ctrl_ (
        .Clk(ClkIngress),
        .ARst(ARst),
        .WriteAddr(waddr[23:2]),
        .WriteData(wdata),
        .WriteDataValid(dataValid),
        .AEgress(AEgress),
        .AEgressValid(AEgressValid),
        .BEgress(BEgress),
        .BEgressValid(BEgressValid),
        .CtrlAddr(CtrlAddr[0]),
        .CtrlWord(CtrlWord[0]),
        .CtrlValid(CtrlValid[0])
    );

    wire                        SPRcsn_bf0;
    wire                        SPRwen_bf0;
    wire [NUM_POINTS_LOG2-1:0]  SPRaddr_bf0;
    wire [(TW_WIDTH*2)-1:0]     SPRdin_bf0;
    wire [(TW_WIDTH*2)-1:0]     SPRdout_bf0;

    spram#(
        .DW(32),
        .AW(7),
        .RAM_DEPTH(1 << 7)
    ) spram_bf0 (
        .Clk(ClkIngress),
        .Csb0(SPRcsn_bf0),
        .Web0(SPRwen_bf0),
        .ADDR0(SPRaddr_bf0),
        .DIN0(SPRdin_bf0),
        .DOUT0(SPRdout_bf0)
    );

    stc0butterfly#(
        .DATA_WIDTH(16),
        .BF_NUM(`CTRL_BF2),
        .TW_WIDTH(16)
    ) bf0 (
        .Clk(ClkIngress),
        .ARst(ARst),
        // Control
        .CtrlAddr(CtrlAddr[0]),
        .CtrlWord(CtrlWord[0]),
        .CtrlValid(CtrlValid[0]),
        .CtrlAddrOut(CtrlAddr[1]),
        .CtrlWordOut(CtrlWord[1]),
        .CtrlValidOut(CtrlValid[1]),
        // Data
        .Ar(AEgress[31:16]),
        .Ai(AEgress[15:0]),
        .Br(BEgress[31:16]),
        .Bi(BEgress[15:0]),
        .IngressValid(AEgressValid),
        .Cr(C[16*2-1:16]),
        .Ci(C[16-1:0]),
        .Dr(D[16*2-1:16]),
        .Di(D[16-1:0]),
        .EgressValid(bf0EgressValid),
        .SRAM_WData(SPRdin_bf0),
        .SRAM_RData(SPRdout_bf0),
        .Addr(SPRaddr_bf0),
        .CSn(SPRcsn_bf0),
        .WEn(SPRwen_bf0)
    );
    egressStage #(
        .DATA_WIDTH(16),
        .CTRL_STAGE(`CTRL_ES)
    ) egressStage_ (
        .Clk(ClkIngress),
        .ARst(ARst),
        // Control
        .CtrlAddr(CtrlAddr[1]),
        .CtrlWord(CtrlWord[1]),
        .CtrlValid(CtrlValid[1]),
        .CtrlAddrOut(CtrlAddr[2]),
        .CtrlWordOut(CtrlWord[2]),
        .CtrlValidOut(CtrlValid[2]),
        // Data
        .C(C),
        .D(D),
        .IngressValid(bf0EgressValid),
        .EgressData(egressData),
        .EgressValid(egressValid),
        .Ready(byteEgressReady)
    );

    byteEgress byteEgress_0 (
        .ClkEngress(ClkIngress),
        .ARst(ARst),
        .WriteData(egressData),
        .WriteDataValid(egressValid),
        .Data(ED),
        .DataValid(EValid),
        .Ready(byteEgressReady)
    );
endmodule
`default_nettype wire
