`timescale 1ns/1ps

module shifter4_tb;

reg  [3:0] a;
reg  [1:0] amount;
reg        dir;

wire [3:0] y;

shifter4 uut (
    .a(a),
    .amount(amount),
    .dir(dir),
    .y(y)
);

task probar;
    input [3:0] va;
    input       vdir;
    input [1:0] vamount;
    input [3:0] esperado;
    begin
        a = va;
        dir = vdir;
        amount = vamount;
        #10;

        if (y !== esperado)
            $display("FAIL shifter4: a=%b dir=%b amount=%b esperado=%b obtenido=%b", va, vdir, vamount, esperado, y);
        else
            $display("PASS shifter4: a=%b dir=%b amount=%b -> %b", va, vdir, vamount, y);
    end
endtask

initial begin

    $dumpfile("shifter4_tb.vcd");
    $dumpvars(0, shifter4_tb);

    // left shifts: 0001 << n
    probar(4'b0001, 1'b0, 2'd0, 4'b0001);
    probar(4'b0001, 1'b0, 2'd1, 4'b0010);
    probar(4'b0001, 1'b0, 2'd2, 4'b0100);
    probar(4'b0001, 1'b0, 2'd3, 4'b1000);

    // left shift con overflow: 1111 << 3 -> 1000 (se trunca a 4 bits)
    probar(4'b1111, 1'b0, 2'd3, 4'b1000);

    // right shifts: 1000 >> n
    probar(4'b1000, 1'b1, 2'd0, 4'b1000);
    probar(4'b1000, 1'b1, 2'd1, 4'b0100);
    probar(4'b1000, 1'b1, 2'd2, 4'b0010);
    probar(4'b1000, 1'b1, 2'd3, 4'b0001);

    // right shift con overflow: 1111 >> 3 -> 0001
    probar(4'b1111, 1'b1, 2'd3, 4'b0001);

    $finish;

end

endmodule
