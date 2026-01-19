# RISC-V CPU ASIC Design

This directory contains the ASIC implementation of the RISC-V CPU using the OpenLane flow.

## Directory Structure

```
asic/
├── src/                    # RTL source files
│   ├── riscv_cpu.sv       # Top-level CPU module
│   ├── alu_core.sv        # ALU implementation
│   ├── alu_defs.svh       # ALU operation definitions
│   ├── control_unit.sv    # Instruction decoder
│   ├── register_file.sv   # 32x32 register file
│   ├── branch_comparator.sv # Branch comparison unit
│   └── immediate_generator.sv # Immediate extraction
├── sim/                    # Simulation files
│   ├── tb_riscv.sv        # Main testbench
│   ├── common_tasks.svh   # Shared test utilities
│   └── tests/             # Individual test files
├── config.json            # OpenLane configuration
├── constraint.sdc         # Timing constraints (SDC)
├── pin_order.cfg          # Pin placement configuration
├── Makefile               # Build automation
└── README.md              # This file
```

## Prerequisites

### 1. Install OpenLane 2.0+

```bash
# Using pip (recommended)
pip install openlane

# Or using Docker
docker pull efabless/openlane:latest
```

### 2. Install PDK (SkyWater 130nm)

```bash
# Using volare (recommended)
pip install volare
volare enable --pdk sky130 --pdk-root ~/.volare

# Set environment variable
export PDK_ROOT=~/.volare
export PDK=sky130A
```

## Usage

### Quick Start

```bash
# Run full RTL-to-GDSII flow
make harden

# Run synthesis only
make synth

# Interactive mode (for debugging)
make interactive

# Clean build artifacts
make clean
```

### Running with Docker

```bash
# Using the provided docker script
make docker-harden
```

### Simulation (pre-synthesis verification)

```bash
# Using Icarus Verilog
make sim

# View waveforms
make waves
```

## Design Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Target Clock | 50 MHz | 20ns period |
| PDK | sky130A | SkyWater 130nm |
| Core Utilization | 40% | Target density |
| Die Area | 500x500 µm | Approximate |

## Flow Stages

The OpenLane flow performs these stages:

1. **Synthesis** - RTL to gate-level netlist (Yosys)
2. **Floorplanning** - Die/core area, macro placement
3. **Placement** - Standard cell placement (OpenROAD)
4. **Clock Tree Synthesis** - CTS (OpenROAD)
5. **Routing** - Global and detailed routing (OpenROAD)
6. **Signoff** - DRC, LVS, timing analysis

## Output Files

After successful completion, find outputs in `runs/<tag>/`:

```
runs/<tag>/
├── final/
│   ├── gds/           # Final GDSII layout
│   ├── lef/           # Library Exchange Format
│   ├── def/           # Design Exchange Format
│   ├── nl/            # Final netlist
│   └── sdc/           # Final timing constraints
├── reports/           # Timing, area, power reports
└── logs/              # Detailed logs for each stage
```

## Customization

### Changing Clock Frequency

Edit `config.json`:
```json
"CLOCK_PERIOD": 20.0  // Change to desired period in ns
```

And `constraint.sdc`:
```tcl
create_clock -name clk -period 20.0 [get_ports clk]
```

### Changing Die Size

Edit `config.json`:
```json
"DIE_AREA": "0 0 500 500"  // x0 y0 x1 y1 in µm
```

### Pin Placement

Edit `pin_order.cfg` to control I/O pin locations.

## Troubleshooting

### Common Issues

1. **Synthesis fails with SystemVerilog errors**
   - Ensure you're using OpenLane 2.0+ with recent Yosys
   - Check for unsupported SV constructs

2. **Timing violations**
   - Increase clock period
   - Enable `SYNTH_STRATEGY` optimization
   - Check critical paths in timing reports

3. **Routing congestion**
   - Decrease `FP_CORE_UTIL`
   - Increase die area

### Getting Help

- [OpenLane Documentation](https://openlane2.readthedocs.io/)
- [SkyWater PDK Documentation](https://skywater-pdk.readthedocs.io/)
- [OpenROAD Documentation](https://openroad.readthedocs.io/)

## License

Same license as the parent RISC-V project.


