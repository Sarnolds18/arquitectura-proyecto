// Indicador de overflow con signo (complemento a dos), sugerido por el
// profesor en el foro -- no obligatorio para la nota, implementado como
// mejora opcional. Sale por led_overflow (pin 60 del .pcf, reservado para
// esto).
//
// Criterio clasico de overflow con signo, aplicado bit a bit sobre el bit
// de signo (bit 3) de cada operando/resultado:
//   Suma        (A+B):  overflow si signo(A)==signo(B) y signo(R)!=signo(A)
//   Resta       (A-B):  overflow si signo(A)!=signo(B) y signo(R)!=signo(A)
//   Resta_inv   (B-A):  mismo criterio que resta, con A y B intercambiados
//   Shift/reinicio:    no aplica overflow con signo -> 0
//
// Se calculan los 3 overflow posibles en paralelo (uno por operacion
// aritmetica) y se selecciona el que corresponde al codigo activo con el
// mismo mux8to1 que ya usa opsel4.v, para no introducir if/case.
module overflow_detect(
    input  [2:0] codigo,
    input  [3:0] op1,
    input  [3:0] op2,
    input  [3:0] suma,
    input  [3:0] resta,
    input  [3:0] resta_inv,
    output       overflow
);

wire signo_a, signo_b;
buf (signo_a, op1[3]);
buf (signo_b, op2[3]);

wire signo_suma, signo_resta, signo_resta_inv;
buf (signo_suma,      suma[3]);
buf (signo_resta,     resta[3]);
buf (signo_resta_inv, resta_inv[3]);

// --- overflow de suma: signo_a==signo_b y signo_suma!=signo_a ---
wire mismo_signo_ab, signo_a_xor_b_n;
xor (signo_a_xor_b_n, signo_a, signo_b);
not (mismo_signo_ab, signo_a_xor_b_n);

wire resultado_distinto_suma;
xor (resultado_distinto_suma, signo_suma, signo_a);

wire ov_suma;
and (ov_suma, mismo_signo_ab, resultado_distinto_suma);

// --- overflow de resta (A-B): signo_a!=signo_b y signo_resta!=signo_a ---
wire signo_distinto_ab;
buf (signo_distinto_ab, signo_a_xor_b_n);

wire resultado_distinto_resta;
xor (resultado_distinto_resta, signo_resta, signo_a);

wire ov_resta;
and (ov_resta, signo_distinto_ab, resultado_distinto_resta);

// --- overflow de resta_inv (B-A): signo_b!=signo_a y signo_resta_inv!=signo_b ---
wire resultado_distinto_resta_inv;
xor (resultado_distinto_resta_inv, signo_resta_inv, signo_b);

wire ov_resta_inv;
and (ov_resta_inv, signo_distinto_ab, resultado_distinto_resta_inv);

// --- seleccion segun codigo, mismo layout que opsel4.v ---
// 000=reinicio(0) 001=suma 010=resta 011=resta_inv 100=shl(0) 101=shr(0)
// 110/111 = alias de reinicio (0), igual que en opsel4.v
mux8to1 mux_overflow (
    .in0(1'b0), .in1(ov_suma), .in2(ov_resta), .in3(ov_resta_inv),
    .in4(1'b0), .in5(1'b0), .in6(1'b0), .in7(1'b0),
    .sel(codigo), .y(overflow)
);

endmodule
