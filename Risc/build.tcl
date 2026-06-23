# =====================================================================
#  build.tcl - sintetiza, implementa e gera o bitstream para a Zybo.
#  Os LEDs sao controlados pelo processador (assembly em memory_inst.v).
#  Projeto em memoria, sem depender do .xpr.  Zybo Rev B: xc7z010clg400-1
# =====================================================================
set script_dir [file dirname [file normalize [info script]]]
set src_dir [file normalize [file join $script_dir componentes]]

create_project -in_memory -part xc7z010clg400-1

# Fontes sintetizaveis (top + processador completo)
read_verilog [list [file join $src_dir top.v]]
read_verilog [list [file join $src_dir cpu_top.v]]
read_verilog [list [file join $src_dir counter_clk.v]]
read_verilog [list [file join $src_dir controller_inst.v]]
read_verilog [list [file join $src_dir counter_pc.v]]
read_verilog [list [file join $src_dir address_mux.v]]
read_verilog [list [file join $src_dir register_ir.v]]
read_verilog [list [file join $src_dir alu_inst.v]]
read_verilog [list [file join $src_dir register_ac.v]]
read_verilog [list [file join $src_dir driver_inst.v]]
read_verilog [list [file join $src_dir memory_inst.v]]

# Constraints (pinos da Zybo)
read_xdc [list [file join $script_dir Zybo_Constraints.xdc]]

# Fluxo de implementacao
synth_design -top top
opt_design
place_design
route_design

# Gera o bitstream na pasta deste script
set bitstream_file [file join $script_dir top.bit]
write_bitstream -force $bitstream_file
puts "Bitstream gerado em: $bitstream_file"
