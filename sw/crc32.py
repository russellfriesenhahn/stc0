# vim: ts=8 sw=8 noexpandtab

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

# CRC polynomial coefficients: x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
#                              0xEDB88320 (hex)
# CRC width:                   32 bits
# CRC shift direction:         right

def crc32(crcIn, data):
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
	crcIn = bitwrapper(crcIn)
	data = bitwrapper(data)
	ret = bitwrapper(0)
	ret[0] = (crcIn[0] ^ crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[16] ^ crcIn[20] ^ crcIn[22] ^ crcIn[23] ^ crcIn[26] ^ data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[6] ^ data[7] ^ data[8] ^ data[16] ^ data[20] ^ data[22] ^ data[23] ^ data[26])
	ret[1] = (crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[17] ^ crcIn[21] ^ crcIn[23] ^ crcIn[24] ^ crcIn[27] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[7] ^ data[8] ^ data[9] ^ data[17] ^ data[21] ^ data[23] ^ data[24] ^ data[27])
	ret[2] = (crcIn[0] ^ crcIn[2] ^ crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ crcIn[8] ^ crcIn[9] ^ crcIn[10] ^ crcIn[18] ^ crcIn[22] ^ crcIn[24] ^ crcIn[25] ^ crcIn[28] ^ data[0] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[8] ^ data[9] ^ data[10] ^ data[18] ^ data[22] ^ data[24] ^ data[25] ^ data[28])
	ret[3] = (crcIn[1] ^ crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[9] ^ crcIn[10] ^ crcIn[11] ^ crcIn[19] ^ crcIn[23] ^ crcIn[25] ^ crcIn[26] ^ crcIn[29] ^ data[1] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7] ^ data[9] ^ data[10] ^ data[11] ^ data[19] ^ data[23] ^ data[25] ^ data[26] ^ data[29])
	ret[4] = (crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[10] ^ crcIn[11] ^ crcIn[12] ^ crcIn[20] ^ crcIn[24] ^ crcIn[26] ^ crcIn[27] ^ crcIn[30] ^ data[2] ^ data[4] ^ data[5] ^ data[6] ^ data[7] ^ data[8] ^ data[10] ^ data[11] ^ data[12] ^ data[20] ^ data[24] ^ data[26] ^ data[27] ^ data[30])
	ret[5] = (crcIn[0] ^ crcIn[3] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[11] ^ crcIn[12] ^ crcIn[13] ^ crcIn[21] ^ crcIn[25] ^ crcIn[27] ^ crcIn[28] ^ crcIn[31] ^ data[0] ^ data[3] ^ data[5] ^ data[6] ^ data[7] ^ data[8] ^ data[9] ^ data[11] ^ data[12] ^ data[13] ^ data[21] ^ data[25] ^ data[27] ^ data[28] ^ data[31])
	ret[6] = (crcIn[0] ^ crcIn[2] ^ crcIn[3] ^ crcIn[9] ^ crcIn[10] ^ crcIn[12] ^ crcIn[13] ^ crcIn[14] ^ crcIn[16] ^ crcIn[20] ^ crcIn[23] ^ crcIn[28] ^ crcIn[29] ^ data[0] ^ data[2] ^ data[3] ^ data[9] ^ data[10] ^ data[12] ^ data[13] ^ data[14] ^ data[16] ^ data[20] ^ data[23] ^ data[28] ^ data[29])
	ret[7] = (crcIn[1] ^ crcIn[3] ^ crcIn[4] ^ crcIn[10] ^ crcIn[11] ^ crcIn[13] ^ crcIn[14] ^ crcIn[15] ^ crcIn[17] ^ crcIn[21] ^ crcIn[24] ^ crcIn[29] ^ crcIn[30] ^ data[1] ^ data[3] ^ data[4] ^ data[10] ^ data[11] ^ data[13] ^ data[14] ^ data[15] ^ data[17] ^ data[21] ^ data[24] ^ data[29] ^ data[30])
	ret[8] = (crcIn[0] ^ crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[11] ^ crcIn[12] ^ crcIn[14] ^ crcIn[15] ^ crcIn[16] ^ crcIn[18] ^ crcIn[22] ^ crcIn[25] ^ crcIn[30] ^ crcIn[31] ^ data[0] ^ data[2] ^ data[4] ^ data[5] ^ data[11] ^ data[12] ^ data[14] ^ data[15] ^ data[16] ^ data[18] ^ data[22] ^ data[25] ^ data[30] ^ data[31])
	ret[9] = (crcIn[0] ^ crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ crcIn[8] ^ crcIn[12] ^ crcIn[13] ^ crcIn[15] ^ crcIn[17] ^ crcIn[19] ^ crcIn[20] ^ crcIn[22] ^ crcIn[31] ^ data[0] ^ data[2] ^ data[4] ^ data[5] ^ data[7] ^ data[8] ^ data[12] ^ data[13] ^ data[15] ^ data[17] ^ data[19] ^ data[20] ^ data[22] ^ data[31])
	ret[10] = (crcIn[0] ^ crcIn[2] ^ crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ crcIn[9] ^ crcIn[13] ^ crcIn[14] ^ crcIn[18] ^ crcIn[21] ^ crcIn[22] ^ crcIn[26] ^ data[0] ^ data[2] ^ data[4] ^ data[5] ^ data[7] ^ data[9] ^ data[13] ^ data[14] ^ data[18] ^ data[21] ^ data[22] ^ data[26])
	ret[11] = (crcIn[1] ^ crcIn[3] ^ crcIn[5] ^ crcIn[6] ^ crcIn[8] ^ crcIn[10] ^ crcIn[14] ^ crcIn[15] ^ crcIn[19] ^ crcIn[22] ^ crcIn[23] ^ crcIn[27] ^ data[1] ^ data[3] ^ data[5] ^ data[6] ^ data[8] ^ data[10] ^ data[14] ^ data[15] ^ data[19] ^ data[22] ^ data[23] ^ data[27])
	ret[12] = (crcIn[2] ^ crcIn[4] ^ crcIn[6] ^ crcIn[7] ^ crcIn[9] ^ crcIn[11] ^ crcIn[15] ^ crcIn[16] ^ crcIn[20] ^ crcIn[23] ^ crcIn[24] ^ crcIn[28] ^ data[2] ^ data[4] ^ data[6] ^ data[7] ^ data[9] ^ data[11] ^ data[15] ^ data[16] ^ data[20] ^ data[23] ^ data[24] ^ data[28])
	ret[13] = (crcIn[0] ^ crcIn[3] ^ crcIn[5] ^ crcIn[7] ^ crcIn[8] ^ crcIn[10] ^ crcIn[12] ^ crcIn[16] ^ crcIn[17] ^ crcIn[21] ^ crcIn[24] ^ crcIn[25] ^ crcIn[29] ^ data[0] ^ data[3] ^ data[5] ^ data[7] ^ data[8] ^ data[10] ^ data[12] ^ data[16] ^ data[17] ^ data[21] ^ data[24] ^ data[25] ^ data[29])
	ret[14] = (crcIn[0] ^ crcIn[1] ^ crcIn[4] ^ crcIn[6] ^ crcIn[8] ^ crcIn[9] ^ crcIn[11] ^ crcIn[13] ^ crcIn[17] ^ crcIn[18] ^ crcIn[22] ^ crcIn[25] ^ crcIn[26] ^ crcIn[30] ^ data[0] ^ data[1] ^ data[4] ^ data[6] ^ data[8] ^ data[9] ^ data[11] ^ data[13] ^ data[17] ^ data[18] ^ data[22] ^ data[25] ^ data[26] ^ data[30])
	ret[15] = (crcIn[1] ^ crcIn[2] ^ crcIn[5] ^ crcIn[7] ^ crcIn[9] ^ crcIn[10] ^ crcIn[12] ^ crcIn[14] ^ crcIn[18] ^ crcIn[19] ^ crcIn[23] ^ crcIn[26] ^ crcIn[27] ^ crcIn[31] ^ data[1] ^ data[2] ^ data[5] ^ data[7] ^ data[9] ^ data[10] ^ data[12] ^ data[14] ^ data[18] ^ data[19] ^ data[23] ^ data[26] ^ data[27] ^ data[31])
	ret[16] = (crcIn[1] ^ crcIn[4] ^ crcIn[7] ^ crcIn[10] ^ crcIn[11] ^ crcIn[13] ^ crcIn[15] ^ crcIn[16] ^ crcIn[19] ^ crcIn[22] ^ crcIn[23] ^ crcIn[24] ^ crcIn[26] ^ crcIn[27] ^ crcIn[28] ^ data[1] ^ data[4] ^ data[7] ^ data[10] ^ data[11] ^ data[13] ^ data[15] ^ data[16] ^ data[19] ^ data[22] ^ data[23] ^ data[24] ^ data[26] ^ data[27] ^ data[28])
	ret[17] = (crcIn[2] ^ crcIn[5] ^ crcIn[8] ^ crcIn[11] ^ crcIn[12] ^ crcIn[14] ^ crcIn[16] ^ crcIn[17] ^ crcIn[20] ^ crcIn[23] ^ crcIn[24] ^ crcIn[25] ^ crcIn[27] ^ crcIn[28] ^ crcIn[29] ^ data[2] ^ data[5] ^ data[8] ^ data[11] ^ data[12] ^ data[14] ^ data[16] ^ data[17] ^ data[20] ^ data[23] ^ data[24] ^ data[25] ^ data[27] ^ data[28] ^ data[29])
	ret[18] = (crcIn[0] ^ crcIn[3] ^ crcIn[6] ^ crcIn[9] ^ crcIn[12] ^ crcIn[13] ^ crcIn[15] ^ crcIn[17] ^ crcIn[18] ^ crcIn[21] ^ crcIn[24] ^ crcIn[25] ^ crcIn[26] ^ crcIn[28] ^ crcIn[29] ^ crcIn[30] ^ data[0] ^ data[3] ^ data[6] ^ data[9] ^ data[12] ^ data[13] ^ data[15] ^ data[17] ^ data[18] ^ data[21] ^ data[24] ^ data[25] ^ data[26] ^ data[28] ^ data[29] ^ data[30])
	ret[19] = (crcIn[0] ^ crcIn[1] ^ crcIn[4] ^ crcIn[7] ^ crcIn[10] ^ crcIn[13] ^ crcIn[14] ^ crcIn[16] ^ crcIn[18] ^ crcIn[19] ^ crcIn[22] ^ crcIn[25] ^ crcIn[26] ^ crcIn[27] ^ crcIn[29] ^ crcIn[30] ^ crcIn[31] ^ data[0] ^ data[1] ^ data[4] ^ data[7] ^ data[10] ^ data[13] ^ data[14] ^ data[16] ^ data[18] ^ data[19] ^ data[22] ^ data[25] ^ data[26] ^ data[27] ^ data[29] ^ data[30] ^ data[31])
	ret[20] = (crcIn[0] ^ crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[11] ^ crcIn[14] ^ crcIn[15] ^ crcIn[16] ^ crcIn[17] ^ crcIn[19] ^ crcIn[22] ^ crcIn[27] ^ crcIn[28] ^ crcIn[30] ^ crcIn[31] ^ data[0] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7] ^ data[11] ^ data[14] ^ data[15] ^ data[16] ^ data[17] ^ data[19] ^ data[22] ^ data[27] ^ data[28] ^ data[30] ^ data[31])
	ret[21] = (crcIn[0] ^ crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[12] ^ crcIn[15] ^ crcIn[17] ^ crcIn[18] ^ crcIn[22] ^ crcIn[26] ^ crcIn[28] ^ crcIn[29] ^ crcIn[31] ^ data[0] ^ data[2] ^ data[3] ^ data[5] ^ data[12] ^ data[15] ^ data[17] ^ data[18] ^ data[22] ^ data[26] ^ data[28] ^ data[29] ^ data[31])
	ret[22] = (crcIn[2] ^ crcIn[7] ^ crcIn[8] ^ crcIn[13] ^ crcIn[18] ^ crcIn[19] ^ crcIn[20] ^ crcIn[22] ^ crcIn[26] ^ crcIn[27] ^ crcIn[29] ^ crcIn[30] ^ data[2] ^ data[7] ^ data[8] ^ data[13] ^ data[18] ^ data[19] ^ data[20] ^ data[22] ^ data[26] ^ data[27] ^ data[29] ^ data[30])
	ret[23] = (crcIn[0] ^ crcIn[3] ^ crcIn[8] ^ crcIn[9] ^ crcIn[14] ^ crcIn[19] ^ crcIn[20] ^ crcIn[21] ^ crcIn[23] ^ crcIn[27] ^ crcIn[28] ^ crcIn[30] ^ crcIn[31] ^ data[0] ^ data[3] ^ data[8] ^ data[9] ^ data[14] ^ data[19] ^ data[20] ^ data[21] ^ data[23] ^ data[27] ^ data[28] ^ data[30] ^ data[31])
	ret[24] = (crcIn[2] ^ crcIn[3] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[10] ^ crcIn[15] ^ crcIn[16] ^ crcIn[21] ^ crcIn[23] ^ crcIn[24] ^ crcIn[26] ^ crcIn[28] ^ crcIn[29] ^ crcIn[31] ^ data[2] ^ data[3] ^ data[6] ^ data[7] ^ data[8] ^ data[9] ^ data[10] ^ data[15] ^ data[16] ^ data[21] ^ data[23] ^ data[24] ^ data[26] ^ data[28] ^ data[29] ^ data[31])
	ret[25] = (crcIn[1] ^ crcIn[2] ^ crcIn[6] ^ crcIn[9] ^ crcIn[10] ^ crcIn[11] ^ crcIn[17] ^ crcIn[20] ^ crcIn[23] ^ crcIn[24] ^ crcIn[25] ^ crcIn[26] ^ crcIn[27] ^ crcIn[29] ^ crcIn[30] ^ data[1] ^ data[2] ^ data[6] ^ data[9] ^ data[10] ^ data[11] ^ data[17] ^ data[20] ^ data[23] ^ data[24] ^ data[25] ^ data[26] ^ data[27] ^ data[29] ^ data[30])
	ret[26] = (crcIn[2] ^ crcIn[3] ^ crcIn[7] ^ crcIn[10] ^ crcIn[11] ^ crcIn[12] ^ crcIn[18] ^ crcIn[21] ^ crcIn[24] ^ crcIn[25] ^ crcIn[26] ^ crcIn[27] ^ crcIn[28] ^ crcIn[30] ^ crcIn[31] ^ data[2] ^ data[3] ^ data[7] ^ data[10] ^ data[11] ^ data[12] ^ data[18] ^ data[21] ^ data[24] ^ data[25] ^ data[26] ^ data[27] ^ data[28] ^ data[30] ^ data[31])
	ret[27] = (crcIn[0] ^ crcIn[1] ^ crcIn[2] ^ crcIn[6] ^ crcIn[7] ^ crcIn[11] ^ crcIn[12] ^ crcIn[13] ^ crcIn[16] ^ crcIn[19] ^ crcIn[20] ^ crcIn[23] ^ crcIn[25] ^ crcIn[27] ^ crcIn[28] ^ crcIn[29] ^ crcIn[31] ^ data[0] ^ data[1] ^ data[2] ^ data[6] ^ data[7] ^ data[11] ^ data[12] ^ data[13] ^ data[16] ^ data[19] ^ data[20] ^ data[23] ^ data[25] ^ data[27] ^ data[28] ^ data[29] ^ data[31])
	ret[28] = (crcIn[0] ^ crcIn[4] ^ crcIn[6] ^ crcIn[12] ^ crcIn[13] ^ crcIn[14] ^ crcIn[16] ^ crcIn[17] ^ crcIn[21] ^ crcIn[22] ^ crcIn[23] ^ crcIn[24] ^ crcIn[28] ^ crcIn[29] ^ crcIn[30] ^ data[0] ^ data[4] ^ data[6] ^ data[12] ^ data[13] ^ data[14] ^ data[16] ^ data[17] ^ data[21] ^ data[22] ^ data[23] ^ data[24] ^ data[28] ^ data[29] ^ data[30])
	ret[29] = (crcIn[0] ^ crcIn[1] ^ crcIn[5] ^ crcIn[7] ^ crcIn[13] ^ crcIn[14] ^ crcIn[15] ^ crcIn[17] ^ crcIn[18] ^ crcIn[22] ^ crcIn[23] ^ crcIn[24] ^ crcIn[25] ^ crcIn[29] ^ crcIn[30] ^ crcIn[31] ^ data[0] ^ data[1] ^ data[5] ^ data[7] ^ data[13] ^ data[14] ^ data[15] ^ data[17] ^ data[18] ^ data[22] ^ data[23] ^ data[24] ^ data[25] ^ data[29] ^ data[30] ^ data[31])
	ret[30] = (crcIn[3] ^ crcIn[4] ^ crcIn[7] ^ crcIn[14] ^ crcIn[15] ^ crcIn[18] ^ crcIn[19] ^ crcIn[20] ^ crcIn[22] ^ crcIn[24] ^ crcIn[25] ^ crcIn[30] ^ crcIn[31] ^ data[3] ^ data[4] ^ data[7] ^ data[14] ^ data[15] ^ data[18] ^ data[19] ^ data[20] ^ data[22] ^ data[24] ^ data[25] ^ data[30] ^ data[31])
	ret[31] = (crcIn[0] ^ crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[15] ^ crcIn[19] ^ crcIn[21] ^ crcIn[22] ^ crcIn[25] ^ crcIn[31] ^ data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[5] ^ data[6] ^ data[7] ^ data[15] ^ data[19] ^ data[21] ^ data[22] ^ data[25] ^ data[31])
	return ret.value
