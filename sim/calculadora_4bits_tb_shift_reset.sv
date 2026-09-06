`timescale 1ns/1ps

module calculadora_4bits_tb_shift_reset;

  logic clk;
  logic ejecutar;
  logic [2:0] codigo;
  logic sel_op2;
  logic [3:0] op1;
  logic [3:0] op2_ext;
  logic [3:0] resultado;

  calculadora_4bits dut (
    .clk(clk),
    .ejecutar(ejecutar),
    .codigo(codigo),
    .sel_op2(sel_op2),
    .op1(op1),
    .op2_ext(op2_ext),
    .resultado(resultado)
  );

  localparam REINICIO    = 3'b000;
  localparam SUMA        = 3'b001;
  localparam SHIFT_LEFT  = 3'b100;
  localparam SHIFT_RIGHT = 3'b101;

  always #5 clk = ~clk;

  task automatic pulso_ejecutar;
    begin
      ejecutar = 1'b1;
      @(posedge clk);
      #1;
      ejecutar = 1'b0;
      @(posedge clk);
      #1;
    end
  endtask

  task automatic probar;
    input [2:0] cod;
    input [3:0] a;
    input [3:0] b;
    input [3:0] esperado;
    input string nombre;
    begin
      codigo  = cod;
      sel_op2 = 1'b0;
      op1     = a;
      op2_ext = b;

      pulso_ejecutar();

      if (resultado !== esperado) begin
        $display("FAIL %s", nombre);
        $display("  codigo   = %b", cod);
        $display("  op1      = %b", a);
        $display("  op2_ext  = %b", b);
        $display("  esperado = %b", esperado);
        $display("  obtenido = %b", resultado);
        $fatal;
      end else begin
        $display("PASS %s: resultado = %b", nombre, resultado);
      end
    end
  endtask

  initial begin
    $dumpfile("calculadora_4bits_tb_shift_reset.vcd");
    $dumpvars(0, calculadora_4bits_tb_shift_reset);

    clk = 1'b0;
    ejecutar = 1'b0;
    codigo = 3'b000;
    sel_op2 = 1'b0;
    op1 = 4'b0000;
    op2_ext = 4'b0000;

    repeat (2) @(posedge clk);

    // shift left: A << B[1:0], B[1:0] llega en op2_ext[1:0]
    probar(SHIFT_LEFT,  4'b0001, 4'b0000, 4'b0001, "shift left 0001 << 0 = 0001");
    probar(SHIFT_LEFT,  4'b0001, 4'b0001, 4'b0010, "shift left 0001 << 1 = 0010");
    probar(SHIFT_LEFT,  4'b0001, 4'b0011, 4'b1000, "shift left 0001 << 3 = 1000");
    probar(SHIFT_LEFT,  4'b1111, 4'b0011, 4'b1000, "shift left con overflow 1111 << 3 = 1000");

    // shift right: A >> B[1:0]
    probar(SHIFT_RIGHT, 4'b1000, 4'b0000, 4'b1000, "shift right 1000 >> 0 = 1000");
    probar(SHIFT_RIGHT, 4'b1000, 4'b0001, 4'b0100, "shift right 1000 >> 1 = 0100");
    probar(SHIFT_RIGHT, 4'b1000, 4'b0011, 4'b0001, "shift right 1000 >> 3 = 0001");
    probar(SHIFT_RIGHT, 4'b1111, 4'b0011, 4'b0001, "shift right con overflow 1111 >> 3 = 0001");

    // reinicio: siempre 0000, sin importar op1/op2
    probar(REINICIO, 4'b1010, 4'b0101, 4'b0000, "reinicio con operandos no nulos = 0000");
    probar(REINICIO, 4'b1111, 4'b1111, 4'b0000, "reinicio con operandos en -1 = 0000");

    // reinicio despues de un resultado no nulo, para confirmar que limpia el registro
    probar(SUMA,     4'b0011, 4'b0100, 4'b0111, "suma previa 3 + 4 = 7 antes de reiniciar");
    probar(REINICIO, 4'b0000, 4'b0000, 4'b0000, "reinicio tras suma previa = 0000");

    $display("LOS TESTS DE SHIFT Y REINICIO PASARON!");
    $finish;
  end

endmodule
