// Top level para la Nandland Go Board. Conecta los 4 botones fisicos,
// la FSM de entrada, los contadores editables (codigo/op1/op2), la
// calculadora, los LEDs (codigo de operacion) y los displays de 7
// segmentos (signo + magnitud en hex para op1/op2 mientras se editan,
// y para el resultado una vez confirmado).
//
// Botones de la Go Board (activo-alto, confirmado en la placa fisica
// 2026-09-08 -- ver constraints/go-board.pcf):
//   btn_inc      : superior izquierdo -> incrementar valor actual
//   btn_dec      : inferior izquierdo -> disminuir valor actual
//   btn_confirm  : superior derecho   -> confirmar/avanzar, y reiniciar
//                  el flujo si se presiona tras ver el resultado
//   btn_usar_ant : inferior derecho   -> usar resultado anterior como op2
module top_fpga(
    input  clk,
    input  btn_inc,
    input  btn_dec,
    input  btn_confirm,
    input  btn_usar_ant,

    output [2:0] led_codigo,
    output       led_overflow,

    output disp_signo_a, output disp_signo_b, output disp_signo_c, output disp_signo_d,
    output disp_signo_e, output disp_signo_f, output disp_signo_g,

    output disp_mag_a, output disp_mag_b, output disp_mag_c, output disp_mag_d,
    output disp_mag_e, output disp_mag_f, output disp_mag_g
);

// ------------------------------------------------------------------
// Botones: debounce + edge-detect -> pulso de 1 ciclo cada uno
// ------------------------------------------------------------------
wire inc_estable, dec_estable, confirm_estable, usar_ant_estable;

debouncer db_inc      (.clk(clk), .in_cruda(btn_inc),      .out_estable(inc_estable));
debouncer db_dec      (.clk(clk), .in_cruda(btn_dec),      .out_estable(dec_estable));
debouncer db_confirm  (.clk(clk), .in_cruda(btn_confirm),  .out_estable(confirm_estable));
debouncer db_usar_ant (.clk(clk), .in_cruda(btn_usar_ant), .out_estable(usar_ant_estable));

wire pulso_inc, pulso_dec, pulso_confirm, pulso_usar_ant;

edge_detect ed_inc      (.clk(clk), .in_estable(inc_estable),      .pulso(pulso_inc));
edge_detect ed_dec      (.clk(clk), .in_estable(dec_estable),      .pulso(pulso_dec));
edge_detect ed_confirm  (.clk(clk), .in_estable(confirm_estable),  .pulso(pulso_confirm));
edge_detect ed_usar_ant (.clk(clk), .in_estable(usar_ant_estable), .pulso(pulso_usar_ant));

// ------------------------------------------------------------------
// Reset de arranque: activo en el instante de power-on, se libera en
// el primer flanco de clk. Mismo patron initial+always que ya usan
// debouncer/edge_detect/dff_en para su estado inicial; el iCE40
// inicializa los flip-flops via el bitstream, asi que esto se
// comporta igual en simulacion y en la FPGA real.
// ------------------------------------------------------------------
reg reset_inicial_reg;

initial begin
    reset_inicial_reg = 1'b1;
end

always @(posedge clk) begin
    reset_inicial_reg <= 1'b0;
end

wire reset_inicial;
buf (reset_inicial, reset_inicial_reg);

// ------------------------------------------------------------------
// FSM de entrada
// ------------------------------------------------------------------
wire activo_op, activo_op1, activo_op2, sel_op2, ejecutar_pulso;
wire reset_op1, reset_op2;

fsm_entrada fsm (
    .clk(clk), .reset(reset_inicial),
    .pulso_confirm(pulso_confirm), .pulso_usar_ant(pulso_usar_ant),
    .activo_op(activo_op), .activo_op1(activo_op1), .activo_op2(activo_op2),
    .sel_op2(sel_op2), .ejecutar_pulso(ejecutar_pulso),
    .reset_op1(reset_op1), .reset_op2(reset_op2)
);

// ------------------------------------------------------------------
// Contadores editables: cada uno solo recibe pulso_inc/dec si esta activo
// ------------------------------------------------------------------
wire pulso_inc_codigo, pulso_dec_codigo;
wire pulso_inc_op1, pulso_dec_op1;
wire pulso_inc_op2, pulso_dec_op2;

and (pulso_inc_codigo, pulso_inc, activo_op);
and (pulso_dec_codigo, pulso_dec, activo_op);
and (pulso_inc_op1,    pulso_inc, activo_op1);
and (pulso_dec_op1,    pulso_dec, activo_op1);
and (pulso_inc_op2,    pulso_inc, activo_op2);
and (pulso_dec_op2,    pulso_dec, activo_op2);

wire [2:0] codigo;
wire [3:0] op1, op2_ext;

// op1/op2 se reinician a 0000 cada vez que se ENTRA a su estado de edicion
// (SEL_OP -> SEL_OP1 y SEL_OP1 -> SEL_OP2 respectivamente), ademas del
// reset de arranque de la placa: cada operando nuevo arranca desde cero en
// vez de conservar el valor del ingreso anterior (decision de diseno, ver
// informe seccion 4). El codigo de operacion NO se reinicia al confirmar
// -- solo en el arranque -- para no perder la operacion seleccionada al
// volver de MOSTRAR a SEL_OP (ver top_fpga_tb.v).
wire reset_op1_total, reset_op2_total;
or (reset_op1_total, reset_inicial, reset_op1);
or (reset_op2_total, reset_inicial, reset_op2);

