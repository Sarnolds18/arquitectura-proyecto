// Top level para la Nandland Go Board. Conecta los 4 botones fisicos,
// la FSM de entrada, los contadores editables (codigo/op1/op2), la
// calculadora, los LEDs (codigo de operacion) y los displays de 7
// segmentos (signo + magnitud en hex para op1/op2 mientras se editan,
// y para el resultado una vez confirmado).
//
// Botones de la Go Board (activo-alto asumido; ajustar polaridad segun
// el .pcf real si son activo-bajo):
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

fsm_entrada fsm (
    .clk(clk), .reset(reset_inicial),
    .pulso_confirm(pulso_confirm), .pulso_usar_ant(pulso_usar_ant),
    .activo_op(activo_op), .activo_op1(activo_op1), .activo_op2(activo_op2),
    .sel_op2(sel_op2), .ejecutar_pulso(ejecutar_pulso)
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

contador_updown3 cont_codigo (.clk(clk), .pulso_inc(pulso_inc_codigo), .pulso_dec(pulso_dec_codigo), .reset(reset_inicial), .valor(codigo));
contador_updown4 cont_op1    (.clk(clk), .pulso_inc(pulso_inc_op1),    .pulso_dec(pulso_dec_op1),    .reset(reset_inicial), .valor(op1));
contador_updown4 cont_op2    (.clk(clk), .pulso_inc(pulso_inc_op2),    .pulso_dec(pulso_dec_op2),    .reset(reset_inicial), .valor(op2_ext));

// ------------------------------------------------------------------
// Calculadora
// ------------------------------------------------------------------
wire [3:0] resultado;

calculadora_4bits calc (
    .clk(clk),
    .ejecutar(ejecutar_pulso),
    .codigo(codigo),
    .sel_op2(sel_op2),
    .op1(op1),
    .op2_ext(op2_ext),
    .resultado(resultado)
);

// ------------------------------------------------------------------
// LEDs: codigo de operacion
// ------------------------------------------------------------------
buf (led_codigo[0], codigo[0]);
buf (led_codigo[1], codigo[1]);
buf (led_codigo[2], codigo[2]);

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

seven_seg_signo disp_signo (
    .signo(signo),
    .seg_a(disp_signo_a), .seg_b(disp_signo_b), .seg_c(disp_signo_c), .seg_d(disp_signo_d),
    .seg_e(disp_signo_e), .seg_f(disp_signo_f), .seg_g(disp_signo_g)
);

seven_seg_hex disp_magnitud (
    .in(magnitud),
    .seg_a(disp_mag_a), .seg_b(disp_mag_b), .seg_c(disp_mag_c), .seg_d(disp_mag_d),
    .seg_e(disp_mag_e), .seg_f(disp_mag_f), .seg_g(disp_mag_g)
);

endmodule
