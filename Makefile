
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

INIT_PRODUCTS=py3env/bin/cocotb-config
init: $(INIT_PRODUCTS)

clean:
	rm -rf modules
