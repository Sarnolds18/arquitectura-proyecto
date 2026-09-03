module restador4(
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] resta,        // a - b
    output [3:0] resta_inv,    // b - a
    output       cout_resta,
    output       cout_resta_inv
);

wire [3:0] a_neg;
wire [3:0] b_neg;

not (b_neg[0], b[0]);
not (b_neg[1], b[1]);
not (b_neg[2], b[2]);
not (b_neg[3], b[3]);

not (a_neg[0], a[0]);
not (a_neg[1], a[1]);
not (a_neg[2], a[2]);
not (a_neg[3], a[3]);

// a - b = a + (~b) + 1 (complemento a dos)
adder4 add_ab (.a(a), .b(b_neg), .cin(1'b1), .sum(resta),     .cout(cout_resta));
// b - a = b + (~a) + 1
adder4 add_ba (.a(b), .b(a_neg), .cin(1'b1), .sum(resta_inv), .cout(cout_resta_inv));

endmodule
