// Decodificador de signo para el primer display de 7 segmentos:
// signo=1 (negativo) -> solo el segmento g encendido (guion '-').
// signo=0 (positivo) -> todos los segmentos apagados.
module seven_seg_signo(
    input  signo,
    output seg_a,
    output seg_b,
    output seg_c,
    output seg_d,
    output seg_e,
    output seg_f,
    output seg_g
);

assign seg_a = 1'b0;
assign seg_b = 1'b0;
assign seg_c = 1'b0;
assign seg_d = 1'b0;
assign seg_e = 1'b0;
assign seg_f = 1'b0;
buf (seg_g, signo);

endmodule
