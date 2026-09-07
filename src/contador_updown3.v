// Contador de 3 bits con incrementar/disminuir por pulso, wrap real
// 0-7 (para el codigo de operacion). Misma estructura que
// contador_updown4 pero sobre 3 bits: reusa adder4/restador4 con el
// bit alto fijo en 0 y descarta ese bit en la salida.
module contador_updown3(
    input        clk,
    input        pulso_inc,
    input        pulso_dec,
    input        reset,
    output [2:0] valor
);

wire [3:0] valor4;
wire [3:0] mas_uno4;
wire [3:0] menos_uno4;
wire       cout_suma, cout_resta;
wire [3:0] resultado_inc_dec;
wire [3:0] con_dec;
wire [3:0] siguiente4;

buf (valor4[0], valor[0]);
buf (valor4[1], valor[1]);
buf (valor4[2], valor[2]);
assign valor4[3] = 1'b0;

adder4    sumador  (.a(valor4), .b(4'b0001), .cin(1'b0), .sum(mas_uno4), .cout(cout_suma));
restador4 restador (.a(valor4), .b(4'b0001), .resta(menos_uno4), .resta_inv(), .cout_resta(cout_resta), .cout_resta_inv());

mux2to1 sel0 (.a(valor4[0]), .b(mas_uno4[0]), .sel(pulso_inc), .y(resultado_inc_dec[0]));
mux2to1 sel1 (.a(valor4[1]), .b(mas_uno4[1]), .sel(pulso_inc), .y(resultado_inc_dec[1]));
mux2to1 sel2 (.a(valor4[2]), .b(mas_uno4[2]), .sel(pulso_inc), .y(resultado_inc_dec[2]));

mux2to1 dec0 (.a(resultado_inc_dec[0]), .b(menos_uno4[0]), .sel(pulso_dec), .y(con_dec[0]));
mux2to1 dec1 (.a(resultado_inc_dec[1]), .b(menos_uno4[1]), .sel(pulso_dec), .y(con_dec[1]));
mux2to1 dec2 (.a(resultado_inc_dec[2]), .b(menos_uno4[2]), .sel(pulso_dec), .y(con_dec[2]));

mux2to1 rst0 (.a(con_dec[0]), .b(1'b0), .sel(reset), .y(siguiente4[0]));
mux2to1 rst1 (.a(con_dec[1]), .b(1'b0), .sel(reset), .y(siguiente4[1]));
mux2to1 rst2 (.a(con_dec[2]), .b(1'b0), .sel(reset), .y(siguiente4[2]));

// truncar a 3 bits: el modulo 8 aparece naturalmente porque siempre
// forzamos el bit 3 de entrada en 0 y solo usamos +1/-1 sobre 3 bits
// efectivos (el adder4/restador4 de 4 bits con bit alto en 0 hace wrap
// correcto en el rango 0-7: 7+1=8=1000, se trunca a [2:0]=000; 0-1=1111,
// se trunca a [2:0]=111)
wire [2:0] siguiente3;
buf (siguiente3[0], siguiente4[0]);
buf (siguiente3[1], siguiente4[1]);
buf (siguiente3[2], siguiente4[2]);

dff_pos bit0 (.clk(clk), .d(siguiente3[0]), .q(valor[0]));
dff_pos bit1 (.clk(clk), .d(siguiente3[1]), .q(valor[1]));
dff_pos bit2 (.clk(clk), .d(siguiente3[2]), .q(valor[2]));

endmodule
