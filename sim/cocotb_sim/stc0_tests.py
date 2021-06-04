# Simple tests for an adder module
import cocotb
#from cocotb.triggers import Timer
from cocotb.triggers import *
from cocotb.result import TestFailure
from cocotb.clock import Clock
import random
from ft245 import FT245
import numpy
import sys
sys.path.append("../../sw")
sys.path.append("../../modules/housekeeper/sw")
from hk import *
from stc0 import *
from stc0SIMcocotb import *
from lfsr32 import *
from crc32 import *

async def reset_dut(reset_n, duration_ns):
    reset_n <= 1
    await Timer(duration_ns, units='ns')
    reset_n <= 0
    reset_n._log.debug("Reset complete")

CLK_PERIOD_NS = 10
def setup_dut(dut):
    cocotb.fork(Clock(dut.Clk, CLK_PERIOD_NS, units='ns').start())

@cocotb.test(skip = False)
def stc0_load_tw(dut):
    """
        This test loads the Twiddle RAM up with LFSRY data, then reads it back
        out verifying the ability to load and read the Twiddle factors.
    """


    numpy.set_printoptions(formatter={'int':lambda x:hex(int(x))})
    dut.ARst <= 1
    stc0 = stc0SIMcocotb(dut, CLK_PERIOD_NS)
    cocotb.fork(Clock(dut.Clk, CLK_PERIOD_NS, units='ns').start())
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.ARst <= 0
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    yield stc0.hk.reset()

    patternLength = 512
    seedValA = 0x1
    seedValB = 0x2
    crcValA = 0x0
    crcValB = 0x0
    yield stc0.hk.set_sfifoWrSrc(hk.HW_SFFWRSRC_INGRESS)
    bf0Ctrl = (stc0.HW_CTRL_BF0 << stc0.HW_RB_CTRL_ADDR) | (0x1 << stc0.HW_RB_BFCTRL_TWWR)
    yield stc0.hk.send_write_command(0x1, stc0.HW_FA_CTRL_CTRLWORD, [bf0Ctrl])
    esCtrl = (stc0.HW_CTRL_ES << stc0.HW_RB_CTRL_ADDR) | (0x0 << stc0.HW_RB_EGRESSCTRL_OUTPUTEN) | (0x1 << stc0.HW_RB_EGRESSCTRL_CRCBYPASS)|(0x2 << stc0.HW_RB_EGRESSCTRL_OUTPUTMUX)
    #yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_CTRLWORD << stc0.HW_RAL), [esCtrl])
    yield stc0.hk.send_write_command(0x1, stc0.HW_FA_CTRL_CTRLWORD, [esCtrl])
    yield stc0.configAndStartLFSRs(0x1, patternLength, 0x0, 0x1, 0x2)
    yield Timer(CLK_PERIOD_NS * 1050, units='ns')
    print(hex(bf0Ctrl))
    bf0Ctrl ^= (0x1 << stc0.HW_RB_BFCTRL_TWWR)
    print(hex(bf0Ctrl))
    bf0Ctrl |= (0x1 << stc0.HW_RB_BFCTRL_TWRD)
    print(hex(bf0Ctrl))
    yield stc0.hk.send_write_command(0x1, stc0.HW_FA_CTRL_CTRLWORD, [bf0Ctrl])
    esCtrl |= (0x1 << stc0.HW_RB_EGRESSCTRL_OUTPUTEN)
    esCtrl |= (0x2 << stc0.HW_RB_EGRESSCTRL_OUTPUTMUX)
    yield stc0.hk.send_write_command(0x1, stc0.HW_FA_CTRL_CTRLWORD, [esCtrl])
    yield stc0.configAndStartLFSRs(0x4, patternLength, 0x0, 0x0, 0x0)
    yield Timer(CLK_PERIOD_NS * 530 * 4, units='ns')
    #yield Timer(CLK_PERIOD_NS * 30, units='ns')
    yield stc0.hk.send_write_command(stc0.hk.HW_HK_WRITE, stc0.hk.HW_ADDR_SFFRB_NUMBYTES, [patternLength*4])
    yield Timer(CLK_PERIOD_NS * 5, units='ns')
    a = yield stc0.hk.ft245m.read_bytes(patternLength*4)
    yield Timer(CLK_PERIOD_NS * 40, units='ns')

    data = numpy.arange(patternLength)
    for i in range(0,patternLength):
        data[i] = seedValB
        crcValB = crc32(crcValB, seedValB)
        seedValB = lfsr32(seedValB, 1)

    #print(data)
    #print(a)
    print("crcA is " + hex(crcValA))
    print("crcB is " + hex(crcValB))
    if numpy.array_equal(data, a) is False:
        # Fail
        raise TestFailure("Readback data does not match")

