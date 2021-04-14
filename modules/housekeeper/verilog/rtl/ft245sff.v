//------------------------------------------------------------------------------
// FT245 Style Synchronous FIFO Interface
//
// This is meant to interface to an FTDI FT2232H device configured to provide
// FT245 synchronous interface mode
//
// Read and write are defined by the FT2232H FT245 documentation
//------------------------------------------------------------------------------

`timescale 1ns/100ps
`default_nettype none
module ft245sff (
    input   wire          Clk,
    input   wire          ARst,
    // FTDI FT245 Synchronous FIFO Signaling
    input   wire          RXFn,
    output  reg           RDn,
    input   wire  [7:0]   ADBUS_Rd,
    input   wire          TXEn,
    output  reg           WRn,
    output  reg   [7:0]   ADBUS_Wr,
    output  reg           OEn,
    output  wire          SIWU,
    // Mode for FSM controlling FT245 interface
    input   wire          RWn,
    // Interface for write data
    input   wire  [7:0]   Data_Wr,
    input   wire          Valid_Wr,
    output  reg           Rdy_Wr,
    // Interface for read data
    output  reg           RdValid,
    output  reg   [7:0]   RdData
);
    // By default, this FT245 client will read from the host whenever
    // possible. The host will set RWn high when the host expects the client
    // to transmit data

    assign SIWU = 1'b1;

    localparam STATE_IDLE   = 0;
    localparam STATE_OEN    = 1;
    localparam STATE_RDN    = 2;
    localparam STATE_WRN    = 3;

    reg [1:0]   state;
    reg [1:0]   state_ns;

    always @(posedge Clk or posedge ARst) begin
        if (ARst) begin
            state <= STATE_IDLE;
            RdValid <= 1'b0;
            WRn <= 1'b1;
        end else begin
            state <= state_ns;
            RdData <= ADBUS_Rd;
            RdValid <= ~RXFn & ~OEn & ~RDn;

            ADBUS_Wr <= Data_Wr;
            WRn <= ~((state == STATE_WRN) && Valid_Wr);
            //case(state)
                //STATE_IDLE: begin
                    //OEn = 1'b1;
                    //RDn = 1'b1;
                    //WRn = 1'b1;

                    //if ((RXFn == 1'b0) && (RWn == 1'b1))      state_ns = STATE_OEN;
                    //else if ((TXEn == 1'b0) && (RWn == 1'b0)) state_ns = STATE_WRN;
                    //else                                      state_ns = STATE_IDLE;
                //end
                //STATE_OEN: begin
                    //OEn = 1'b0;
                    //RDn = 1'b1;
                    //WRn = 1'b1;
                    //state_ns = STATE_RDN;
                //end
                //STATE_RDN: begin
                    //OEn = 1'b0;
                    //RDn = 1'b0;
                    //WRn = 1'b1;
                    //if (RXFn == 1'b1)   state_ns = STATE_IDLE;
                    //else                state_ns = STATE_RDN;
                //end
                //STATE_WRN: begin
                    //OEn = 1'b1;
                    //RDn = 1'b1;
                    //WRn = 1'b0;

                    //if ((TXEn == 1'b1) || (RWn == 1'b1))  state_ns = STATE_IDLE;
                    //else                                  state_ns = STATE_WRN;
                //end
            //endcase
        end
    end
 
    always @(*) begin
        OEn = 1'b1;
        RDn = 1'b1;
        //WRn = 1'b1;
        Rdy_Wr = 1'b0;
        case(state)
            STATE_IDLE: begin
                OEn = 1'b1;
                RDn = 1'b1;
                //WRn = 1'b1;

                if ((RXFn == 1'b0) && (RWn == 1'b1))      state_ns = STATE_OEN;
                else if ((TXEn == 1'b0) && (RWn == 1'b0)) state_ns = STATE_WRN;
                else                                      state_ns = STATE_IDLE;
            end
            STATE_OEN: begin
                OEn = 1'b0;
                RDn = 1'b1;
                //WRn = 1'b1;
                state_ns = STATE_RDN;
            end
            STATE_RDN: begin
                OEn = 1'b0;
                RDn = 1'b0;
                //WRn = 1'b1;
                if (RXFn == 1'b1)   state_ns = STATE_IDLE;
                else                state_ns = STATE_RDN;
            end
            STATE_WRN: begin
                OEn = 1'b1;
                RDn = 1'b1;
                //WRn = Valid_Wr;
                Rdy_Wr = ~TXEn;

                if ((TXEn == 1'b1) || (RWn == 1'b1))  state_ns = STATE_IDLE;
                else                                  state_ns = STATE_WRN;
            end
        endcase
    end
endmodule
`default_nettype wire
