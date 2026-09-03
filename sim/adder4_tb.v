`timescale 1ns/1ps

module adder4_tb;

reg  [3:0] a;
reg  [3:0] b;
reg        cin;

wire [3:0] sum;
wire       cout;

adder4 uut (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
);

initial begin

    $dumpfile("adder4.vcd");
    $dumpvars(0, adder4_tb);

    a = 4'd0; b = 4'd0; cin = 0; #10;
    a = 4'd1; b = 4'd1; cin = 0; #10;   // 1+1=2
    a = 4'd7; b = 4'd8; cin = 0; #10;   // 7+8=15
    a = 4'd15; b = 4'd1; cin = 0; #10;  // 15+1=0, cout=1 (overflow)
    a = 4'd5; b = 4'd3; cin = 1; #10;   // 5+3+1=9
    a = 4'd9; b = 4'd6; cin = 0; #10;   // 9+6=15

    $finish;

end

endmodule
