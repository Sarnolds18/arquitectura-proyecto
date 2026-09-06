module op2sel4(
    input        sel_op2,             // 0 = op2_ext, 1 = resultado anterior
    input  [3:0] op2_ext,
    input  [3:0] resultado_anterior,
    output [3:0] op2
);

mux2to1 mux_op2_0 (.a(op2_ext[0]), .b(resultado_anterior[0]), .sel(sel_op2), .y(op2[0]));
mux2to1 mux_op2_1 (.a(op2_ext[1]), .b(resultado_anterior[1]), .sel(sel_op2), .y(op2[1]));
mux2to1 mux_op2_2 (.a(op2_ext[2]), .b(resultado_anterior[2]), .sel(sel_op2), .y(op2[2]));
mux2to1 mux_op2_3 (.a(op2_ext[3]), .b(resultado_anterior[3]), .sel(sel_op2), .y(op2[3]));

endmodule
