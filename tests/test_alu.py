import cocotb
from cocotb.triggers import Timer
import configparser

def parse_config(filename):
    """
    解析配置文件
    :param filename: 配置文件路径
    :return: 测试用例列表，每个用例包含 inputs 和 expected
    """
    config = configparser.ConfigParser()
    config.read(filename)

    test_cases = []
    for section in config.sections():
        if section.startswith("test_"):
            inputs = [int(x) if x.isdigit() else x for x in config[section]['inputs'].split(',')]
            expected = int(config[section]['expected'])
            test_cases.append((inputs, expected))
    return test_cases

def opcode_to_operator(opcode):
    """
    将 opcode 转换为对应的运算符号
    """
    operators = {
        0b00: '+',  # 加法
        0b01: '-',  # 减法
        0b10: '&',  # 按位与
        0b11: '|',  # 按位或
    }
    return operators.get(opcode, '?')  # 默认返回 '?' 表示未知操作符


@cocotb.test()
async def test_alu(dut):
    """
    测试测试，测试简单 ALU 的功能
    """
    # ANSI 转义码用于控制高亮
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RESET = '\033[0m'

    # 解析测试用例
    test_cases = parse_config("config/alu_test.ini")

    # 遍历测试用例
    for idx, (inputs, expected) in enumerate(test_cases):
        a, b, opcode = inputs

        if isinstance(opcode, str):
            opcode = int(opcode, 2)
        opcode &= 0b11

        operator = opcode_to_operator(opcode)

        # 设置 DUT 输入信号
        dut.a.value = a
        dut.b.value = b
        dut.opcode.value = opcode

        # 等待信号稳定
        await Timer(1, units="ns")

        # 验证 DUT 输出并打印结果
        try:
            assert dut.result.value == expected, (
                f"Test {idx} FAILED:{YELLOW} {a} {operator} {b} = {dut.result.value}, expected {expected}"
            )
            cocotb.log.info(f"{GREEN}Test {idx} PASSED:{YELLOW} {a} {operator} {b} = {expected}{RESET}")
        except AssertionError as e:
            cocotb.log.error(f"{RED}{str(e)}{RESET}")