# =============================================================================
# OpenLane 1.x Configuration for RISC-V CPU
# =============================================================================

# Design name
set ::env(DESIGN_NAME) "riscv_cpu"
set ::env(DESIGN_IS_CORE) 1

# Source files
set ::env(VERILOG_FILES) [glob -directory $::env(DESIGN_DIR)/src *.sv]
set ::env(VERILOG_INCLUDE_DIRS) "$::env(DESIGN_DIR)/src"

# Clock configuration (50 MHz target = 20ns period)
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "20.0"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

# Timing constraints
set ::env(BASE_SDC_FILE) "$::env(DESIGN_DIR)/constraint.sdc"

# Die and core area
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 850 850"
set ::env(FP_CORE_UTIL) 40
set ::env(PL_TARGET_DENSITY) 0.40

# Pin configuration
set ::env(FP_PIN_ORDER_CFG) "$::env(DESIGN_DIR)/pin_order.cfg"

# Synthesis settings
# DELAY strategy prioritizes timing over area - better for high-fanout nets
set ::env(SYNTH_STRATEGY) "DELAY 3"
set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SYNTH_NO_FLAT) 0
set ::env(SYNTH_MAX_FANOUT) 4

# Placement settings
set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_SKIP_INITIAL_PLACEMENT) 0
set ::env(PL_RANDOM_GLB_PLACEMENT) 0
set ::env(PL_RANDOM_INITIAL_PLACEMENT) 0

# Routing settings
set ::env(GRT_ALLOW_CONGESTION) 0
set ::env(RT_MAX_LAYER) "met5"
set ::env(GRT_ADJUSTMENT) 0.3


# DRC/LVS settings
set ::env(RUN_DRC) 1
set ::env(RUN_LVS) 1
set ::env(RUN_MAGIC_DRC) 1

# Power settings
set ::env(FP_PDN_CORE_RING) 1
set ::env(FP_PDN_ENABLE_RAILS) 1

# Antenna settings
set ::env(RUN_ANTENNA_REPAIR) 1
set ::env(GRT_ANTENNA_MARGIN) 5

# CTS settings (sky130 specific)
set ::env(CTS_CLK_BUFFER_LIST) "sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8"
set ::env(CTS_SINK_CLUSTERING_SIZE) 16
set ::env(CTS_SINK_CLUSTERING_MAX_DIAMETER) 50
set ::env(MAX_FANOUT_CONSTRAINT) 4

