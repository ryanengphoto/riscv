## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports clk]
#create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


## Switches
#set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports sw]
#set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
#set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
#set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]
#set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]
#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]
#set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]
#set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports {sw[8]}]
#set_property -dict { PACKAGE_PIN T3    IOSTANDARD LVCMOS33 } [get_ports {sw[9]}]
#set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports {sw[10]}]
#set_property -dict { PACKAGE_PIN R3    IOSTANDARD LVCMOS33 } [get_ports {sw[11]}]
#set_property -dict { PACKAGE_PIN W2    IOSTANDARD LVCMOS33 } [get_ports {sw[12]}]
#set_property -dict { PACKAGE_PIN U1    IOSTANDARD LVCMOS33 } [get_ports {sw[13]}]
#set_property -dict { PACKAGE_PIN T1    IOSTANDARD LVCMOS33 } [get_ports {sw[14]}]
#set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports {sw[15]}]


## LEDs
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports led]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports led_0]
#set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports led3]
#set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports led4]
#set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports led5]
#set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports {led[5]}]
#set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports {led[6]}]
#set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports {led[7]}]
#set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports {led[8]}]
#set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports {led[9]}]
#set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 } [get_ports {led[10]}]
#set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports {led[11]}]
#set_property -dict { PACKAGE_PIN P3    IOSTANDARD LVCMOS33 } [get_ports {led[12]}]
#set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 } [get_ports {led[13]}]
#set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 } [get_ports {led[14]}]
#set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 } [get_ports {led[15]}]


##7 Segment Display
#set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]
#set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]
#set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]
#set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]
#set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]
#set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]
#set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]

#set_property -dict { PACKAGE_PIN V7   IOSTANDARD LVCMOS33 } [get_ports dp]

#set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
#set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
#set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
#set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {an[3]}]


##Buttons
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports rst]
#set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports btnU]
#set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports btnL]
#set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports btnR]
#set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports btnD]

#set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports tx]
#set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports rx]

##Pmod Header JA

#set_property -dict { PACKAGE_PIN J2   IOSTANDARD LVCMOS33 } [get_ports {JA[2]}];#Sch name = JA3
#set_property -dict { PACKAGE_PIN G2   IOSTANDARD LVCMOS33 } [get_ports {JA[3]}];#Sch name = JA4
#set_property -dict { PACKAGE_PIN H1   IOSTANDARD LVCMOS33 } [get_ports {JA[4]}];#Sch name = JA7
#set_property -dict { PACKAGE_PIN K2   IOSTANDARD LVCMOS33 } [get_ports {JA[5]}];#Sch name = JA8
#set_property -dict { PACKAGE_PIN H2   IOSTANDARD LVCMOS33 } [get_ports {JA[6]}];#Sch name = JA9
#set_property -dict { PACKAGE_PIN G3   IOSTANDARD LVCMOS33 } [get_ports {JA[7]}];#Sch name = JA10

##Pmod Header JB

#set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports tx];#Sch name = JB1
#set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports rx];#Sch name = JB2

#set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports {JB[2]}];#Sch name = JB3
#set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports {JB[3]}];#Sch name = JB4
#set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports {JB[4]}];#Sch name = JB7
#set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports {JB[5]}];#Sch name = JB8
#set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports {JB[6]}];#Sch name = JB9
#set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports {JB[7]}];#Sch name = JB10

##Pmod Header JC
#set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports {JC[0]}];#Sch name = JC1
#set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports {JC[1]}];#Sch name = JC2
#set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports {JC[2]}];#Sch name = JC3
#set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports {JC[3]}];#Sch name = JC4
#set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports {JC[4]}];#Sch name = JC7
#set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports {JC[5]}];#Sch name = JC8
#set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports {JC[6]}];#Sch name = JC9
#set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports {JC[7]}];#Sch name = JC10