contador_updown3 cont_codigo (.clk(clk), .pulso_inc(pulso_inc_codigo), .pulso_dec(pulso_dec_codigo), .reset(reset_inicial), .valor(codigo));
contador_updown4 cont_op1    (.clk(clk), .pulso_inc(pulso_inc_op1),    .pulso_dec(pulso_dec_op1),    .reset(reset_op1_total), .valor(op1));
contador_updown4 cont_op2    (.clk(clk), .pulso_inc(pulso_inc_op2),    .pulso_dec(pulso_dec_op2),    .reset(reset_op2_total), .valor(op2_ext));

// ------------------------------------------------------------------
// Calculadora
// ------------------------------------------------------------------
wire [3:0] resultado;
wire       overflow;

calculadora_4bits calc (
    .clk(clk),
    .ejecutar(ejecutar_pulso),
    .codigo(codigo),
    .sel_op2(sel_op2),
    .op1(op1),
    .op2_ext(op2_ext),
    .resultado(resultado),
    .overflow(overflow)
);

// ------------------------------------------------------------------
// LEDs: codigo de operacion + indicador de overflow (opcional)
// ------------------------------------------------------------------
buf (led_codigo[0], codigo[0]);
buf (led_codigo[1], codigo[1]);
buf (led_codigo[2], codigo[2]);
buf (led_overflow, overflow);

// ------------------------------------------------------------------
// Displays: durante SEL_OP1 muestra op1, durante SEL_OP2 muestra op2_ext,
// en cualquier otro momento (SEL_OP, MOSTRAR) muestra el resultado
// almacenado en el registro de la calculadora.
// ------------------------------------------------------------------
wire [3:0] valor_a_mostrar;
wire m_op1_or_resultado_0, m_op1_or_resultado_1, m_op1_or_resultado_2, m_op1_or_resultado_3;

mux2to1 disp_sel0 (.a(resultado[0]), .b(op1[0]), .sel(activo_op1), .y(m_op1_or_resultado_0));
mux2to1 disp_sel1 (.a(resultado[1]), .b(op1[1]), .sel(activo_op1), .y(m_op1_or_resultado_1));
mux2to1 disp_sel2 (.a(resultado[2]), .b(op1[2]), .sel(activo_op1), .y(m_op1_or_resultado_2));
mux2to1 disp_sel3 (.a(resultado[3]), .b(op1[3]), .sel(activo_op1), .y(m_op1_or_resultado_3));

mux2to1 disp_final0 (.a(m_op1_or_resultado_0), .b(op2_ext[0]), .sel(activo_op2), .y(valor_a_mostrar[0]));
mux2to1 disp_final1 (.a(m_op1_or_resultado_1), .b(op2_ext[1]), .sel(activo_op2), .y(valor_a_mostrar[1]));
mux2to1 disp_final2 (.a(m_op1_or_resultado_2), .b(op2_ext[2]), .sel(activo_op2), .y(valor_a_mostrar[2]));
mux2to1 disp_final3 (.a(m_op1_or_resultado_3), .b(op2_ext[3]), .sel(activo_op2), .y(valor_a_mostrar[3]));

wire       signo;
wire [3:0] magnitud;

signo_magnitud4 conv_display (.valor(valor_a_mostrar), .signo(signo), .magnitud(magnitud));

// seven_seg_signo/seven_seg_hex producen segmentos activo-alto (1 = segmento
// encendido). La Go Board tiene el display en anodo comun (activo-bajo: 0 =
// encendido) -- confirmado en la placa fisica el 2026-09-08 (con op1=0000 se
// veia el digito de signo como un "8" completo y el de magnitud como un
// guion en el segmento del medio, exactamente el patron esperado si se
// manda "todo apagado"/"0" activo-alto a un display activo-bajo). Se
// invierten las 14 salidas con `not` justo antes de los pines fisicos, sin
// tocar la logica interna de los decodificadores.
wire signo_a_ah, signo_b_ah, signo_c_ah, signo_d_ah, signo_e_ah, signo_f_ah, signo_g_ah;
wire mag_a_ah, mag_b_ah, mag_c_ah, mag_d_ah, mag_e_ah, mag_f_ah, mag_g_ah;

seven_seg_signo disp_signo (
    .signo(signo),
    .seg_a(signo_a_ah), .seg_b(signo_b_ah), .seg_c(signo_c_ah), .seg_d(signo_d_ah),
    .seg_e(signo_e_ah), .seg_f(signo_f_ah), .seg_g(signo_g_ah)
);

seven_seg_hex disp_magnitud (
    .in(magnitud),
    .seg_a(mag_a_ah), .seg_b(mag_b_ah), .seg_c(mag_c_ah), .seg_d(mag_d_ah),
    .seg_e(mag_e_ah), .seg_f(mag_f_ah), .seg_g(mag_g_ah)
);

not (disp_signo_a, signo_a_ah);
not (disp_signo_b, signo_b_ah);
not (disp_signo_c, signo_c_ah);
not (disp_signo_d, signo_d_ah);
not (disp_signo_e, signo_e_ah);
not (disp_signo_f, signo_f_ah);
not (disp_signo_g, signo_g_ah);

not (disp_mag_a, mag_a_ah);
not (disp_mag_b, mag_b_ah);
not (disp_mag_c, mag_c_ah);
not (disp_mag_d, mag_d_ah);
not (disp_mag_e, mag_e_ah);
not (disp_mag_f, mag_f_ah);
not (disp_mag_g, mag_g_ah);

endmodule
