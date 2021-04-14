//------------------------------------------------------------------------------
// Synchronous FIFO using a Single-Port RAM
//------------------------------------------------------------------------------

`timescale 1ns/100ps
`default_nettype none
module sfifo #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
) (
    input wire                  Clk,
    input wire                  ARst,
    input wire                  Ren,
    input wire                  Wen,
    input wire [DATA_WIDTH-1:0] WData,
    output reg [DATA_WIDTH-1:0] RData,
    output wire                 Empty,
    output wire                 Full,
    output wire                 Unf,
    output wire                 Ovf
);
    reg [ADDR_WIDTH:0]  rptr;
    reg [ADDR_WIDTH:0]  rptr_comb;
    reg [ADDR_WIDTH:0]  wptr;
    reg empty_d1;
    
    assign Full = (wptr[ADDR_WIDTH] != rptr[ADDR_WIDTH]) 
                    && (wptr[ADDR_WIDTH-1:0] == rptr[ADDR_WIDTH-1:0]);
    assign Empty = (wptr == rptr) || empty_d1;
    assign Ovf = Full & Wen;
    assign Unf = Empty & Ren;

    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    //reg rptr_comb;
    
    always @(*) begin
        rptr_comb = rptr + Ren;
    end
    always @(posedge Clk or posedge ARst) begin
        if (ARst == 1'b1) begin
            rptr <= 0;
            wptr <= 0;
            empty_d1 <= 0;
        end else begin
            //empty_d1 <= Empty;
            empty_d1 <= (wptr == rptr);

            //if (Ren == 1'b1) rptr <= rptr + 1;
            rptr <= rptr_comb;

            if (Wen == 1'b1) begin
                //mem[wptr[ADDR_WIDTH-1:0]] <= WData;
                wptr <= wptr + 1;
            end
        end
    end
    always @(posedge Clk) begin
        if (Wen == 1'b1) mem[wptr[ADDR_WIDTH-1:0]] <= WData;
        RData <= mem[rptr_comb[ADDR_WIDTH-1:0]];
    end
endmodule
`default_nettype wire
