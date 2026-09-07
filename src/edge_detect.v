// Detector de flanco de subida: produce un pulso de 1 ciclo de clk
// cuando in_estable pasa de 0 a 1. Usar sobre una senal ya debounced.
module edge_detect(
    input  clk,
    input  in_estable,
    output pulso
);

reg prev;

initial begin
    prev = 1'b0;
end

always @(posedge clk) begin
    prev <= in_estable;
end

assign pulso = in_estable & ~prev;

endmodule
