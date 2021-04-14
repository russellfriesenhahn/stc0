# Test Chip 0



## Initialize Design

1. $ cd <stc0 git repo>
2. $ make design_init

## Simulate Design

1. $ cd <stc0 git repo>
2. $ make env
3. $ make design_init
4. $ . py3env/bin/activate
5. $ cd sim/cocotb_sim
6. $ make
