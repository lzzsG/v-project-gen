module alu (
    input [3:0] a,
    input [3:0] b,
    input [1:0] opcode,
    output reg [3:0] result
);
  always @(*) begin
    case (opcode)
      2'b00:   result = a + b;  // 加法
      2'b01:   result = a - b;  // 减法
      2'b10:   result = a & b;  // 按位与
      2'b11:   result = a | b;  // 按位或
      default: result = 4'b0000;
    endcase
  end
endmodule
