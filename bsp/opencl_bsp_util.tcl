
set board "$::env(INTELFPGAOCLSDKROOT)/ip/board"

source "$board/incremental/aocl_incremental.tcl"
source "$board/fast_compile/aocl_fast_compile.tcl"
source "$board/floorplanner/floorplanner_utils.tcl"

namespace eval ::opencl_bsp {
}

proc ::opencl_bsp::pre_synth_init {project_name revision_name pr_base_rev top_path} {
  ::aocl_incremental::init_partitions $project_name $revision_name $top_path
  ::aocl_floorplanner::set_floorplan $project_name $revision_name $pr_base_rev $top_path
}

