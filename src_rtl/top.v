module top (
    input [3:0] a,
    input [3:0] b,
    input [1:0] opcode,
    output reg [3:0] result
);
  alu u_alu (
      .a(a),
      .b(b),
      .opcode(opcode),
      .result(result)
  );
endmodule