@cocotb.test(skip = False)
def stc0_both_crc_test(dut):
    """Verify CRC operations.

    The LFSRs' data goes to the CRC blocks. Only the two final CRC values
    are transmitted from the DUT for comparison
    """

    numpy.set_printoptions(formatter={'int':lambda x:hex(int(x))})
    dut.ARst <= 1
    stc0 = stc0SIMcocotb(dut, CLK_PERIOD_NS)
    cocotb.fork(Clock(dut.Clk, CLK_PERIOD_NS, units='ns').start())
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.ARst <= 0
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    yield stc0.hk.reset()

    seedValA = 0x1
    seedValB = 0x2
    crcValA = 0x0
    crcValB = 0x0
    yield stc0.hk.set_sfifoWrSrc(hk.HW_SFFWRSRC_INGRESS)
    yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_CTRLWORD << stc0.HW_RAL), [(stc0.HW_CTRL_BF0 << stc0.HW_RB_CTRL_ADDR) | (0x1 << stc0.HW_RB_BFCTRL_BFBYPASS)])
    yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_CTRLWORD << stc0.HW_RAL), [(stc0.HW_CTRL_ES << stc0.HW_RB_CTRL_ADDR) | (0x0 << stc0.HW_RB_EGRESSCTRL_OUTPUTEN) | (0x0 << stc0.HW_RB_EGRESSCTRL_CRCBYPASS)|(0x0 << stc0.HW_RB_EGRESSCTRL_OUTPUTMUX) ])
    yield stc0.configAndStartLFSRs(0x1, 0x10, 0x0, 0x1, 0x2)
    yield Timer(CLK_PERIOD_NS * 30, units='ns')
    yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_CTRLWORD << stc0.HW_RAL), [(stc0.HW_CTRL_ES << stc0.HW_RB_CTRL_ADDR) | (0x1 << stc0.HW_RB_EGRESSCTRL_OUTPUTEN) | (0x0 << stc0.HW_RB_EGRESSCTRL_CRCBYPASS)|(0x0 << stc0.HW_RB_EGRESSCTRL_OUTPUTMUX) ])
    yield stc0.hk.send_write_command(stc0.hk.HW_HK_WRITE, stc0.hk.HW_ADDR_SFFRB_NUMBYTES, [8])
    yield Timer(CLK_PERIOD_NS * 5, units='ns')
    a = yield stc0.hk.ft245m.read_bytes(8)
    yield Timer(CLK_PERIOD_NS * 40, units='ns')

    data = numpy.arange(32)
    for i in range(0,32,2):
        data[i] = seedValA
        data[i+1] = seedValB
        crcValA = crc32(crcValA, seedValA)
        seedValA = lfsr32(seedValA, 1)
        crcValB = crc32(crcValB, seedValB)
        seedValB = lfsr32(seedValB, 1)

    print(a)
    print("crcA is " + hex(crcValA))
    print("crcB is " + hex(crcValB))
    if numpy.array_equal([crcValA,crcValB], a) is False:
        # Fail
        raise TestFailure("Readback data does not match")

