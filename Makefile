# 仿真器和顶层模块配置
SIM ?= verilator                 # 使用 Verilator 作为仿真器
TOPLEVEL_LANG ?= verilog         # Verilog 模块语言
TOPLEVEL ?= top					 # 顶层模块名（你的 Verilog 模块名称）
MODULE ?= test_alu              # Python 测试文件名（不带 .py 后缀）
PYTHONPATH ?= tests

RTL_DIR := src_rtl
CXX_DIR := src_cxx
WAVE_DIR := wave

VERILOG_SOURCES = $(wildcard $(RTL_DIR)/*.v)
CONFIG_SCRIPT = scripts/generate_alu_config.py  # 配置文件生成脚本

ifeq ($(VERILATOR_ROOT),)
  VERILATOR = verilator
else
  export VERILATOR_ROOT
  VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif


# NVBoard 相关配置
ifeq ($(NVBOARD_HOME),)
  $(error NVBOARD_HOME is not set. Please export NVBOARD_HOME to your environment.)
endif
include $(NVBOARD_HOME)/scripts/nvboard.mk
NVBOARD_SCRIPTS := $(NVBOARD_HOME)/scripts
NVBOARD_PIN_BIND_SCRIPT := $(NVBOARD_SCRIPTS)/auto_pin_bind.py
NVBOARD_INC := $(NVBOARD_HOME)/include
CXXFLAGS += -I$(NVBOARD_USR_INC) -I$(NVBOARD_INC) $(shell sdl2-config --cflags) -D_REENTRANT -DNVBOARD
LDFLAGS += $(NVBOARD_ARCHIVE) $(shell sdl2-config --libs) -lSDL2_image -lSDL2_ttf
ifdef COMB
CXXFLAGS += -DCOMB
endif


# 加载 Cocotb 提供的 Makefile
include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: test config clean-all build wave dir nvb nvboard-bind vhelp

dir:
	mkdir -p $(WAVE_DIR) obj_dir config

config: dir
	python3 $(CONFIG_SCRIPT)

test:
	@$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim \
	SIM=$(SIM) TOPLEVEL=$(TOPLEVEL) MODULE=$(MODULE) PYTHONPATH=$(PYTHONPATH) VERILOG_SOURCES="$(VERILOG_SOURCES)"

clean-all: clean
	rm -rf $(SIM_BUILD)
	rm -rf obj_dir
	rm -rf dump.vcd
	rm -rf results.xml
# rm -f config/*.ini

build: dir
	@echo "Building project..."
	$(VERILATOR) -cc --exe --build \
		--top-module $(TOPLEVEL) \
		$(VERILOG_SOURCES) $(CXX_DIR)/main.cpp\
		-CFLAGS "-std=c++11 -I./src-cxx" \
		-Mdir obj_dir
	@echo "Build complete."
	@echo "-- RUN --------"
	./obj_dir/V$(TOPLEVEL)
	@echo "-- DONE --------------------"

wave: dir
	@echo "Building project..."
	$(VERILATOR) -cc --exe --trace --build \
		--top-module $(TOPLEVEL) \
		$(VERILOG_SOURCES) $(CXX_DIR)/main.cpp\
		-CFLAGS "-std=c++11 -I./src-cxx -DTRACE" \
		-Mdir obj_dir
	@echo "Build complete (with waveform)."
	@echo "-- RUN with tracing --------"
	./obj_dir/V$(TOPLEVEL)
	@echo "-- DONE --------------------"
	gtkwave wave/dump.vcd wave/gtks.gtkw

nvboard-bind:
	@echo "Generating NVBoard pin bindings..."
	python3 $(NVBOARD_PIN_BIND_SCRIPT) $(RTL_DIR)/pins.nxdc $(CXX_DIR)/auto_bind.cpp
	@echo "Pin bindings generated."

nvb: nvboard-bind
	@echo "Building NVBoard project..."
	$(VERILATOR) -cc --exe --build \
		--top-module $(TOPLEVEL) \
		$(VERILOG_SOURCES) $(CXX_DIR)/main.cpp $(CXX_DIR)/auto_bind.cpp \
		--CFLAGS "$(CXXFLAGS)" \
		--LDFLAGS "$(LDFLAGS)" \
		-Mdir obj_dir
	@echo "NVBoard build complete."
	@echo "-- RUN NVBoard simulation --------"
	./obj_dir/V$(TOPLEVEL)
	@echo "-- DONE --------------------"

vhelp:
	@echo "Usage: make [TARGET]"
	@echo
	@echo "Available targets:"
	@echo "  dir             Create necessary directories for build and wave files."
	@echo "  config          Run the configuration script to generate ALU configuration."
	@echo "  test            Run Cocotb testbench using the specified simulator."
	@echo "  build           Build the project using Verilator without waveform tracing."
	@echo "  wave            Build the project using Verilator with waveform tracing."
	@echo "  nvboard-bind    Generate NVBoard pin bindings from the configuration file."
	@echo "  nvb             Build and run the project with NVBoard simulation."
	@echo "  nvb COMB=1      Build and run NVBoard for combinational logic(without clk)."
	@echo "  clean-all       Clean all build files, simulation results, and configurations."