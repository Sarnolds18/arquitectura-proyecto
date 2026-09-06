module opsel4(
    input  [2:0] codigo,
    input  [3:0] suma,
    input  [3:0] resta,
    input  [3:0] resta_inv,
    input  [3:0] shift_left,
    input  [3:0] shift_right,
    output [3:0] y
);

// codigo: 000=reinicio 001=suma 010=resta 011=resta_inv 100=shl 101=shr
// 110 y 111 no estan definidos por el enunciado -> se decidio dejarlos como
// alias de reinicio (salida 0000), documentado en el informe.

mux8to1 mux_bit0 (
    .in0(1'b0), .in1(suma[0]), .in2(resta[0]), .in3(resta_inv[0]),
    .in4(shift_left[0]), .in5(shift_right[0]), .in6(1'b0), .in7(1'b0),
    .sel(codigo), .y(y[0])
);

mux8to1 mux_bit1 (
    .in0(1'b0), .in1(suma[1]), .in2(resta[1]), .in3(resta_inv[1]),
    .in4(shift_left[1]), .in5(shift_right[1]), .in6(1'b0), .in7(1'b0),
    .sel(codigo), .y(y[1])
);

mux8to1 mux_bit2 (
    .in0(1'b0), .in1(suma[2]), .in2(resta[2]), .in3(resta_inv[2]),
    .in4(shift_left[2]), .in5(shift_right[2]), .in6(1'b0), .in7(1'b0),
    .sel(codigo), .y(y[2])
);

mux8to1 mux_bit3 (
    .in0(1'b0), .in1(suma[3]), .in2(resta[3]), .in3(resta_inv[3]),
    .in4(shift_left[3]), .in5(shift_right[3]), .in6(1'b0), .in7(1'b0),
    .sel(codigo), .y(y[3])
);

endmodule
