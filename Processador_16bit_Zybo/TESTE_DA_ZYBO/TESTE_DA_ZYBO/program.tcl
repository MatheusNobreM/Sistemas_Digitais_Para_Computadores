set script_dir [file dirname [file normalize [info script]]]
set bitstream_file [file join $script_dir top.bit]

if {![file exists $bitstream_file]} {
    error "Bitstream nao encontrado: $bitstream_file. Execute o build antes de programar."
}

open_hw_manager
connect_hw_server

set targets [get_hw_targets *]
if {[llength $targets] == 0} {
    close_hw_manager
    error "Nenhum alvo JTAG encontrado. Verifique se a Zybo esta ligada, se o cabo USB/JTAG esta conectado e se os drivers Digilent/Xilinx estao instalados."
}

puts "Alvos JTAG encontrados: $targets"
open_hw_target [lindex $targets 0]

set devices [get_hw_devices]
if {[llength $devices] == 0} {
    close_hw_manager
    error "Nenhum dispositivo FPGA encontrado no alvo JTAG."
}

set device [lindex [get_hw_devices xc7z010_1] 0]
if {$device eq ""} {
    set device [lindex $devices 0]
}

current_hw_device $device
refresh_hw_device $device

set_property PROGRAM.FILE $bitstream_file $device
program_hw_devices $device

close_hw_manager
