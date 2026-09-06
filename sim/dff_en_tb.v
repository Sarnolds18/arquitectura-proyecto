`timescale 1ns/1ps

module dff_en_tb;

reg clk;
reg en;
reg d;
wire q;

dff_en uut (.clk(clk), .en(en), .d(d), .q(q));

always #5 clk = ~clk;

initial begin
    $dumpfile("dff_en_tb.vcd");
    $dumpvars(0, dff_en_tb);

    clk = 0; en = 0; d = 0;
    #12; // deja asentar

    // en=0: q no debe cambiar aunque d cambie
    d = 1;
    #10;
    $display("t=%0t en=0 d=1 -> q=%b (esperado retiene valor anterior)", $time, q);

    // en=1, d=1: en el proximo flanco q deberia pasar a 1
    en = 1; d = 1;
    #10;
    $display("t=%0t en=1 d=1 tras flanco -> q=%b (esperado 1)", $time, q);

    // en=1, d=0: en el proximo flanco q deberia pasar a 0
    d = 0;
    #10;
    $display("t=%0t en=1 d=0 tras flanco -> q=%b (esperado 0)", $time, q);

    // en=0: cambia d, q no debe seguirlo
    en = 0; d = 1;
    #10;
    $display("t=%0t en=0 d=1 -> q=%b (esperado retiene 0)", $time, q);

    $finish;
end

endmodule
