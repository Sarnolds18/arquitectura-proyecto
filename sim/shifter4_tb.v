`timescale 1ns/1ps

module shifter4_tb;

reg  [3:0] a;
reg  [1:0] amount;
reg        dir;

wire [3:0] y;

shifter4 uut (
    .a(a),
    .amount(amount),
    .dir(dir),
    .y(y)
);

initial begin

    $dumpfile("shifter4_tb.vcd");
    $dumpvars(0, shifter4_tb);

    // left shifts: 0001 << n
    a = 4'b0001; dir = 1'b0; amount = 2'd0; #10; // 0001
    a = 4'b0001; dir = 1'b0; amount = 2'd1; #10; // 0010
    a = 4'b0001; dir = 1'b0; amount = 2'd2; #10; // 0100
    a = 4'b0001; dir = 1'b0; amount = 2'd3; #10; // 1000

    // left shift con overflow: 1111 << 3 -> 1000 (se trunca a 4 bits)
    a = 4'b1111; dir = 1'b0; amount = 2'd3; #10; // 1000

    // right shifts: 1000 >> n
    a = 4'b1000; dir = 1'b1; amount = 2'd0; #10; // 1000
    a = 4'b1000; dir = 1'b1; amount = 2'd1; #10; // 0100
    a = 4'b1000; dir = 1'b1; amount = 2'd2; #10; // 0010
    a = 4'b1000; dir = 1'b1; amount = 2'd3; #10; // 0001

    // right shift con overflow: 1111 >> 3 -> 0001
    a = 4'b1111; dir = 1'b1; amount = 2'd3; #10; // 0001

    $finish;

end

endmodule
