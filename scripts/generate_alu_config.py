import random
import os
import configparser


def generate_config(filename, module_name, num_tests, input_rules, output_rules):
    """
    通用配置文件生成器
    :param filename: 输出文件名
    :param module_name: 模块名称（ALU, LFSR, etc.）
    :param num_tests: 测试用例数量
    :param input_rules: 输入规则
    :param output_rules: 输出规则
    """
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    config = configparser.ConfigParser()

    # 根据模块特性生成测试用例
    for i in range(num_tests):
        inputs = input_rules(i)  # 调用输入生成规则
        expected = output_rules(inputs)  # 根据输入生成期望输出

        config[f"test_{i}"] = {
            "inputs": ",".join(map(lambda x: format(x, "d"), inputs)),  # 转为十进制
            "expected": format(expected, "d"),  # 转为十进制
        }

    # 保存到文件
    with open(filename, "w") as f:
        config.write(f)


def generate_alu_config(filename, num_tests=100):
    """
    为 ALU 自动生成配置文件
    """

    def input_rules(_):
        a = random.randint(0, 15)  # 操作数范围 0-15
        b = random.randint(0, 15)
        opcode = random.randint(0, 3)
        return [a, b, opcode]

    def output_rules(inputs):
        a, b, opcode = inputs
        if opcode == 0:
            return (a + b) & 15
        elif opcode == 1:
            return (a - b) & 15
        elif opcode == 2:
            return a & b
        elif opcode == 3:
            return a | b

    generate_config(filename, "ALU", num_tests, input_rules, output_rules)


if __name__ == "__main__":
    generate_alu_config("config/alu_test.ini")
