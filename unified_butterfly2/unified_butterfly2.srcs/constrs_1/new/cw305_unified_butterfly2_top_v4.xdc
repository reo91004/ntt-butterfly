###############################################################################
# CW305 official-pin based XDC for cw305_unified_butterfly2_top_v4
#
# Top module ports expected:
#   usb_clk, usb_data[7:0], usb_addr[20:0], usb_rdn, usb_wrn, usb_cen,
#   usb_trigger,
#   j16_sel, k16_sel, k15_sel, l14_sel, pushbutton,
#   led1, led2, led3,
#   pll_clk1,
#   tio_trigger, tio_clkout, tio_clkin
#
# This is based on the official ChipWhisperer CW305 cw305.xdc pin mapping.
# The U_clocks/CCLK_MUX case_analysis line from the official AES design is
# intentionally removed because our wrapper does not instantiate U_clocks.
###############################################################################

###############################################################################
# LEDs
###############################################################################
set_property DRIVE 8 [get_ports led1]
set_property PACKAGE_PIN T2 [get_ports led1]

set_property DRIVE 8 [get_ports led2]
set_property PACKAGE_PIN T3 [get_ports led2]

set_property DRIVE 8 [get_ports led3]
set_property PACKAGE_PIN T4 [get_ports led3]

###############################################################################
# Switches / pushbutton
###############################################################################
set_property PACKAGE_PIN J16 [get_ports j16_sel]
set_property PACKAGE_PIN K16 [get_ports k16_sel]
set_property PACKAGE_PIN L14 [get_ports l14_sel]
set_property PACKAGE_PIN K15 [get_ports k15_sel]
set_property PACKAGE_PIN R1  [get_ports pushbutton]

###############################################################################
# PLL clock input
###############################################################################
set_property PACKAGE_PIN N13 [get_ports pll_clk1]

###############################################################################
# 20-pin connector
###############################################################################
set_property PACKAGE_PIN T14 [get_ports tio_trigger]
set_property PACKAGE_PIN M16 [get_ports tio_clkout]
set_property PACKAGE_PIN N14 [get_ports tio_clkin]

###############################################################################
# USB connector / SAM3U parallel interface
###############################################################################
set_property PACKAGE_PIN F5 [get_ports usb_clk]

set_property PACKAGE_PIN A7 [get_ports {usb_data[0]}]
set_property PACKAGE_PIN B6 [get_ports {usb_data[1]}]
set_property PACKAGE_PIN D3 [get_ports {usb_data[2]}]
set_property PACKAGE_PIN E3 [get_ports {usb_data[3]}]
set_property PACKAGE_PIN F3 [get_ports {usb_data[4]}]
set_property PACKAGE_PIN B5 [get_ports {usb_data[5]}]
set_property PACKAGE_PIN K1 [get_ports {usb_data[6]}]
set_property PACKAGE_PIN K2 [get_ports {usb_data[7]}]

set_property PACKAGE_PIN F4 [get_ports {usb_addr[0]}]
set_property PACKAGE_PIN G5 [get_ports {usb_addr[1]}]
set_property PACKAGE_PIN J1 [get_ports {usb_addr[2]}]
set_property PACKAGE_PIN H1 [get_ports {usb_addr[3]}]
set_property PACKAGE_PIN H2 [get_ports {usb_addr[4]}]
set_property PACKAGE_PIN G1 [get_ports {usb_addr[5]}]
set_property PACKAGE_PIN G2 [get_ports {usb_addr[6]}]
set_property PACKAGE_PIN F2 [get_ports {usb_addr[7]}]
set_property PACKAGE_PIN E1 [get_ports {usb_addr[8]}]
set_property PACKAGE_PIN E2 [get_ports {usb_addr[9]}]
set_property PACKAGE_PIN D1 [get_ports {usb_addr[10]}]
set_property PACKAGE_PIN C1 [get_ports {usb_addr[11]}]
set_property PACKAGE_PIN K3 [get_ports {usb_addr[12]}]
set_property PACKAGE_PIN L2 [get_ports {usb_addr[13]}]
set_property PACKAGE_PIN J3 [get_ports {usb_addr[14]}]
set_property PACKAGE_PIN B2 [get_ports {usb_addr[15]}]
set_property PACKAGE_PIN C7 [get_ports {usb_addr[16]}]
set_property PACKAGE_PIN C6 [get_ports {usb_addr[17]}]
set_property PACKAGE_PIN D6 [get_ports {usb_addr[18]}]
set_property PACKAGE_PIN C4 [get_ports {usb_addr[19]}]
set_property PACKAGE_PIN D5 [get_ports {usb_addr[20]}]

