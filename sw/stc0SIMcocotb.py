"""
@file stc0SIMcocotb.py
"""

import numpy
#import ftdi1 as ftdi
import re
import sys
import cocotb
from cocotb.triggers import *
from cocotb.result import TestFailure
from cocotb.clock import Clock
import random
from hk import *
from lfsr32 import *
from stc0 import *

class stc0SIMcocotb(stc0):

    def __init__(self, dut, CLK_PERIOD_NS=10):
        self.hk = hkSIMcocotb(dut, CLK_PERIOD_NS)
        #super(stc0SIMcocotb,self).__init__(fftLength=fftLength)

    def init(self):
        pass

    @cocotb.coroutine
    def configAndStartLFSRs(self, stride, iterations, iterationsSrcCount, lfsrXSeed, lfsrYSeed):
        """TODO: Docstring for configAndStartLFSRs.

        :arg1: TODO
        :returns: TODO

        """
        yield self.hk.send_write_command(0x1, (self.HW_RM_CTRL << self.HW_RML) | (self.HW_RA_CTRL_MUXCTRL << self.HW_RAL), [0x1])
        yield self.hk.send_write_command(0x1, (self.HW_RM_CTRL << self.HW_RML) | (self.HW_RA_CTRL_LFSRS_STRIDE << self.HW_RAL), [stride])
        yield self.hk.send_write_command(0x1, (self.HW_RM_CTRL << self.HW_RML) | (self.HW_RA_CTRL_LFSRS_ITERATIONS << self.HW_RAL), [iterations])
        yield self.hk.send_write_command(0x1, (self.HW_RM_CTRL << self.HW_RML) | (self.HW_RA_CTRL_LFSRX_SEED << self.HW_RAL), [lfsrXSeed])
        yield self.hk.send_write_command(0x1, (self.HW_RM_CTRL << self.HW_RML) | (self.HW_RA_CTRL_LFSRY_SEED << self.HW_RAL), [lfsrYSeed])
        yield self.hk.send_write_command(0x1, (self.HW_RM_CTRL << self.HW_RML) | (self.HW_RA_CTRL_LFSRS_CTRL << self.HW_RAL), [(0x1 << self.HW_RB_LFSRCTRL_ENABLE) | (iterationsSrcCount << self.HW_RB_LFSRCTRL_ITERSRC)])

    @cocotb.coroutine
    def disableLFSRs(self):
        yield self.hk.send_write_command(0x1, (self.HW_RM_CTRL << self.HW_RML) | (self.HW_RA_CTRL_LFSRS_CTRL << self.HW_RAL), [(0x0 << self.HW_RB_LFSRCTRL_ENABLE)])
