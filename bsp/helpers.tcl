
# recursive glob
proc glob_r {{dir .}} {
  set res {}
  foreach i [lsort [glob -nocomplain -dir $dir *]] {
    if {[file type $i] eq {directory}} {
      eval lappend res [glob_r $i]
    } else {
      lappend res $i
    }
  }
  set res
}

proc create_qar_list {bak_list dir} {
  # get a list of files to add to the archive
  set list_in [glob_r $dir]
  set list_handle [open $bak_list a+]
  foreach line $list_in {
    # no sdc files
    if {[string match "*sdc" $line]} { continue }
    puts $list_handle $line
  }
  close $list_handle
}
