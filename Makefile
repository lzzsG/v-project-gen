# 仿真器和顶层模块配置
SIM ?= verilator                 # 使用 Verilator 作为仿真器
TOPLEVEL_LANG ?= verilog         # Verilog 模块语言
TOPLEVEL ?= top					 # 顶层模块名（你的 Verilog 模块名称）
MODULE ?= test_alu              # Python 测试文件名（不带 .py 后缀）
CSRC := src_cxx



LDFLAGS += $(NVBOARD_ARCHIVE) $(shell sdl2-config --libs) -lSDL2_image -lSDL2_ttf

# 源文件路径
VERILOG_SOURCES = $(wildcard src_rtl/*.v)    # Verilog 源文件路径
CONFIG_SCRIPT = scripts/generate_alu_config.py  # 配置文件生成脚本

# Python 路径
PYTHONPATH ?= tests

ifeq ($(VERILATOR_ROOT),)
  VERILATOR = verilator
else
  export VERILATOR_ROOT
  VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif

# 加载 Cocotb 提供的 Makefile
include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: run-t                      # 一键运行目标
run-t:
	@$(MAKE) SIM=$(SIM) TOPLEVEL=$(TOPLEVEL) MODULE=$(MODULE) PYTHONPATH=$(PYTHONPATH)

.PHONY: config                   # 生成测试配置文件
config: 
	python3 $(CONFIG_SCRIPT)

.PHONY: clean-all                # 清理所有生成文件
clean-all: clean
	rm -rf $(SIM_BUILD)
	rm -rf obj_dir
	rm -rf dump.vcd
	rm -rf results.xml
# rm -f config/*.ini

.PHONY: build
build: 
	@echo "Building project..."
	$(VERILATOR) -cc --exe --build \
		--top-module $(TOPLEVEL) \
		$(VERILOG_SOURCES) $(CSRC)/main.cpp\
		-CFLAGS "-std=c++11 -I./src-cxx" \
		-Mdir obj_dir
	@echo "Build complete."
	@echo "-- RUN --------"
	./obj_dir/V$(TOPLEVEL)
	@echo "-- DONE --------------------"



.PHONY: wave
wave:
	@echo "Building project..."
	$(VERILATOR) -cc --exe --trace --build \
		--top-module $(TOPLEVEL) \
		$(VERILOG_SOURCES) $(CSRC)/main.cpp\
		-CFLAGS "-std=c++11 -I./src-cxx -DTRACE" \
		-Mdir obj_dir
	@echo "Build complete (with waveform)."
	@echo "-- RUN with tracing --------"
	./obj_dir/V$(TOPLEVEL)
	@echo "-- DONE --------------------"
	gtkwave dump.vcd gtks.gtkw
