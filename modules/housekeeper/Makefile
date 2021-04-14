PROJ = housekeeping_top
PIN_DEF = hx8kboard.pcf
DEVICE = hx8k

HDL_SRCS=housekeeping_top.v uart_rx.v sfifo.v asciiCmd.v

all: $(PROJ).rpt $(PROJ).bin

%.blif: $(HDL_SRCS)
	yosys -p 'synth_ice40 -top $(PROJ) -blif $@' $^ > yosys.log

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	iceprog -d d:$$(../../iceprog/iceprogHelper.py) $<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo iceprog -d d:$$(../../iceprog/iceprogHelper.py) $<

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin

.SECONDARY:
.PHONY: all prog clean
