def generate_config(filename, module_name, num_tests, input_rules, output_rules):
    """
    通用配置文件生成器
    :param filename: 输出文件名
    :param module_name: 模块名称（ALU, LFSR, etc.）
    :param num_tests: 测试用例数量
    :param input_rules: 输入规则
    :param output_rules: 输出规则
    """
    import configparser
    import os

    os.makedirs(os.path.dirname(filename), exist_ok=True)

    config = configparser.ConfigParser()

    # 根据模块特性生成测试用例
    for i in range(num_tests):
        inputs = input_rules(i)  # 调用输入生成规则
        expected = output_rules(inputs)  # 根据输入生成期望输出

        config[f'test_{i}'] = {
            'inputs': ','.join(map(str, inputs)),
            'expected': str(expected)
        }

    # 保存到文件
    with open(filename, 'w') as f:
        config.write(f)


def generate_alu_config(filename, num_tests=10):
    """
    为 ALU 自动生成配置文件
    """
    def input_rules(_):
        import random
        a = random.randint(0, 15)  # 操作数范围 0-15
        b = random.randint(0, 15)
        opcode = random.choice(["00", "01", "10", "11"])  # 保证 opcode 为 2 位字符串
        return [a, b, opcode]


    def output_rules(inputs):
        a, b, opcode = inputs
        if opcode == "00":  # 加法
            return (a + b) & 0xF  # 保持 4 位
        elif opcode == "01":  # 减法
            return (a - b) & 0xF  # 保持 4 位
        elif opcode == "10":  # 按位与
            return a & b
        elif opcode == "11":  # 按位或
            return a | b

    generate_config(filename, "ALU", num_tests, input_rules, output_rules)


if __name__ == "__main__":
    generate_alu_config('config/alu_test.ini')
