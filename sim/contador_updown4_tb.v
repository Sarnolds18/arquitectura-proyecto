`timescale 1ns/1ps

module contador_updown4_tb;

reg  clk;
reg  pulso_inc, pulso_dec, reset;
wire [3:0] valor;

contador_updown4 uut (
    .clk(clk), .pulso_inc(pulso_inc), .pulso_dec(pulso_dec), .reset(reset), .valor(valor)
);

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

initial begin
    $dumpfile("contador_updown4_tb.vcd");
    $dumpvars(0, contador_updown4_tb);

    clk = 0; pulso_inc = 0; pulso_dec = 0; reset = 1;
    @(posedge clk); #1;
    reset = 0;

    if (valor !== 4'b0000) $display("FAIL: valor inicial tras reset = %b (esperado 0000)", valor);
    else $display("PASS: valor inicial tras reset = 0000");

    pulso_un_ciclo(1); // +1 -> 1
    pulso_un_ciclo(1); // +1 -> 2
    pulso_un_ciclo(1); // +1 -> 3
    if (valor !== 4'b0011) $display("FAIL: tras 3 incrementos valor=%b (esperado 0011)", valor);
    else $display("PASS: tras 3 incrementos valor=0011");

    pulso_un_ciclo(0); // -1 -> 2
    if (valor !== 4'b0010) $display("FAIL: tras 1 decremento valor=%b (esperado 0010)", valor);
    else $display("PASS: tras 1 decremento valor=0010");

    // wraparound: bajar desde 0 a -1 (4'b1111)
    pulso_un_ciclo(0);
    pulso_un_ciclo(0);
    if (valor !== 4'b0000) $display("FAIL: deberia estar en 0 antes del wrap, valor=%b", valor);
    pulso_un_ciclo(0); // 0 - 1 -> 1111
    if (valor !== 4'b1111) $display("FAIL: wraparound decremento valor=%b (esperado 1111)", valor);
    else $display("PASS: wraparound decremento valor=1111");

    // wraparound: subir desde 1111 a 0000
    pulso_un_ciclo(1);
    if (valor !== 4'b0000) $display("FAIL: wraparound incremento valor=%b (esperado 0000)", valor);
    else $display("PASS: wraparound incremento valor=0000");

    // reset en cualquier momento
    pulso_un_ciclo(1);
    pulso_un_ciclo(1);
    reset = 1;
    @(posedge clk); #1;
    reset = 0;
    if (valor !== 4'b0000) $display("FAIL: tras reset valor=%b (esperado 0000)", valor);
    else $display("PASS: reset vuelve a 0000");

    $display("FIN contador_updown4_tb");
    $finish;
end

endmodule
