// Filtro anti-rebote para un boton fisico. Mientras la entrada cruda
// cambie, reinicia el contador; si se mantiene estable durante
// CICLOS_ESTABLE ciclos de reloj, la salida adopta ese valor.
//
// A 25 MHz, CICLOS_ESTABLE = 250_000 equivale a ~10 ms.
//
// Nota: el contador y el registro de estado son secuenciales (clk),
// no logica combinacional de la calculadora, por lo que el uso de
// operadores aritmeticos/comparacion aqui esta fuera de la restriccion
// de "solo compuertas" del enunciado (esa restriccion aplica a la ALU).
module debouncer #(
    parameter CICLOS_ESTABLE = 250_000
) (
    input  clk,
    input  in_cruda,
    output reg out_estable
);

reg [$clog2(CICLOS_ESTABLE):0] contador;
reg in_prev;

initial begin
    out_estable = 1'b0;
    in_prev     = 1'b0;
    contador    = 0;
end

always @(posedge clk) begin
    if (in_cruda != in_prev) begin
        contador <= 0;
        in_prev  <= in_cruda;
    end else if (contador < CICLOS_ESTABLE) begin
        contador <= contador + 1'b1;
    end else begin
        out_estable <= in_cruda;
    end
end

endmodule
