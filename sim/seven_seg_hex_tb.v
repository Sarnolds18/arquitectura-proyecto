`timescale 1ns/1ps

module seven_seg_hex_tb;

reg [3:0] in;
wire seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g;

seven_seg_hex uut (
    .in(in),
    .seg_a(seg_a), .seg_b(seg_b), .seg_c(seg_c), .seg_d(seg_d),
    .seg_e(seg_e), .seg_f(seg_f), .seg_g(seg_g)
);

// patrones esperados abcdefg, activo-alto, tabla estandar de 7 segmentos
reg [6:0] esperado;
reg [6:0] obtenido;
integer i;
integer fallos;

initial begin
    $dumpfile("seven_seg_hex_tb.vcd");
    $dumpvars(0, seven_seg_hex_tb);

    fallos = 0;

    for (i = 0; i < 16; i = i + 1) begin
        in = i[3:0];
        #10;
        obtenido = {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g};

        case (i)
            0:  esperado = 7'b1111110;
            1:  esperado = 7'b0110000;
            2:  esperado = 7'b1101101;
            3:  esperado = 7'b1111001;
            4:  esperado = 7'b0110011;
            5:  esperado = 7'b1101011;
            6:  esperado = 7'b1101111;
            7:  esperado = 7'b1110000;
            8:  esperado = 7'b1111111;
            9:  esperado = 7'b1111011;
            10: esperado = 7'b1110111; // A
            11: esperado = 7'b0011111; // b
            12: esperado = 7'b1001110; // C
            13: esperado = 7'b0111101; // d
            14: esperado = 7'b1001111; // E
            15: esperado = 7'b1000111; // F
        endcase

        if (obtenido !== esperado) begin
            $display("FAIL in=%0d(%h): esperado=%b obtenido=%b", i, i, esperado, obtenido);
            fallos = fallos + 1;
        end else begin
            $display("PASS in=%0d(%h): abcdefg=%b", i, i, obtenido);
        end
    end

    if (fallos == 0)
        $display("TODOS LOS DIGITOS PASARON");
    else
        $display("%0d DIGITOS FALLARON", fallos);

    $finish;
end

endmodule
