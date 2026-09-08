// Decodificador de 4 bits (0-F) a 7 segmentos, a nivel de compuertas
// (mux16to1 por segmento, construido sobre mux8to1/mux2to1 ya verificados).
// Salidas activo-alto (1 = segmento encendido). Si la placa usa anodo
// comun (activo-bajo), invertir con `not` en el top level o en el .pcf.
//
// Segmentos:
//   _a_
//  f   b
//  |_g_|
//  e   c
//  |_d_|
//
// Tabla de verdad (entrada in[3:0] -> segmentos abcdefg):
//  0: 1111110   4: 0110011   8: 1111111   C: 1001110
//  1: 0110000   5: 1011011   9: 1111011   D: 0111101
//  2: 1101101   6: 1011111   A: 1110111   E: 1001111
//  3: 1111001   7: 1110000   B: 0011111   F: 1000111
//
// (5 y 6 corregidos 2026-09-08: la version anterior tenia b y c
// invertidos -- 1101011/1101111 en vez de 1011011/1011111 -- error de
// tipeo al armar la tabla, no detectado en simulacion porque
// sim/seven_seg_hex_tb.v tenia copiado el mismo error. Confirmado en la
// placa fisica: el "5" y el "6" se veian con el segmento b encendido en
// vez de c.)

module seven_seg_hex(
    input  [3:0] in,
    output seg_a,
    output seg_b,
    output seg_c,
    output seg_d,
    output seg_e,
    output seg_f,
    output seg_g
);

// bit a bit, MSB a LSB, de cada patron 0..F
mux16to1 mux_a (
    .in0(1'b1),.in1(1'b0),.in2(1'b1),.in3(1'b1),.in4(1'b0),.in5(1'b1),.in6(1'b1),.in7(1'b1),
    .in8(1'b1),.in9(1'b1),.in10(1'b1),.in11(1'b0),.in12(1'b1),.in13(1'b0),.in14(1'b1),.in15(1'b1),
    .sel(in), .y(seg_a)
);

mux16to1 mux_b (
    .in0(1'b1),.in1(1'b1),.in2(1'b1),.in3(1'b1),.in4(1'b1),.in5(1'b0),.in6(1'b0),.in7(1'b1),
    .in8(1'b1),.in9(1'b1),.in10(1'b1),.in11(1'b0),.in12(1'b0),.in13(1'b1),.in14(1'b0),.in15(1'b0),
    .sel(in), .y(seg_b)
);

mux16to1 mux_c (
    .in0(1'b1),.in1(1'b1),.in2(1'b0),.in3(1'b1),.in4(1'b1),.in5(1'b1),.in6(1'b1),.in7(1'b1),
    .in8(1'b1),.in9(1'b1),.in10(1'b1),.in11(1'b1),.in12(1'b0),.in13(1'b1),.in14(1'b0),.in15(1'b0),
    .sel(in), .y(seg_c)
);

mux16to1 mux_d (
    .in0(1'b1),.in1(1'b0),.in2(1'b1),.in3(1'b1),.in4(1'b0),.in5(1'b1),.in6(1'b1),.in7(1'b0),
    .in8(1'b1),.in9(1'b1),.in10(1'b0),.in11(1'b1),.in12(1'b1),.in13(1'b1),.in14(1'b1),.in15(1'b0),
    .sel(in), .y(seg_d)
);

mux16to1 mux_e (
    .in0(1'b1),.in1(1'b0),.in2(1'b1),.in3(1'b0),.in4(1'b0),.in5(1'b0),.in6(1'b1),.in7(1'b0),
    .in8(1'b1),.in9(1'b0),.in10(1'b1),.in11(1'b1),.in12(1'b1),.in13(1'b1),.in14(1'b1),.in15(1'b1),
    .sel(in), .y(seg_e)
);

mux16to1 mux_f (
    .in0(1'b1),.in1(1'b0),.in2(1'b0),.in3(1'b0),.in4(1'b1),.in5(1'b1),.in6(1'b1),.in7(1'b0),
    .in8(1'b1),.in9(1'b1),.in10(1'b1),.in11(1'b1),.in12(1'b1),.in13(1'b0),.in14(1'b1),.in15(1'b1),
    .sel(in), .y(seg_f)
);

mux16to1 mux_g (
    .in0(1'b0),.in1(1'b0),.in2(1'b1),.in3(1'b1),.in4(1'b1),.in5(1'b1),.in6(1'b1),.in7(1'b0),
    .in8(1'b1),.in9(1'b1),.in10(1'b1),.in11(1'b1),.in12(1'b0),.in13(1'b1),.in14(1'b1),.in15(1'b1),
    .sel(in), .y(seg_g)
);

endmodule
