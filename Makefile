# TOP y TB tienen como default el entregable final (la calculadora completa
# con el testbench de referencia de los ayudantes). Para simular un submodulo
# suelto durante el desarrollo, sobreescribir por linea de comando, ej:
#   make sim  TOP=adder4  TB=sim/adder4_tb.v
#   make wave TOP=adder4  TB=sim/adder4_tb.v VCD=adder4.vcd
TOP      ?= calculadora_4bits
TB       ?= sim/calculadora_4bits_tb_basico.sv
TB_TOP   := $(basename $(notdir $(TB)))
VCD      ?= $(TB_TOP).vcd
PCF      := constraints/go-board.pcf

SRC      := $(wildcard src/*.v)
BUILD    := build
SIM      := $(BUILD)/$(TB_TOP)
JSON     := $(BUILD)/$(TOP).json
ASC      := $(BUILD)/$(TOP).asc
BIN      := $(BUILD)/$(TOP).bin

.PHONY: all sim wave synth pnr bitstream prog clean check

all: bitstream

$(BUILD):
	mkdir -p $(BUILD)

# ---------------------------------------------------------
# Simulacion
# ---------------------------------------------------------
# -s $(TB_TOP) fija explicitamente cual testbench es la raiz de la
# simulacion, para que compilar todo src/*.v junto no arrastre otros
# testbenches sueltos en sim/ como raices adicionales.

$(SIM): $(SRC) $(TB) | $(BUILD)
	iverilog \
		-g2012 \
		-Wall \
		-s $(TB_TOP) \
		-o $(SIM) \
		$(SRC) $(TB)

sim: $(SIM)
	vvp $(SIM)

wave: sim
	gtkwave $(VCD)

# ---------------------------------------------------------
# Sintesis FPGA (yosys + nextpnr-ice40 + icestorm)
# ---------------------------------------------------------
# Requiere el toolchain IceStorm (yosys, nextpnr-ice40, icepack, iceprog).
# Instalado y probado en este entorno de desarrollo desde 2026-09-03 -- solo
# falta acceso USB a la placa fisica para el target `prog` (ver README/
# CLAUDE.md).

$(JSON): $(SRC) | $(BUILD)
	yosys -p "read_verilog $(SRC); \
	          synth_ice40 \
	          -top $(TOP) \
	          -abc2 \
	          -relut \
	          -dffe_min_ce_use 4 \
	          -json $(JSON); \
	          stat"

synth: $(JSON)

# ---------------------------------------------------------
# Place and route
# ---------------------------------------------------------

# --no-promote-globals: sin este flag, nextpnr intenta promover el reset y
# el enable de cada uno de los 4 contadores internos de `debouncer` (dentro
# de `top_fpga`) a buffers globales dedicados (SB_GB) y se queda sin
# suficientes (la iCE40 HX1K solo tiene 8) -- falla con "Unable to find
# legal placement". A 25MHz hay margen de timing de sobra (el diseno cierra
# limpio a ~93MHz) para rutear esas senales por el fabric normal en vez de
# por buffers dedicados.
$(ASC): $(JSON) $(PCF)
	nextpnr-ice40 \
		--hx1k \
		--package vq100 \
		--json $(JSON) \
		--pcf $(PCF) \
		--no-promote-globals \
		--asc $(ASC)

pnr: $(ASC)

# ---------------------------------------------------------
# Bitstream
# ---------------------------------------------------------

$(BIN): $(ASC)
	icepack $(ASC) $(BIN)

bitstream: $(BIN)

# ---------------------------------------------------------
# Programar la FPGA
# ---------------------------------------------------------

prog: $(BIN)
	iceprog $(BIN)

# ---------------------------------------------------------
# Utilidades
# ---------------------------------------------------------

check:
	iverilog \
		-g2012 \
		-Wall \
		-s $(TOP) \
		-tnull \
		$(SRC)

clean:
	rm -rf $(BUILD) *.vcd
