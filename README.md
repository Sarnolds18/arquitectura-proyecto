# Proyecto 1 - Arquitectura de Computadores

## Diseño Lógico y FPGA

Calculadora de 4 bits implementada en Verilog utilizando compuertas lógicas, para
implementar en una FPGA Lattice iCE40 HX1K de la Nandland Go Board.

### Integrantes

- Santiago Arnolds
- Lucas Nestler
- Matias Veto

### Estructura del repositorio

```
proyecto1/
├── Makefile               # Automatiza compilar, simular, sintetizar y programar la FPGA
├── src/                   # Módulos de diseño (Verilog)
│   ├── full_adder.v       # Sumador completo de 1 bit
│   └── adder4.v           # Sumador de 4 bits (ripple-carry sobre full_adder)
├── sim/                   # Testbenches
│   ├── full_adder_tb.v
│   ├── adder4_tb.v
│   └── calculadora_4bits_tb_basico.sv   # Testbench de referencia (entregado por el curso)
├── constraints/
│   └── go-board.pcf       # Pines de la Nandland Go Board (pendiente de completar)
└── build/                 # Artefactos generados (ignorado por git)
```

El módulo top-level `calculadora_4bits` (con la interfaz que espera el testbench
de referencia) todavía no existe — es el próximo paso grande del proyecto.

### Requisitos

- [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`, `vvp`) — con soporte
  `-g2012` (SystemVerilog), necesario para el testbench de referencia.
- [GTKWave](http://gtkwave.sourceforge.net/) para ver las formas de onda.
- Para sintetizar y programar la FPGA real: toolchain IceStorm
  (`yosys`, `nextpnr-ice40`, `icepack`, `iceprog`). No es necesario para simular.

### Simulación

Con `make` (recomendado):

```bash
# Simula el entregable final (calculadora_4bits + testbench de referencia).
# Todavía falla porque calculadora_4bits.v no existe aún.
make sim

# Simular un submódulo suelto durante el desarrollo:
make sim  TOP=adder4 TB=sim/adder4_tb.v
make wave TOP=adder4 TB=sim/adder4_tb.v      # además abre GTKWave

make sim  TOP=full_adder TB=sim/full_adder_tb.v
make wave TOP=full_adder TB=sim/full_adder_tb.v

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

```bash
make synth      # yosys: genera build/calculadora_4bits.json
make pnr        # nextpnr-ice40: place & route -> build/calculadora_4bits.asc
make bitstream  # icepack: genera build/calculadora_4bits.bin
make prog       # iceprog: programa la Go Board
```

Requiere el toolchain IceStorm instalado y la FPGA conectada; no está disponible
en todos los entornos de desarrollo (por ejemplo, no está instalado en WSL en
este momento — probar en el laboratorio del curso o instalarlo aparte).
