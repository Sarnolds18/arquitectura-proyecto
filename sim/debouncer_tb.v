`timescale 1ns/1ps

module debouncer_tb;

localparam CICLOS = 10; // valor chico para simular rapido

reg clk;
reg in_cruda;
wire out_estable;

debouncer #(.CICLOS_ESTABLE(CICLOS)) uut (
    .clk(clk),
    .in_cruda(in_cruda),
    .out_estable(out_estable)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("debouncer_tb.vcd");
    $dumpvars(0, debouncer_tb);

    clk = 0;
    in_cruda = 0;
    repeat (3) @(posedge clk);

    // rebote simulado: varios cambios rapidos antes de asentarse en 1
    in_cruda = 1; @(posedge clk);
    in_cruda = 0; @(posedge clk);
    in_cruda = 1; @(posedge clk);
    in_cruda = 0; @(posedge clk);
    in_cruda = 1; // se asienta aqui

    repeat (CICLOS + 3) @(posedge clk);

    if (out_estable !== 1'b1)
        $display("FAIL: tras asentarse en 1 y esperar, out_estable=%b (esperado 1)", out_estable);
    else
        $display("PASS: out_estable siguio a la entrada estable tras el rebote");

    // vuelve a 0 y se asienta
    in_cruda = 0;
    repeat (CICLOS + 3) @(posedge clk);

    if (out_estable !== 1'b0)
        $display("FAIL: tras asentarse en 0, out_estable=%b (esperado 0)", out_estable);
    else
        $display("PASS: out_estable bajo tras estabilizarse en 0");

    $finish;
end

endmodule
