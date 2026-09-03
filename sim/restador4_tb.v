`timescale 1ns/1ps

module restador4_tb;

reg  [3:0] a;
reg  [3:0] b;

wire [3:0] resta;
wire [3:0] resta_inv;
wire       cout_resta;
wire       cout_resta_inv;

restador4 uut (
    .a(a),
    .b(b),
    .resta(resta),
    .resta_inv(resta_inv),
    .cout_resta(cout_resta),
    .cout_resta_inv(cout_resta_inv)
);

task probar;
    input [3:0] va;
    input [3:0] vb;
    input [3:0] esperado_resta;
    input [3:0] esperado_resta_inv;
    begin
        a = va;
        b = vb;
        #10;

        if (resta !== esperado_resta)
            $display("FAIL resta:     a=%b b=%b esperado=%b obtenido=%b", va, vb, esperado_resta, resta);
        else
            $display("PASS resta:     a=%b b=%b -> %b", va, vb, resta);

        if (resta_inv !== esperado_resta_inv)
            $display("FAIL resta_inv: a=%b b=%b esperado=%b obtenido=%b", va, vb, esperado_resta_inv, resta_inv);
        else
            $display("PASS resta_inv: a=%b b=%b -> %b", va, vb, resta_inv);
    end
endtask

initial begin

    $dumpfile("restador4.vcd");
    $dumpvars(0, restador4_tb);

    // 5 - 2 = 3 ; 2 - 5 = -3
    probar(4'b0101, 4'b0010, 4'b0011, 4'b1101);

    // 2 - 5 = -3 ; 5 - 2 = 3 (mismo caso invertido, chequea simetria)
    probar(4'b0010, 4'b0101, 4'b1101, 4'b0011);

    // -5 - (-2) = -3 ; -2 - (-5) = 3 (caso del testbench oficial de referencia)
    probar(4'b1011, 4'b1110, 4'b1101, 4'b0011);

    // 7 - (-8) = 15 -> overflow, se quedan los 4 LSB = -1 (1111)
    // -8 - 7 = -15 -> overflow, se quedan los 4 LSB = 1 (0001)
    probar(4'b0111, 4'b1000, 4'b1111, 4'b0001);

    // 0 - 0 = 0
    probar(4'b0000, 4'b0000, 4'b0000, 4'b0000);

    $finish;

end

endmodule
