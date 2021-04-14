"""
@file hk.py
"""
from abc import *
#import ftdi1 as ftdi
import re
import sys
import numpy

import cocotb
#from cocotb.triggers import Timer
from cocotb.triggers import *
from cocotb.result import TestFailure
from cocotb.clock import Clock
import random
from ft245 import FT245

class hk():
    __metaclass__ = ABCMeta

    HW_LASTWORD = 0xABCD
    HW_LASTWORD_LN = 16
    HW_HK_WRITE = 0x81
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

    HW_ADDR_LEDS = 1
    HW_ADDR_SFFWRSRC = 2
    HW_ADDR_SFFRB_NUMBYTES = 3
    HW_ADDR_SFFRB_TIMEOUT = 4

    HW_SFFWRSRC_INGRESS = 0
    HW_SFFWRSRC_LOOPBACK = 1
    HW_SFFWRSRC_DIRECT = 2

    @abstractmethod
    def init(self):
        pass

    @abstractmethod
    def reset(self):
        pass

    @abstractmethod
    def send_command(self):
        pass

    @abstractmethod
    def send_write_command(self, command, address, data):
        pass

    
class hkHW(hk):

    def init(self):
        pass

    def reset(self):
        pass

    def send_command(self):
        pass

class hkSIMcocotb(hk):

    def __init__(self, dut, clk_period_ns):
        self.ft245m = FT245(dut, "", dut.Clk)
        self.CLK_PERIOD_NS = clk_period_ns
        self.dut = dut

    @cocotb.coroutine
    def reset(self):
        self.dut.ARst <= 1
        yield Timer(self.CLK_PERIOD_NS * 5, units='ns')
        self.dut.ARst <= 0
        #yield self.ft245m.write_four_bytes(0xDEADC0DE, True)

    @cocotb.coroutine
    def set_sfifoWrSrc(self, source):
        yield self.send_write_command(self.HW_HK_WRITE, self.HW_ADDR_SFFWRSRC, [source])

    @cocotb.coroutine
    def send_write_command(self, command, address, data):
        #cmdWrd = (self.HW_WRITE << self.HW_CMDL) | (address << self.HW_CMDADDRL)
        cmdWrd = (command << self.HW_CMDL) | (address << self.HW_CMDADDRL)
        lenWrd = len(data)
        endWrd = self.HW_LASTWORD << 16

        yield self.send_command(numpy.concatenate([[cmdWrd, lenWrd], data, [endWrd]]))

    @cocotb.coroutine
    def send_command(self, data):
        yield self.ft245m.send_command(data)
        #yield self.ft245m.write_four_bytes(0xDEADC0DE, True)
        
