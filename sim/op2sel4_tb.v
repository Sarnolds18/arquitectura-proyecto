`timescale 1ns/1ps

module op2sel4_tb;

reg        sel_op2;
reg  [3:0] op2_ext;
reg  [3:0] resultado_anterior;
wire [3:0] op2;

op2sel4 uut (
    .sel_op2(sel_op2),
    .op2_ext(op2_ext),
    .resultado_anterior(resultado_anterior),
    .op2(op2)
);

task probar;
    input       vsel;
    input [3:0] vext;
    input [3:0] vant;
    input [3:0] esperado;
    begin
        sel_op2 = vsel;
        op2_ext = vext;
        resultado_anterior = vant;
        #10;

        if (op2 !== esperado)
            $display("FAIL op2sel4: sel_op2=%b op2_ext=%b resultado_anterior=%b esperado=%b obtenido=%b", vsel, vext, vant, esperado, op2);
        else
            $display("PASS op2sel4: sel_op2=%b op2_ext=%b resultado_anterior=%b -> %b", vsel, vext, vant, op2);
    end
endtask

initial begin

    $dumpfile("op2sel4_tb.vcd");
    $dumpvars(0, op2sel4_tb);

    // patrones complementarios para detectar cualquier cruce de bits
    probar(1'b0, 4'b0101, 4'b1010, 4'b0101); // sel=0 -> usa op2_ext
    probar(1'b1, 4'b0101, 4'b1010, 4'b1010); // sel=1 -> usa resultado anterior

    probar(1'b0, 4'b1111, 4'b0000, 4'b1111);
    probar(1'b1, 4'b1111, 4'b0000, 4'b0000);

    probar(1'b0, 4'b0000, 4'b1111, 4'b0000);
    probar(1'b1, 4'b0000, 4'b1111, 4'b1111);

    $finish;

end

endmodule
