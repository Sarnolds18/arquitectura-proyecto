module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

wire x1;
wire c1;
wire c2;

xor (x1, a, b);
xor (sum, x1, cin);

and (c1, a, b);
and (c2, x1, cin);

or (cout, c1, c2);

endmodule