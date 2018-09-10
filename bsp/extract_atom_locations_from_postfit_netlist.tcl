package require ::quartus::project
package require ::quartus::report
package require ::quartus::flow
package require ::quartus::atoms

set resource_type [lindex $argv 0]
set kernel_name [lindex $argv 1]
set base_name [lindex $argv 2]
set project_name [lindex $argv 3]
set revision_name [lindex $argv 4]

# Open project
if { [catch {project_open $project_name -revision $revision_name} output] } {
  post_message -type error $output
  exit 2
# ERROR
}

# Read atom netlist
if { [catch {read_atom_netlist} output] } {
  post_message -type error $output
  project_close
  exit 2
# ERROR
}

puts "# $resource_type locations (originate from $kernel_name)" 

if {[string match $resource_type "DSP"]} {
  set atom_node_type "FP_MAC"
} elseif {[string match $resource_type "RAM"]} {
  set atom_node_type "RAM"
}

foreach_in_collection node [get_atom_nodes -type $atom_node_type] {
  set name       [get_atom_node_info -key NAME     -node $node]
  regsub -all $kernel_name $name $base_name name
  set location   [get_atom_node_info -key LOCATION -node $node]
  set loc_assign "set_location_assignment $location -to \"$name\""
  puts $loc_assign
}

puts "# $resource_type locations END"

project_close
