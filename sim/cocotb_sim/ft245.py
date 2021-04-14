
"""Driver for FT245 interface on FTDI FT2232H"""

import cocotb
#from cocotb.triggers import *
from cocotb.triggers import RisingEdge, ReadOnly, Lock, FallingEdge, Timer
from cocotb.drivers import BusDriver
from cocotb.result import ReturnValue
from cocotb.binary import BinaryValue

import array
import numpy

class FT245ProtocolError(Exception):
    pass

class FT245(BusDriver):
    """FT2232H FT245 Style Synchornous FIFO Interface
    """
    
    _signals = ["DIN",      # Input side of hardware byte-wide bidirectional FIFO data
                "DOUT",     # Output side of hardware byte-wide bidirectional FIFO data
                "RXFn",     # Output; when low, data available to read by driving RDn low
                "TXEn",     # Output; when low, can write by driving WRn low
                "RDn",      # Input; drive current availabe byte from FIFO to D
                "WRn",      # Input; write current byte on D to transmit FIFO
                #"CLKOUT",  # Output; 60 MHz clock driven from chip, all signals sync'ed to this
                "OEn"]      # Input; when low, data can be driven onto D by driving RDn low
                #"SIWU"]     # Input; Send Immediate / WakeUp signals; tie high if not used

    def __init__(self, entity, name, clock, **kwargs):
        BusDriver.__init__(self, entity, name, clock, **kwargs)

        # Drive some sensible defaults (setimmediatevalue to avoid x asserts)
        self.bus.DOUT.setimmediatevalue(0)
        self.bus.RXFn.setimmediatevalue(1)
        self.bus.TXEn.setimmediatevalue(1)

    @cocotb.coroutine
    def write_four_bytes(self, data, last):

        yield RisingEdge(self.clock)
        self.bus.RXFn <= 0
        self.bus.DIN <= int(data & 0xFF)

        while True:
            yield ReadOnly()
            if self.bus.RDn.value == 0:
                break
            yield FallingEdge(self.clock)

        yield RisingEdge(self.clock)
        self.bus.DIN <= int((data >> 8) & 0xFF)

        yield RisingEdge(self.clock)
        self.bus.DIN <= int((data >> 16) & 0xFF)

        yield RisingEdge(self.clock)
        self.bus.DIN <= int((data >> 24) & 0xFF)

        if last is True:
            yield RisingEdge(self.clock)
            self.bus.RXFn <= 1

    @cocotb.coroutine
    def send_command(self, data):
        totNumWords = len(data)
        numWords = 0
        last = 0
        
        for word in data:
            numWords = numWords + 1
            if numWords == totNumWords:
                last = True;
            yield self.write_four_bytes(word, last)

    @cocotb.coroutine
    def read_bytes(self, numBytes):
        data = numpy.zeros(int(numBytes/4), dtype=numpy.uint32)

        yield RisingEdge(self.clock)
        self.bus.TXEn <= 0

        while True:
            yield ReadOnly()
            if self.bus.WRn.value == 0:
                break
            yield RisingEdge(self.clock)

        for byte in range(numBytes):
            #print("DOUT " + (hex(self.bus.DOUT.value)))
            yield RisingEdge(self.clock)
            data[int(byte/4)] |= (self.bus.DOUT.value << (8 * (byte % 4)))
            if self.bus.WRn.value == 1:
                raise FT245ProtocolError("WRn deasserted during read_bytes routine at byte %d" %
                               (byte))

        self.bus.TXEn <= 1
        yield RisingEdge(self.clock)

        return data
