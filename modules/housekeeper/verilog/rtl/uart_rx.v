//------------------------------------------------------------------------------
// UART Receiver
//
//------------------------------------------------------------------------------

`timescale 1ns/100ps
`default_nettype none
module uart_rx #(
    parameter integer BAUD_RATE = 9600,
    parameter integer CLK_FREQ_HZ = 12000000
) (
    input   wire        Clk,
    input   wire        Rst,
    input   wire        Rx,
    output  reg [7:0]   RxD,
    output  reg         RxDValid
);
localparam integer PERIOD = CLK_FREQ_HZ / BAUD_RATE;
localparam integer HALF_PERIOD = PERIOD / 2;

reg [$clog2(3*HALF_PERIOD):0] clkCntr;
reg [3:0] bitCntr = 0;
reg recv = 0;

always @(posedge Clk or posedge Rst) begin
    if (Rst == 1'b1) begin
        RxDValid <= 0;
        recv <= 0;
        RxD <= 0;
    end else begin
        RxDValid <= 0;
        if (recv == 0) begin
            if (Rx == 0) begin
                clkCntr <= HALF_PERIOD/2;
                bitCntr <= 0;
                recv <= 1;
            end
        end else begin
            if (clkCntr == 2*HALF_PERIOD) begin
                clkCntr <= 0;
                bitCntr <= bitCntr + 1;
                if (bitCntr == 9) begin
                    RxDValid <= 1;
                    recv <= 0;
                end else begin
                    RxD <= {Rx, RxD[7:1]};
                end
            end else begin
                clkCntr <= clkCntr + 1;
            end
        end
    end
end
endmodule
//module uart_rx #(
    //parameter integer BAUD_RATE = 9600,
    //parameter integer CLK_FREQ_HZ = 12000000
//) (
    //input   wire        Clk,
    //input   wire        Rst,
    //input   wire        Rx,
    //output  reg [7:0]   RxD,
    //output  reg         RxDValid
//);
    //localparam integer PERIOD = CLK_FREQ_HZ / BAUD_RATE;
    //localparam integer HALF_PERIOD = PERIOD / 2;

    //reg [$clog2(3*HALF_PERIOD):0] clkCntr;
    //reg [3:0] bitCntr = 0;
    //reg recv;

    //always @(posedge Clk or posedge Rst) begin
        //if (Rst == 1'b1) begin
            //RxDValid <= 0;
            //recv <= 0;
        //end else begin
            //if (recv == 0) begin
                //if (Rx == 0) begin
                    //clkCntr <= clkCntr + 1;
                    //if (clkCntr == HALF_PERIOD) begin
                        //bitCntr <= 0;
                        //recv <= 1;
                    //end
                //end
            //end else begin
                //if (clkCntr == 2*HALF_PERIOD) begin
                    //clkCntr <= 0;
                    //bitCntr <= bitCntr + 1;
                    //if (bitCntr == 9) begin
                        //RxDValid <= 1;
                        //recv <= 0;
                    //end else begin
                        //RxDValid <= {Rx, RxDValid[7:1]};
                    //end
                //end else begin
                    //clkCntr <= clkCntr + 1;
                //end
            //end
        //end
    //end
//endmodule
`default_nettype wire 
