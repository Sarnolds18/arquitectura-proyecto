module mux16to1(
    input  in0,  input  in1,  input  in2,  input  in3,
    input  in4,  input  in5,  input  in6,  input  in7,
    input  in8,  input  in9,  input  in10, input  in11,
    input  in12, input  in13, input  in14, input  in15,
    input  [3:0] sel,
    output y
);

wire lo, hi;

mux8to1 mux_lo (
    .in0(in0), .in1(in1), .in2(in2), .in3(in3),
    .in4(in4), .in5(in5), .in6(in6), .in7(in7),
    .sel(sel[2:0]), .y(lo)
);

mux8to1 mux_hi (
    .in0(in8),  .in1(in9),  .in2(in10), .in3(in11),
    .in4(in12), .in5(in13), .in6(in14), .in7(in15),
    .sel(sel[2:0]), .y(hi)
);

mux2to1 mux_top (.a(lo), .b(hi), .sel(sel[3]), .y(y));

endmodule
