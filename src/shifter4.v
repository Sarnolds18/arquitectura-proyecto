module shifter4(
    input  [3:0] a,
    input  [1:0] amount,   // B[1:0], 0-3 posiciones
    input        dir,      // 0 = left, 1 = right
    output [3:0] y
);

// Etapa 0: desplazamiento de 1 posicion, controlado por amount[0]
wire [3:0] a_shl1, a_shr1;
wire [3:0] stage0;

// shift left 1: bit0<-0, resto se corre hacia bits altos
assign a_shl1[0] = 1'b0;
assign a_shl1[1] = a[0];
assign a_shl1[2] = a[1];
assign a_shl1[3] = a[2];

// shift right 1: bit3<-0, resto se corre hacia bits bajos
assign a_shr1[3] = 1'b0;
assign a_shr1[2] = a[3];
assign a_shr1[1] = a[2];
assign a_shr1[0] = a[1];

wire [3:0] shl1, shr1;
mux2to1 m_dir0_0 (.a(a[0]), .b(a_shr1[0]), .sel(dir), .y(shr1[0]));
mux2to1 m_dir0_1 (.a(a[1]), .b(a_shr1[1]), .sel(dir), .y(shr1[1]));
mux2to1 m_dir0_2 (.a(a[2]), .b(a_shr1[2]), .sel(dir), .y(shr1[2]));
mux2to1 m_dir0_3 (.a(a[3]), .b(a_shr1[3]), .sel(dir), .y(shr1[3]));

// selecciona entre "sin desplazar" y "desplazado 1 en la direccion dir"
wire [3:0] noshift1;
mux2to1 m_pick0_0 (.a(a[0]), .b(a_shl1[0]), .sel(dir), .y(noshift1[0]));
mux2to1 m_pick0_1 (.a(a[1]), .b(a_shl1[1]), .sel(dir), .y(noshift1[1]));
mux2to1 m_pick0_2 (.a(a[2]), .b(a_shl1[2]), .sel(dir), .y(noshift1[2]));
mux2to1 m_pick0_3 (.a(a[3]), .b(a_shl1[3]), .sel(dir), .y(noshift1[3]));

mux2to1 m_amt0_0 (.a(a[0]),        .b(noshift1[0]), .sel(amount[0]), .y(stage0[0]));
mux2to1 m_amt0_1 (.a(a[1]),        .b(noshift1[1]), .sel(amount[0]), .y(stage0[1]));
mux2to1 m_amt0_2 (.a(a[2]),        .b(noshift1[2]), .sel(amount[0]), .y(stage0[2]));
mux2to1 m_amt0_3 (.a(a[3]),        .b(noshift1[3]), .sel(amount[0]), .y(stage0[3]));

// Etapa 1: desplazamiento de 2 posiciones sobre stage0, controlado por amount[1]
wire [3:0] stage0_shl2, stage0_shr2, stage0_shift2;

assign stage0_shl2[0] = 1'b0;
assign stage0_shl2[1] = 1'b0;
assign stage0_shl2[2] = stage0[0];
assign stage0_shl2[3] = stage0[1];

assign stage0_shr2[3] = 1'b0;
assign stage0_shr2[2] = 1'b0;
assign stage0_shr2[1] = stage0[3];
assign stage0_shr2[0] = stage0[2];

mux2to1 m_dir1_0 (.a(stage0_shl2[0]), .b(stage0_shr2[0]), .sel(dir), .y(stage0_shift2[0]));
mux2to1 m_dir1_1 (.a(stage0_shl2[1]), .b(stage0_shr2[1]), .sel(dir), .y(stage0_shift2[1]));
mux2to1 m_dir1_2 (.a(stage0_shl2[2]), .b(stage0_shr2[2]), .sel(dir), .y(stage0_shift2[2]));
mux2to1 m_dir1_3 (.a(stage0_shl2[3]), .b(stage0_shr2[3]), .sel(dir), .y(stage0_shift2[3]));

mux2to1 m_amt1_0 (.a(stage0[0]), .b(stage0_shift2[0]), .sel(amount[1]), .y(y[0]));
mux2to1 m_amt1_1 (.a(stage0[1]), .b(stage0_shift2[1]), .sel(amount[1]), .y(y[1]));
mux2to1 m_amt1_2 (.a(stage0[2]), .b(stage0_shift2[2]), .sel(amount[1]), .y(y[2]));
mux2to1 m_amt1_3 (.a(stage0[3]), .b(stage0_shift2[3]), .sel(amount[1]), .y(y[3]));

endmodule
