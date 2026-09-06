`timescale 1ns/1ps

module seven_seg_signo_tb;

reg  signo;
wire seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g;

seven_seg_signo uut (
    .signo(signo),
    .seg_a(seg_a), .seg_b(seg_b), .seg_c(seg_c), .seg_d(seg_d),
    .seg_e(seg_e), .seg_f(seg_f), .seg_g(seg_g)
);

initial begin
    $dumpfile("seven_seg_signo_tb.vcd");
    $dumpvars(0, seven_seg_signo_tb);

    signo = 1'b0;
    #10;
    if ({seg_a,seg_b,seg_c,seg_d,seg_e,seg_f,seg_g} !== 7'b0000000)
        $display("FAIL signo=0: esperado todo apagado, obtenido %b%b%b%b%b%b%b", seg_a,seg_b,seg_c,seg_d,seg_e,seg_f,seg_g);
    else
        $display("PASS signo=0: todo apagado");

    signo = 1'b1;
    #10;
    if ({seg_a,seg_b,seg_c,seg_d,seg_e,seg_f,seg_g} !== 7'b0000001)
        $display("FAIL signo=1: esperado solo g, obtenido %b%b%b%b%b%b%b", seg_a,seg_b,seg_c,seg_d,seg_e,seg_f,seg_g);
    else
        $display("PASS signo=1: solo g encendido (guion)");

    $finish;
end

endmodule