# Official CW305 control pins
set_property PACKAGE_PIN A4 [get_ports usb_rdn]
set_property PACKAGE_PIN C2 [get_ports usb_wrn]
set_property PACKAGE_PIN A3 [get_ports usb_cen]
set_property PACKAGE_PIN A5 [get_ports usb_trigger]

###############################################################################
# I/O standard
###############################################################################
set_property IOSTANDARD LVCMOS33 [get_ports *]

###############################################################################
# Clocks
###############################################################################
create_clock -period 10.000 -name usb_clk   -waveform {0.000 5.000} [get_ports usb_clk]
create_clock -period 10.000 -name tio_clkin -waveform {0.000 5.000} [get_ports tio_clkin]
create_clock -period 10.000 -name pll_clk1  -waveform {0.000 5.000} [get_ports pll_clk1]

set_clock_groups -asynchronous \
    -group [get_clocks usb_clk] \
    -group [get_clocks {tio_clkin pll_clk1}]

###############################################################################
# Basic USB interface timing
###############################################################################
set_input_delay -clock usb_clk -add_delay 2.000 [get_ports usb_addr]
set_input_delay -clock usb_clk -add_delay 2.000 [get_ports usb_data]
set_input_delay -clock usb_clk -add_delay 2.000 [get_ports usb_trigger]
set_input_delay -clock usb_clk -add_delay 2.000 [get_ports usb_cen]
set_input_delay -clock usb_clk -add_delay 2.000 [get_ports usb_rdn]
set_input_delay -clock usb_clk -add_delay 2.000 [get_ports usb_wrn]

set_input_delay -clock usb_clk -add_delay 0.000 [get_ports j16_sel]
set_input_delay -clock usb_clk -add_delay 0.000 [get_ports k16_sel]
set_input_delay -clock usb_clk -add_delay 0.000 [get_ports k15_sel]
set_input_delay -clock usb_clk -add_delay 0.000 [get_ports l14_sel]
set_input_delay -clock usb_clk -add_delay 0.500 [get_ports pushbutton]

set_output_delay -clock usb_clk 0.000 [get_ports led1]
set_output_delay -clock usb_clk 0.000 [get_ports led2]
set_output_delay -clock usb_clk 0.000 [get_ports led3]
set_output_delay -clock usb_clk 0.000 [get_ports usb_data]
set_output_delay -clock usb_clk 0.000 [get_ports tio_trigger]
set_output_delay -clock usb_clk 0.000 [get_ports tio_clkout]

# These outputs are not performance-critical for this experiment.
set_false_path -to [get_ports led1]
set_false_path -to [get_ports led2]
set_false_path -to [get_ports led3]
set_false_path -to [get_ports usb_data]
set_false_path -to [get_ports tio_trigger]
set_false_path -to [get_ports tio_clkout]

###############################################################################
# Multicycle path: removed.
#
# The butterfly core (unified_butterfly2_core) is now fully pipelined:
#   - 4-stage Montgomery Modular_Reduction32
#   - registers around the 32x32 multiplier and the final add/sub
# Every register-to-register path is single-cycle, so no multicycle relaxation
# is needed.
###############################################################################

###############################################################################
# Bitstream configuration
###############################################################################
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
