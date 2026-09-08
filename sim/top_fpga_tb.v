`timescale 1ns/1ps

// Testbench funcional del top de FPGA: simula la secuencia de botones
// para una suma completa (3 + 4 = 7) y verifica LEDs + displays.
//
// Usa CICLOS_ESTABLE chico en los debouncers (via defparam) para que la
// simulacion no tarde los ~10ms reales de debounce.
module top_fpga_tb;

reg clk, btn_inc, btn_dec, btn_confirm, btn_usar_ant;
wire [2:0] led_codigo;
wire led_overflow;
wire disp_signo_a, disp_signo_b, disp_signo_c, disp_signo_d, disp_signo_e, disp_signo_f, disp_signo_g;
wire disp_mag_a, disp_mag_b, disp_mag_c, disp_mag_d, disp_mag_e, disp_mag_f, disp_mag_g;

top_fpga dut (
    .clk(clk),
    .btn_inc(btn_inc), .btn_dec(btn_dec), .btn_confirm(btn_confirm), .btn_usar_ant(btn_usar_ant),
    .led_codigo(led_codigo), .led_overflow(led_overflow),
    .disp_signo_a(disp_signo_a), .disp_signo_b(disp_signo_b), .disp_signo_c(disp_signo_c), .disp_signo_d(disp_signo_d),
    .disp_signo_e(disp_signo_e), .disp_signo_f(disp_signo_f), .disp_signo_g(disp_signo_g),
    .disp_mag_a(disp_mag_a), .disp_mag_b(disp_mag_b), .disp_mag_c(disp_mag_c), .disp_mag_d(disp_mag_d),
    .disp_mag_e(disp_mag_e), .disp_mag_f(disp_mag_f), .disp_mag_g(disp_mag_g)
);

// debounce reducido para simular rapido (10 ciclos en vez de 250_000)
defparam dut.db_inc.CICLOS_ESTABLE      = 10;
defparam dut.db_dec.CICLOS_ESTABLE      = 10;
defparam dut.db_confirm.CICLOS_ESTABLE  = 10;
defparam dut.db_usar_ant.CICLOS_ESTABLE = 10;

always #5 clk = ~clk;

// mantiene el boton en alto el tiempo suficiente para pasar el debounce
// reducido, luego lo suelta y espera a que se estabilice en 0
task presionar;
    input sel_inc, sel_dec, sel_confirm, sel_usar_ant;
    begin
        if (sel_inc)      btn_inc      = 1'b1;
        if (sel_dec)      btn_dec      = 1'b1;
        if (sel_confirm)  btn_confirm  = 1'b1;
        if (sel_usar_ant) btn_usar_ant = 1'b1;

        repeat (15) @(posedge clk); // > CICLOS_ESTABLE, genera 1 pulso

        btn_inc = 1'b0; btn_dec = 1'b0; btn_confirm = 1'b0; btn_usar_ant = 1'b0;

        repeat (15) @(posedge clk); // deja que el debounce vea el boton soltado
    end
endtask

task incrementar_n_veces;
    input integer n;
    integer i;
    begin
        for (i = 0; i < n; i = i + 1)
            presionar(1'b1, 1'b0, 1'b0, 1'b0);
    end
endtask

task confirmar;
    begin
        presionar(1'b0, 1'b0, 1'b1, 1'b0);
    end
endtask

initial begin
    $dumpfile("top_fpga_tb.vcd");
    $dumpvars(0, top_fpga_tb);

    clk = 0;
    btn_inc = 0; btn_dec = 0; btn_confirm = 0; btn_usar_ant = 0;

    repeat (5) @(posedge clk); // deja pasar el reset de arranque

    // codigo de operacion: SUMA = 3'b001 -> 1 incremento desde 0
    incrementar_n_veces(1);
    if (led_codigo !== 3'b001)
        $display("FAIL: led_codigo=%b tras seleccionar SUMA (esperado 001)", led_codigo);
    else
        $display("PASS: led_codigo=001 (SUMA) antes de confirmar");

    confirmar(); // SEL_OP -> SEL_OP1

    // op1 = 3 (0011): 3 incrementos
    incrementar_n_veces(3);
    confirmar(); // SEL_OP1 -> SEL_OP2

    // op2 = 4 (0100): 4 incrementos
    incrementar_n_veces(4);
    confirmar(); // SEL_OP2 -> MOSTRAR, dispara ejecutar_pulso

    // magnitud esperada = 7 (0111) -> 7 segmentos de "7": a,b,c encendidos
    // signo esperado = positivo -> display de signo todo apagado
    if ({disp_signo_a,disp_signo_b,disp_signo_c,disp_signo_d,disp_signo_e,disp_signo_f,disp_signo_g} !== 7'b0000000)
        $display("FAIL: display de signo deberia estar apagado (positivo), obtenido %b%b%b%b%b%b%b",
                  disp_signo_a,disp_signo_b,disp_signo_c,disp_signo_d,disp_signo_e,disp_signo_f,disp_signo_g);
    else
        $display("PASS: display de signo apagado (resultado positivo)");

    if ({disp_mag_a,disp_mag_b,disp_mag_c,disp_mag_d,disp_mag_e,disp_mag_f,disp_mag_g} !== 7'b1110000)
        $display("FAIL: display de magnitud deberia mostrar 7 (1110000), obtenido %b%b%b%b%b%b%b",
                  disp_mag_a,disp_mag_b,disp_mag_c,disp_mag_d,disp_mag_e,disp_mag_f,disp_mag_g);
    else
        $display("PASS: display de magnitud muestra 7 (3+4=7)");

    // confirmar en MOSTRAR vuelve a SEL_OP para una nueva operacion.
    // el codigo de operacion NO se reinicia a 0: el enunciado solo pide
    // volver al estado inicial (poder editar una operacion nueva), no
    // borrar el valor previamente ingresado.
    confirmar();
    if (led_codigo !== 3'b001)
        $display("FAIL: codigo deberia conservar su valor (001) al volver a SEL_OP, obtenido %b", led_codigo);
    else
        $display("PASS: ciclo completo, vuelve a SEL_OP conservando el codigo previo, listo para editar una nueva operacion");

    // --- reset de operandos al confirmar (decision de diseno, ver informe seccion 4) ---
    // codigo ya esta en SUMA (001) desde el bloque anterior; se mantiene tal cual.
    confirmar(); // SEL_OP -> SEL_OP1

    // op1 = 5 (0101): 5 incrementos
    incrementar_n_veces(5);
    confirmar(); // SEL_OP1 -> SEL_OP2, esto debe resetear op1... pero ya no importa,
                 // lo que se verifica es que op2_ext arranca en 0000 al entrar a SEL_OP2

    // display en SEL_OP2 muestra op2_ext (magnitud 0, signo positivo) antes de tocar nada.
    // "0" en el display de 7 segmentos activo-alto es 1111110 (a-f encendidos, g apagado),
    // no 0000000 -- ver tabla de seven_seg_hex.v en el informe seccion 2.12.
    if ({disp_mag_a,disp_mag_b,disp_mag_c,disp_mag_d,disp_mag_e,disp_mag_f,disp_mag_g} !== 7'b1111110)
        $display("FAIL: op2 deberia arrancar en 0000 al entrar a SEL_OP2, magnitud obtenida %b%b%b%b%b%b%b (esperado digito '0' = 1111110)",
                  disp_mag_a,disp_mag_b,disp_mag_c,disp_mag_d,disp_mag_e,disp_mag_f,disp_mag_g);
    else
        $display("PASS: op2 arranca en 0000 al entrar a SEL_OP2 (reset por confirmar op1)");

    // op2 = 3 (0011): 3 incrementos, luego confirmar -> ejecuta 5+3=8 (overflow: fuera de [-8,7]... en realidad 8 cae fuera del rango positivo de 4 bits con signo)
    incrementar_n_veces(3);
    confirmar(); // SEL_OP2 -> MOSTRAR, ejecuta 5+3=8 -> overflow con signo

    if (led_overflow !== 1'b1)
        $display("FAIL: led_overflow deberia ser 1 tras 5+3=8 (overflow con signo), obtenido %b", led_overflow);
    else
        $display("PASS: led_overflow=1 tras suma con overflow (5+3=8)");

    confirmar(); // MOSTRAR -> SEL_OP, listo para una nueva operacion
    confirmar(); // SEL_OP -> SEL_OP1, esto debe resetear op1 a 0000 tambien

    if ({disp_signo_a,disp_signo_b,disp_signo_c,disp_signo_d,disp_signo_e,disp_signo_f,disp_signo_g} !== 7'b0000000 ||
        {disp_mag_a,disp_mag_b,disp_mag_c,disp_mag_d,disp_mag_e,disp_mag_f,disp_mag_g} !== 7'b1111110)
        $display("FAIL: op1 deberia arrancar en 0000 al entrar a SEL_OP1 (segunda vez)");
    else
        $display("PASS: op1 arranca en 0000 al entrar a SEL_OP1 (segunda vez, confirma que el reset se repite en cada ciclo)");

    $display("FIN top_fpga_tb");
    $finish;
end

endmodule
