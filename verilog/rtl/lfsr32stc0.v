// vim: ts=4 sw=4 expandtab
//
// THIS IS GENERATED CODE.
// 
// This code is Public Domain.
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted.
// 
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
// SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
// RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
// NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
// USE OR PERFORMANCE OF THIS SOFTWARE.

`ifndef LFSR32_V_
`define LFSR32_V_

// LFSR polynomial coeffiecients: x^32 + x^22 + x^2 + x^1 + 1
// LFSR width: 32 bits

module lfsr32stc0 (
	input wire  Clk,
	input wire  ARst,
	input wire  Enable,
	input wire  Load,
	input wire  [31:0] Seed,
	output reg  [31:0] LFSR
);

	wire [31:0] newValue;

	always @(posedge Clk or posedge ARst) begin
		if (ARst == 1'b1) begin
			LFSR <= 0;
		end else begin
			if (Load == 1'b1) begin
				LFSR <= Seed;
			end else if (Enable == 1'b1) begin
				LFSR <= newValue;
			end
		end
	end

	assign newValue[0] = LFSR[0] ^ LFSR[2] ^ LFSR[4] ^ LFSR[5] ^ LFSR[7] ^ LFSR[8] ^ LFSR[10] ^ LFSR[11] ^ LFSR[12] ^ LFSR[13] ^ LFSR[16] ^ LFSR[17] ^ LFSR[18] ^ LFSR[19] ^ LFSR[25] ^ LFSR[27] ^ LFSR[31];
	assign newValue[1] = LFSR[0] ^ LFSR[2] ^ LFSR[3] ^ LFSR[5] ^ LFSR[6] ^ LFSR[8] ^ LFSR[9] ^ LFSR[11] ^ LFSR[12] ^ LFSR[13] ^ LFSR[14] ^ LFSR[17] ^ LFSR[18] ^ LFSR[19] ^ LFSR[20] ^ LFSR[22] ^ LFSR[26] ^ LFSR[28];
	assign newValue[2] = LFSR[1] ^ LFSR[3] ^ LFSR[4] ^ LFSR[6] ^ LFSR[7] ^ LFSR[9] ^ LFSR[10] ^ LFSR[12] ^ LFSR[13] ^ LFSR[14] ^ LFSR[15] ^ LFSR[18] ^ LFSR[19] ^ LFSR[20] ^ LFSR[21] ^ LFSR[23] ^ LFSR[27] ^ LFSR[29];
	assign newValue[3] = LFSR[2] ^ LFSR[4] ^ LFSR[5] ^ LFSR[7] ^ LFSR[8] ^ LFSR[10] ^ LFSR[11] ^ LFSR[13] ^ LFSR[14] ^ LFSR[15] ^ LFSR[16] ^ LFSR[19] ^ LFSR[20] ^ LFSR[21] ^ LFSR[22] ^ LFSR[24] ^ LFSR[28] ^ LFSR[30];
	assign newValue[4] = LFSR[3] ^ LFSR[5] ^ LFSR[6] ^ LFSR[8] ^ LFSR[9] ^ LFSR[11] ^ LFSR[12] ^ LFSR[14] ^ LFSR[15] ^ LFSR[16] ^ LFSR[17] ^ LFSR[20] ^ LFSR[21] ^ LFSR[22] ^ LFSR[23] ^ LFSR[25] ^ LFSR[29] ^ LFSR[31];
	assign newValue[5] = LFSR[0] ^ LFSR[1] ^ LFSR[2] ^ LFSR[4] ^ LFSR[6] ^ LFSR[7] ^ LFSR[9] ^ LFSR[10] ^ LFSR[12] ^ LFSR[13] ^ LFSR[15] ^ LFSR[16] ^ LFSR[17] ^ LFSR[18] ^ LFSR[21] ^ LFSR[23] ^ LFSR[24] ^ LFSR[26] ^ LFSR[30];
	assign newValue[6] = LFSR[1] ^ LFSR[2] ^ LFSR[3] ^ LFSR[5] ^ LFSR[7] ^ LFSR[8] ^ LFSR[10] ^ LFSR[11] ^ LFSR[13] ^ LFSR[14] ^ LFSR[16] ^ LFSR[17] ^ LFSR[18] ^ LFSR[19] ^ LFSR[22] ^ LFSR[24] ^ LFSR[25] ^ LFSR[27] ^ LFSR[31];
	assign newValue[7] = LFSR[0] ^ LFSR[1] ^ LFSR[3] ^ LFSR[4] ^ LFSR[6] ^ LFSR[8] ^ LFSR[9] ^ LFSR[11] ^ LFSR[12] ^ LFSR[14] ^ LFSR[15] ^ LFSR[17] ^ LFSR[18] ^ LFSR[19] ^ LFSR[20] ^ LFSR[22] ^ LFSR[23] ^ LFSR[25] ^ LFSR[26] ^ LFSR[28];
	assign newValue[8] = LFSR[1] ^ LFSR[2] ^ LFSR[4] ^ LFSR[5] ^ LFSR[7] ^ LFSR[9] ^ LFSR[10] ^ LFSR[12] ^ LFSR[13] ^ LFSR[15] ^ LFSR[16] ^ LFSR[18] ^ LFSR[19] ^ LFSR[20] ^ LFSR[21] ^ LFSR[23] ^ LFSR[24] ^ LFSR[26] ^ LFSR[27] ^ LFSR[29];
	assign newValue[9] = LFSR[2] ^ LFSR[3] ^ LFSR[5] ^ LFSR[6] ^ LFSR[8] ^ LFSR[10] ^ LFSR[11] ^ LFSR[13] ^ LFSR[14] ^ LFSR[16] ^ LFSR[17] ^ LFSR[19] ^ LFSR[20] ^ LFSR[21] ^ LFSR[22] ^ LFSR[24] ^ LFSR[25] ^ LFSR[27] ^ LFSR[28] ^ LFSR[30];
	assign newValue[10] = LFSR[3] ^ LFSR[4] ^ LFSR[6] ^ LFSR[7] ^ LFSR[9] ^ LFSR[11] ^ LFSR[12] ^ LFSR[14] ^ LFSR[15] ^ LFSR[17] ^ LFSR[18] ^ LFSR[20] ^ LFSR[21] ^ LFSR[22] ^ LFSR[23] ^ LFSR[25] ^ LFSR[26] ^ LFSR[28] ^ LFSR[29] ^ LFSR[31];
	assign newValue[11] = LFSR[0] ^ LFSR[1] ^ LFSR[2] ^ LFSR[4] ^ LFSR[5] ^ LFSR[7] ^ LFSR[8] ^ LFSR[10] ^ LFSR[12] ^ LFSR[13] ^ LFSR[15] ^ LFSR[16] ^ LFSR[18] ^ LFSR[19] ^ LFSR[21] ^ LFSR[23] ^ LFSR[24] ^ LFSR[26] ^ LFSR[27] ^ LFSR[29] ^ LFSR[30];
	assign newValue[12] = LFSR[1] ^ LFSR[2] ^ LFSR[3] ^ LFSR[5] ^ LFSR[6] ^ LFSR[8] ^ LFSR[9] ^ LFSR[11] ^ LFSR[13] ^ LFSR[14] ^ LFSR[16] ^ LFSR[17] ^ LFSR[19] ^ LFSR[20] ^ LFSR[22] ^ LFSR[24] ^ LFSR[25] ^ LFSR[27] ^ LFSR[28] ^ LFSR[30] ^ LFSR[31];
	assign newValue[13] = LFSR[0] ^ LFSR[1] ^ LFSR[3] ^ LFSR[4] ^ LFSR[6] ^ LFSR[7] ^ LFSR[9] ^ LFSR[10] ^ LFSR[12] ^ LFSR[14] ^ LFSR[15] ^ LFSR[17] ^ LFSR[18] ^ LFSR[20] ^ LFSR[21] ^ LFSR[22] ^ LFSR[23] ^ LFSR[25] ^ LFSR[26] ^ LFSR[28] ^ LFSR[29] ^ LFSR[31];
	assign newValue[14] = LFSR[0] ^ LFSR[4] ^ LFSR[5] ^ LFSR[7] ^ LFSR[8] ^ LFSR[10] ^ LFSR[11] ^ LFSR[13] ^ LFSR[15] ^ LFSR[16] ^ LFSR[18] ^ LFSR[19] ^ LFSR[21] ^ LFSR[23] ^ LFSR[24] ^ LFSR[26] ^ LFSR[27] ^ LFSR[29] ^ LFSR[30];
	assign newValue[15] = LFSR[1] ^ LFSR[5] ^ LFSR[6] ^ LFSR[8] ^ LFSR[9] ^ LFSR[11] ^ LFSR[12] ^ LFSR[14] ^ LFSR[16] ^ LFSR[17] ^ LFSR[19] ^ LFSR[20] ^ LFSR[22] ^ LFSR[24] ^ LFSR[25] ^ LFSR[27] ^ LFSR[28] ^ LFSR[30] ^ LFSR[31];
	assign newValue[16] = LFSR[0] ^ LFSR[1] ^ LFSR[6] ^ LFSR[7] ^ LFSR[9] ^ LFSR[10] ^ LFSR[12] ^ LFSR[13] ^ LFSR[15] ^ LFSR[17] ^ LFSR[18] ^ LFSR[20] ^ LFSR[21] ^ LFSR[22] ^ LFSR[23] ^ LFSR[25] ^ LFSR[26] ^ LFSR[28] ^ LFSR[29] ^ LFSR[31];
	assign newValue[17] = LFSR[0] ^ LFSR[7] ^ LFSR[8] ^ LFSR[10] ^ LFSR[11] ^ LFSR[13] ^ LFSR[14] ^ LFSR[16] ^ LFSR[18] ^ LFSR[19] ^ LFSR[21] ^ LFSR[23] ^ LFSR[24] ^ LFSR[26] ^ LFSR[27] ^ LFSR[29] ^ LFSR[30];
	assign newValue[18] = LFSR[1] ^ LFSR[8] ^ LFSR[9] ^ LFSR[11] ^ LFSR[12] ^ LFSR[14] ^ LFSR[15] ^ LFSR[17] ^ LFSR[19] ^ LFSR[20] ^ LFSR[22] ^ LFSR[24] ^ LFSR[25] ^ LFSR[27] ^ LFSR[28] ^ LFSR[30] ^ LFSR[31];
	assign newValue[19] = LFSR[0] ^ LFSR[1] ^ LFSR[9] ^ LFSR[10] ^ LFSR[12] ^ LFSR[13] ^ LFSR[15] ^ LFSR[16] ^ LFSR[18] ^ LFSR[20] ^ LFSR[21] ^ LFSR[22] ^ LFSR[23] ^ LFSR[25] ^ LFSR[26] ^ LFSR[28] ^ LFSR[29] ^ LFSR[31];
	assign newValue[20] = LFSR[0] ^ LFSR[10] ^ LFSR[11] ^ LFSR[13] ^ LFSR[14] ^ LFSR[16] ^ LFSR[17] ^ LFSR[19] ^ LFSR[21] ^ LFSR[23] ^ LFSR[24] ^ LFSR[26] ^ LFSR[27] ^ LFSR[29] ^ LFSR[30];
	assign newValue[21] = LFSR[1] ^ LFSR[11] ^ LFSR[12] ^ LFSR[14] ^ LFSR[15] ^ LFSR[17] ^ LFSR[18] ^ LFSR[20] ^ LFSR[22] ^ LFSR[24] ^ LFSR[25] ^ LFSR[27] ^ LFSR[28] ^ LFSR[30] ^ LFSR[31];
	assign newValue[22] = LFSR[0] ^ LFSR[1] ^ LFSR[12] ^ LFSR[13] ^ LFSR[15] ^ LFSR[16] ^ LFSR[18] ^ LFSR[19] ^ LFSR[21] ^ LFSR[22] ^ LFSR[23] ^ LFSR[25] ^ LFSR[26] ^ LFSR[28] ^ LFSR[29] ^ LFSR[31];
	assign newValue[23] = LFSR[0] ^ LFSR[13] ^ LFSR[14] ^ LFSR[16] ^ LFSR[17] ^ LFSR[19] ^ LFSR[20] ^ LFSR[23] ^ LFSR[24] ^ LFSR[26] ^ LFSR[27] ^ LFSR[29] ^ LFSR[30];
	assign newValue[24] = LFSR[1] ^ LFSR[14] ^ LFSR[15] ^ LFSR[17] ^ LFSR[18] ^ LFSR[20] ^ LFSR[21] ^ LFSR[24] ^ LFSR[25] ^ LFSR[27] ^ LFSR[28] ^ LFSR[30] ^ LFSR[31];
	assign newValue[25] = LFSR[0] ^ LFSR[1] ^ LFSR[15] ^ LFSR[16] ^ LFSR[18] ^ LFSR[19] ^ LFSR[21] ^ LFSR[25] ^ LFSR[26] ^ LFSR[28] ^ LFSR[29] ^ LFSR[31];
	assign newValue[26] = LFSR[0] ^ LFSR[16] ^ LFSR[17] ^ LFSR[19] ^ LFSR[20] ^ LFSR[26] ^ LFSR[27] ^ LFSR[29] ^ LFSR[30];
	assign newValue[27] = LFSR[1] ^ LFSR[17] ^ LFSR[18] ^ LFSR[20] ^ LFSR[21] ^ LFSR[27] ^ LFSR[28] ^ LFSR[30] ^ LFSR[31];
	assign newValue[28] = LFSR[0] ^ LFSR[1] ^ LFSR[18] ^ LFSR[19] ^ LFSR[21] ^ LFSR[28] ^ LFSR[29] ^ LFSR[31];
	assign newValue[29] = LFSR[0] ^ LFSR[19] ^ LFSR[20] ^ LFSR[29] ^ LFSR[30];
	assign newValue[30] = LFSR[1] ^ LFSR[20] ^ LFSR[21] ^ LFSR[30] ^ LFSR[31];
	assign newValue[31] = LFSR[0] ^ LFSR[1] ^ LFSR[21] ^ LFSR[31];
endmodule
`endif // LFSR32_V_
