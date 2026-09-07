// Flip-flop D disparado por flanco de subida.
//
// Version anterior: maestro-esclavo armado a mano con 8 compuertas `nand`
// (dos latches SR cruzados). Funcionalmente correcta y verificada en
// simulacion (todos los testbenches del proyecto pasaban igual con esa
// version), pero al correr place & route real con nextpnr sobre el
// top-level completo (`top_fpga.v`) aparecio un error real:
// "timing analysis failed due to presence of combinatorial loops". El
// mapeo de yosys/ABC9 no siempre logra reconocer el par de `nand`
// cruzados como una celda SB_DFF nativa una vez que el diseno completo se
// aplana y optimiza junto a la logica combinacional de alrededor: en al
// menos un caso quedo como un lazo combinacional real en el netlist final,
// lo que bloquea por completo la generacion de bitstream (nextpnr no
// produce ni un .asc).
//
// Se reemplazo por un flip-flop comportamental estandar. El foro del curso
// aclaro que `<=` en un `always @(posedge clk)` SI esta permitido (la
// restriccion de "solo compuertas" es sobre la logica combinacional de la
// calculadora, no sobre los registros) -- ver CLAUDE.md seccion 0 e
// informe_borrador.md seccion 4. La interfaz (`clk`, `d`, `q`) no cambio,
// asi que ningun modulo que instancia `dff_pos` (dff_en, fsm_entrada,
// contador_updown3) necesito modificacion alguna.
module dff_pos(
    input      clk,
    input      d,
    output reg q
);

always @(posedge clk) begin
    q <= d;
end

endmodule
