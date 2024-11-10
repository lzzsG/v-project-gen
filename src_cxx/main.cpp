#include <verilated.h>
#include "Vtop.h" // Verilator 自动生成的顶层模块头文件

#ifdef TRACE
#include "verilated_vcd_c.h" // 如果启用波形生成，需要包含此头文件
#endif

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv); // 传递命令行参数
    Vtop *top = new Vtop;               // 实例化顶层模块

#ifdef TRACE
    VerilatedVcdC *tfp = new VerilatedVcdC;
    Verilated::traceEverOn(true); // 打开波形生成
    top->trace(tfp, 99);          // 注册波形生成器
    tfp->open("dump.vcd");        // 打开波形文件
#endif

    // 仿真循环
    for (int i = 0; i < 100; ++i)
    {
        // 示例输入信号
        top->a = i & 0xF;       // 输入信号 a
        top->b = (i * 2) & 0xF; // 输入信号 b
        top->opcode = i % 4;    // 示例操作码

        top->eval(); // 调用 Verilator 的仿真计算

#ifdef TRACE
        tfp->dump(i); // 如果启用波形，将当前仿真时刻的数据写入波形文件
#endif
    }

#ifdef TRACE
    tfp->close(); // 如果启用波形，关闭波形文件
    delete tfp;   // 清理波形生成器
#endif

    delete top; // 清理顶层模块
    return 0;
}
