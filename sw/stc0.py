"""
@file stc0.py
"""

from abc import *

import numpy
import re
import sys
import random

class stc0():
    #__metaclass__ = ABCMeta

    HW_LASTWORD = 0xABCD
    HW_LASTWORD_LN = 16
    HW_WRITE = 0x01
    HW_WRITE_LN = 8
    HW_CMDH = 7
    HW_CMDL = 0
    HW_CMDADDRH = 31
    HW_CMDADDRL = 8
    HW_RMH = 21
    HW_RML = 14
    HW_RAH = 5
    HW_RAL = 2

    HW_RM_CTRL = 0x01
    HW_RM_CTRL_LN = 8

    HW_RM_XYINGRESS = 0x03
    HW_RM_XYINGRESS_LN = 8

    HW_RA_CTRL_MUXCTRL = 0x01
    HW_RA_CTRL_MUXCTRL_LN = 8
    HW_RA_CTRL_LFSRS_CTRL = 0x02
    HW_RA_CTRL_LFSRS_STRIDE = 0x03
    HW_RA_CTRL_LFSRS_ITERATIONS = 0x04
    HW_RA_CTRL_LFSRX_SEED = 0x05
    HW_RA_CTRL_LFSRY_SEED = 0x06
    HW_RA_CTRL_CTRLWORD = 0x7

    HW_RA_CTRL_CTRL0 = 0x0
    HW_RA_CTRL_CTRL0_LN = 4
    HW_RA_CTRL_CTRL1 = 0x1
    HW_RA_CTRL_CTRL1_LN = 4
    HW_RA_CTRL_STAT0 = 0x2
    HW_RA_CTRL_STAT0_LN = 4
    HW_RA_CTRL_STAT1 = 0x3
    HW_RA_CTRL_STAT1_LN = 4
    HW_RA_CTRL_XINGRESS = 0x8
    HW_RA_CTRL_XINGRESS_LN = 4
    HW_RA_CTRL_YINGRESS = 0x9
    HW_RA_CTRL_YINGRESS_LN = 4
    HW_RA_CTRL_BFP = 0xA
    HW_RA_CTRL_BFP_LN = 4

    HW_RA_BFP_CTRL0 = 0x00
    HW_RA_BFP_CTRL0_LN = 8
    HW_RA_BFP_STAT0 = 0x04
    HW_RA_BFP_STAT0_LN = 8

    HW_RB_LFSRCTRL_ENABLE = 0x0
    HW_RB_LFSRCTRL_ITERSRC = 0x1
    HW_RB_LFSRCTRL_STRIDE = 0x100
    HW_RB_LFSRCTRL_ITERS = 0x10000

    HW_FA_CTRL_CTRLWORD = (HW_RM_CTRL << HW_RML) | (HW_RA_CTRL_CTRLWORD << HW_RAL)
    HW_CTRL_BF0 = 0
    HW_CTRL_ES = 13
    HW_CTRLWRD_SZ = 10
    HW_RB_CTRL_ADDR = 28
    HW_RB_BFCTRL_SS = 0
    HW_RB_BFCTRL_BFBYPASS = 4
    HW_RB_BFCTRL_BFBYPASSX = 5
    # 0: auto
    # 1: C data
    # 2: D data
    HW_RB_EGRESSCTRL_OUTPUTMUX = 0
    # 0: C,D reg1 cannot be written
    HW_RB_EGRESSCTRL_OUTPUTEN = 2
    # 0: use CRC output
    # 1: bypass CRC
    HW_RB_EGRESSCTRL_CRCBYPASS = 3
    #HW_RB_BFPCTRL_TMUXUSRVAL = 2
    #HW_RB_BFPCTRL_TMUXUSRCTRL = 3
    HW_RB_BFCTRL_TWRD = 6
    HW_RB_BFCTRL_TWWR = 7
    # 0,2: Twiddle RAM
    # 1: 1
    # 3: static value
    HW_RB_BFCTRL_TWMUXCTRL = 8
    #HW_RB_BFPCTRL_SRAM_CLR = 8
    #HW_RB_BFPCTRL_DISABLE_OUT = 9


    @abstractmethod
    def init(self):
        pass

    def genVerilogAddrMap(self, filename):

        with open(filename, "w") as vhFile:
            for attr in dir(self):
                hwMatch = re.match("^HW_.*$(?<!_LN$)", attr)

                if hwMatch:
                    try:
                        size = getattr(self, attr + "_LN")
                        vhFile.write("`define " + attr[3:].ljust(35) + " " + str(size) + "'h" + hex(getattr(self, attr))[2:].zfill(int(size/4)).upper() + "\n")
                    except:
                        vhFile.write("`define " + attr[3:].ljust(35) + " " + str(getattr(self, attr)) + "\n")

    def gen_twiddle(self):
        """TODO: Docstring for gen_twiddle.
        :returns: TODO

        """
        x = numpy.arange(self.FFT_LENGTH / 2)
        y = numpy.exp(-1j * x * 2. * numpy.pi / self.FFT_LENGTH)
        return y

    def toHex(self, value, nbits):
        if (value < int(2**(nbits-1))) and (value >= int(-2**(nbits-1))):
            return hex(value & (2**nbits - 1))[2:].zfill(nbits/4)
        else:
            raise Exception("Two's complement number of " + str(nbits) + " bits cannot represent value " + str(value))
