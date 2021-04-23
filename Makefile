
COCOTBREV = 9b930054
COCOTBTAG = v1.4.0
COCOTBURL ?= https://github.com/cocotb/cocotb

modules/cocotb/.git/ORIG_HEAD:
	mkdir -p modules/
	test -d modules/cocotb || git clone $(COCOTBURL) modules/cocotb
ifneq ($(COCOTBREV),default)
	cd modules/cocotb; git checkout $(COCOTBTAG)
endif

py3env/bin/activate:
	virtualenv -p python3 py3env

py3env/bin/cocotb-config: py3env/bin/activate modules/cocotb/.git/ORIG_HEAD
	. py3env/bin/activate; \
	cd modules/cocotb; \
	python3 setup.py install; \
	pip install numpy; \
	deactivate

ENV_PRODUCTS=py3env/bin/cocotb-config
env: $(ENV_PRODUCTS)

verilog/rtl/stc0_addrMap.vh: sw/mk_addrMapvh.py sw/stc0.py
	python $< $@

INIT_PRODUCTS=verilog/rtl/stc0_addrMap.vh
design_init: $(INIT_PRODUCTS)

sim: design_init
	cd sim/cocotb_sim; make

clean:
	rm -rf modules/cocotb
	rm -rf py3env
	cd sim/cocotb_sim; make clean
