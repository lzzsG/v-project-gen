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
            inputs = [int(x) for x in config[section]["inputs"].split(",")]
            expected = int(config[section]["expected"])
            test_cases.append((inputs, expected))
    return test_cases


@cocotb.test()
async def test_alu(dut):
    """
    测试测试，测试简单 ALU 的功能
    """

    # 初始化颜色代码和格式化变量
    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    RESET = "\033[0m"
    BLUE = "\033[94m"

    FORMAT_IDX = "02d"  # 索引格式
    FORMAT = "04b"  # 二进制格式
    FORMAT_RULES = [
        "{:04b}",  # 索引 0 的格式：2 位二进制
        "{:04b}",  # 索引 1 的格式：2 位二进制
        "{:02b}",  # 索引 2 的格式：2 位二进制
    ]

    # 定义格式化函数
    def format_inputs(inputs):
        """
        根据预定义的格式规则格式化 inputs
        """
        return [FORMAT_RULES[idx].format(value) for idx, value in enumerate(inputs)]

    # 解析测试用例
    test_cases = parse_config("config/alu_test.ini")

    # 记录失败的测试序号
    failed_tests = []

    # 遍历测试用例
    for idx, (inputs, expected) in enumerate(test_cases):
        a, b, opcode = inputs

        # 设置 DUT 输入信号
        dut.a.value = a
        dut.b.value = b
        dut.opcode.value = opcode

        # 等待信号稳定
        await Timer(1, units="ns")

        # 格式化 inputs
        formatted_inputs = format_inputs(inputs)

        # 获取实际输出
        actual = int(dut.result.value)

        # 打印结果并记录失败的序号
        if actual == expected:
            cocotb.log.info(
                f"{BLUE}Test {idx:{FORMAT_IDX}}:{RESET} Inputs={formatted_inputs}, Output={actual:{FORMAT}}, Expected={expected:{FORMAT}} - {GREEN}PASS{RESET}"
            )
        else:
            cocotb.log.error(
                f"{BLUE}Test {idx:{FORMAT_IDX}}:{RESET} {RED}Inputs={formatted_inputs}, Output={actual:{FORMAT}}, Expected={expected:{FORMAT}} - FAIL{RESET}"
            )
            failed_tests.append(idx)  # 记录失败的序号

        # 统计测试结果
    total_tests = len(test_cases)
    failed_count = len(failed_tests)
    passed_count = total_tests - failed_count

    # 打印统计信息
    cocotb.log.info(
        f"{BLUE}Total tests: {total_tests}{RESET}, {GREEN}Passed: {passed_count}{RESET}, {RED}Failed: {failed_count}{RESET}"
    )

    # 打印失败的测试序号并检查
    if failed_tests:
        failed_tests_str = ", ".join(f"{i:{FORMAT_IDX}}" for i in failed_tests)
        cocotb.log.error(f"{RED}Failed tests: {failed_tests_str}{RESET}")
        # 抛出异常标记测试失败
        assert failed_count == 0, f"{RED}Some tests failed: {failed_tests_str}{RESET}"
    else:
        cocotb.log.info(f"{GREEN}All tests passed!{RESET}")
