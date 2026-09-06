`timescale 1ns/1ps

module calculadora_4bits_tb_extra;

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

  localparam REINICIO   = 3'b000;
  localparam SUMA       = 3'b001;
  localparam RESTA      = 3'b010;
  localparam RESTA_INV  = 3'b011;
  localparam SHL        = 3'b100;
  localparam SHR        = 3'b101;
  localparam NODEF6     = 3'b110;
  localparam NODEF7     = 3'b111;

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
    input       sel2;
    input [3:0] a;
    input [3:0] b;
    input [3:0] esperado;
    input string nombre;
    begin
      codigo  = cod;
      sel_op2 = sel2;
      op1     = a;
      op2_ext = b;

      pulso_ejecutar();

      if (resultado !== esperado) begin
        $display("FAIL %s", nombre);
        $display("  codigo   = %b", cod);
        $display("  sel_op2  = %b", sel2);
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
    $dumpfile("calculadora_4bits_tb_extra.vcd");
    $dumpvars(0, calculadora_4bits_tb_extra);

    clk = 1'b0;
    ejecutar = 1'b0;
    codigo = 3'b000;
    sel_op2 = 1'b0;
    op1 = 4'b0000;
    op2_ext = 4'b0000;

    repeat (2) @(posedge clk);

    // resta inversa (no cubierta por el tb oficial)
    probar(RESTA_INV, 1'b0, 4'b0010, 4'b0101, 4'b0011, "resta_inv 5 - 2 = 3");
    probar(RESTA_INV, 1'b0, 4'b0101, 4'b0010, 4'b1101, "resta_inv 2 - 5 = -3");

    // shift left / right (no cubiertas por el tb oficial)
    probar(SHL, 1'b0, 4'b0011, 4'b0001, 4'b0110, "shl 0011 << 1 = 0110");
    probar(SHL, 1'b0, 4'b0001, 4'b0011, 4'b1000, "shl 0001 << 3 = 1000");
    probar(SHR, 1'b0, 4'b1000, 4'b0001, 4'b0100, "shr 1000 >> 1 = 0100");
    probar(SHR, 1'b0, 4'b1100, 4'b0010, 4'b0011, "shr 1100 >> 2 = 0011");

    // reinicio explicito y alias 110/111
    probar(SUMA,     1'b0, 4'b0011, 4'b0001, 4'b0100, "suma 3+1=4 (deja resultado=4 para el siguiente caso)");
    probar(REINICIO, 1'b0, 4'b1111, 4'b1111, 4'b0000, "reinicio -> 0000");
    probar(SUMA,     1'b0, 4'b0011, 4'b0001, 4'b0100, "suma 3+1=4 (deja resultado=4 de nuevo)");
    probar(NODEF6,   1'b0, 4'b1111, 4'b1111, 4'b0000, "codigo 110 (no definido) -> alias de reinicio");
    probar(SUMA,     1'b0, 4'b0011, 4'b0001, 4'b0100, "suma 3+1=4 (deja resultado=4 de nuevo)");
    probar(NODEF7,   1'b0, 4'b1111, 4'b1111, 4'b0000, "codigo 111 (no definido) -> alias de reinicio");

    // sel_op2=1: usar el resultado anterior como segundo operando
    probar(SUMA, 1'b0, 4'b0010, 4'b0011, 4'b0101, "suma 2+3=5 (deja resultado=5)");
    probar(SUMA, 1'b1, 4'b0001, 4'b1111, 4'b0110, "sel_op2=1: 1 + resultado_anterior(5) = 6 (op2_ext=1111 se ignora)");

    $display("LOS TESTS EXTRA PASARON!");
    $finish;
  end

endmodule
