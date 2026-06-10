set script_dir [file dirname [file normalize [info script]]]

open_hw_manager
connect_hw_server
open_hw_target

set device [lindex [get_hw_devices xc7z010_1] 0]
if {$device eq ""} {
    set device [lindex [get_hw_devices] 0]
}

current_hw_device $device
refresh_hw_device $device

set_property PROGRAM.FILE [file join $script_dir top.bit] $device
program_hw_devices $device

close_hw_manager
