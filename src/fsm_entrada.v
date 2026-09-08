// FSM de entrada para el flujo de botones de la Go Board:
//   SEL_OP  -> SEL_OP1 -> SEL_OP2 -> MOSTRAR -> SEL_OP -> ...
//
// Botones (ya debounced + edge-detected antes de llegar aqui, cada uno
// como pulso de 1 ciclo):
//   pulso_inc     : incrementar valor en el estado actual (sup. izq.)
//   pulso_dec     : disminuir valor en el estado actual (inf. izq.)
//   pulso_confirm : confirmar/avanzar de estado (sup. der.)
//   pulso_usar_ant: usar resultado anterior como op2 (inf. der.),
//                   solo tiene efecto durante SEL_OP2
//
// Salidas de control hacia el resto del datapath:
//   activo_op, activo_op1, activo_op2 : habilitan el contador
//     correspondiente a recibir pulso_inc/pulso_dec
//   sel_op2       : 1 si se debe usar el resultado anterior como op2
//   ejecutar_pulso: pulso de 1 ciclo hacia calculadora_4bits.ejecutar,
//     generado al confirmar op2 (transicion SEL_OP2 -> MOSTRAR)
//   reset_op1     : pulso de 1 ciclo al entrar a SEL_OP1 (SEL_OP -> SEL_OP1),
//     limpia el contador de op1 para que el siguiente ingreso arranque en 0
//   reset_op2     : pulso de 1 ciclo al entrar a SEL_OP2 (SEL_OP1 -> SEL_OP2),
//     mismo motivo para el contador de op2
//
// Estados codificados en one-hot (registros individuales, sin `case`),
// usando exclusivamente flip-flops + compuertas para las transiciones.
module fsm_entrada(
    input  clk,
    input  reset,          // fuerza el estado inicial SEL_OP (arranque/power-on)
    input  pulso_confirm,
    input  pulso_usar_ant,

    output activo_op,
    output activo_op1,
    output activo_op2,
    output sel_op2,
    output ejecutar_pulso,
    output reset_op1,
    output reset_op2
);

wire estado_sel_op, estado_sel_op1, estado_sel_op2, estado_mostrar;

// --- transiciones de estado, one-hot ---
// avanza de SEL_OP a SEL_OP1 al confirmar
wire avanza_desde_op, avanza_desde_op1, avanza_desde_op2, avanza_desde_mostrar;
and (avanza_desde_op,      pulso_confirm, estado_sel_op);
and (avanza_desde_op1,     pulso_confirm, estado_sel_op1);
and (avanza_desde_op2,     pulso_confirm, estado_sel_op2);
and (avanza_desde_mostrar, pulso_confirm, estado_mostrar);

// siguiente-estado por flip-flop, usando el propio estado actual como
// "quedarse" cuando no hay pulso de confirmar en ese estado
wire mantener_op, mantener_op1, mantener_op2, mantener_mostrar;
wire pulso_confirm_n;
not (pulso_confirm_n, pulso_confirm);
and (mantener_op,      estado_sel_op,  pulso_confirm_n);
and (mantener_op1,     estado_sel_op1, pulso_confirm_n);
and (mantener_op2,     estado_sel_op2, pulso_confirm_n);
and (mantener_mostrar, estado_mostrar, pulso_confirm_n);

wire siguiente_sel_op_natural, siguiente_sel_op1_natural, siguiente_sel_op2_natural, siguiente_mostrar_natural;
or (siguiente_sel_op_natural,  mantener_op,  avanza_desde_mostrar);
or (siguiente_sel_op1_natural, mantener_op1, avanza_desde_op);
or (siguiente_sel_op2_natural, mantener_op2, avanza_desde_op1);
or (siguiente_mostrar_natural, mantener_mostrar, avanza_desde_op2);

// con reset=1, fuerza siguiente estado = SEL_OP (one-hot: 1,0,0,0)
wire siguiente_sel_op, siguiente_sel_op1, siguiente_sel_op2, siguiente_mostrar;
mux2to1 rst_op  (.a(siguiente_sel_op_natural),  .b(1'b1), .sel(reset), .y(siguiente_sel_op));
mux2to1 rst_op1 (.a(siguiente_sel_op1_natural), .b(1'b0), .sel(reset), .y(siguiente_sel_op1));
mux2to1 rst_op2 (.a(siguiente_sel_op2_natural), .b(1'b0), .sel(reset), .y(siguiente_sel_op2));
mux2to1 rst_mos (.a(siguiente_mostrar_natural), .b(1'b0), .sel(reset), .y(siguiente_mostrar));

dff_pos reg_sel_op  (.clk(clk), .d(siguiente_sel_op),  .q(estado_sel_op));
dff_pos reg_sel_op1 (.clk(clk), .d(siguiente_sel_op1), .q(estado_sel_op1));
dff_pos reg_sel_op2 (.clk(clk), .d(siguiente_sel_op2), .q(estado_sel_op2));
dff_pos reg_mostrar (.clk(clk), .d(siguiente_mostrar), .q(estado_mostrar));

// --- registro de "usar resultado anterior", valido solo en SEL_OP2 ---
// se fija con pulso_usar_ant durante SEL_OP2 y queda retenido (aunque el
// pulso dure solo 1 ciclo) mientras se siga en SEL_OP2. El selector del mux
// es `siguiente_sel_op2` (el PROXIMO estado, no el actual) para que el
// registro se limpie en el mismo flanco en que la FSM sale de SEL_OP2, en
// vez de un ciclo despues.
wire sel_op2_set, sel_op2_or, sel_op2_next;
and (sel_op2_set, pulso_usar_ant, estado_sel_op2);
or  (sel_op2_or,  sel_op2_set,    sel_op2);
mux2to1 sel_op2_mux (.a(1'b0), .b(sel_op2_or), .sel(siguiente_sel_op2), .y(sel_op2_next));
// nota: si el proximo estado sigue siendo SEL_OP2, el mux elige
// sel_op2_or = set | valor_actual (se fija con el pulso o se retiene lo que
// ya tenia); si el proximo estado ya no es SEL_OP2 (se esta confirmando y
// saliendo), fuerza 0 desde ya, limpiando la seleccion en el mismo flanco
// en que cambia el estado.
dff_pos reg_usar_ant (.clk(clk), .d(sel_op2_next), .q(sel_op2));

buf (activo_op,  estado_sel_op);
buf (activo_op1, estado_sel_op1);
buf (activo_op2, estado_sel_op2);
buf (ejecutar_pulso, avanza_desde_op2);
buf (reset_op1, avanza_desde_op);
buf (reset_op2, avanza_desde_op1);

endmodule
