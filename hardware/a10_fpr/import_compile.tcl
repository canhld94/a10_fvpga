# (C) 1992-2017 Intel Corporation.                            
# Intel, the Intel logo, Intel, MegaCore, NIOS II, Quartus and TalkBack words    
# and logos are trademarks of Intel Corporation or its subsidiaries in the U.S.  
# and/or other countries. Other marks and brands may be claimed as the property  
# of others. See Trademarks on intel.com for full list of Intel trademarks or    
# the Trademarks & Brands Names Database (if Intel) or See www.Intel.com/legal (if Altera) 
# Your use of Intel Corporation's design tools, logic functions and other        
# software and tools, and its AMPP partner logic functions, and any output       
# files any of the foregoing (including device programming or simulation         
# files), and any associated documentation or information are expressly subject  
# to the terms and conditions of the Altera Program License Subscription         
# Agreement, Intel MegaCore Function License Agreement, or other applicable      
# license agreement, including, without limitation, that your use is for the     
# sole purpose of programming logic devices manufactured by Intel and sold by    
# Intel or its authorized distributors.  Please refer to the applicable          
# agreement for further details.                                                 

# Make sure OpenCL SDK installation exists
post_message "Checking for OpenCL SDK installation, environment should have INTELFPGAOCLSDKROOT defined"
if {[catch {set sdk_root $::env(INTELFPGAOCLSDKROOT)} result]} {
  post_message -type error "OpenCL SDK installation not found.  Make sure INTELFPGAOCLSDKROOT is correctly set"
  exit 2
} else {
  post_message "INTELFPGAOCLSDKROOT=$::env(INTELFPGAOCLSDKROOT)"
}

load_package flow
load_package design

# Load OpenCL BSP utility functions
source "$sdk_root/ip/board/bsp/opencl_bsp_util.tcl"

# Attempt to migrate qdb to a new Quartus version
source "$sdk_root/ip/board/bsp/bak_flow.tcl"

set top_path "freeze_wrapper_inst|kernel_system_inst"

# set-up OpenCL BSP utilities
::opencl_bsp::pre_synth_init "top" "top" "base" $top_path

# Synthesize PR logic
if {!$::aocl_incremental::incremental_compile} {
  qexec "quartus_syn top -c top_synth"
  # Exporting the kernel from the top_synth compile
  project_open top -revision top_synth
  if {[catch {design::export_block root_partition -snapshot synthesized -file kernel.qdb} result]} {
    post_message -type error "Error! $result"
    exit 2
  }
  project_close

  # Importing static partition from base revision compile
  project_open top -revision top
  if {[catch {design::import_block root_partition -file root_partition.qdb} result]} {
    post_message -type error "Error! $result"
    exit 2
  }
  project_close

  # Importing the kernel from the top_synth compile
  project_open top -revision top
  if {[catch {design::import_block kernel -file kernel.qdb} result]} {
    post_message -type error "Error! $result"
    exit 2
  }
  project_close
} else {
  qexec "quartus_syn top -c top"
}

# Invoke quartus_fit.  This call replaces the standard quartus_fit in order to apply post processing to better support incremental compilation in the OpenCL development flow.
::aocl_incremental::fit_retry "top" "top" $top_path

if {![::aocl_fast_compile::is_fast_compile]} {
  qexec "quartus_sta top -c top"
}

# Generate report, generate PLL configuration file, re-run STA
qexec "quartus_cdb -t scripts/post_flow_pr.tcl"

