
# Required packages
package require ::quartus::project
package require ::quartus::report
package require ::quartus::flow
package require ::quartus::atoms
package require ::quartus::incremental_compilation
source "$::env(INTELFPGAOCLSDKROOT)/ip/board/fast_compile/aocl_fast_compile.tcl"

##############################################################################
##############################       MAIN        #############################
##############################################################################

set fast_compile [::aocl_fast_compile::is_fast_compile]
if {$fast_compile} {
  post_message "Warning: Fast compile does not have Fitter RAM summary. Skipping PR checks script"
  return 0
}

post_message "Running PR checks script"

set project_name UNKNOWN
set revision_name UNKNOWN

if { [llength $quartus(args) ] == 0 } {
  # If this script is run manually, just compile the default revision
  set qpf_files [glob -nocomplain *.qpf]

  if {[llength $qpf_files] == 0} {
    error "No QSF detected"
  } elseif {[llength $qpf_files] > 1} {
    post_message "Warning: More than one QSF detected. Picking the first one."
  }
  set qpf_file [lindex $qpf_files 0]
  set project_name [string range $qpf_file 0 [expr [string first . $qpf_file] - 1]]
  set revision_name [get_current_revision $project_name]
} else {
  set project_name [lindex $quartus(args) 1]
  set revision_name [lindex $quartus(args) 2]
}

post_message "Project name: $project_name"
post_message "Revision name: $revision_name"

load_package design
project_open $project_name -revision $revision_name
design::load_design -writeable -snapshot final
load_report $revision_name

# Error out if initialized MLAB RAMs are found in kernel partition (not PR compatible)
set panel_name "Fitter||Place Stage||Fitter RAM Summary"
set panel_id [get_report_panel_id $panel_name] 
set num_rows [get_number_of_rows -id $panel_id]
for {set r 1} {$r < $num_rows} {incr r} {

  # Parse all instance paths and only process everything inside freeze_wrapper_inst|kernel_system_inst 
  set instance_path [get_report_panel_data -id $panel_id -row $r -col 0]
  if { [info exists instance_path_parsed] } { unset instance_path_parsed }
  regexp {freeze_wrapper_inst*\|kernel_system_inst.*$} $instance_path instance_path_parsed

  if { [info exists instance_path_parsed] } {
    
    # Only scan through RAMs that consists of MLABs
    set mlabs [get_report_panel_data -id $panel_id -row $r -col 19]
    if { $mlabs != 0 } {

      #  Find MIF initialized MLAB RAMs
      set mif_file [get_report_panel_data -id $panel_id -row $r -col 20]
      if { $mif_file != "None" } {
        post_message -type error "Found MLAB with initialized memory content which is not supported in A10 Partial Reconfiguration." -submsgs [list "Instance path: $instance_path_parsed" "MLABs: $mlabs" "MIF file: $mif_file"]
        post_message -type error "Terminating post-flow script"
        exit 2
      }
    }
  }
}

design::unload_design
project_close

