# 仿真器和顶层模块配置
SIM ?= verilator                 # 使用 Verilator 作为仿真器
TOPLEVEL_LANG ?= verilog         # Verilog 模块语言
TOPLEVEL ?= alu                  # 顶层模块名（你的 Verilog 模块名称）
MODULE ?= test_alu              # Python 测试文件名（不带 .py 后缀）

# 源文件路径
VERILOG_SOURCES = $(wildcard src/*.v)    # Verilog 源文件路径
CONFIG_SCRIPT = scripts/generate_alu_config.py  # 配置文件生成脚本

# Python 路径
PYTHONPATH ?= tests

# 加载 Cocotb 提供的 Makefile
include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: run                      # 一键运行目标
run:
	@$(MAKE) SIM=$(SIM) TOPLEVEL=$(TOPLEVEL) MODULE=$(MODULE) PYTHONPATH=$(PYTHONPATH)

.PHONY: config                   # 生成测试配置文件
config: 
	python3 $(CONFIG_SCRIPT)

.PHONY: clean-all                # 清理所有生成文件
clean-all: clean
	rm -rf $(SIM_BUILD)
# rm -f config/*.ini