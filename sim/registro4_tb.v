`timescale 1ns/1ps

module registro4_tb;

reg        clk;
reg        ejecutar;
reg  [3:0] d;
wire [3:0] q;

registro4 uut (.clk(clk), .ejecutar(ejecutar), .d(d), .q(q));

always #5 clk = ~clk;

initial begin
    $dumpfile("registro4_tb.vcd");
    $dumpvars(0, registro4_tb);

    clk = 0; ejecutar = 0; d = 4'b0000;
    #12;

    // ejecutar=1: carga 4'b1010
    d = 4'b1010; ejecutar = 1;
    #10;
    $display("t=%0t ejecutar=1 d=1010 -> q=%b (esperado 1010)", $time, q);

    // ejecutar=0: cambia d, q no debe seguir
    ejecutar = 0; d = 4'b0101;
    #10;
    $display("t=%0t ejecutar=0 d=0101 -> q=%b (esperado retiene 1010)", $time, q);

    // ejecutar=1: carga 4'b0101
    ejecutar = 1;
    #10;
    $display("t=%0t ejecutar=1 d=0101 -> q=%b (esperado 0101)", $time, q);

    $finish;
end

endmodule
