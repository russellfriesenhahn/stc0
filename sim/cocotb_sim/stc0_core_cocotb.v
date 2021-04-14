
module stc0_core_cocotb (
    input   wire        Clk,
    input   wire        ARst, 
    // FT245 SFF Interface
    input   wire        RXFn,
    input   wire        TXEn,
    output  wire        RDn,
    output  wire        WRn,
    output  wire        OEn,
    `ifdef COCOTB_SIM
    output  wire [7:0]  DOUT,
    input   wire [7:0]  DIN,
    `endif
    output  wire [7:0]  LED
);

    wire [7:0] DIO;
    assign DOUT = DIO;
    assign DIO  = ~OEn ? DIN : 8'hzz;

    wire        IValid;
    wire [7:0]  ID;
    wire [7:0]  ED;

    housekeeper_top housekeeper_top_0 (
        .Clk(Clk),
        .ARst(ARst), 
        // FT245 SFF Interface
        .D(DIO),
        .RXFn(RXFn),
        .TXEn(TXEn),
        .RDn(RDn),
        .WRn(WRn),
        .OEn(OEn),
        // UART
        //.UartRx(1'b0),
        //.UartTx(),
        .LED0(LED[0]),
        .LED1(LED[1]),
        .LED2(LED[2]),
        .LED3(LED[3]),
        .LED4(LED[4]),
        .LED5(LED[5]),
        .LED6(LED[6]),
        .LED7(LED[7]),
        // SCP Interface
        .ScpClk(ScpClk),
        .EValid(EValid),
        .ED0(ED[0]),
        .ED1(ED[1]),
        .ED2(ED[2]),
        .ED3(ED[3]),
        .ED4(ED[4]),
        .ED5(ED[5]),
        .ED6(ED[6]),
        .ED7(ED[7]),
        .IValid(IValid),
        .ID0(ID[0]),
        .ID1(ID[1]),
        .ID2(ID[2]),
        .ID3(ID[3]),
        .ID4(ID[4]),
        .ID5(ID[5]),
        .ID6(ID[6]),
        .ID7(ID[7])
    );
    stc0_core stco0_core_(
        .ClkIngress(Clk),
        .ClkProc(ClkProc),
        .ARst(ARst),
        .ID(ED),
        .IValid(EValid),
        .ED(ID),
        .EValid(IValid)
    );
endmodule
