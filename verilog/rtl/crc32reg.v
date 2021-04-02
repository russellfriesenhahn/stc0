
module crc32reg (
    input wire  Clk,
    input wire  ARst,
    input wire  Enable,
    input wire  [31:0] Data,
    output reg  [31:0] CrcOut,
    output reg         CrcOutValid
);
    wire [31:0] crcOut_comb;

    always @(posedge Clk or posedge ARst) begin
        if (ARst == 1'b1) begin
            CrcOut <= 0;
            CrcOutValid <= 0;
        end else begin
            CrcOutValid <= Enable;

            if (Enable == 1'b1) begin
                CrcOut <= crcOut_comb;
            end
        end
    end

    crc32 crc32_(
        .crcIn(CrcOut),
        .data(Data),
        .crcOut(crcOut_comb)
    );
endmodule
