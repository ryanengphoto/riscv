# =============================================================================
# RISC-V CPU Timing Constraints for OpenLane/OpenROAD
# =============================================================================

# -----------------------------------------------------------------------------
# Clock Definition
# -----------------------------------------------------------------------------
# Target: 50 MHz (20ns period)
# Adjust CLOCK_PERIOD for different targets:
#   100 MHz = 10.0ns
#   50 MHz  = 20.0ns
#   25 MHz  = 40.0ns

create_clock -name clk -period 20.0 [get_ports clk]

# Clock uncertainty (jitter + skew margin)
set_clock_uncertainty 0.25 [get_clocks clk]

# Clock transition time
set_clock_transition 0.15 [get_clocks clk]

# -----------------------------------------------------------------------------
# Reset Timing
# -----------------------------------------------------------------------------
# Reset is asynchronous - exclude from timing analysis
set_false_path -from [get_ports rst]

# -----------------------------------------------------------------------------
# Input Delays
# -----------------------------------------------------------------------------
# All inputs relative to clock
# Assumes inputs arrive 2ns after clock edge (external setup)

set_input_delay -clock clk -max 2.0 [get_ports rst]

# Instruction memory interface
set_input_delay -clock clk -max 4.0 [get_ports imem_data[*]]

# Data memory interface
set_input_delay -clock clk -max 4.0 [get_ports dmem_rdata[*]]

# -----------------------------------------------------------------------------
# Output Delays
# -----------------------------------------------------------------------------
# All outputs relative to clock
# Assumes outputs need to be stable 2ns before next clock edge

# Instruction memory interface
set_output_delay -clock clk -max 2.0 [get_ports imem_addr[*]]

# Data memory interface
set_output_delay -clock clk -max 2.0 [get_ports dmem_addr[*]]
set_output_delay -clock clk -max 2.0 [get_ports dmem_wdata[*]]
set_output_delay -clock clk -max 2.0 [get_ports dmem_read]
set_output_delay -clock clk -max 2.0 [get_ports dmem_write]

# -----------------------------------------------------------------------------
# Input/Output Drive and Load
# -----------------------------------------------------------------------------
# Set driving cell for inputs (typical value for external logic)
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 -pin X [all_inputs]

# Set output load (typical fanout capacitance)
set_load 0.05 [all_outputs]

# -----------------------------------------------------------------------------
# Design Rule Constraints
# -----------------------------------------------------------------------------
# Maximum transition time
set_max_transition 0.75 [current_design]

# Maximum capacitance
set_max_capacitance 0.2 [current_design]

# Maximum fanout
set_max_fanout 6 [current_design]

# -----------------------------------------------------------------------------
# Multicycle Paths (if any)
# -----------------------------------------------------------------------------
# None currently - all paths are single-cycle

# -----------------------------------------------------------------------------
# Case Analysis (if needed)
# -----------------------------------------------------------------------------
# None currently


