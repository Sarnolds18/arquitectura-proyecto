`timescale 1ns/1ps

module mux8to1_tb;

reg  in0, in1, in2, in3, in4, in5, in6, in7;
reg  [2:0] sel;
wire y;

mux8to1 uut (
    .in0(in0), .in1(in1), .in2(in2), .in3(in3),
    .in4(in4), .in5(in5), .in6(in6), .in7(in7),
    .sel(sel), .y(y)
);

task probar_alto;
    // deja en 1 solo la entrada in_k (one-hot), sel=k, espera y=1
    input [2:0] k;
    begin
        {in0, in1, in2, in3, in4, in5, in6, in7} = 8'b0;
        case (k)
            0: in0 = 1'b1; 1: in1 = 1'b1; 2: in2 = 1'b1; 3: in3 = 1'b1;
            4: in4 = 1'b1; 5: in5 = 1'b1; 6: in6 = 1'b1; 7: in7 = 1'b1;
        endcase
        sel = k;
        #10;
        if (y !== 1'b1)
            $display("FAIL mux8to1 (alto): sel=%0d esperado=1 obtenido=%b", k, y);
        else
            $display("PASS mux8to1 (alto): sel=%0d -> %b", k, y);
    end
endtask

task probar_bajo;
    // deja en 1 todas menos in_k, sel=k, espera y=0
    input [2:0] k;
    begin
        {in0, in1, in2, in3, in4, in5, in6, in7} = 8'hFF;
        case (k)
            0: in0 = 1'b0; 1: in1 = 1'b0; 2: in2 = 1'b0; 3: in3 = 1'b0;
            4: in4 = 1'b0; 5: in5 = 1'b0; 6: in6 = 1'b0; 7: in7 = 1'b0;
        endcase
        sel = k;
        #10;
        if (y !== 1'b0)
            $display("FAIL mux8to1 (bajo): sel=%0d esperado=0 obtenido=%b", k, y);
        else
            $display("PASS mux8to1 (bajo): sel=%0d -> %b", k, y);
    end
endtask

integer i;

initial begin

    $dumpfile("mux8to1_tb.vcd");
    $dumpvars(0, mux8to1_tb);

    for (i = 0; i < 8; i = i + 1)
        probar_alto(i[2:0]);

    for (i = 0; i < 8; i = i + 1)
        probar_bajo(i[2:0]);

    $finish;

end

endmodule
