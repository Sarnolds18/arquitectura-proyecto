module calculadora_4bits (
    input  wire       clk,
    input  wire       ejecutar,
    input  wire [2:0] codigo,
    input  wire       sel_op2,
    input  wire [3:0] op1,
    input  wire [3:0] op2_ext,
    output wire [3:0] resultado,
    output wire       overflow
);

wire [3:0] op2;

wire [3:0] suma;
wire       cout_suma;

wire [3:0] resta;
wire [3:0] resta_inv;
wire       cout_resta;
wire       cout_resta_inv;

wire [3:0] shift_left;
wire [3:0] shift_right;

wire [3:0] siguiente_resultado;

// segundo operando: op2_ext (sel_op2=0) o el resultado anterior (sel_op2=1)
op2sel4 sel_op2_inst (
    .sel_op2(sel_op2),
    .op2_ext(op2_ext),
    .resultado_anterior(resultado),
    .op2(op2)
);

adder4 sumador (.a(op1), .b(op2), .cin(1'b0), .sum(suma), .cout(cout_suma));

restador4 restador (
    .a(op1), .b(op2),
    .resta(resta), .resta_inv(resta_inv),
    .cout_resta(cout_resta), .cout_resta_inv(cout_resta_inv)
);

shifter4 desplazador_izq (.a(op1), .amount(op2[1:0]), .dir(1'b0), .y(shift_left));
shifter4 desplazador_der (.a(op1), .amount(op2[1:0]), .dir(1'b1), .y(shift_right));

// codigo: 000=reinicio 001=suma 010=resta 011=resta_inv 100=shl 101=shr
// 110/111 = alias de reinicio (ver src/opsel4.v)
opsel4 selector_operacion (
    .codigo(codigo),
    .suma(suma),
    .resta(resta),
    .resta_inv(resta_inv),
    .shift_left(shift_left),
    .shift_right(shift_right),
    .y(siguiente_resultado)
);

// registro de resultado: carga siguiente_resultado en cada pulso de ejecutar
registro4 registro (
    .clk(clk),
    .ejecutar(ejecutar),
    .d(siguiente_resultado),
    .q(resultado)
);

// indicador de overflow con signo (opcional, sugerido por el profesor):
// combinacional sobre op1/op2/codigo actuales, igual que led_codigo ya se
// muestra en vivo mientras se edita, no solo tras ejecutar.
overflow_detect ov (
    .codigo(codigo),
    .op1(op1),
    .op2(op2),
    .suma(suma),
    .resta(resta),
    .resta_inv(resta_inv),
    .overflow(overflow)
);

endmodule
