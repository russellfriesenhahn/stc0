###############################################################################
# Copyright (c) 2013 Potential Ventures Ltd
# Copyright (c) 2013 SolarFlare Communications Inc
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Potential Ventures Ltd,
#       SolarFlare Communications Inc nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL POTENTIAL VENTURES LTD BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###############################################################################

#cocotb14/bin/activate:
	#virtualenv -p python3 cocotb14

#cocotb14/git: cocotb14/bin/activate
	#mkdir -p $@

#cocotb14/git/cocotb/.git/HEAD: cocotb14/git
	#cd cocotb14/git/; \
	#git clone gitlab@repositories.arlut.utexas.edu:slicer/cocotb

#cocotb14/git/cocotb: cocotb14/git/cocotb/.git/HEAD
	#. ./cocotb14/bin/activate; \
	#cd cocotb14/git/cocotb; \
	#git checkout v1.4.0; \
	#python3 setup.py install; \
	#deactivate

TOPLEVEL_LANG ?= verilog

PWD=$(shell pwd)

WPWD=$(shell pwd)
DUTD=$(WPWD)/../../verilog/rtl
HKD=$(WPWD)/../../modules/housekeeper/verilog/rtl
PYTHONPATH := $(HKD)/../../sw/:$(WPWD)/../../sw:$(PYTHONPATH)

DUT_VERILOG_SOURCES = $(DUTD)/stc0_addrMap.vh $(DUTD)/rstSync.v $(DUTD)/byteIngressCmdProcessor.v
DUT_VERILOG_SOURCES += $(DUTD)/byteEgress.v $(DUTD)/stc0Ctrl.v $(DUTD)/lfsr32.v
DUT_VERILOG_SOURCES += $(DUTD)/spram.v $(DUTD)/multiplier.v $(DUTD)/stc0butterfly.v
DUT_VERILOG_SOURCES += $(DUTD)/crc32.v $(DUTD)/crc32reg.v $(DUTD)/oneWordFifo.v $(DUTD)/egressStage.v
DUT_VERILOG_SOURCES += $(DUTD)/stc0_core.v
VERILOG_SOURCES += $(DUT_VERILOG_SOURCES)
VERILOG_SOURCES += $(HKD)/asciiCmd.v $(HKD)/byteIngress.v $(HKD)/ft245sff.v
VERILOG_SOURCES += $(HKD)/HKbyteIngress.v $(HKD)/housekeeper_top.v $(HKD)/sfifo.v
VERILOG_SOURCES += $(HKD)/uart_rx.v $(WPWD)/stc0_core_cocotb.v

TOPLEVEL := stc0_core_cocotb 
MODULE   := stc0_tests

#SIM_ARGS = "-lxt2"
COMPILE_ARGS += "-I$(DUTD)"
#EXTRA_ARGS += "-lxt2"
PLUSARGS = '-lxt2'

#include $(shell cocotb-config --makefiles)/Makefile.inc
#sim: cocotb14/git/cocotb
include $(shell cocotb-config --makefiles)/Makefile.sim
