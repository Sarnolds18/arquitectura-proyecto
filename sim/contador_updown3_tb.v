`timescale 1ns/1ps

module contador_updown3_tb;

reg clk, pulso_inc, pulso_dec, reset;
wire [2:0] valor;

contador_updown3 uut (.clk(clk), .pulso_inc(pulso_inc), .pulso_dec(pulso_dec), .reset(reset), .valor(valor));

always #5 clk = ~clk;

task pulso_un_ciclo;
    input sube;
    begin
        if (sube) pulso_inc = 1'b1; else pulso_dec = 1'b1;
        @(posedge clk); #1;
        pulso_inc = 1'b0;
        pulso_dec = 1'b0;
    end
endtask

integer i;

initial begin
    $dumpfile("contador_updown3_tb.vcd");
    $dumpvars(0, contador_updown3_tb);

    clk = 0; pulso_inc = 0; pulso_dec = 0; reset = 1;
    @(posedge clk); #1;
    reset = 0;

    if (valor !== 3'b000) $display("FAIL: inicial=%b (esperado 000)", valor);
    else $display("PASS: inicial=000");

    for (i = 0; i < 7; i = i + 1) pulso_un_ciclo(1);
    if (valor !== 3'b111) $display("FAIL: tras 7 incrementos valor=%b (esperado 111)", valor);
    else $display("PASS: tras 7 incrementos valor=111");

    pulso_un_ciclo(1); // wrap 7 -> 0
    if (valor !== 3'b000) $display("FAIL: wrap 7->0 valor=%b (esperado 000)", valor);
    else $display("PASS: wrap 7->0 correcto");

    pulso_un_ciclo(0); // wrap 0 -> 7
    if (valor !== 3'b111) $display("FAIL: wrap 0->7 valor=%b (esperado 111)", valor);
    else $display("PASS: wrap 0->7 correcto");

    reset = 1;
    @(posedge clk); #1;
    reset = 0;
    if (valor !== 3'b000) $display("FAIL: tras reset valor=%b (esperado 000)", valor);
    else $display("PASS: reset OK");

    $display("FIN contador_updown3_tb");
    $finish;
end

endmodule