@cocotb.test(skip = False)
def stc0_both_lfsr_test(dut):
    """Verifies both LFSRs and transmitting data from both streams.

    The LFSRs are run and LFSR values are streamed out for comparison.
    Due to the egress setup, the LFSR values are interleaved.
    """

    numpy.set_printoptions(formatter={'int':lambda x:hex(int(x))})
    dut.ARst <= 1
    stc0 = stc0SIMcocotb(dut, CLK_PERIOD_NS)
    cocotb.fork(Clock(dut.Clk, CLK_PERIOD_NS, units='ns').start())
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.ARst <= 0
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    yield stc0.hk.reset()

    seedValA = 0x1
    seedValB = 0x2
    yield stc0.hk.set_sfifoWrSrc(hk.HW_SFFWRSRC_INGRESS)
    yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_CTRLWORD << stc0.HW_RAL), [(stc0.HW_CTRL_BF0 << stc0.HW_RB_CTRL_ADDR) | (0x1 << stc0.HW_RB_BFCTRL_BFBYPASS)])
    yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_CTRLWORD << stc0.HW_RAL), [(stc0.HW_CTRL_ES << stc0.HW_RB_CTRL_ADDR) | (0x1 << stc0.HW_RB_EGRESSCTRL_OUTPUTEN) | (0x1 << stc0.HW_RB_EGRESSCTRL_CRCBYPASS)|(0x0 << stc0.HW_RB_EGRESSCTRL_OUTPUTMUX) ])
    yield stc0.configAndStartLFSRs(0x8, 0x10, 0x0, 0x1, 0x2)
    yield stc0.hk.send_write_command(stc0.hk.HW_HK_WRITE, stc0.hk.HW_ADDR_SFFRB_NUMBYTES, [128])
    yield Timer(CLK_PERIOD_NS * 5, units='ns')
    a = yield stc0.hk.ft245m.read_bytes(128)
    yield Timer(CLK_PERIOD_NS * 40, units='ns')

    data = numpy.arange(32)
    for i in range(0,32,2):
        data[i] = seedValA
        data[i+1] = seedValB
        seedValA = lfsr32(seedValA, 1)
        seedValB = lfsr32(seedValB, 1)
    print(data)
    print(a)
    if numpy.array_equal(data, a) is False:
        # Fail
        raise TestFailure("Readback data does not match")

@cocotb.test(skip = False)
def stc0_lfsr_test(dut):
    """Verifies basic LFSR X operation.

    The LFSR is run and LFSR values are streamed out for comparison.
    """

    numpy.set_printoptions(formatter={'int':lambda x:hex(int(x))})
    dut.ARst <= 1
    stc0 = stc0SIMcocotb(dut, CLK_PERIOD_NS)
    cocotb.fork(Clock(dut.Clk, CLK_PERIOD_NS, units='ns').start())
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.ARst <= 0
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    yield stc0.hk.reset()

    seedVal = 0x1
    yield stc0.hk.set_sfifoWrSrc(hk.HW_SFFWRSRC_INGRESS)
    yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_CTRLWORD << stc0.HW_RAL), [(stc0.HW_CTRL_BF0 << stc0.HW_RB_CTRL_ADDR) | (0x1 << stc0.HW_RB_BFCTRL_BFBYPASS)])
    yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_CTRLWORD << stc0.HW_RAL), [(stc0.HW_CTRL_ES << stc0.HW_RB_CTRL_ADDR) | (0x1 << stc0.HW_RB_EGRESSCTRL_OUTPUTEN) | (0x1 << stc0.HW_RB_EGRESSCTRL_CRCBYPASS)|(0x1 << stc0.HW_RB_EGRESSCTRL_OUTPUTMUX) ])
    yield stc0.configAndStartLFSRs(0x4, 0x10, 0x0, 0x1, 0x1)
    #yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_MUXCTRL << stc0.HW_RAL), [0x1])
    #yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_LFSRS_STRIDE << stc0.HW_RAL), [0x3])
    #yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_LFSRS_ITERATIONS << stc0.HW_RAL), [0x10])
    #yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_LFSRX_SEED << stc0.HW_RAL), [seedVal])
    #yield stc0.hk.send_write_command(0x1, (stc0.HW_RM_CTRL << stc0.HW_RML) | (stc0.HW_RA_CTRL_LFSRS_CTRL << stc0.HW_RAL), [0x1])
    yield stc0.hk.send_write_command(stc0.hk.HW_HK_WRITE, stc0.hk.HW_ADDR_SFFRB_NUMBYTES, [64])
    yield Timer(CLK_PERIOD_NS * 5, units='ns')
    a = yield stc0.hk.ft245m.read_bytes(64)
    yield Timer(CLK_PERIOD_NS * 30, units='ns')

    data = numpy.arange(16)
    for i in range(16):
        data[i] = seedVal
        seedVal = lfsr32(seedVal, 1)
    print(data)
    print(a)
    if numpy.array_equal(data, a) is False:
        # Fail
        raise TestFailure("Readback data does not match")

