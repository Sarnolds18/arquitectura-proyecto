`timescale 1ns/1ps

module dff_pos_tb;

reg clk;
reg d;
wire q;

dff_pos uut (.clk(clk), .d(d), .q(q));

always #5 clk = ~clk;

initial begin
    $dumpfile("dff_pos_tb.vcd");
    $dumpvars(0, dff_pos_tb);

    clk = 0; d = 0;
    #12;
    $display("t=%0t d=0 -> q=%b", $time, q);

    d = 1;
    #10;
    $display("t=%0t tras flanco con d=1 -> q=%b (esperado 1)", $time, q);

    d = 0;
    #10;
    $display("t=%0t tras flanco con d=0 -> q=%b (esperado 0)", $time, q);

    d = 1;
    #10;
    $display("t=%0t tras flanco con d=1 -> q=%b (esperado 1)", $time, q);

    $finish;
end

endmodule
