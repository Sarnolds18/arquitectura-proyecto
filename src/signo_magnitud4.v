// Convierte un valor de 4 bits en complemento a 2 a signo + magnitud,
// para mostrar en los displays de 7 segmentos (primer display = signo,
// segundo display = magnitud en hex). Ver aclaracion del curso: el
// segundo display muestra la magnitud (valor absoluto), no los bits
// crudos en complemento a 2.
//
// Caso especial: -8 (4'b1000) no tiene magnitud positiva representable
// en 4 bits (el complemento a 2 de 1000 vuelve a dar 1000). Se deja
// truncado a 4 bits, documentado en el informe.
module signo_magnitud4(
    input  [3:0] valor,
    output       signo,       // 1 = negativo
    output [3:0] magnitud
);

wire [3:0] valor_neg;
wire [3:0] complemento;
wire       cout_complemento;

not (valor_neg[0], valor[0]);
not (valor_neg[1], valor[1]);
not (valor_neg[2], valor[2]);
not (valor_neg[3], valor[3]);

// complemento a 2 de valor = ~valor + 1
adder4 negador (.a(valor_neg), .b(4'b0000), .cin(1'b1), .sum(complemento), .cout(cout_complemento));

buf (signo, valor[3]);

mux2to1 mag0 (.a(valor[0]), .b(complemento[0]), .sel(signo), .y(magnitud[0]));
mux2to1 mag1 (.a(valor[1]), .b(complemento[1]), .sel(signo), .y(magnitud[1]));
mux2to1 mag2 (.a(valor[2]), .b(complemento[2]), .sel(signo), .y(magnitud[2]));
mux2to1 mag3 (.a(valor[3]), .b(complemento[3]), .sel(signo), .y(magnitud[3]));

endmodule