# Test the stc0 simulation class
# This test no longer works because it expects the output of the HK FPGA to be
# looped back
@cocotb.test(skip = True)
def stc0_basic_test(dut):
    """Tests Housekeeper sending and receiving data.

    This test requires an external loopback which is no longer present
    due to the actual DUT wired up to the Housekeeper FPGA
    """

    dut.ARst <= 1
    stc0 = stc0SIMcocotb(dut, CLK_PERIOD_NS)
    cocotb.fork(Clock(dut.Clk, CLK_PERIOD_NS, units='ns').start())
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.ARst <= 0
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    yield stc0.hk.reset()

    data = numpy.arange(10)
    data[0] = 0xA5B6C7D8
    data[8] = 0x12345678
    data[9] = 0xDEADC0DE

    yield stc0.hk.set_sfifoWrSrc(hk.HW_SFFWRSRC_INGRESS)
    yield stc0.hk.send_write_command(0x1, 0x1, data)
    yield Timer(CLK_PERIOD_NS * 20, units='ns')
    yield stc0.hk.send_write_command(stc0.hk.HW_HK_WRITE, stc0.hk.HW_ADDR_SFFRB_NUMBYTES, [40])
    yield Timer(CLK_PERIOD_NS * 5, units='ns')
    a = yield stc0.hk.ft245m.read_bytes(40)

    numpy.set_printoptions(formatter={'int':lambda x:hex(int(x))})

    print(data)
    print(a)
    if numpy.array_equal(data, a) is False:
        # Fail
        raise TestFailure("Readback data does not match")

# Test the housekeeper simulation class
@cocotb.test()
def stc0_housekeeper_test(dut):
    """Tests basic Housekeeper FPGA functionality using internal loopback.

    FPGA is configured for loopback and data streamed in.
    """

    dut.ARst <= 1
    hk = hkSIMcocotb(dut, CLK_PERIOD_NS)
    cocotb.fork(Clock(dut.Clk, CLK_PERIOD_NS, units='ns').start())
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    dut.ARst <= 0
    yield Timer(CLK_PERIOD_NS * 10, units='ns')
    yield hk.reset()

    data = numpy.arange(10)

    data[0] = 0xA5B6C7D8
    data[8] = 0x12345678
    data[9] = 0xDEADC0DE
    yield hk.set_sfifoWrSrc(hk.HW_SFFWRSRC_LOOPBACK)
    yield hk.send_write_command(0x1, 0x1, data)
    yield Timer(CLK_PERIOD_NS * 20, units='ns')
    yield hk.send_write_command(hk.HW_HK_WRITE, hk.HW_ADDR_SFFRB_NUMBYTES, [52])
    yield Timer(CLK_PERIOD_NS * 5, units='ns')
    a = yield hk.ft245m.read_bytes(52)

    numpy.set_printoptions(formatter={'int':lambda x:hex(int(x))})

    #vhex = numpy.vectorize(hex)
    #print(vhex(a))
    print(sys.path)
    print(data)
    print(a[2:-1])
    if numpy.array_equal(data, a[2:-1]) is False:
        # Fail
        raise TestFailure("Readback data does not match")

    #yield hk.set_sfifoWrSrc(hk.HW_SFFWRSRC_INGRESS)
    #yield hk.send_write_command(0x1, 0x1, data)
    #yield hk.send_write_command(hk.HW_HK_WRITE, hk.HW_ADDR_SFFRB_NUMBYTES, [40])
    #a = yield hk.ft245m.read_bytes(40)
    #print(data)
    #print(a)
    #if numpy.array_equal(data, a) is False:
        ## Fail
        #raise TestFailure("Readback data does not match")