##Pmod Header JXADC
#set_property -dict { PACKAGE_PIN J3   IOSTANDARD LVCMOS33 } [get_ports {JXADC[0]}];#Sch name = XA1_P
#set_property -dict { PACKAGE_PIN L3   IOSTANDARD LVCMOS33 } [get_ports {JXADC[1]}];#Sch name = XA2_P
#set_property -dict { PACKAGE_PIN M2   IOSTANDARD LVCMOS33 } [get_ports {JXADC[2]}];#Sch name = XA3_P
#set_property -dict { PACKAGE_PIN N2   IOSTANDARD LVCMOS33 } [get_ports {JXADC[3]}];#Sch name = XA4_P
#set_property -dict { PACKAGE_PIN K3   IOSTANDARD LVCMOS33 } [get_ports {JXADC[4]}];#Sch name = XA1_N
#set_property -dict { PACKAGE_PIN M3   IOSTANDARD LVCMOS33 } [get_ports {JXADC[5]}];#Sch name = XA2_N
#set_property -dict { PACKAGE_PIN M1   IOSTANDARD LVCMOS33 } [get_ports {JXADC[6]}];#Sch name = XA3_N
#set_property -dict { PACKAGE_PIN N1   IOSTANDARD LVCMOS33 } [get_ports {JXADC[7]}];#Sch name = XA4_N


##VGA Connector
#set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS33 } [get_ports {vgaRed[0]}]
#set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVCMOS33 } [get_ports {vgaRed[1]}]
#set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS33 } [get_ports {vgaRed[2]}]
#set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS33 } [get_ports {vgaRed[3]}]
#set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports {vgaBlue[0]}]
#set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports {vgaBlue[1]}]
#set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports {vgaBlue[2]}]
#set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports {vgaBlue[3]}]
#set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports {vgaGreen[0]}]
#set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports {vgaGreen[1]}]
#set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports {vgaGreen[2]}]
#set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports {vgaGreen[3]}]
#set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports Hsync]
#set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports Vsync]


##USB-RS232 Interface
#set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports RsRx]
#set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports RsTx]


##USB HID (PS/2)
#set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33   PULLUP true } [get_ports PS2Clk]
#set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33   PULLUP true } [get_ports PS2Data]


##Quad SPI Flash
##Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
##STARTUPE2 primitive.
#set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[0]}]
#set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[1]}]
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[2]}]
#set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[3]}]
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports QspiCSn]


## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]





# ===================================
# Preserve full dmem_addr signal for debugging
# ===================================
# Keep the full 32-bit dmem_addr signal from being optimized away
# This allows probing both the full address and the sliced version [14:2]
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[*]}]
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/dmem_addr[*]}]

# ===================================
# Preserve data path signals for debugging dmem_wdata issue
# ===================================
# Keep ex_mem_rs2_data - this directly drives dmem_wdata
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data[*]}]

# Keep id_ex_rs2_data - pipeline register that feeds ex_mem_rs2_data
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs2_data[*]}]

# Keep rs2_data_forwarded - forwarding mux output that feeds ex_mem_rs2_data
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[*]}]

# Keep rs1_data_forwarded - for completeness
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs1_data_forwarded[*]}]

# Keep register file read outputs
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/u_reg_file/rdata2[*]}]
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/u_reg_file/rdata4[*]}]

# Keep ex_rs2_data_current - register file output for EX stage
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[*]}]

# Keep forwarding control signals
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/forward_rs2[*]}]
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/forward_rs1[*]}]

# Keep wb_data - used in forwarding
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[*]}]

# Keep dmem_wdata and dmem_rdata for debugging
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[*]}]
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/dmem_wdata[*]}]
set_property KEEP true [get_nets {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[*]}]


