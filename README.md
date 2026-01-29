# RISC-V CPU Core

A complete RISC-V CPU implementation supporting RV32I base instruction set and Zbb bit manipulation extension, designed for ASIC implementation using the Sky130 process node.

## Author

Ryan Eng

## Project Overview

This repository contains a fully functional RISC-V CPU core with two implementation targets:
- **ASIC Version**: Designed for tapeout using LibreLane/OpenLane flow with Sky130 PDK
- **FPGA Version**: Optimized for Basys3 Artix-7 FPGA development board

The CPU features a 6-stage in-order pipeline with comprehensive hazard detection, forwarding, and branch prediction capabilities.

## Development Methodology

This project was developed using a **closed-loop iterative approach** combining AI-assisted development tools with manual implementation:

### AI-Assisted Development
- **Cursor IDE**: [Cursor](https://cursor.sh/) - Primary development environment with AI-powered code completion and refactoring
    - Cursor was used in agent mode with access to the command-line and simulation tools to allow continuous automated iteration, with the ability to make changes and analyze simulation results via debug statements and VCD waveform outputs. This allowed the tool to effectively find solutions to problems and bugs faster.
- **AI Tools**: Used for:
  - Architecture exploration and optimization suggestions
  - Code refactoring and cleanup
  - Debugging assistance and error analysis
  - Documentation generation
  - Performance analysis and critical path identification

### Development Workflow
1. **Architecture Design**: Manual design decisions for pipeline structure and optimizations
2. **Implementation**: AI-assisted code generation with iterative refinement
3. **Testing**: Comprehensive test suite with 22+ test cases covering all instruction types
4. **Optimization**: Performance analysis using static timing analysis (STA) reports
5. **Iteration**: Closed-loop refinement based on simulation results and timing reports

### Manual Implementation Areas
- Critical path optimizations (pipeline stage splitting)
- Hazard detection logic
- Forwarding unit design
- Branch prediction and flush logic
- Control signal generation

## Architecture

### Pipeline Structure

The CPU implements a **6-stage in-order pipeline**:

1. **IF (Instruction Fetch)**: Fetches instructions from instruction memory
2. **ID1 (Instruction Decode Stage 1)**: 
   - Instruction field extraction (opcode, funct3, funct7, registers)
   - Register file read
   - Immediate generation
   - Control signal generation
3. **ID2 (Instruction Decode Stage 2)**:
   - Branch comparison and target calculation
   - Jump target calculation (JALR)
   - Forwarding detection for branch operands
   - Early branch resolution
4. **EX (Execute)**: 
   - ALU operations
   - Address calculation for loads/stores
5. **MEM (Memory)**: 
   - Data memory access (load/store)
6. **WB (Writeback)**: 
   - Register file write
   - Result forwarding to earlier stages

### Key Architectural Features

#### Pipeline Optimizations
- **ID Stage Split**: Decode stage split into ID1/ID2 to reduce critical path
  - ID1: Register file read, immediate generation, control decoding
  - ID2: Branch comparison, forwarding, target calculation
- **Early Branch Resolution**: Branch decisions made in ID2 stage, reducing branch penalty
- **Forwarding Network**: Comprehensive 3-stage forwarding (EX/MEM → ID2, MEM/WB → ID2, EX/MEM → EX)
- **Hazard Detection**: 
  - Load-use hazard detection (1-cycle stall)
  - Branch data hazard detection (stall when operand not ready)
  - Branch control hazard (flush on taken branches)

#### Data Path
- **Register File**: 32 registers (x0-x31), 2 read ports, 1 write port
- **ALU**: Supports RV32I + Zbb operations (30+ operations)
- **Branch Comparator**: Dedicated combinational comparator in ID2 stage
- **Immediate Generator**: Supports all RISC-V immediate formats (I, S, B, U, J)

## Instruction Set Support

### RV32I Base Instruction Set
- **R-type**: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
- **I-type**: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
- **Load**: LB, LH, LW, LBU, LHU
- **Store**: SB, SH, SW
- **Branch**: BEQ, BNE, BLT, BGE, BLTU, BGEU
- **Jump**: JAL, JALR
- **Upper Immediate**: LUI, AUIPC

### Zbb Bit Manipulation Extension
- **Logical Operations**: ANDN, ORN, XNOR
- **Min/Max**: MIN, MINU, MAX, MAXU
- **Rotate**: ROL, ROR, RORI
- **Count**: CLZ (Count Leading Zeros), CTZ (Count Trailing Zeros), CPOP (Population Count)
- **Sign/Zero Extend**: SEXT.B, SEXT.H, ZEXT.H
- **Byte Operations**: ORC.B, REV8

## Performance Optimizations

### Critical Path Reduction
1. **ID Stage Split**: Reduced combinational logic depth by splitting decode into two stages
2. **Early Branch Resolution**: Branch decisions in ID2 instead of EX stage
3. **Dedicated Branch Comparator**: Removed branch logic from ALU critical path
4. **Forwarding at Capture**: Operands forwarded when captured into pipeline registers, reducing later-stage mux delays

### Pipeline Efficiency
- **Forwarding**: 3-stage forwarding network eliminates most data hazards
- **Stall Minimization**: Only stalls for load-use hazards and branch data dependencies
- **Branch Prediction**: Early resolution reduces branch penalty to 1 cycle

## Tooling and Build System

### ASIC Flow
- **Synthesis**: [Yosys](https://github.com/YosysHQ/yosys)
- **Place & Route**: [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD)
- **PDK**: [Sky130A](https://github.com/google/skywater-pdk) (via LibreLane/OpenLane)
- **Timing Analysis**: Static Timing Analysis (STA) with OpenROAD
- **DRC/LVS**: [Magic](https://github.com/RTimothyEdwards/magic) and [Netgen](https://github.com/RTimothyEdwards/netgen)
- **Flow**: [LibreLane](https://librelane.readthedocs.io/en/stable/index.html)

#### LibreLane Usage
The ASIC flow uses LibreLane (OpenLane fork) with the Classic flow:

```bash
# Run flow up to pre-PNR STA (for timing analysis)
librelane --flow Classic --to OpenROAD.STAPrePNR ./config.json

# Full flow (RTL-to-GDSII)
librelane --flow Classic ./config.json
```

**Key Analysis Commands:**
- **Timing Reports**: Generated in `runs/RUN_*/12-openroad-staprepnr/nom_ss_100C_1v60/`
  - `max.rpt`: Maximum delay paths (critical path analysis)
  - `summary.rpt`: Timing summary (WNS, TNS, etc.)
  - `clock.rpt`: Clock domain analysis
- **Critical Path Analysis**: Used `max.rpt` to identify timing bottlenecks and guide RTL optimizations
- **Iterative Optimization**: Ran STA after each RTL change to measure timing improvements

### Simulation
- **Simulator**: [Icarus Verilog](http://iverilog.icarus.com/) (iverilog)
- **Testbench**: Comprehensive test suite with 22+ test cases
- **Waveform Viewer**: [GTKWave](https://github.com/gtkwave/gtkwave)

### Build Commands
```bash
# ASIC flow
cd asic
make harden      # Full RTL-to-GDSII flow
make synth       # Synthesis only
make sim         # Run simulation
make waves       # View waveforms

# LibreLane direct commands
librelane --flow Classic --to OpenROAD.STAPrePNR ./config.json  # Run to STA for timing analysis
librelane --flow Classic ./config.json                          # Full flow

# Interactive mode
make interactive # OpenLane interactive shell
```

**Timing Analysis Workflow:**
1. Run synthesis and placement: `librelane --flow Classic --to OpenROAD.STAPrePNR ./config.json`
2. Analyze timing reports in `runs/RUN_*/12-openroad-staprepnr/nom_ss_100C_1v60/`
3. Identify critical paths from `max.rpt`
4. Optimize RTL based on timing bottlenecks
5. Re-run flow and compare results
6. Iterate until timing closure

### Configuration
- **Clock Target**: 50 MHz (20ns period)
- **Die Area**: 850x850 μm²
- **Core Utilization**: 40%
- **Synthesis Strategy**: DELAY 3 (timing-optimized)

## Project Structure

```
riscv/
├── asic/                    # ASIC implementation
│   ├── src/                 # RTL source files
│   │   ├── riscv_cpu.sv     # Top-level CPU module
│   │   ├── control_unit.sv  # Instruction decoder
│   │   ├── alu_core.sv      # ALU implementation
│   │   ├── branch_comparator.sv
│   │   ├── register_file.sv
│   │   ├── immediate_generator.sv
│   │   ├── alu_defs.svh     # ALU operation definitions
│   │   └── riscv_defs.svh   # RISC-V instruction format definitions
│   ├── sim/                 # Simulation files
│   │   ├── tb_riscv.sv      # Main testbench
│   │   └── tests/           # Test cases
│   ├── config.tcl           # OpenLane configuration
│   └── Makefile             # Build system
├── fpga/                    # FPGA implementation
└── README.md                # This file
```

## Testing

The CPU includes a comprehensive test suite covering:
- Basic arithmetic operations (ADD, SUB, AND, OR, XOR)
- Load-use hazard detection
- Data forwarding (EX/MEM, MEM/WB)
- Branch forwarding and stalling
- Zbb bit manipulation operations
- JAL/JALR return address handling

All 22 test cases pass, ensuring correct functionality across all supported instructions.

## Key Design Decisions

1. **6-Stage Pipeline**: Chosen to reduce critical path while maintaining reasonable branch penalty
2. **ID Stage Split**: ID1/ID2 split reduces combinational logic depth in decode stage
3. **Early Branch Resolution**: Branch decisions in ID2 enable 1-cycle branch penalty
4. **Comprehensive Forwarding**: 3-stage forwarding network minimizes stalls

## Future Enhancements

Potential improvements for future iterations:
- Out-of-order execution (major architectural change)
- Superscalar execution (multiple instructions per cycle)
- Branch prediction (beyond early resolution)
- Cache system integration
- Additional RISC-V extensions (M, A, F, D)

## Resources and References

### RISC-V Specifications
- [RISC-V Instruction Set Manual](https://riscv.org/technical/specifications/)
- [RV32I Base Instruction Set](https://github.com/riscv/riscv-isa-manual)
- [Zbb Bit Manipulation Extension](https://five-embeddev.com/riscv-bitmanip/1.0.0/bitmanip.html#zbb)

### Tools and Frameworks
- [LibreLane](https://librelane.readthedocs.io/en/stable/index.html) - OpenLane fork for ASIC flow
- [Yosys](https://github.com/YosysHQ/yosys) - Verilog synthesis tool
- [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) - Place & Route tool
- [Sky130 PDK](https://github.com/google/skywater-pdk) - SkyWater 130nm process design kit
- [Cursor IDE](https://cursor.sh/) - AI-powered code editor
- [Icarus Verilog](https://steveicarus.github.io/iverilog/) - Verilog simulation tool
- [GTKWave](https://github.com/gtkwave/gtkwave) - Waveform viewer
