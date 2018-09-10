load_package flow
load_package design

set bak_qar "qdb.qar"
set base_bak_qar "base_bak.qar"
set list_qar "bak_list.txt"
set base_bak_qar_list [list "base.sof" "base.kernel.pmsf" "base.static.msf"]

proc skipping_bak {} {
  global bak_qar
  global base_bak_qar
  set copy_files [list $bak_qar $base_bak_qar "root_partition.qdb"]
  # version check to see if we can skip the BAK flow
  set skip_bak 1
  foreach f $copy_files {
    if {![file exists $f]} {
      set skip_bak 0
      break
    }
  }
  return $skip_bak
}

source "$::env(INTELFPGAOCLSDKROOT)/ip/board/bsp/helpers.tcl"

#### MAIN ####
# bak flow can potentially be skipped if version is same and cached
if { ![skipping_bak] } {
  # Import base revision compile design
  qexec "quartus_cdb top -c base --import_design --file base.qdb --overwrite"

  # run BAK flow
  qexec "quartus_fit top -c base"
  qexec "quartus_asm top -c base"

  # Export static partition of base revision compile
  qexec "quartus_cdb top -c base --export_pr_static_block root_partition --snapshot final --file root_partition.qdb"

  # create a list of files to archive
  # first clear the file if present
  set list_handle [open $list_qar w]
  close $list_handle
  create_qar_list $list_qar "qdb"

  # create a list for base files to qar
  set list_handle [open "tmp_list_base_bak" w]
  puts $list_handle [join $base_bak_qar_list "\n"]
  close $list_handle
  qexec "quartus_sh --archive -input tmp_list_base_bak -output $base_bak_qar"

  # create new archive
  qexec "quartus_sh --archive -input $list_qar -output $bak_qar"
  post_message "Successfully completed BAK flow"
  post_message "To reduce compile time on future compiles, you can generate a BAK cache by adding the arguments '--bsp-flow regenerate_cache' to aoc to skip BAK"
} else {
  qexec "quartus_sh --restore $base_bak_qar"
  qexec "quartus_sh --restore -output qdb $bak_qar"
}