set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[1]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[2]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[5]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[6]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[18]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[21]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[26]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[29]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[30]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[0]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[8]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[9]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[11]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[14]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[15]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[24]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[31]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[3]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[7]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[12]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[16]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[22]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[27]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[4]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[10]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[13]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[17]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[19]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[20]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[23]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[25]}]
set_property MARK_DEBUG true [get_nets {design_1_i/riscv_cpu_wrapper_0_dmem_addr[28]}]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list design_1_i/clk_wiz_0/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[4]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[5]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[6]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[7]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[8]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[9]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[10]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[11]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[12]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[13]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[14]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[15]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[16]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[17]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[18]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[19]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[20]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[21]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[22]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[23]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[24]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[25]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[26]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[27]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[28]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[29]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[30]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/alu_result[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 5 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rd[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rd[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rd[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rd[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rd[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 3 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_funct3[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_funct3[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_funct3[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[4]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[5]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[6]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[7]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[8]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[9]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[10]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[11]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[12]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[13]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[14]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[15]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[16]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[17]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[18]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[19]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[20]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[21]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[22]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[23]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[24]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[25]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[26]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[27]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[28]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[29]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[30]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_immediate[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 4 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_alu_sel[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_alu_sel[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_alu_sel[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_alu_sel[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[4]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[5]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[6]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[7]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[8]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[9]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[10]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[11]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[12]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[13]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[14]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[15]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[16]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[17]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[18]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[19]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[20]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[21]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[22]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[23]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[24]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[25]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[26]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[27]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[28]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[29]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[30]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_rs2_data_reg[31]_0[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[4]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[5]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[6]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[7]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[8]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[9]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[10]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[11]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[12]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[13]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[14]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[15]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[16]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[17]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[18]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[19]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[20]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[21]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[22]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[23]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[24]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[25]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[26]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[27]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[28]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[29]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[30]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_rs2_data_current[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 32 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[0]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[1]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[2]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[3]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[4]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[5]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[6]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[7]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[8]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[9]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[10]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[11]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[12]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[13]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[14]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[15]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[16]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[17]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[18]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[19]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[20]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[21]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[22]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[23]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[24]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[25]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[26]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[27]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[28]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[29]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[30]} {design_1_i/riscv_cpu_wrapper_0/dmem_rdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 32 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[4]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[5]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[6]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[7]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[8]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[9]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[10]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[11]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[12]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[13]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[14]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[15]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[16]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[17]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[18]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[19]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[20]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[21]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[22]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[23]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[24]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[25]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[26]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[27]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[28]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[29]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[30]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/rs2_data_forwarded[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 32 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[4]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[5]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[6]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[7]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[8]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[9]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[10]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[11]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[12]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[13]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[14]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[15]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[16]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[17]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[18]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[19]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[20]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[21]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[22]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[23]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[24]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[25]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[26]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[27]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[28]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[29]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[30]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/wb_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 32 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[4]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[5]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[6]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[7]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[8]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[9]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[10]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[11]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[12]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[13]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[14]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[15]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[16]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[17]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[18]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[19]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[20]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[21]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[22]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[23]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[24]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[25]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[26]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[27]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[28]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[29]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[30]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 32 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[4]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[5]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[6]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[7]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[8]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[9]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[10]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[11]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[12]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[13]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[14]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[15]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[16]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[17]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[18]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[19]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[20]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[21]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[22]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[23]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[24]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[25]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[26]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[27]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[28]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[29]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[30]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 32 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[4]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[5]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[6]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[7]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[8]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[9]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[10]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[11]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[12]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[13]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[14]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[15]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[16]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[17]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[18]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[19]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[20]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[21]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[22]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[23]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[24]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[25]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[26]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[27]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[28]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[29]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[30]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_alu_result[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 32 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {design_1_i/riscv_cpu_wrapper_0_dmem_addr[0]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[1]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[2]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[3]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[4]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[5]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[6]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[7]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[8]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[9]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[10]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[11]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[12]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[13]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[14]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[15]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[16]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[17]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[18]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[19]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[20]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[21]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[22]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[23]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[24]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[25]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[26]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[27]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[28]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[29]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[30]} {design_1_i/riscv_cpu_wrapper_0_dmem_addr[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 5 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs2[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs2[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs2[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs2[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs2[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 32 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[0]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[1]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[2]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[3]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[4]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[5]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[6]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[7]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[8]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[9]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[10]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[11]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[12]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[13]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[14]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[15]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[16]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[17]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[18]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[19]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[20]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[21]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[22]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[23]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[24]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[25]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[26]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[27]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[28]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[29]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[30]} {design_1_i/riscv_cpu_wrapper_0_dmem_wdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 5 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rd[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rd[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rd[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rd[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rd[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 5 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_rs1[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 5 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_rd[0]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_rd[1]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_rd[2]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_rd[3]} {design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_rd[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list design_1_i/riscv_cpu_wrapper_0/dmem_read]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list design_1_i/riscv_cpu_wrapper_0_dmem_write]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_mem_to_reg]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/mem_wb_reg_write]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/ex_mem_reg_write]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list design_1_i/riscv_cpu_wrapper_0/inst/u_riscv_cpu/id_ex_reg_write]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_clk_out1]
