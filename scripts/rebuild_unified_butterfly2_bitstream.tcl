set script_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $script_dir ..]]
set project_path [file join $repo_root unified_butterfly2 unified_butterfly2.xpr]

open_project $project_path
reset_run synth_1
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]
puts "impl_1 STATUS: $impl_status"
if {[string first "write_bitstream Complete" $impl_status] < 0} {
    puts "ERROR: bitstream generation did not complete"
    exit 1
}

close_project
