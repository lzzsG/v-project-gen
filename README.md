
# Verilog 项目生成器 (verilog-project-gen)

该项目旨在使用 `Verilator` 和 `Cocotb` 进行 Verilog 设计的仿真、测试与开发。项目集成了 NVBoard 进行可视化调试，并通过 GTKWave 进行波形分析，结构清晰且易于扩展。

---

## 项目结构

```

verilog-project-gen/
├── config/                  # 配置文件目录
│   └── alu_test.ini         # ALU 测试的 INI 配置文件
├── obj_dir/                 # Verilator 生成的中间对象目录
├── scripts/                 # 实用脚本
│   └── generate_alu_config.py # 用于生成 ALU 配置的 Python 脚本
├── sim_build/               # Cocotb 仿真构建目录
├── src_cxx/                 # C++ 源代码目录
│   ├── auto_bind.cpp        # 自动生成的 NVBoard 引脚绑定代码
│   └── main.cpp             # 仿真主程序入口
├── src_rtl/                 # Verilog 源代码目录
│   ├── alu.v                # ALU Verilog 模块
│   ├── pins.nxdc            # NVBoard 引脚配置
│   └── top.v                # 顶层 Verilog 模块
├── tests/                   # Python 测试脚本目录
│   └── test_alu.py          # 针对 ALU 模块的 Cocotb 测试脚本
├── wave/                    # 波形文件和 GTKWave 配置
│   ├── dump.vcd             # 仿真生成的波形文件
│   └── gtks.gtkw            # GTKWave 配置文件
├── .gitignore               
├── Makefile                 
└── README.md                

```

---

## 功能特性

- **仿真与测试**：
  - 使用 `Verilator` 作为主要的 Verilog 仿真工具。
  - 基于 `Cocotb` 的 Python 测试平台，支持高级验证功能。

- **波形分析**：
  - 仿真后生成波形文件（`dump.vcd`）。
  - 集成 `GTKWave` 进行信号可视化。

- **NVBoard 支持**：
  - 使用 NVBoard 进行交互式硬件调试。

---

## 前置要求

### 必备工具

1. **Verilator**：Verilog 仿真器，用于编译和运行设计。
2. **Cocotb**：基于 Python 的验证框架。
3. **Python**：运行测试脚本和生成配置文件。
4. **NVBoard**：硬件调试可视化工具（需配置 `NVBOARD_HOME` 环境变量）。
5. **GTKWave**：波形可视化工具。

### 环境设置

- 配置环境变量：

  ```bash
  export NVBOARD_HOME=/path/to/nvboard
  export VERILATOR_ROOT=/path/to/verilator
  ```

- 安装 Python 依赖：

  ```bash
  pip install cocotb
  ```

---

## 使用方法

### 1. 构建项目运行仿真

使用 `Verilator` 编译 Verilog 源文件：

运行带或不带波形生成的仿真：

```bash
make build       # 不带波形生成的仿真
make wave        # 带波形生成的仿真
make test        # 运行 Cocotb 测试
```

### 2. 分析波形

使用 GTKWave 打开波形文件：

```bash
make wave
```

### 3. NVBoard 调试

生成 NVBoard 引脚绑定并运行仿真：

```bash
make nvb
```

默认情况下，NVBoard 会使用带时钟的仿真。如需不带时钟的仿真，请使用：

```bash
make nvb COMB=1
```

### 5. 清理项目

清理所有生成文件：

```bash
make clean-all
```

---

## 核心文件说明

### Verilog RTL 文件

- `src_rtl/alu.v`：ALU 模块的 Verilog 源代码。
- `src_rtl/top.v`：顶层 Verilog 模块。
- `src_rtl/pins.nxdc`：NVBoard 引脚配置。

### C++ 仿真文件

- `src_cxx/main.cpp`：Verilator 仿真入口文件。
- `src_cxx/auto_bind.cpp`：自动生成的 NVBoard 引脚绑定代码。

### Python 测试脚本

- `tests/test_alu.py`：基于 Cocotb 的 ALU 模块测试脚本。
- `scripts/generate_alu_config.py`：生成 ALU 配置的 Python 脚本, 作为示例和框架参考。

---

## Makefile 目标

`make help`

```
  dir             Create necessary directories for build and wave files.
  config          Run the configuration script to generate ALU configuration.
  test            Run Cocotb testbench using the specified simulator.
  build           Build the project using Verilator without waveform tracing.
  wave            Build the project using Verilator with waveform tracing.
  nvboard-bind    Generate NVBoard pin bindings from the configuration file.
  nvb             Build and run the project with NVBoard simulation.
  nvb COMB=1      Build and run NVBoard for combinational logic(without clk).
  clean-all       Clean all build files, simulation results, and configurations.

```
