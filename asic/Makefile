# =============================================================================
# RISC-V CPU ASIC Makefile for OpenLane Flow
# =============================================================================

DESIGN_NAME := riscv_cpu
PDK ?= sky130A
PDK_ROOT ?= $(HOME)/.volare

# OpenLane paths
OPENLANE_ROOT ?= $(HOME)/OpenLane
OPENLANE_TAG := $(shell date +%Y%m%d_%H%M%S)

# Docker settings
DOCKER_IMAGE := efabless/openlane:latest
DOCKER_OPTIONS := --rm -v $(PWD):/work -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -w /work

# Simulation settings
SIM_TOP := tb_riscv
SIM_SRCS := $(wildcard src/*.sv) $(wildcard sim/*.sv)

# =============================================================================
# Main Targets
# =============================================================================

.PHONY: all harden synth interactive clean sim waves help

all: harden

help:
	@echo "RISC-V CPU ASIC Build System"
	@echo ""
	@echo "Main targets:"
	@echo "  make harden      - Run full RTL-to-GDSII flow"
	@echo "  make synth       - Run synthesis only"
	@echo "  make interactive - Run OpenLane in interactive mode"
	@echo "  make sim         - Run simulation (Icarus Verilog)"
	@echo "  make waves       - View simulation waveforms (GTKWave)"
	@echo "  make clean       - Remove build artifacts"
	@echo ""
	@echo "Docker targets:"
	@echo "  make docker-harden      - Run flow in Docker"
	@echo "  make docker-interactive - Interactive mode in Docker"
	@echo ""
	@echo "Configuration:"
	@echo "  PDK=$(PDK)"
	@echo "  PDK_ROOT=$(PDK_ROOT)"

# =============================================================================
# OpenLane Flow (Native)
# =============================================================================

harden:
	@echo "Running OpenLane flow..."
	openlane --pdk $(PDK) --pdk-root $(PDK_ROOT) config.json

synth:
	@echo "Running synthesis..."
	openlane --pdk $(PDK) --pdk-root $(PDK_ROOT) --last-run --flow Classic --to Synthesis config.json

interactive:
	@echo "Starting OpenLane interactive mode..."
	openlane --pdk $(PDK) --pdk-root $(PDK_ROOT) --interactive config.json

# =============================================================================
# OpenLane Flow (Docker)
# =============================================================================

docker-harden:
	@echo "Running OpenLane flow in Docker..."
	docker run $(DOCKER_OPTIONS) $(DOCKER_IMAGE) \
		openlane --pdk $(PDK) --pdk-root $(PDK_ROOT) config.json

docker-interactive:
	@echo "Starting OpenLane interactive mode in Docker..."
	docker run -it $(DOCKER_OPTIONS) $(DOCKER_IMAGE) \
		openlane --pdk $(PDK) --pdk-root $(PDK_ROOT) --interactive config.json

docker-shell:
	@echo "Opening shell in Docker container..."
	docker run -it $(DOCKER_OPTIONS) $(DOCKER_IMAGE) bash

# =============================================================================
# Simulation
# =============================================================================

sim: $(SIM_TOP).vvp
	@echo "Running simulation..."
	vvp $(SIM_TOP).vvp

$(SIM_TOP).vvp: $(SIM_SRCS)
	@echo "Compiling simulation..."
	iverilog -g2012 -o $@ \
		-I src \
		-I sim \
		-s $(SIM_TOP) \
		src/alu_core.sv \
		src/control_unit.sv \
		src/immediate_generator.sv \
		src/branch_comparator.sv \
		src/register_file.sv \
		src/riscv_cpu.sv \
		sim/tb_riscv.sv

waves: sim
	@echo "Opening waveform viewer..."
	gtkwave $(SIM_TOP).vcd &

# ChaCha20 full block test (larger memory)
sim-chacha20: tb_chacha20.vvp
	@echo "Running ChaCha20 full block simulation..."
	vvp tb_chacha20.vvp

tb_chacha20.vvp: $(SIM_SRCS) sim/tb_chacha20.sv
	@echo "Compiling ChaCha20 testbench..."
	iverilog -g2012 -o $@ \
		-I src \
		-I sim \
		-s tb_chacha20 \
		src/alu_core.sv \
		src/control_unit.sv \
		src/immediate_generator.sv \
		src/branch_comparator.sv \
		src/register_file.sv \
		src/riscv_cpu.sv \
		sim/tb_chacha20.sv

waves-chacha20: sim-chacha20
	@echo "Opening ChaCha20 waveform viewer..."
	gtkwave tb_chacha20.vcd &

# =============================================================================
# Reports
# =============================================================================

.PHONY: report-timing report-area report-power

report-timing:
	@echo "=== Timing Report ==="
	@cat runs/*/reports/signoff/*sta*.rpt 2>/dev/null || echo "No timing reports found. Run 'make harden' first."

report-area:
	@echo "=== Area Report ==="
	@cat runs/*/reports/signoff/*area*.rpt 2>/dev/null || echo "No area reports found. Run 'make harden' first."

report-power:
	@echo "=== Power Report ==="
	@cat runs/*/reports/signoff/*power*.rpt 2>/dev/null || echo "No power reports found. Run 'make harden' first."

# =============================================================================
# Cleanup
# =============================================================================

clean:
	@echo "Cleaning build artifacts..."
	rm -rf runs/
	rm -f *.vvp *.vcd *.fst *.lxt

clean-all: clean
	rm -rf openlane/
	rm -rf .openlane/

# =============================================================================
# Utilities
# =============================================================================

.PHONY: check-env lint

check-env:
	@echo "Checking environment..."
	@which openlane || echo "WARNING: openlane not found in PATH"
	@which iverilog || echo "WARNING: iverilog not found in PATH"
	@which gtkwave || echo "WARNING: gtkwave not found in PATH"
	@test -d $(PDK_ROOT) || echo "WARNING: PDK_ROOT does not exist: $(PDK_ROOT)"
	@echo "PDK: $(PDK)"
	@echo "PDK_ROOT: $(PDK_ROOT)"

lint:
	@echo "Running Verilator lint..."
	verilator --lint-only -Wall -Isrc src/*.sv


