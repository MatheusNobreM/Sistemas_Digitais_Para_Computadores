set script_dir [file dirname [file normalize [info script]]]
set src_dir [file normalize [file join $script_dir .. .. Processador_16bit.srcs sources_1 new]]

create_project -in_memory -part xc7z010clg400-1

read_verilog [list [file join $script_dir top.v]]
read_verilog [list [file join $src_dir processador_top.v]]
read_verilog [list [file join $src_dir datapath.v]]
read_verilog [list [file join $src_dir fsm.v]]
read_verilog [list [file join $src_dir pc.v]]
read_verilog [list [file join $src_dir rom.v]]
read_verilog [list [file join $src_dir ir.v]]
read_verilog [list [file join $src_dir mux4.v]]
read_verilog [list [file join $src_dir register_file.v]]
read_verilog [list [file join $src_dir ula.v]]
read_verilog [list [file join $src_dir ram.v]]

read_xdc [list [file join $script_dir zybo.xdc]]

synth_design -top top
opt_design
place_design
route_design
set bitstream_file [file join $script_dir top.bit]
write_bitstream -force $bitstream_file
