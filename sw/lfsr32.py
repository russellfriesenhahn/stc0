# vim: ts=4 sw=4 expandtab
#
# THIS IS GENERATED CODE.
# 
# This code is Public Domain.
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
# RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
# NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
# USE OR PERFORMANCE OF THIS SOFTWARE.


# LFSR polynomial coeffiecients: x^32 + x^22 + x^2 + x^1 + 1
# LFSR width: 32 bits

def lfsr32(seed, numSteps):
	class bitwrapper:
		def __init__(self, value):
			self.value = value
		def __getitem__(self, index):
			return ((self.value >> index) & 1)
		def __setitem__(self, index, value):
			if value:
				self.value |= 1 << index
			else:
				self.value &= ~(1 << index)
	seed = bitwrapper(seed)
	ret = bitwrapper(0)

	for step in range(numSteps):
		ret[0] = seed[0] ^ seed[2] ^ seed[4] ^ seed[5] ^ seed[7] ^ seed[8] ^ seed[10] ^ seed[11] ^ seed[12] ^ seed[13] ^ seed[16] ^ seed[17] ^ seed[18] ^ seed[19] ^ seed[25] ^ seed[27] ^ seed[31]
		ret[1] = seed[0] ^ seed[2] ^ seed[3] ^ seed[5] ^ seed[6] ^ seed[8] ^ seed[9] ^ seed[11] ^ seed[12] ^ seed[13] ^ seed[14] ^ seed[17] ^ seed[18] ^ seed[19] ^ seed[20] ^ seed[22] ^ seed[26] ^ seed[28]
		ret[2] = seed[1] ^ seed[3] ^ seed[4] ^ seed[6] ^ seed[7] ^ seed[9] ^ seed[10] ^ seed[12] ^ seed[13] ^ seed[14] ^ seed[15] ^ seed[18] ^ seed[19] ^ seed[20] ^ seed[21] ^ seed[23] ^ seed[27] ^ seed[29]
		ret[3] = seed[2] ^ seed[4] ^ seed[5] ^ seed[7] ^ seed[8] ^ seed[10] ^ seed[11] ^ seed[13] ^ seed[14] ^ seed[15] ^ seed[16] ^ seed[19] ^ seed[20] ^ seed[21] ^ seed[22] ^ seed[24] ^ seed[28] ^ seed[30]
		ret[4] = seed[3] ^ seed[5] ^ seed[6] ^ seed[8] ^ seed[9] ^ seed[11] ^ seed[12] ^ seed[14] ^ seed[15] ^ seed[16] ^ seed[17] ^ seed[20] ^ seed[21] ^ seed[22] ^ seed[23] ^ seed[25] ^ seed[29] ^ seed[31]
		ret[5] = seed[0] ^ seed[1] ^ seed[2] ^ seed[4] ^ seed[6] ^ seed[7] ^ seed[9] ^ seed[10] ^ seed[12] ^ seed[13] ^ seed[15] ^ seed[16] ^ seed[17] ^ seed[18] ^ seed[21] ^ seed[23] ^ seed[24] ^ seed[26] ^ seed[30]
		ret[6] = seed[1] ^ seed[2] ^ seed[3] ^ seed[5] ^ seed[7] ^ seed[8] ^ seed[10] ^ seed[11] ^ seed[13] ^ seed[14] ^ seed[16] ^ seed[17] ^ seed[18] ^ seed[19] ^ seed[22] ^ seed[24] ^ seed[25] ^ seed[27] ^ seed[31]
		ret[7] = seed[0] ^ seed[1] ^ seed[3] ^ seed[4] ^ seed[6] ^ seed[8] ^ seed[9] ^ seed[11] ^ seed[12] ^ seed[14] ^ seed[15] ^ seed[17] ^ seed[18] ^ seed[19] ^ seed[20] ^ seed[22] ^ seed[23] ^ seed[25] ^ seed[26] ^ seed[28]
		ret[8] = seed[1] ^ seed[2] ^ seed[4] ^ seed[5] ^ seed[7] ^ seed[9] ^ seed[10] ^ seed[12] ^ seed[13] ^ seed[15] ^ seed[16] ^ seed[18] ^ seed[19] ^ seed[20] ^ seed[21] ^ seed[23] ^ seed[24] ^ seed[26] ^ seed[27] ^ seed[29]
		ret[9] = seed[2] ^ seed[3] ^ seed[5] ^ seed[6] ^ seed[8] ^ seed[10] ^ seed[11] ^ seed[13] ^ seed[14] ^ seed[16] ^ seed[17] ^ seed[19] ^ seed[20] ^ seed[21] ^ seed[22] ^ seed[24] ^ seed[25] ^ seed[27] ^ seed[28] ^ seed[30]
		ret[10] = seed[3] ^ seed[4] ^ seed[6] ^ seed[7] ^ seed[9] ^ seed[11] ^ seed[12] ^ seed[14] ^ seed[15] ^ seed[17] ^ seed[18] ^ seed[20] ^ seed[21] ^ seed[22] ^ seed[23] ^ seed[25] ^ seed[26] ^ seed[28] ^ seed[29] ^ seed[31]
		ret[11] = seed[0] ^ seed[1] ^ seed[2] ^ seed[4] ^ seed[5] ^ seed[7] ^ seed[8] ^ seed[10] ^ seed[12] ^ seed[13] ^ seed[15] ^ seed[16] ^ seed[18] ^ seed[19] ^ seed[21] ^ seed[23] ^ seed[24] ^ seed[26] ^ seed[27] ^ seed[29] ^ seed[30]
		ret[12] = seed[1] ^ seed[2] ^ seed[3] ^ seed[5] ^ seed[6] ^ seed[8] ^ seed[9] ^ seed[11] ^ seed[13] ^ seed[14] ^ seed[16] ^ seed[17] ^ seed[19] ^ seed[20] ^ seed[22] ^ seed[24] ^ seed[25] ^ seed[27] ^ seed[28] ^ seed[30] ^ seed[31]
		ret[13] = seed[0] ^ seed[1] ^ seed[3] ^ seed[4] ^ seed[6] ^ seed[7] ^ seed[9] ^ seed[10] ^ seed[12] ^ seed[14] ^ seed[15] ^ seed[17] ^ seed[18] ^ seed[20] ^ seed[21] ^ seed[22] ^ seed[23] ^ seed[25] ^ seed[26] ^ seed[28] ^ seed[29] ^ seed[31]
		ret[14] = seed[0] ^ seed[4] ^ seed[5] ^ seed[7] ^ seed[8] ^ seed[10] ^ seed[11] ^ seed[13] ^ seed[15] ^ seed[16] ^ seed[18] ^ seed[19] ^ seed[21] ^ seed[23] ^ seed[24] ^ seed[26] ^ seed[27] ^ seed[29] ^ seed[30]
		ret[15] = seed[1] ^ seed[5] ^ seed[6] ^ seed[8] ^ seed[9] ^ seed[11] ^ seed[12] ^ seed[14] ^ seed[16] ^ seed[17] ^ seed[19] ^ seed[20] ^ seed[22] ^ seed[24] ^ seed[25] ^ seed[27] ^ seed[28] ^ seed[30] ^ seed[31]
		ret[16] = seed[0] ^ seed[1] ^ seed[6] ^ seed[7] ^ seed[9] ^ seed[10] ^ seed[12] ^ seed[13] ^ seed[15] ^ seed[17] ^ seed[18] ^ seed[20] ^ seed[21] ^ seed[22] ^ seed[23] ^ seed[25] ^ seed[26] ^ seed[28] ^ seed[29] ^ seed[31]
		ret[17] = seed[0] ^ seed[7] ^ seed[8] ^ seed[10] ^ seed[11] ^ seed[13] ^ seed[14] ^ seed[16] ^ seed[18] ^ seed[19] ^ seed[21] ^ seed[23] ^ seed[24] ^ seed[26] ^ seed[27] ^ seed[29] ^ seed[30]
		ret[18] = seed[1] ^ seed[8] ^ seed[9] ^ seed[11] ^ seed[12] ^ seed[14] ^ seed[15] ^ seed[17] ^ seed[19] ^ seed[20] ^ seed[22] ^ seed[24] ^ seed[25] ^ seed[27] ^ seed[28] ^ seed[30] ^ seed[31]
		ret[19] = seed[0] ^ seed[1] ^ seed[9] ^ seed[10] ^ seed[12] ^ seed[13] ^ seed[15] ^ seed[16] ^ seed[18] ^ seed[20] ^ seed[21] ^ seed[22] ^ seed[23] ^ seed[25] ^ seed[26] ^ seed[28] ^ seed[29] ^ seed[31]
		ret[20] = seed[0] ^ seed[10] ^ seed[11] ^ seed[13] ^ seed[14] ^ seed[16] ^ seed[17] ^ seed[19] ^ seed[21] ^ seed[23] ^ seed[24] ^ seed[26] ^ seed[27] ^ seed[29] ^ seed[30]
		ret[21] = seed[1] ^ seed[11] ^ seed[12] ^ seed[14] ^ seed[15] ^ seed[17] ^ seed[18] ^ seed[20] ^ seed[22] ^ seed[24] ^ seed[25] ^ seed[27] ^ seed[28] ^ seed[30] ^ seed[31]
		ret[22] = seed[0] ^ seed[1] ^ seed[12] ^ seed[13] ^ seed[15] ^ seed[16] ^ seed[18] ^ seed[19] ^ seed[21] ^ seed[22] ^ seed[23] ^ seed[25] ^ seed[26] ^ seed[28] ^ seed[29] ^ seed[31]
		ret[23] = seed[0] ^ seed[13] ^ seed[14] ^ seed[16] ^ seed[17] ^ seed[19] ^ seed[20] ^ seed[23] ^ seed[24] ^ seed[26] ^ seed[27] ^ seed[29] ^ seed[30]
		ret[24] = seed[1] ^ seed[14] ^ seed[15] ^ seed[17] ^ seed[18] ^ seed[20] ^ seed[21] ^ seed[24] ^ seed[25] ^ seed[27] ^ seed[28] ^ seed[30] ^ seed[31]
		ret[25] = seed[0] ^ seed[1] ^ seed[15] ^ seed[16] ^ seed[18] ^ seed[19] ^ seed[21] ^ seed[25] ^ seed[26] ^ seed[28] ^ seed[29] ^ seed[31]
		ret[26] = seed[0] ^ seed[16] ^ seed[17] ^ seed[19] ^ seed[20] ^ seed[26] ^ seed[27] ^ seed[29] ^ seed[30]
		ret[27] = seed[1] ^ seed[17] ^ seed[18] ^ seed[20] ^ seed[21] ^ seed[27] ^ seed[28] ^ seed[30] ^ seed[31]
		ret[28] = seed[0] ^ seed[1] ^ seed[18] ^ seed[19] ^ seed[21] ^ seed[28] ^ seed[29] ^ seed[31]
		ret[29] = seed[0] ^ seed[19] ^ seed[20] ^ seed[29] ^ seed[30]
		ret[30] = seed[1] ^ seed[20] ^ seed[21] ^ seed[30] ^ seed[31]
		ret[31] = seed[0] ^ seed[1] ^ seed[21] ^ seed[31]
		seed = ret
	return ret.value
