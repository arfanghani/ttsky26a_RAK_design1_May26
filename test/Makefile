# Makefile
# TinyTapeout cocotb simulation flow

# defaults
SIM ?= icarus
FST ?= -fst
TOPLEVEL_LANG ?= verilog

SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = project.v

# -------------------------
# RTL simulation
# -------------------------
ifneq ($(GATES),yes)

SIM_BUILD = sim_build/rtl

VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

# -------------------------
# Gate level simulation
# -------------------------
SIM_BUILD = sim_build/gl

COMPILE_ARGS += -DGL_TEST
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DUSE_POWER_PINS
COMPILE_ARGS += -DSIM
COMPILE_ARGS += -DUNIT_DELAY=\#1

# PDK standard cells
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# gate-level netlist injected by TinyTapeout flow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# -------------------------
# Shared settings
# -------------------------

# allow RTL + TB shared includes
COMPILE_ARGS += -I$(SRC_DIR)

# testbench
VERILOG_SOURCES += $(PWD)/tb.v

TOPLEVEL = tb

# -------------------------
# Cocotb test module
# -------------------------
MODULE = test

# -------------------------
# Cocotb make system
# -------------------------
include $(shell cocotb-config --makefiles)/Makefile.sim
