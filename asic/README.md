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
├── config.tcl             # OpenLane 1.x configuration
├── config.json            # OpenLane 2.x configuration
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

# For OpenLane 1.x (Docker), use this specific version:
volare enable --pdk sky130 bdc9412b3e468c102d01b7cf6337be06ec6e9c9a --pdk-root ~/.volare

# For OpenLane 2.x, use latest:
volare enable --pdk sky130 --pdk-root ~/.volare

# Set environment variables
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

### Running with Docker (OpenLane 1.x)

```bash
# First, install the PDK using volare
pip install volare
volare enable --pdk sky130 bdc9412b3e468c102d01b7cf6337be06ec6e9c9a --pdk-root ~/.volare

# Run the full RTL-to-GDSII flow
cd ~/riscv/asic
sudo docker run --rm \
    -v $(pwd):/openlane/designs/riscv_cpu \
    -v ~/.volare:/home/root/.volare \
    -e PDK_ROOT=/home/root/.volare \
    -e PDK=sky130A \
    efabless/openlane:latest \
    bash -c "flow.tcl -design /openlane/designs/riscv_cpu -tag run1"

# To overwrite an existing run
sudo docker run --rm \
    -v $(pwd):/openlane/designs/riscv_cpu \
    -v ~/.volare:/home/root/.volare \
    -e PDK_ROOT=/home/root/.volare \
    -e PDK=sky130A \
    efabless/openlane:latest \
    bash -c "flow.tcl -design /openlane/designs/riscv_cpu -tag run1 -overwrite"

# To open the gui
sudo docker run --rm -it     -e DISPLAY=$DISPLAY     -v /tmp/.X11-unix:/tmp/.X11-unix     -v /home/rye20/riscv/asic:/work     -v ~/.volare:/home/root/.volare     -w /work     efabless/openlane:latest     openroad -gui

# Clean up root-owned run files
sudo rm -rf runs/

```

**Note:** Docker runs as root, so files in `runs/` will be owned by root. Use `sudo` to delete them or run `sudo chown -R $(whoami) runs/` to take ownership.

### Running with LibreLane (Nix)

LibreLane is the next-generation OpenLane infrastructure. Requires Nix installation.

```bash
# Enter nix-shell (from librelane repo)
nix-shell ~/librelane/shell.nix

# Run synthesis only
librelane --flow Classic --to Yosys.Synthesis ./config.json

# Run synthesis + STA for PPA metrics (Power, Performance, Area)
librelane --flow Classic --to OpenROAD.STAPrePNR ./config.json

# Run full RTL-to-GDSII flow
librelane --flow Classic ./config.json

# View metrics after run
cat runs/<RUN_TAG>/final/metrics.json
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
| Target Density | 40% | PL_TARGET_DENSITY |
| Die Area | 850x850 µm | Configurable in config.tcl/json |
| Max Routing Layer | met5 | RT_MAX_LAYER |

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

4. **Placement density error (GPL-0302)**
   - Error: "Use a higher -density or re-floorplan with a larger core area"
   - Increase `PL_TARGET_DENSITY` in config.tcl (e.g., from 0.45 to 0.56)
   - Or increase `DIE_AREA` (e.g., from "0 0 500 500" to "0 0 550 550")

### Getting Help

- [OpenLane Documentation](https://openlane2.readthedocs.io/)
- [SkyWater PDK Documentation](https://skywater-pdk.readthedocs.io/)
- [OpenROAD Documentation](https://openroad.readthedocs.io/)

## License

Same license as the parent RISC-V project.


