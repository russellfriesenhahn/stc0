module housekeeper_top (
    input   wire    Clk,
    input   wire    ARst, 
    // FT245 SFF Interface
    `ifdef COCOTB_SIM
    inout  wire [7:0]    D,
    `else
    inout   wire    D0,
    inout   wire    D1,
    inout   wire    D2,
    inout   wire    D3,
    inout   wire    D4,
    inout   wire    D5,
    inout   wire    D6,
    inout   wire    D7,
    `endif
    input   wire    RXFn,
    input   wire    TXEn,
    output  wire    RDn,
    output  wire    WRn,
    output  wire    OEn,
    // UART
    //input   wire    UartRx,
    //output  reg     UartTx,
    output  wire    LED0,
    output  wire    LED1,
    output  wire    LED2,
    output  wire    LED3,
    output  wire    LED4,
    output  wire    LED5,
    output  wire    LED6,
    output  wire    LED7,
    // SCP Interface
    output  wire    ScpClk,
    output  wire    EValid,
    output  wire    ED0,
    output  wire    ED1,
    output  wire    ED2,
    output  wire    ED3,
    output  wire    ED4,
    output  wire    ED5,
    output  wire    ED6,
    output  wire    ED7,
    input   wire    IValid,
    input   wire    ID0,
    input   wire    ID1,
    input   wire    ID2,
    input   wire    ID3,
    input   wire    ID4,
    input   wire    ID5,
    input   wire    ID6,
    input   wire    ID7
);

//assign OEn = 1'b0;
    `ifdef COCOTB_SIM
    initial begin
        $dumpfile("scp_rtlsim_top_simple_tb.lxt2");
        $dumpvars;
    end
    `endif

    wire [7:0] din;
    wire [7:0] dout;

    reg  [1:0]  sfifoWrSrc;
    reg  [7:0]  ledReg;
    reg  [7:0]  idata;
    reg         sfifoWen;

    always @(*) begin
        case(sfifoWrSrc)
            2'b00: begin
                idata = {ID7,ID6,ID5,ID4,ID3,ID2,ID1,ID0};
                sfifoWen = IValid;
            end
            2'b01: begin
                idata = ED;
                sfifoWen = EValid_int;
            end
            2'b10: begin
                idata = wdata[7:0];
                sfifoWen = dataValid && (waddr[23:12] == 12'h001);
            end
            2'b11: begin
                idata = {ID7,ID6,ID5,ID4,ID3,ID2,ID1,ID0};
                sfifoWen = IValid;
            end
        endcase
    end
    //assign idata = sfifoWrSrc ? ED : {ID7,ID6,ID5,ID4,ID3,ID2,ID1,ID0};
    //assign sfifoWen = sfifoWrSrc ? EValid_int : IValid;

    //reg [7:0] odata;
    //assign {ED7,ED6,ED5,ED4,ED3,ED2,ED1,ED0} = odata;

    //`define SIMULATION
    `ifdef COCOTB_SIM 
        assign din = D;
        assign D  = ~OEn ? 8'hzz : dout;
        //assign {D7,D6,D5,D4,D3,D2,D1,D0} = ~OEn ? 8'hzz : dout;
    `else
        SB_IO #(.PIN_TYPE(6'b 1010_01),.PULLUP(1'b 0)
        ) sbio_d0 (.PACKAGE_PIN(D0),.OUTPUT_ENABLE(OEn),.D_OUT_0(1'b0),.D_IN_0(din[0]));
        SB_IO #(.PIN_TYPE(6'b 1010_01),.PULLUP(1'b 0)
        ) sbio_d1 (.PACKAGE_PIN(D1),.OUTPUT_ENABLE(OEn),.D_OUT_0(1'b0),.D_IN_0(din[1]));
        SB_IO #(.PIN_TYPE(6'b 1010_01),.PULLUP(1'b 0)
        ) sbio_d2 (.PACKAGE_PIN(D2),.OUTPUT_ENABLE(OEn),.D_OUT_0(1'b0),.D_IN_0(din[2]));
        SB_IO #(.PIN_TYPE(6'b 1010_01),.PULLUP(1'b 0)
        ) sbio_d3 (.PACKAGE_PIN(D3),.OUTPUT_ENABLE(OEn),.D_OUT_0(1'b0),.D_IN_0(din[3]));
        SB_IO #(.PIN_TYPE(6'b 1010_01),.PULLUP(1'b 0)
        ) sbio_d4 (.PACKAGE_PIN(D4),.OUTPUT_ENABLE(OEn),.D_OUT_0(1'b0),.D_IN_0(din[4]));
        SB_IO #(.PIN_TYPE(6'b 1010_01),.PULLUP(1'b 0)
        ) sbio_d5 (.PACKAGE_PIN(D5),.OUTPUT_ENABLE(OEn),.D_OUT_0(1'b0),.D_IN_0(din[5]));
        SB_IO #(.PIN_TYPE(6'b 1010_01),.PULLUP(1'b 0)
        ) sbio_d6 (.PACKAGE_PIN(D6),.OUTPUT_ENABLE(OEn),.D_OUT_0(1'b0),.D_IN_0(din[6]));
        SB_IO #(.PIN_TYPE(6'b 1010_01),.PULLUP(1'b 0)
        ) sbio_d7 (.PACKAGE_PIN(D7),.OUTPUT_ENABLE(OEn),.D_OUT_0(1'b0),.D_IN_0(din[7]));
    `endif

    wire    [7:0]   hostData;
    wire            hostDataValid;
    wire    [7:0]   wrData;
    wire            rdy_wr;
    reg             rwn;


    ft245sff ft245sff (
        .Clk(Clk),
        .ARst(ARst),
        // FTDI FT245 Synchronous FIFO Signaling
        .RXFn(RXFn),
        .RDn(RDn),
        .ADBUS_Rd(din),
        .TXEn(TXEn),
        .WRn(WRn),
        .ADBUS_Wr(dout),
        .OEn(OEn),
        .SIWU(),
        // Mode for FSM controlling FT245 interface
        .RWn(rwn),
        // Interface for write data
        .Data_Wr(wrData),
        .Valid_Wr(sfifoRen),
        .Rdy_Wr(rdy_wr),
        // Interface for read data
        .RdValid(hostDataValid),
        .RdData(hostData)
    );

    wire [23:0] waddr;
    wire [31:0] wdata;

    wire [7:0] ED;
    assign {ED7,ED6,ED5,ED4,ED3,ED2,ED1,ED0} = ED;

    wire EValid_int;
    assign EValid = EValid_int & ~sfifoWrSrc;

    HKbyteIngress byteIngress_0 (
        .ClkIngress(Clk),
        .ARst(ARst),
        .Data(hostData),
        .DataValid(hostDataValid),
        .Rdyn(IRdyn),
        .RWn(),
        .HostWriteValid(sfifoRen),
        .CmdAddr(waddr),
        .WriteData(wdata),
        .WriteDataValid(dataValid),
        .EValid(EValid_int),
        .ED(ED)
    );
    
    //wire [2:0] state;
    wire [31:0] ctrl0;

    assign {LED7,LED6,LED5,LED4,LED3,LED2,LED1,LED0} = ledReg;
    
    reg [31:0] sfifoReadbackBytes;

    localparam STATE_IDLE   = 0;
    localparam STATE_RXCMD  = 1;
    localparam STATE_SCPCMD = 2;
    localparam STATE_HKWR   = 3;
    localparam STATE_HKRD   = 3;

    // Address Map
    // 1 - LEDs via SW
    // 2 - sfifo input mux control 
    // 3 - sfifo readback number of bytes
    // 4 - sfifo readback timeout
    always @(posedge Clk or posedge ARst) begin
        if (ARst) begin
            sfifoWrSrc <= 2'b00;
            rwn <= 1'b1;
            sfifoReadbackBytes <= 0;
            ledReg <= 0;
        end else begin
            if (dataValid && (waddr == 24'h000001)) begin
                ledReg <= wdata[7:0];
            end else if (dataValid && (waddr == 24'h000002)) begin
                sfifoWrSrc <= wdata[1:0];
                //rwn <= 1'b0
            end else if (dataValid && (waddr == 24'h000003)) begin
                sfifoReadbackBytes <= wdata;
            end else if (dataValid && (waddr == 24'h000004)) begin
                //ledReg <= wdata[7:0];
            end

            if (sfifoReadbackBytes > 0) begin
                rwn <= 1'b0;
                if (sfifoRen == 1'b1) begin
                    sfifoReadbackBytes <= sfifoReadbackBytes - 1;
                end
            end else begin
                rwn <= 1'b1;
            end

        end
    end
    //reg [1:0]   state;
    //reg [1:0]   state_ns;

    // Command processing
    //
    // Pass commands to downstream SCP ASIC if command is 0x01. Since the
    // command byte is bits 31:24 in the first 32-bit word, the first full
    // word is always transmitted because this module would overflow
    // eventually if we always tried to hold the first word. The SCP command
    // processor will properly discard an incorrect command, but since there
    // are not SOF or EOF signals used, care must be taken in what bytes are
    // transmitted. 
    //
    // Once the command has been identified as a housekeeper command, no more
    // bytes will be transmitted to the SCP
    //always @(posedge Clk or posedge ARst) begin
        //if (ARst) begin
            //state <= STATE_IDLE;
        //end else begin
            //case(state)
                //STATE_IDLE: begin
                //end
                //STATE_RXCMD: begin
                //end
                //STATE_SCPCMD: begin
                //end
                //STATE_HKWR: begin
                //end
                //STATE_HKRD: begin
                //end
            //endcase
        //end
    //end

    //wire sfifoRen;
    wire sfifoEty;

    assign sfifoRen = ~sfifoEty & ~rwn & rdy_wr;

    sfifo #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(12)
    ) pingff (
        .Clk(Clk),
        .ARst(ARst),
        .Ren(sfifoRen),
        .Wen(sfifoWen),
        .WData(idata),
        .RData(wrData),
        .Empty(sfifoEty),
        .Full(),
        .Unf(),
        .Ovf()
    );
    //wire [7:0]  RxD;
    //wire        RxDValid;

    //uart_rx #(
        //.BAUD_RATE(115200),
        //.CLK_FREQ_HZ(60000000)
    //) uart_rx (
        //.Clk(Clk),
        //.Rst(ARst),
        //.Rx(UartRx),
        //.RxD(RxD),
        //.RxDValid(RxDValid)
    //);
    //asciiCmd asciiCmd(
        //.Clk(Clk),
        //.ARst(ARst),
        //.Char(RxD),
        //.CharValid(RxDValid),
        //.CmdAddr(),
        //.CmdData(),
        //.CmdValid(cmdValid),
        //.ctrl0(ctrl0)
    //);
endmodule
