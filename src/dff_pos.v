// Flip-flop D disparado por flanco de subida, maestro-esclavo con NAND.
module dff_pos(
    input  clk,
    input  d,
    output q
);

wire clk_n, d_n;
wire m_set, m_reset, m_q, m_qn;
wire s_set, s_reset, s_qn;

not (clk_n, clk);
not (d_n, d);

// latch maestro: transparente cuando clk=0
nand (m_set,   d,   clk_n);
nand (m_reset, d_n, clk_n);
nand (m_q,  m_set,   m_qn);
nand (m_qn, m_reset, m_q);

// latch esclavo: transparente cuando clk=1, copia al maestro en flanco de subida
nand (s_set,   m_q,  clk);
nand (s_reset, m_qn, clk);
nand (q,   s_set,   s_qn);
nand (s_qn, s_reset, q);

endmodule
