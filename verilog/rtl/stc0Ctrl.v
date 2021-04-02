`timescale 1ns/100ps
`include "stc0_addrMap.vh"
`default_nettype none
module stc0Ctrl#(
    parameter DATA_WIDTH = 16
) (
    input wire                       Clk,
    input wire                       ARst,
    // Simple Bus Interface
    input wire  [23:2]               WriteAddr,
    input wire  [31:0]               WriteData,
    input wire                       WriteDataValid,
    // Egress to ports A and B of Biplex FFT
    output wire [(DATA_WIDTH*2)-1:0] AEgress,
    output wire                      AEgressValid,
    output wire [(DATA_WIDTH*2)-1:0] BEgress,
    output wire                      BEgressValid,
    output wire [32-`RB_CTRL_ADDR-1:0] CtrlAddr,
    output wire [`CTRLWRD_SZ-1:0]    CtrlWord,
    output reg                       CtrlValid
);
    reg [(DATA_WIDTH*2)-1:0] XIngress;
    reg [(DATA_WIDTH*2)-1:0] YIngress;
    //reg [NUM_POINTS_LOG2+2:0]   clkCntr;
    //reg [NUM_POINTS_LOG2 - 2:0] sampleCntr;

    //---------------------------------------------------
    // Bus Accessible Registers
    //---------------------------------------------------
    reg  [31:0] muxCtrl;
    reg  [1:0]  lfsrsCtrl;
    reg  [31:0] lfsrsStride;
    reg  [31:0] lfsrsIterations;
    reg  [31:0] lfsrX_Seed;
    reg  [31:0] lfsrY_Seed;
    reg  [31:0] ctrlWordReg;

    //---------------------------------------------------
    // Bus Write Enables
    //---------------------------------------------------
    wire selMuxCtrl =       (WriteAddr[`RMH:`RML] == `RM_CTRL)
                        &&  (WriteAddr[`RAH:`RAL] == `RA_CTRL_MUXCTRL)
                        &&  WriteDataValid;
    wire selLfsrsCtrl =     (WriteAddr[`RMH:`RML] == `RM_CTRL)
                        &&  (WriteAddr[`RAH:`RAL] == `RA_CTRL_LFSRS_CTRL)
                        &&  WriteDataValid;
    wire selLfsrsStride =   (WriteAddr[`RMH:`RML] == `RM_CTRL)
                        &&  (WriteAddr[`RAH:`RAL] == `RA_CTRL_LFSRS_STRIDE)
                        &&  WriteDataValid;
    wire selLfsrsIterations = (WriteAddr[`RMH:`RML] == `RM_CTRL)
                        &&  (WriteAddr[`RAH:`RAL] == `RA_CTRL_LFSRS_ITERATIONS)
                        &&  WriteDataValid;
    wire selLfsrXSeed =    (WriteAddr[`RMH:`RML] == `RM_CTRL)
                        &&  (WriteAddr[`RAH:`RAL] == `RA_CTRL_LFSRX_SEED)
                        &&  WriteDataValid;
    wire selLfsrYSeed =    (WriteAddr[`RMH:`RML] == `RM_CTRL)
                        &&  (WriteAddr[`RAH:`RAL] == `RA_CTRL_LFSRY_SEED)
                        &&  WriteDataValid;
    wire selCtrlWord =      (WriteAddr[`RMH:`RML] == `RM_CTRL)
                        &&  (WriteAddr[`RAH:`RAL] == `RA_CTRL_CTRLWORD)
                        &&  WriteDataValid;
    wire XIngressValid =    (WriteAddr[`RMH:`RML] == `RM_XYINGRESS)
                        &&  (WriteAddr[2] == 1'b0)
                        &&  WriteDataValid;
    wire YIngressValid =    (WriteAddr[`RMH:`RML] == `RM_XYINGRESS)
                        &  (WriteAddr[2] == 1'b1)
                        &  WriteDataValid;
    wire enableLfsrX;
    wire enableLfsrY;
    wire [31:0] LfsrX;
    wire [31:0] LfsrY;
    reg [7:0] lfsrStrideCount;
    reg [31:0] lfsrsIterCount;
    reg lfsrsEnabled;

    wire updateLFSRs = lfsrsEnabled && (lfsrStrideCount == lfsrsStride-1) && (lfsrsIterCount != lfsrsIterations);
    wire lfsrsValid = updateLFSRs;
    wire enableLFSRs = lfsrsCtrl[`RB_LFSRCTRL_ENABLE] & ~lfsrsEnabled;

    assign AEgress = muxCtrl[0] ? LfsrX : XIngress;
    assign BEgress = muxCtrl[0] ? LfsrY : YIngress;
    assign AEgressValid = muxCtrl ? lfsrsValid : YIngressValid;

    assign CtrlAddr = ctrlWordReg[31:`RB_CTRL_ADDR];
    assign CtrlWord = ctrlWordReg[`CTRLWRD_SZ-1:0];

    always @(posedge Clk or posedge ARst) begin
        if (ARst == 1'b1) begin
            muxCtrl <= 0;
            lfsrsCtrl <= 0;
            lfsrsEnabled <= 0;
            lfsrsIterCount <= 0;
            lfsrsIterations <= 0;
            CtrlValid <= 0;
            ctrlWordReg <= 0;
        end else begin
            CtrlValid <= 0;

            if (selMuxCtrl)     muxCtrl <= WriteData[0];
            if (selLfsrsCtrl)   lfsrsCtrl <= WriteData[1:0];
            if (selLfsrsStride) lfsrsStride <= WriteData[7:0];
            if (selLfsrsIterations) lfsrsIterations <= WriteData;
            if (selLfsrXSeed)  lfsrX_Seed <= WriteData;
            if (selLfsrYSeed)  lfsrY_Seed <= WriteData;
            if (selCtrlWord) begin
                ctrlWordReg <= WriteData;
                CtrlValid <= 1'b1;
            end
            if (XIngressValid) XIngress <= WriteData;
            if (YIngressValid) YIngress <= WriteData;

            lfsrsEnabled <= lfsrsCtrl[`RB_LFSRCTRL_ENABLE];

            if (lfsrsIterCount == lfsrsIterations) begin
                lfsrsCtrl[`RB_LFSRCTRL_ENABLE] <= 0;
                lfsrsEnabled <= 0;
                lfsrsIterCount <= 0;
            end
            
            if (enableLFSRs) begin
                lfsrStrideCount <= 0;
                //lfsrsIterCount <= 0;
            end else if (updateLFSRs) begin
                lfsrStrideCount <= 0;

                if (lfsrsCtrl[`RB_LFSRCTRL_ITERSRC]) begin
                    lfsrsIterCount <= lfsrsIterCount + (LfsrX == lfsrX_Seed);
                end else begin
                    lfsrsIterCount <= lfsrsIterCount + 1;
                end
                
            end else if (lfsrsEnabled) begin
                lfsrStrideCount <= lfsrStrideCount + 1;
            end
            //case (clkCntr[2:0])
                //3'b000: begin
                    //if (YIngressValid) begin
                        //clkCntr <= clkCntr + 1;
                    //end
                //end
                //3'b001: begin
                    //clkCntr <= clkCntr + 1;
                    //AEgress <= aEgressInt;
                    //BEgress <= bEgressInt;
                    //aEgressValid_cmd <= aEgressValidInt;
                    //bEgressValid_cmd <= bEgressValidInt;
                //end
                //3'b010: begin
                    //clkCntr <= clkCntr + 1;
                //end
                //3'b011: begin
                    //clkCntr <= clkCntr + 1;
                //end
                //3'b100: begin
                    //clkCntr <= clkCntr + 1;
                //end
                //3'b101: begin
                    //clkCntr <= clkCntr + 1;
                    //AEgress <= aEgressInt;
                    //BEgress <= bEgressInt;
                    //aEgressValid_cmd <= aEgressValidInt;
                    //bEgressValid_cmd <= bEgressValidInt;
                //end
                //3'b110: begin
                    //clkCntr <= clkCntr + 1;
                //end
                //3'b111: begin
                    //clkCntr <= clkCntr + 1;
                //end
            //endcase
        end
    end

    //-----------------------------------------------------
    // LFSR Instantiation and Control
    //
    // Need a way to limit the LFSR rounds to repeatable
    // Set the number of ticks or the number of times the seed value is hit
    //-----------------------------------------------------
    lfsr32 lfsr32_x (
        .Clk(Clk),
        .ARst(ARst),
        .Enable(updateLFSRs),
        .Load(lfsrsCtrl[`RB_LFSRCTRL_ENABLE] & ~lfsrsEnabled),
        .Seed(lfsrX_Seed),
        .LFSR(LfsrX)
    );
    lfsr32 lfsr32_y (
        .Clk(Clk),
        .ARst(ARst),
        .Enable(updateLFSRs),
        .Load(lfsrsCtrl[`RB_LFSRCTRL_ENABLE] & ~lfsrsEnabled),
        .Seed(lfsrY_Seed),
        .LFSR(LfsrY)
    );

    //wire ctrlBfpValid =    (WriteAddr[`RMH:`RML] == `RM_CTRL)
                        //&& (WriteAddr[`RAH:`RAL] == `RA_CTRL_BFP)
                        //&  WriteDataValid;


    //wire PRst;

    //rstSync #(.NUM_SYNC_CLKS(3)) rstSync_pclk (.Clk(ClkProc),.ARst(ARst),.Rst(PRst));
    //// Sync egress valid signals to the bpfft processing clock which is at
    //// least twice as fast
    //nsync #(.NUM_SYNC_CLKS(2)) nync_aegressValid (.Clk(ClkProc),.ARst(PRst),.D(aEgressValid_cmd),.DSync(AEgressValid));
    //nsync #(.NUM_SYNC_CLKS(2)) nync_begressValid (.Clk(ClkProc),.ARst(PRst),.D(bEgressValid_cmd),.DSync(BEgressValid));
    //nsync #(.NUM_SYNC_CLKS(2)) nync_bfpCtrlValid (.Clk(ClkProc),.ARst(PRst),.D(ctrlBfpValid),.DSync(BfpCtrlValid));

    //// Egress Valid bit FFs on command clock domain
    //reg aEgressValid_cmd;
    //reg bEgressValid_cmd;
endmodule
`default_nettype wire
