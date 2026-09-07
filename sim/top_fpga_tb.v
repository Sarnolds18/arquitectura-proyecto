`timescale 1ns/1ps

// Testbench funcional del top de FPGA: simula la secuencia de botones
// para una suma completa (3 + 4 = 7) y verifica LEDs + displays.
//
// Usa CICLOS_ESTABLE chico en los debouncers (via defparam) para que la
// simulacion no tarde los ~10ms reales de debounce.
module top_fpga_tb;

reg clk, btn_inc, btn_dec, btn_confirm, btn_usar_ant;
wire [2:0] led_codigo;
wire disp_signo_a, disp_signo_b, disp_signo_c, disp_signo_d, disp_signo_e, disp_signo_f, disp_signo_g;
wire disp_mag_a, disp_mag_b, disp_mag_c, disp_mag_d, disp_mag_e, disp_mag_f, disp_mag_g;

top_fpga dut (
    .clk(clk),
    .btn_inc(btn_inc), .btn_dec(btn_dec), .btn_confirm(btn_confirm), .btn_usar_ant(btn_usar_ant),
    .led_codigo(led_codigo),
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

    $display("FIN top_fpga_tb");
    $finish;
end

endmodule
