module mux2to1(
    input  a,
    input  b,
    input  sel,
    output y
);

wire sel_n;
wire t0, t1;

not (sel_n, sel);
and (t0, a, sel_n);
and (t1, b, sel);
or  (y, t0, t1);

endmodule
