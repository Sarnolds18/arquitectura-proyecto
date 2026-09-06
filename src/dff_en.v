// Flip-flop D con enable, disparado por flanco de subida.
// Estructura: flip-flop D maestro-esclavo (NAND) que siempre captura en
// cada flanco, mas un mux2to1 delante que decide si el dato nuevo (en=1)
// o el propio q (en=0, retiene) es lo que se captura.
module dff_en(
    input  clk,
    input  en,
    input  d,
    output q
);

wire d_in;

mux2to1 sel_en (.a(q), .b(d), .sel(en), .y(d_in));

dff_pos ff (.clk(clk), .d(d_in), .q(q));

endmodule
