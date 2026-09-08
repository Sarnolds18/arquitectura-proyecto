`timescale 1ns/1ps

module fsm_entrada_tb;

reg  clk, reset, pulso_confirm, pulso_usar_ant;
wire activo_op, activo_op1, activo_op2, sel_op2, ejecutar_pulso, reset_op1, reset_op2;

fsm_entrada uut (
    .clk(clk), .reset(reset),
    .pulso_confirm(pulso_confirm), .pulso_usar_ant(pulso_usar_ant),
    .activo_op(activo_op), .activo_op1(activo_op1), .activo_op2(activo_op2),
    .sel_op2(sel_op2), .ejecutar_pulso(ejecutar_pulso),
    .reset_op1(reset_op1), .reset_op2(reset_op2)
);

always #5 clk = ~clk;

task confirmar;
    begin
        pulso_confirm = 1'b1;
        @(posedge clk); #1;
        pulso_confirm = 1'b0;
    end
endtask

initial begin
    $dumpfile("fsm_entrada_tb.vcd");
    $dumpvars(0, fsm_entrada_tb);

    clk = 0; reset = 1; pulso_confirm = 0; pulso_usar_ant = 0;
    @(posedge clk); #1;
    reset = 0;

    if ({activo_op, activo_op1, activo_op2} !== 3'b100)
        $display("FAIL: estado inicial deberia ser SEL_OP (activo_op=1), obtenido %b%b%b", activo_op, activo_op1, activo_op2);
    else
        $display("PASS: estado inicial SEL_OP");

    // reset_op1 debe pulsar exactamente en el ciclo de la transicion
    // SEL_OP -> SEL_OP1 (verificado antes de que confirmar() suelte el pulso)
    pulso_confirm = 1'b1;
    #1;
    if (reset_op1 !== 1'b1)
        $display("FAIL: reset_op1 deberia ser 1 al confirmar en SEL_OP, obtenido %b", reset_op1);
    else
        $display("PASS: reset_op1=1 al entrar a SEL_OP1");
    @(posedge clk); #1;
    pulso_confirm = 1'b0;

    if ({activo_op, activo_op1, activo_op2} !== 3'b010)
        $display("FAIL: tras 1er confirm deberia ser SEL_OP1, obtenido %b%b%b", activo_op, activo_op1, activo_op2);
    else
        $display("PASS: tras confirmar, SEL_OP1");

    // reset_op2 debe pulsar exactamente en el ciclo de la transicion
    // SEL_OP1 -> SEL_OP2
    pulso_confirm = 1'b1;
    #1;
    if (reset_op2 !== 1'b1)
        $display("FAIL: reset_op2 deberia ser 1 al confirmar en SEL_OP1, obtenido %b", reset_op2);
    else
        $display("PASS: reset_op2=1 al entrar a SEL_OP2");
    @(posedge clk); #1;
    pulso_confirm = 1'b0;

    if ({activo_op, activo_op1, activo_op2} !== 3'b001)
        $display("FAIL: tras 2do confirm deberia ser SEL_OP2, obtenido %b%b%b", activo_op, activo_op1, activo_op2);
    else
        $display("PASS: tras confirmar de nuevo, SEL_OP2");

    // usar resultado anterior durante SEL_OP2
    pulso_usar_ant = 1'b1;
    @(posedge clk); #1;
    pulso_usar_ant = 1'b0;
    if (sel_op2 !== 1'b1)
        $display("FAIL: sel_op2 deberia ser 1 tras pulso_usar_ant en SEL_OP2, obtenido %b", sel_op2);
    else
        $display("PASS: sel_op2=1 tras usar resultado anterior");

    // SEL_OP2 -> MOSTRAR, debe generar ejecutar_pulso durante ese ciclo
    pulso_confirm = 1'b1;
    #1;
    if (ejecutar_pulso !== 1'b1)
        $display("FAIL: ejecutar_pulso deberia ser 1 al confirmar en SEL_OP2, obtenido %b", ejecutar_pulso);
    else
        $display("PASS: ejecutar_pulso=1 al confirmar en SEL_OP2");
    @(posedge clk); #1;
    pulso_confirm = 1'b0;

    if ({activo_op, activo_op1, activo_op2} !== 3'b000)
        $display("FAIL: tras 3er confirm deberia estar en MOSTRAR (todos activo_* en 0), obtenido %b%b%b", activo_op, activo_op1, activo_op2);
    else
        $display("PASS: tras confirmar op2, estado MOSTRAR");

    // sel_op2 debe haberse limpiado al salir de SEL_OP2
    if (sel_op2 !== 1'b0)
        $display("FAIL: sel_op2 deberia limpiarse al salir de SEL_OP2, obtenido %b", sel_op2);
    else
        $display("PASS: sel_op2 se limpio al salir de SEL_OP2");

    confirmar(); // MOSTRAR -> SEL_OP de nuevo
    if ({activo_op, activo_op1, activo_op2} !== 3'b100)
        $display("FAIL: tras confirmar en MOSTRAR deberia volver a SEL_OP, obtenido %b%b%b", activo_op, activo_op1, activo_op2);
    else
        $display("PASS: ciclo completo, vuelve a SEL_OP");

    $display("FIN fsm_entrada_tb");
    $finish;
end

endmodule
