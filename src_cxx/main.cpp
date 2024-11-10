#include <verilated.h>
#include "Vtop.h"  // Verilator 自动生成的顶层模块头文件
#include <cstdlib> // 包含 rand() 和 srand()
#include <ctime>   // 包含 time() 用于随机种子

#ifdef NVBOARD
#include <nvboard.h> // 包含 NVBoard 的头文件
#endif

#ifdef TRACE
#include "verilated_vcd_c.h" // 如果启用波形生成，需要包含此头文件
#endif

static Vtop dut; // 顶层模块实例

#ifdef NVBOARD
void nvboard_bind_all_pins(Vtop *top);
// 根据宏定义选择单周期或组合逻辑
#ifdef COMB
static void simulate()
{
    dut.eval(); // 纯组合逻辑只需要调用 eval
}
#else
static void simulate()
{
    // 单周期时钟驱动逻辑
    dut.clk = 0;
    dut.eval();
    dut.clk = 1;
    dut.eval();
}
#endif
#endif

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv); // 传递命令行参数

#ifdef NVBOARD
    nvboard_bind_all_pins(&dut); // 绑定 NVBoard 引脚
    nvboard_init();              // 初始化 NVBoard
#endif

#ifdef TRACE
    VerilatedVcdC *tfp = new VerilatedVcdC;
    Verilated::traceEverOn(true); // 启用波形生成
    dut.trace(tfp, 99);           // 注册波形生成器
    tfp->open("wave/dump.vcd");   // 打开波形文件
#endif

#ifdef NVBOARD
    while (1) // NVBoard 模式下持续运行
    {
        nvboard_update(); // 更新 NVBoard 界面
        simulate();       // 模拟单个时钟周期
    }
#else
    std::srand(std::time(nullptr));

    for (int i = 0; i < 100; ++i) // 非 NVBoard 模式下运行 100 个周期
    {
        dut.a = i & 0b1111;           // 输入信号 a
        dut.b = std::rand() & 0b1111; // 生成随机数 输入信号 b
        dut.opcode = i % 4;           // 示例操作码

        dut.eval(); // 调用 Verilator 的仿真计算

#ifdef TRACE
        tfp->dump(i); // 如果启用波形，将当前仿真时刻的数据写入波形文件
#endif
    }
#endif

#ifdef TRACE
    tfp->close(); // 如果启用波形，关闭波形文件
    delete tfp;   // 清理波形生成器
#endif

#ifdef NVBOARD
    nvboard_quit(); // 关闭 NVBoard
#endif

    return 0;
}
