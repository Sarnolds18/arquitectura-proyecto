`timescale 1ns/1ps

module overflow_detect_tb;

reg  [2:0] codigo;
reg  [3:0] op1, op2;
wire [3:0] suma, resta, resta_inv, shift_left, shift_right;
wire       cout_suma, cout_resta, cout_resta_inv;
wire       overflow;

adder4    sumador  (.a(op1), .b(op2), .cin(1'b0), .sum(suma), .cout(cout_suma));
restador4 restador (.a(op1), .b(op2), .resta(resta), .resta_inv(resta_inv), .cout_resta(cout_resta), .cout_resta_inv(cout_resta_inv));

overflow_detect uut (
    .codigo(codigo), .op1(op1), .op2(op2),
    .suma(suma), .resta(resta), .resta_inv(resta_inv),
    .overflow(overflow)
);

localparam REINICIO  = 3'b000;
localparam SUMA      = 3'b001;
localparam RESTA     = 3'b010;
localparam RESTA_INV = 3'b011;
localparam SHL       = 3'b100;

integer errores = 0;

task automatic probar;
    input [2:0] cod;
    input [3:0] a;
    input [3:0] b;
    input       esperado;
    input [127:0] nombre;
    begin
        codigo = cod; op1 = a; op2 = b;
        #1;
        if (overflow !== esperado) begin
            $display("FAIL %0s: codigo=%b op1=%b op2=%b esperado=%b obtenido=%b", nombre, cod, a, b, esperado, overflow);
            errores = errores + 1;
        end else begin
            $display("PASS %0s", nombre);
        end
    end
endtask

initial begin
    $dumpfile("overflow_detect_tb.vcd");
    $dumpvars(0, overflow_detect_tb);

    // suma: 7 + 3 = 10 (fuera de rango con signo [-8,7]) -> overflow
    probar(SUMA, 4'b0111, 4'b0011, 1'b1, "suma 7+3 overflow");
    // suma: -8 + -3 = -11 (fuera de rango) -> overflow
    probar(SUMA, 4'b1000, 4'b1101, 1'b1, "suma -8+(-3) overflow");
    // suma: 3 + 4 = 7 (dentro de rango) -> sin overflow
    probar(SUMA, 4'b0011, 4'b0100, 1'b0, "suma 3+4 sin overflow");
    // suma: signos distintos nunca da overflow
    probar(SUMA, 4'b0111, 4'b1000, 1'b0, "suma signos distintos sin overflow");

    // resta (A-B): 5 - (-5) = 10 (fuera de rango) -> overflow
    probar(RESTA, 4'b0101, 4'b1011, 1'b1, "resta 5-(-5) overflow");
    // resta: -8 - 1 = -9 (fuera de rango) -> overflow
    probar(RESTA, 4'b1000, 4'b0001, 1'b1, "resta -8-1 overflow");
    // resta normal sin overflow
    probar(RESTA, 4'b0101, 4'b0010, 1'b0, "resta 5-2 sin overflow");

    // resta_inv (B-A): mismo criterio con A y B intercambiados
    probar(RESTA_INV, 4'b1011, 4'b0101, 1'b1, "resta_inv 5-(-5) overflow");
    probar(RESTA_INV, 4'b0010, 4'b0101, 1'b0, "resta_inv 5-2 sin overflow");

    // shift y reinicio no aplican overflow con signo -> siempre 0
    probar(SHL,      4'b0111, 4'b0011, 1'b0, "shift no aplica overflow");
    probar(REINICIO, 4'b0111, 4'b0011, 1'b0, "reinicio no aplica overflow");

    if (errores == 0)
        $display("LOS TESTS DE OVERFLOW PASARON!");
    else
        $display("FALLARON %0d TESTS DE OVERFLOW", errores);

    $finish;
end

endmodule
