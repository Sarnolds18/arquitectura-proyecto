# Proyecto 1 - Arquitectura de Computadores

## Diseño Lógico y FPGA

Calculadora de 4 bits implementada en Verilog utilizando exclusivamente compuertas
lógicas para la parte combinacional, para implementar en una FPGA Lattice iCE40
HX1K de la Nandland Go Board.

### Integrantes

- Santiago Arnolds
- Lucas Nestler
- Matias Veto

### Estructura del repositorio

```
arquitectura-proyecto/
├── Makefile                 # Automatiza compilar, simular, sintetizar y programar la FPGA
├── src/                     # Módulos de diseño (Verilog), a nivel de compuertas
│   ├── full_adder.v         # Sumador completo de 1 bit
│   ├── adder4.v             # Sumador de 4 bits (ripple-carry sobre full_adder)
│   ├── restador4.v          # Resta y resta inversa por complemento a 2, sobre adder4
│   ├── shifter4.v           # Barrel shifter de 4 bits
│   ├── mux2to1.v / mux8to1.v / mux16to1.v
│   ├── opsel4.v             # Selector de operación (código de 3 bits)
│   ├── op2sel4.v            # Selector de segundo operando
│   ├── overflow_detect.v    # Indicador de overflow con signo (opcional)
│   ├── dff_pos.v / dff_en.v / registro4.v   # Elementos secuenciales
│   ├── calculadora_4bits.v  # Núcleo de la calculadora (interfaz del tb oficial)
│   ├── signo_magnitud4.v / seven_seg_hex.v / seven_seg_signo.v  # Displays
│   ├── edge_detect.v / debouncer.v          # Soporte de entrada de botones
│   ├── contador_updown3.v / contador_updown4.v  # Contadores editables (código/op1/op2)
│   ├── fsm_entrada.v        # FSM del flujo de botones (SEL_OP → SEL_OP1 → SEL_OP2 → MOSTRAR)
│   └── top_fpga.v           # Top-level real de la FPGA: conecta todo lo anterior
├── sim/                     # Testbenches (uno por módulo, patrón <módulo>_tb.v)
│   └── calculadora_4bits_tb_basico.sv   # Testbench de referencia (entregado por el curso)
├── constraints/
│   └── go-board.pcf         # Pines reales de la Nandland Go Board (VQ100)
└── build/                   # Artefactos generados (ignorado por git)
```

El diseño completo está implementado: los 23 módulos en `src/` y su testbench
correspondiente en `sim/` (uno por módulo, más `top_fpga_tb.v` end-to-end).
`top_fpga.v` es el módulo top-level real que se sintetiza y programa en la
placa; `calculadora_4bits.v` es el núcleo combinacional/registrado que expone
la interfaz que espera el testbench de referencia del curso.

### Requisitos

- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`, `vvp`) — con soporte
  `-g2012` (SystemVerilog), necesario para el testbench de referencia.
- [GTKWave](http://gtkwave.sourceforge.net/) para ver las formas de onda.
- Toolchain IceStorm (`yosys`, `nextpnr-ice40`, `icepack`, `iceprog`) para
  sintetizar y programar la FPGA real. Instalada y probada en este entorno de
  desarrollo; solo `make prog` requiere acceso USB a la placa física.

### Simulación

Con `make` (recomendado):

```bash
# Simula el entregable final (calculadora_4bits + testbench de referencia del curso).
make sim

# Simular cualquier otro módulo/testbench del proyecto:
make sim  TOP=top_fpga TB=sim/top_fpga_tb.v          # flujo completo end-to-end
make sim  TOP=adder4   TB=sim/adder4_tb.v
make wave TOP=adder4   TB=sim/adder4_tb.v            # además abre GTKWave

make clean   # borra build/ y los .vcd generados
```

`make sim` compila con `iverilog` (sin salida si no hay errores) y corre con
`vvp` (ahí se ve el resultado y se genera el `.vcd`). `make wave` además abre
GTKWave. Si se prefiere no usar `make`, los comandos equivalentes son:

```bash
iverilog -g2012 -Wall -s adder4_tb -o build/adder4_tb src/*.v sim/adder4_tb.v
vvp build/adder4_tb
gtkwave adder4.vcd
```

El flag `-s <módulo>` es importante: fija explícitamente cuál testbench es la
raíz de la simulación. Sin él, compilar varios testbenches a la vez (con
`sim/*.v`) hace que el primero en llamar `$finish` corte la simulación de los
demás.

### Síntesis y FPGA

El top-level real para la FPGA es `top_fpga` (no `calculadora_4bits`, que es
solo el núcleo interno), así que hay que pasarlo explícitamente con `TOP`:

```bash
make synth     TOP=top_fpga   # yosys: genera build/top_fpga.json
make pnr       TOP=top_fpga   # nextpnr-ice40: place & route -> build/top_fpga.asc
make bitstream TOP=top_fpga   # icepack: genera build/top_fpga.bin
make prog      TOP=top_fpga   # iceprog: programa la Go Board
```

El flujo completo (`synth` → `pnr` → `bitstream` → `prog`) ya se validó de
punta a punta: sintetiza sin errores, el place & route cierra timing con
amplio margen sobre el reloj de 25 MHz de la placa, y la calculadora se
programó y probó en la Go Board física (2026-09-08) — las 6 operaciones, los
2 alias, operandos negativos, overflow real y el flujo de "usar resultado
anterior" funcionan correctamente en hardware.

`constraints/go-board.pcf` tiene los pines reales de la Nandland Go Board
(package VQ100) para clk, botones, LEDs y displays, ya verificados en la
placa física: el orden de los 4 botones y su polaridad (activo-alto)
resultaron correctos tal cual estaban; la polaridad del display de 7
segmentos sí estaba mal (la Go Board es de ánodo común, no activo-alto como
se había asumido) y ya se corrigió invirtiendo las 14 salidas de segmento en
`top_fpga.v`.
