`timescale 1ns/1ps

module opsel4_tb;

reg  [2:0] codigo;
reg  [3:0] suma, resta, resta_inv, shift_left, shift_right;
wire [3:0] y;

opsel4 uut (
    .codigo(codigo),
    .suma(suma),
    .resta(resta),
    .resta_inv(resta_inv),
    .shift_left(shift_left),
    .shift_right(shift_right),
    .y(y)
);

task probar;
    input [2:0] vcodigo;
    input [3:0] esperado;
    begin
        codigo = vcodigo;
        #10;
        if (y !== esperado)
            $display("FAIL opsel4: codigo=%b esperado=%b obtenido=%b", vcodigo, esperado, y);
        else
            $display("PASS opsel4: codigo=%b -> %b", vcodigo, y);
    end
endtask

initial begin

    $dumpfile("opsel4_tb.vcd");
    $dumpvars(0, opsel4_tb);

    // buses de entrada con patrones distintos para detectar cruces de bits
    suma        = 4'b1000;
    resta       = 4'b0100;
    resta_inv   = 4'b0010;
    shift_left  = 4'b0001;
    shift_right = 4'b1111;

    probar(3'b000, 4'b0000); // reinicio
    probar(3'b001, suma);
    probar(3'b010, resta);
    probar(3'b011, resta_inv);
    probar(3'b100, shift_left);
    probar(3'b101, shift_right);
    probar(3'b110, 4'b0000); // no definido -> alias de reinicio (decision del grupo)
    probar(3'b111, 4'b0000); // no definido -> alias de reinicio (decision del grupo)

    $finish;

end

endmodule
