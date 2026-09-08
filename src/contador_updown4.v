// Contador de 4 bits con incrementar/disminuir por pulso, construido
// reusando adder4/restador4 (compuertas) para el calculo combinacional
// y dff_en para el almacenamiento, igual que el resto del proyecto.
//
// pulso_inc / pulso_dec deben ser pulsos de 1 ciclo (salida de
// edge_detect), no el nivel crudo del boton. Si ambos estan en 1 al
// mismo tiempo (no deberia pasar con botones fisicos distintos),
// DISMINUIR tiene prioridad: el mux de decremento (dec0..dec3) se aplica
// despues del de incremento (sel0..sel3), asi que su seleccion es la que
// llega a `con_dec` cuando ambos pulsos estan activos a la vez.
module contador_updown4(
    input        clk,
    input        pulso_inc,
    input        pulso_dec,
    input        reset,
    output [3:0] valor
);

wire [3:0] mas_uno;
wire [3:0] menos_uno;
wire       cout_suma;
wire       cout_resta;
wire [3:0] resultado_inc_dec;
wire [3:0] siguiente;

adder4    sumador   (.a(valor), .b(4'b0001), .cin(1'b0), .sum(mas_uno), .cout(cout_suma));
restador4 restador  (.a(valor), .b(4'b0001), .resta(menos_uno), .resta_inv(), .cout_resta(cout_resta), .cout_resta_inv());

mux2to1 sel0 (.a(valor[0]), .b(mas_uno[0]), .sel(pulso_inc), .y(resultado_inc_dec[0]));
mux2to1 sel1 (.a(valor[1]), .b(mas_uno[1]), .sel(pulso_inc), .y(resultado_inc_dec[1]));
mux2to1 sel2 (.a(valor[2]), .b(mas_uno[2]), .sel(pulso_inc), .y(resultado_inc_dec[2]));
mux2to1 sel3 (.a(valor[3]), .b(mas_uno[3]), .sel(pulso_inc), .y(resultado_inc_dec[3]));

wire [3:0] con_dec;
mux2to1 dec0 (.a(resultado_inc_dec[0]), .b(menos_uno[0]), .sel(pulso_dec), .y(con_dec[0]));
mux2to1 dec1 (.a(resultado_inc_dec[1]), .b(menos_uno[1]), .sel(pulso_dec), .y(con_dec[1]));
mux2to1 dec2 (.a(resultado_inc_dec[2]), .b(menos_uno[2]), .sel(pulso_dec), .y(con_dec[2]));
mux2to1 dec3 (.a(resultado_inc_dec[3]), .b(menos_uno[3]), .sel(pulso_dec), .y(con_dec[3]));

mux2to1 rst0 (.a(con_dec[0]), .b(1'b0), .sel(reset), .y(siguiente[0]));
mux2to1 rst1 (.a(con_dec[1]), .b(1'b0), .sel(reset), .y(siguiente[1]));
mux2to1 rst2 (.a(con_dec[2]), .b(1'b0), .sel(reset), .y(siguiente[2]));
mux2to1 rst3 (.a(con_dec[3]), .b(1'b0), .sel(reset), .y(siguiente[3]));

// carga siempre (enable=1): el propio siguiente ya decide si retiene el
// valor actual (cuando no hay pulso ni reset) o lo cambia
registro4 reg_valor (.clk(clk), .ejecutar(1'b1), .d(siguiente), .q(valor));

endmodule
