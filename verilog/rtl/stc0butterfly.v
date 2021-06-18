`timescale 1ns/100ps
`include "stc0_addrMap.vh"
`default_nettype none

module stc0butterfly#(
    parameter DATA_WIDTH=17,
    parameter NUM_POINTS=1024,
    parameter NUM_POINTS_LOG2 = 10,
    parameter BF_NUM = 0,
    parameter TW_WIDTH = 16
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
    input wire signed [DATA_WIDTH-1:0]  Ar,
    input wire signed [DATA_WIDTH-1:0]  Ai,
    input wire signed [DATA_WIDTH-1:0]  Br,
    input wire signed [DATA_WIDTH-1:0]  Bi,
    input wire                          IngressValid,
    output reg signed [DATA_WIDTH-1:0]  Cr,
    output reg signed [DATA_WIDTH-1:0]  Ci,
    output reg signed [DATA_WIDTH-1:0]  Dr,
    output reg signed [DATA_WIDTH-1:0]  Di,
    output reg                          EgressValid,
    // Single-port SRAM interface
    output wire [(TW_WIDTH*2)-1:0]      SRAM_WData,
    input  wire [(TW_WIDTH*2)-1:0]      SRAM_RData,
    output reg  [TW_RAM_ADDR_WIDTH-1:0] Addr,
    output reg                          CSn,    // active low chip select
    output reg                          WEn    // active low write control
);
    localparam TW_RAM_ADDR_WIDTH = NUM_POINTS_LOG2 - (BF_NUM + 1);

    wire Rst = ARst;
    //rstSync #(.NUM_SYNC_CLKS(3)) rstSync_pclk (.Clk(Clk),.ARst(ARst),.Rst(Rst));

    reg [NUM_POINTS_LOG2+2:0]   clkCntr;
    reg [DATA_WIDTH-1:0]  Ars0;
    reg [DATA_WIDTH-1:0]  Ais0;
    reg [DATA_WIDTH-1:0]  Brs0;
    reg [DATA_WIDTH-1:0]  Bis0;
    reg [DATA_WIDTH-1:0]  Brs1;
    reg [DATA_WIDTH-1:0]  Bis1;
    reg valids0;
    reg signed [DATA_WIDTH:0] sumRs1;
    reg signed [DATA_WIDTH:0] sumIs1;
    reg signed [DATA_WIDTH:0] diffRs1;
    reg signed [DATA_WIDTH:0] diffIs1;
    reg valids1;
    reg signed [DATA_WIDTH:0] sumRs2;
    reg signed [DATA_WIDTH:0] sumIs2;
    wire signed [((DATA_WIDTH+1)+TW_WIDTH-1):0] prodrr;
    wire signed [((DATA_WIDTH+1)+TW_WIDTH-1):0] prodri;
    wire signed [((DATA_WIDTH+1)+TW_WIDTH-1):0] prodii;
    wire signed [((DATA_WIDTH+1)+TW_WIDTH-1):0] prodir;
    reg signed [((DATA_WIDTH+1)+TW_WIDTH-1):0] prodrrs2;
    reg signed [((DATA_WIDTH+1)+TW_WIDTH-1):0] prodris2;
    reg signed [((DATA_WIDTH+1)+TW_WIDTH-1):0] prodiis2;
    reg signed [((DATA_WIDTH+1)+TW_WIDTH-1):0] prodirs2;
    reg valids2;
    reg signed [DATA_WIDTH:0] sumRs3;
    reg signed [DATA_WIDTH:0] sumIs3;
    reg signed [((DATA_WIDTH+1)+TW_WIDTH):0] diff2s3;
    reg signed [((DATA_WIDTH+1)+TW_WIDTH):0] sum2s3;
    reg valids3;
    wire signed [TW_WIDTH-1:0]  twR;
    wire signed [TW_WIDTH-1:0]  twI;

    //-----------------------------------------------------
    // Control Register
    //-----------------------------------------------------
    reg [`CTRLWRD_SZ-1:0]    ctrlWordReg;
    always @(posedge Clk or posedge Rst) begin
        if (Rst == 1'b1) begin
            CtrlValidOut <= 1'b0;
            ctrlWordReg <= 0;

        end else begin
            CtrlValidOut <= 1'b0;
            if (CtrlValid == 1'b1) begin
                if (CtrlAddr == BF_NUM) begin
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

    assign {twR,twI} = ctrlWordReg[`RB_BFCTRL_TWMUXCTRL]
                ? (ctrlWordReg[`RB_BFCTRL_TWMUXCTRL+1] ? {16'h4567,16'h2345} : { {(TW_WIDTH-1){1'b0}}, 1'b1 , {(TW_WIDTH-1){1'b0}}, 1'b1} )
                : SRAM_RData;
    assign SRAM_WData = {Brs0, Bis0};

    always @(posedge Clk or posedge Rst) begin
        if (Rst == 1'b1) begin
            clkCntr <= 0;
            valids0 <= 0;
            valids1 <= 0;
            valids2 <= 0;
            valids3 <= 0;
            EgressValid <= 0;
            CSn <= 1'b1;
            WEn <= 1'b1;
            Addr <= 0;
        end else begin
            //-----------------------------------------------------
            // TWiddle RAM Address control
            //-----------------------------------------------------
            if (CtrlValid == 1'b1) begin
                clkCntr <= 0;
                Addr <= 0;
            end else begin
                if (valids0) begin
                    clkCntr <= clkCntr + 1;
                    if (ctrlWordReg[`RB_BFCTRL_TWRD] | ctrlWordReg[`RB_BFCTRL_TWWR]) begin
                        Addr <= Addr + 1;
                    end else if (BF_NUM == 0) begin
                        Addr <= Addr + 1;
                    end else if (clkCntr[9:0] == ((1'b1 << BF_NUM)-1)) begin
                        Addr <= Addr + 1;
                    end
                end
            end
            //-----------------------------------------------------
            // Stage 0
            //-----------------------------------------------------
            Ars0 <= Ar;
            Ais0 <= Ai;
            Brs0 <= Br;
            Bis0 <= Bi;
            //valids0 <= IngressValid & ~ctrlWordReg[`RB_BFCTRL_TWWR];
            valids0 <= IngressValid;
            CSn <= ~IngressValid;
            WEn <= ~(IngressValid & ctrlWordReg[`RB_BFCTRL_TWWR]);

            // Stage 1
            Brs1 <= Brs0;
            Bis1 <= Bis0;
            sumRs1 <= Ars0 + Brs0;
            sumIs1 <= Ais0 + Bis0;
            diffRs1 <= Ars0 - Brs0;
            diffIs1 <= Ais0 - Bis0;
            valids1 <= valids0 & ~ctrlWordReg[`RB_BFCTRL_BFBYPASS] & ~ctrlWordReg[`RB_BFCTRL_TWWR];

            // Stage 2
            sumRs2 <= sumRs1;
            sumIs2 <= sumIs1;
            prodrrs2 <= prodrr;
            prodris2 <= prodri;
            prodiis2 <= prodii;
            prodirs2 <= prodir;
            valids2 <= valids1 & ~ctrlWordReg[`RB_BFCTRL_TWRD];

            // Stage 3
            sumRs3 <= sumRs2;
            sumIs3 <= sumIs2;
            diff2s3 <= prodrrs2 - prodiis2;
            sum2s3 <= prodris2 - prodirs2;
            valids3 <= valids2;

            // Stage 4 / Egress
            case ({ctrlWordReg[`RB_BFCTRL_BFBYPASS],ctrlWordReg[`RB_BFCTRL_BFBYPASSX],ctrlWordReg[`RB_BFCTRL_TWRD]})
                3'd0: begin
                    Cr <= sumRs3;
                    Ci <= sumIs3;
                    Dr <= DrSS;
                    Di <= DiSS;
                    EgressValid <= valids3;
                end
                // bypass non-sensical when TWRD asserted
                3'd1,3'd5: begin
                    Cr <= sumRs3;
                    Ci <= sumIs3;
                    Dr <= twR;
                    Di <= twI;
                    EgressValid <= valids1;
                end
                3'd2: begin
                    Cr <= DrSS;
                    Ci <= DiSS;
                    Dr <= sumRs3;
                    Di <= sumIs3;
                    EgressValid <= valids3;
                end
                3'd3,3'd7: begin
                    Cr <= twR;
                    Ci <= twI;
                    Dr <= sumRs3;
                    Di <= sumIs3;
                    EgressValid <= valids1;
                end
                3'd4: begin
                    Cr <= Ars0;
                    Ci <= Ais0;
                    Dr <= Brs0;
                    Di <= Bis0;
                    EgressValid <= valids0;
                end
                //3'd5: begin
                    //Cr <= Ar_d1;
                    //Ci <= Ai_d1;
                    //Dr <= twR;
                    //Di <= twI;
                //end
                3'd6: begin
                    Cr <= Brs0;
                    Ci <= Bis0;
                    Dr <= Ars0;
                    Di <= Ais0;
                    EgressValid <= valids0;
                end
                //3'd7: begin
                    //Cr <= twR;
                    //Ci <= twI;
                    //Dr <= Ar_d1;
                    //Di <= Ai_d1;
                //end
            endcase
            //if (ctrlWordReg[`RB_BFCTRL_BFBYPASS]) begin
                //Cr <= Ars0;
                //Ci <= Ais0;
                //Dr <= Brs0;
                //Di <= Bis0;
                //EgressValid <= valids0;
            //end else begin
                //EgressValid <= 1'b0;
            //end
        end
    end
    //-----------------------------------------------------
    // Optimize twiddle factor multiplication
    //-----------------------------------------------------
    generate
        // Last butterfly stage uses only one twiddle factor of 1 + 0j
        if (BF_NUM == (NUM_POINTS_LOG2-1)) begin
            // there's an optimization for the ultimate stage that doesn't
            // require multiplications
            assign prodrr = 0;
            assign prodri = 0;
            assign prodii = 0;
            assign prodir = 0;
            //assign mult0_out = twMuxSel ? 0     : diffRs1;
            //assign mult1_out = twMuxSel ? diffIs1 : 0;
        // Second to last butterfly stage uses only two twiddle factors
        // 1 + 0j and 0 - 1j
        end else if (BF_NUM == (NUM_POINTS_LOG2-2)) begin
            // there's an optimization for the penultimate stage that doesn't
            // require multiplications
            assign prodrr = 0;
            assign prodri = 0;
            assign prodii = 0;
            assign prodir = 0;
            //assign mult0_out = clkCntr[3] ? (twMuxSel ? (~diffRs1)+1: 0) : (twMuxSel ? 0     : diffRs1);
            //rr mult0_out = twR:::  0
            //ri mult0_out = twI:::  (~diffRs1)+1
            //assign mult1_out = clkCntr[3] ? (twMuxSel ? 0 : (~diffIs1)+1) : (twMuxSel ? diffIs1 : 0);
        end else begin
            multiplier #(DATA_WIDTH+1,TW_WIDTH) mult0 (.Clk(Clk),.ARst(Rst),.A(diffRs1),.B(twR),.ValidIn(1'b1),.P(prodrr),.ValidOut());
            multiplier #(DATA_WIDTH+1,TW_WIDTH) mult1 (.Clk(Clk),.ARst(Rst),.A(diffRs1),.B(twI),.ValidIn(1'b1),.P(prodri),.ValidOut());
            multiplier #(DATA_WIDTH+1,TW_WIDTH) mult2 (.Clk(Clk),.ARst(Rst),.A(diffIs1),.B(twI),.ValidIn(1'b1),.P(prodii),.ValidOut());
            multiplier #(DATA_WIDTH+1,TW_WIDTH) mult3 (.Clk(Clk),.ARst(Rst),.A(diffIs1),.B(twR),.ValidIn(1'b1),.P(prodir),.ValidOut());
        end
    endgenerate
    //-----------------------------------------------------
    // Scaling Schedule Mux
    //-----------------------------------------------------
    reg signed [DATA_WIDTH-1:0] CrSS;
    reg signed [DATA_WIDTH-1:0] CiSS;
    reg signed [DATA_WIDTH-1:0] DrSS;
    reg signed [DATA_WIDTH-1:0] DiSS;
    always @(*) begin
        case (ctrlWordReg[1:0])
            2'b01: begin
                DrSS <= diff2s3[((DATA_WIDTH+1)+TW_WIDTH)-1:((DATA_WIDTH+1)+TW_WIDTH)-DATA_WIDTH+1-1];
                DiSS <= sum2s3[((DATA_WIDTH+1)+TW_WIDTH)-1:((DATA_WIDTH+1)+TW_WIDTH)-DATA_WIDTH+1-1];
            end
            2'b10: begin
                DrSS <= diff2s3[((DATA_WIDTH+1)+TW_WIDTH)-2:((DATA_WIDTH+1)+TW_WIDTH)-DATA_WIDTH+1-2];
                DiSS <= sum2s3[((DATA_WIDTH+1)+TW_WIDTH)-2:((DATA_WIDTH+1)+TW_WIDTH)-DATA_WIDTH+1-2];
            end
            default: begin
                DrSS <= diff2s3[((DATA_WIDTH+1)+TW_WIDTH):((DATA_WIDTH+1)+TW_WIDTH)-DATA_WIDTH+1];
                DiSS <= sum2s3[((DATA_WIDTH+1)+TW_WIDTH):((DATA_WIDTH+1)+TW_WIDTH)-DATA_WIDTH+1];
            end
        endcase
    end
endmodule
`default_nettype wire
