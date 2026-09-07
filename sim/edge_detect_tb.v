`timescale 1ns/1ps

module edge_detect_tb;

reg clk;
reg in_estable;
wire pulso;

edge_detect uut (.clk(clk), .in_estable(in_estable), .pulso(pulso));

always #5 clk = ~clk;

integer pulsos_vistos;

initial begin
    $dumpfile("edge_detect_tb.vcd");
    $dumpvars(0, edge_detect_tb);

    pulsos_vistos = 0;
    clk = 0;
    in_estable = 0;
    repeat (2) @(posedge clk);
    #1; // evita carrera: cambiar la entrada justo despues del flanco, no en el mismo instante

    // sube: debe haber exactamente 1 pulso, visible durante el resto de este ciclo
    in_estable = 1;
    #1;
    if (pulso !== 1'b1) $display("FAIL: no hubo pulso tras el flanco de subida");
    else begin pulsos_vistos = pulsos_vistos + 1; $display("PASS: pulso detectado tras flanco de subida"); end

    // se mantiene en 1: en el siguiente flanco el pulso debe desaparecer
    @(posedge clk); #1;
    if (pulso !== 1'b0) $display("FAIL: pulso espurio en el segundo flanco con in_estable aun en 1");
    else $display("PASS: pulso desaparece en el siguiente flanco aunque in_estable siga en 1");

    repeat (2) begin
        @(posedge clk); #1;
        if (pulso !== 1'b0) $display("FAIL: pulso espurio mientras se mantiene en 1");
    end
    $display("PASS: sin pulsos espurios mientras in_estable=1 se mantiene");

    // baja y vuelve a subir: debe haber otro pulso
    in_estable = 0;
    repeat (2) @(posedge clk);
    #1;
    in_estable = 1;
    #1;
    if (pulso !== 1'b1) $display("FAIL: no hubo pulso en el segundo flanco de subida");
    else $display("PASS: pulso detectado en segundo flanco de subida");

    $finish;
end

endmodule
