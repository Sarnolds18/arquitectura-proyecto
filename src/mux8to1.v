module mux8to1(
    input  in0,
    input  in1,
    input  in2,
    input  in3,
    input  in4,
    input  in5,
    input  in6,
    input  in7,
    input  [2:0] sel,
    output y
);

// arbol binario de mux2to1: 3 niveles para 3 bits de seleccion (sel[0]=LSB)
wire m0, m1, m2, m3;
wire n0, n1;

mux2to1 mux_lvl0_0 (.a(in0), .b(in1), .sel(sel[0]), .y(m0));
mux2to1 mux_lvl0_1 (.a(in2), .b(in3), .sel(sel[0]), .y(m1));
mux2to1 mux_lvl0_2 (.a(in4), .b(in5), .sel(sel[0]), .y(m2));
mux2to1 mux_lvl0_3 (.a(in6), .b(in7), .sel(sel[0]), .y(m3));

mux2to1 mux_lvl1_0 (.a(m0), .b(m1), .sel(sel[1]), .y(n0));
mux2to1 mux_lvl1_1 (.a(m2), .b(m3), .sel(sel[1]), .y(n1));

mux2to1 mux_lvl2_0 (.a(n0), .b(n1), .sel(sel[2]), .y(y));

endmodule
