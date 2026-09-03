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
# Requiere el toolchain IceStorm (yosys, nextpnr-ice40, icepack, iceprog),
# que no esta instalado en este entorno de desarrollo (WSL) -- correr estos
# targets en una maquina que si lo tenga, o en el laboratorio del curso.

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

$(ASC): $(JSON) $(PCF)
	nextpnr-ice40 \
		--hx1k \
		--package vq100 \
		--json $(JSON) \
		--pcf $(PCF) \
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
