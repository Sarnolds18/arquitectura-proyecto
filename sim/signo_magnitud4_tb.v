`timescale 1ns/1ps

module signo_magnitud4_tb;

reg  [3:0] valor;
wire       signo;
wire [3:0] magnitud;

signo_magnitud4 uut (.valor(valor), .signo(signo), .magnitud(magnitud));

task probar;
    input [3:0] v;
    input       s_esp;
    input [3:0] m_esp;
    begin
        valor = v;
        #10;
        if (signo !== s_esp || magnitud !== m_esp) begin
            $display("FAIL valor=%b: esperado signo=%b magnitud=%b, obtenido signo=%b magnitud=%b",
                      v, s_esp, m_esp, signo, magnitud);
        end else begin
            $display("PASS valor=%b -> signo=%b magnitud=%b", v, signo, magnitud);
        end
    end
endtask

initial begin
    $dumpfile("signo_magnitud4_tb.vcd");
    $dumpvars(0, signo_magnitud4_tb);

    probar(4'b0000, 1'b0, 4'b0000); // 0
    probar(4'b0111, 1'b0, 4'b0111); // 7
    probar(4'b0001, 1'b0, 4'b0001); // 1
    probar(4'b1111, 1'b1, 4'b0001); // -1
    probar(4'b1110, 1'b1, 4'b0010); // -2
    probar(4'b1001, 1'b1, 4'b0111); // -7
    probar(4'b1000, 1'b1, 4'b1000); // -8, caso especial (documentado)

    $display("FIN signo_magnitud4_tb");
    $finish;
end

endmodule
