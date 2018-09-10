
# Required packages
package require ::quartus::project
package require ::quartus::report
package require ::quartus::flow
package require ::quartus::atoms
package ifneeded ::altera::pll_legality 1.0 { 
	switch $tcl_platform(platform) {
		windows {
			load [file join $::quartus(binpath) qcl_pll_legality_tcl.dll] pll_legality
		}
		unix {
			load [file join $::quartus(binpath) libqcl_pll_legality_tcl[info sharedlibextension]] pll_legality
		}
	}
}
package require ::quartus::qcl_pll 
package require ::quartus::pll::legality
package require ::quartus::incremental_compilation

# Definitions
set k_clk_name "*kernel_pll_outclk0"
set k_clk2x_name "*kernel_pll_outclk1"
set k_fmax -1

# Utility functions

# ------------------------------------------------------------------------------------------
proc get_nearest_achievable_frequency { desired_kernel_clk  \
                                        refclk_freq \
					device_speedgrade } {
#
# Description :  Returns the closest achievable IOPLL frequency less than or
#                equal to desired_kernel_clk.
#
# Parameters :
#    desired_kernel_clk  - The desired frequency in MHz (floating point)
#    refclk_freq         - The IOPLL's reference clock frequency in MHz (floating point)
#    device_speedgrade   - The device speedgrade (1, 2 or 3)
#
# Assumptions :  
#    - There are two desired output clocks, the kernel_clk and a kernel_clk_2x
#    - Both clocks have zero phase shift 
#    - The desired_kernel_clk frequency is > 10 MHz
#
# -------------------------------------------------------------------------------------------

	# If the kernel_clk_2x frequency is achievable from a given VCO frequency, 
	# then so must be the kernel_clk (assuming that it is not absurdly low).
	# So, we can simply and compute for an IOPLL with a single clock output of kernel_clk_2x.
	set desired_2x_clk [expr $desired_kernel_clk * 2]
	
	# Use array get to ensure correct input formatting (and avoid curly braces)
	set desired_output(0) [list -type c -index 0 -freq $desired_2x_clk -phase 0.0 -is_degrees false -duty 50.0]
	set desired_counter [array get desired_output]
	
	# Prepare the arguments for a call to the PLL legality package.
	# The non-obvious parameters here are all effectively don't cares.
	set ref_list [list  -family                       "Stratix 10" \
						-speedgrade                   $device_speedgrade \
						-refclk_freq                  $refclk_freq \
						-is_fractional                false \
						-compensation_mode            direct \
						-is_counter_cascading_enabled false \
						-x                            32 \
						-validated_counter_values     {} \
						-desired_counter_values       $desired_counter]
						
	if {[catch {::quartus::pll::legality::retrieve_output_clock_frequency_list $ref_list} result]} {
		post_message "Call to retrieve_output_clock_frequency_list failed because:"
		post_message $result
		return TCL_ERROR
		# ERROR
	}	
		
	# We get a list of six legal frequencies for kernel_clk_2x
	array set result_array $result
	set freq_list $result_array(freq)

	
	# Pick the closest frequency that's still less than the desired frequency
	# Recover the legal kernel_clk frequencies as we go
	set best_freq 0
	set possible_kernel_freqs {}
	
	foreach freq_2x $freq_list {
		set freq [expr double($freq_2x) / 2]
		lappend possible_kernel_freqs $freq
		
		if { $freq > $desired_kernel_clk } {
			# The frequency exceeds fmax -- no good.
		} elseif { $freq > $best_freq } {
			set best_freq $freq
		}
	}
	
	# Debug output:
	#puts "Nearest achievable IOPLL clock frequencies:"
	#puts $possible_kernel_freqs
	
	if {$best_freq == 0} {
		post_message "All of the frequencies were too high!"
		return TCL_ERROR
		# ERROR
	} else {
		return $best_freq
		# SUCCESS!
	}
									
}

# ------------------------------------------------------------------------------------------
proc adjust_iopll_frequency_in_postfit_netlist { design_name \
                                                 pll_name \
						 device_speedgrade \
						 legalized_kernel_clk } {
#
# Description :  Configures IOPLL "pll_name" parameter settings to produce a new output frequency
#                of legalized_kernel_clk.  This must be a legal setting for success.
#
# Parameters :
#    design_name          - Design name (i.e. <design_name>.qpf)
#    pll_name             - The full hierarchical name of the target IOPLL in the design
#    device_speedgrade    - The device speedgrade (1, 2 or 3)
#    legalized_kernel_clk - The new kernel_clk frequency (legalized by get_nearest_achievable_frequency)
#
# Assumptions :  
#    - The legalized_kernel_clk frequency is, in fact, legal
#    - There are two desired output clocks, the kernel_clk and a kernel_clk_2x
#    - Both clocks have zero phase shift 
#    - The PLL is set to low (auto) bandwidth
#
# -------------------------------------------------------------------------------------------

	# Get the IOPLL node
	if { [catch {set node [get_atom_node_by_name -name $pll_name]} ] } {
		post_message "IOPLL not found: $pll_name"
		list_plls_in_design
		return TCL_ERROR
		# ERROR
	}
	
	# Get the refclk frequency from the IOPLL node
	# Using the netlist's refclk frequency gives us a santity check.
	set refclk_MHz  [get_atom_node_info -key TIME_REFERENCE_CLOCK_FREQUENCY -node $node]
	regexp {([0-9.]+)} $refclk_MHz refclk
	
	# Desired output frequencies (kernel_clk and kernel_clk_2x)
	set outclk0 $legalized_kernel_clk
	set outclk1 [expr $outclk0 * 2]

	set desired_output(0) [list -type c -index 0 -freq $outclk0 -phase 0.0 -is_degrees false -duty 50.0]
	set desired_output(1) [list -type c -index 0 -freq $outclk1 -phase 0.0 -is_degrees false -duty 50.0]
	set desired_counters  [array get desired_output]

	# Compute the new IOPLL settings
	if { [catch {get_physical_parameters_for_generation \
				-using_adv_mode false \
				-device_family "Stratix 10" \
				-device_speedgrade $device_speedgrade \
				-compensation_mode direct \
				-refclk_freq $refclk \
				-is_fractional false \
				-x 32 \
				-m 1 \
				-n 1 \
				-k 1 \
				-bw_preset Low \
				-is_counter_cascading_enabled false \
				-validated_counter_settings [array get desired_output]} \
		result] } {
		post_message "Failed to generate new IOPLL settings.  The requested output frequency might have been illegal."
		post_message $result
		return TCL_ERROR
		# ERROR
	}

	# Extract the new IOPLL settings
	array set result_array $result

	# M counter settings
	array set m_array $result_array(m)
	set m_hi_div      $m_array(m_high)
	set m_lo_div      $m_array(m_low)
	set m_bypass      $m_array(m_bypass_en)
	set m_duty_tweak  $m_array(m_tweak)

	# N counter settings
	array set n_array $result_array(n)
	set n_hi_div      $n_array(n_high)
	set n_lo_div      $n_array(n_low)
	set n_bypass      $n_array(n_bypass_en)
	set n_duty_tweak  $n_array(n_tweak)

	# VCO frequency
	set vco_freq      "[round_to_atom_precision $result_array(vco_freq)] MHz"
	
	# BW & CP current settings
	set mif_pll_bwctrl $result_array(bw)
	set mif_pll_cp_current $result_array(cp)
       	
	# C counter settings
	array set c_array $result_array(c)	
	
	# C0 counter settings		
	array set c0_array $c_array(0)
	set outclk_freq0  "[round_to_atom_precision $c0_array(freq)] MHz"
	set c0_hi_div     $c0_array(c_high)
	set c0_lo_div     $c0_array(c_low)
	set c0_bypass     $c0_array(c_bypass_en)
	set c0_duty_tweak $c0_array(c_tweak)

	# C1 counter settings
	array set c1_array $c_array(1)
	set outclk_freq1  "[round_to_atom_precision $c1_array(freq)] MHz"
	set c1_hi_div     $c1_array(c_high)
	set c1_lo_div     $c1_array(c_low)
	set c1_bypass     $c1_array(c_bypass_en)
	set c1_duty_tweak $c1_array(c_tweak)

	# Apply the new settings:
	set_atom_node_info -key TIME_OUTPUT_CLOCK_FREQUENCY_0     -node $node    $outclk_freq0
	set_atom_node_info -key TIME_OUTPUT_CLOCK_FREQUENCY_1     -node $node    $outclk_freq1
	set_atom_node_info -key TIME_VCO_FREQUENCY                -node $node    $vco_freq
																			 
	set_atom_node_info -key INT_IOPLL_M_CNT_HI_DIV            -node $node    $m_hi_div
	set_atom_node_info -key INT_IOPLL_M_CNT_LO_DIV            -node $node    $m_lo_div
	set_atom_node_info -key BOOL_IOPLL_M_CNT_BYPASS_EN        -node $node    $m_bypass
	set_atom_node_info -key BOOL_IOPLL_M_CNT_EVEN_DUTY_EN     -node $node    $m_duty_tweak
																			 
	set_atom_node_info -key INT_IOPLL_N_CNT_HI_DIV            -node $node    $n_hi_div
	set_atom_node_info -key INT_IOPLL_N_CNT_LO_DIV            -node $node    $n_lo_div
	set_atom_node_info -key BOOL_IOPLL_N_CNT_BYPASS_EN        -node $node    $n_bypass
	set_atom_node_info -key BOOL_IOPLL_N_CNT_ODD_DIV_DUTY_EN  -node $node    $n_duty_tweak
																			 
	set_atom_node_info -key INT_IOPLL_C_CNT_0_HI_DIV          -node $node    $c0_hi_div
	set_atom_node_info -key INT_IOPLL_C_CNT_0_LO_DIV          -node $node    $c0_lo_div
	set_atom_node_info -key BOOL_IOPLL_C_CNT_0_BYPASS_EN      -node $node    $c0_bypass
	set_atom_node_info -key BOOL_IOPLL_C_CNT_0_EVEN_DUTY_EN   -node $node    $c0_duty_tweak
																			 
	set_atom_node_info -key INT_IOPLL_C_CNT_1_HI_DIV          -node $node    $c1_hi_div
	set_atom_node_info -key INT_IOPLL_C_CNT_1_LO_DIV          -node $node    $c1_lo_div
	set_atom_node_info -key BOOL_IOPLL_C_CNT_1_BYPASS_EN      -node $node    $c1_bypass
	set_atom_node_info -key BOOL_IOPLL_C_CNT_1_EVEN_DUTY_EN   -node $node    $c1_duty_tweak
																			 
	set_atom_node_info -key ENUM_IOPLL_PLL_BWCTRL             -node $node    $mif_pll_bwctrl
	set_atom_node_info -key ENUM_IOPLL_PLL_CP_CURRENT         -node $node    $mif_pll_cp_current

	# Success!
	return TCL_OK
}


proc round_to_atom_precision { value } {

	# Round to 6 decimal points
	set n 6
	set rounded_num [format "%.${n}f" $value]
	set double_version [expr {double($rounded_num)} ]
	
	if {[string length $double_version] <= [string length $rounded_num]} {
		return $double_version
	} else  {
		return $rounded_num
	}
}


proc list_plls_in_design { } {
	post_message "Found the following IOPLLs in design:"
	foreach_in_collection node [get_atom_nodes -type IOPLL] {
		set name [get_atom_node_info -key NAME -node $node]
		post_message "   $name"
	}
}


proc find_kernel_pll_in_design {pll_search_string} {
	foreach_in_collection node [get_atom_nodes -type IOPLL] {
    		set node_name [ get_atom_node_info -key NAME -node $node]
		set name [get_atom_node_info -key NAME -node $node]
                if { [ string match $pll_search_string $node_name ] == 1} {
        		post_message "Found kernel_pll: $node_name"
      			set kernel_pll_name $node_name
      			return $kernel_pll_name
    		}
	}
}


# Return values: [retval panel_id row_index]
#   panel_id and row_index are only valid if the query is successful
# retval: 
#    0: success
#   -1: not found
#   -2: panel not found (could be report not loaded)
#   -3: no rows found in panel
#   -4: multiple matches found
proc find_report_panel_row { panel_name col_index string_op string_pattern } {
    if {[catch {get_report_panel_id $panel_name} panel_id] || $panel_id == -1} {
        return -2;
    }

    if {[catch {get_number_of_rows -id $panel_id} num_rows] || $num_rows == -1} {
        return -3;
    }

    # Search for row match.
    set found 0
    set row_index -1;

    for {set r 1} {$r < $num_rows} {incr r} {
        if {[catch {get_report_panel_data -id $panel_id -row $r -col $col_index} value] == 0} {
            if {[string $string_op $string_pattern $value]} {
                if {$found == 0} {
                    # If multiple rows match, return the first
                    set row_index $r
                }
                incr found
            }

        }
    }

    if {$found > 1} {return [list -4 $panel_id $row_index]}
    if {$row_index == -1} {return -1}

    return [list 0 $panel_id $row_index]
}


# get_fmax_from_report: Determines the fmax for the given clock. The fmax value returned
# will meet all timing requirements (setup, hold, recovery, removal, minimum pulse width)
# across all corners.  The return value is a 2-element list consisting of the
# fmax and clk name
proc get_fmax_from_report { clkname required } {
    # Find the clock period.
    set result [find_report_panel_row "TimeQuest Timing Analyzer||Clocks" 0 match $clkname]
    set retval [lindex $result 0]

    if {$retval == -1} { 
        if {$required == 1} {
           error "Error: Could not find clock: $clkname" 
        } else {
           post_message -type warning "Could not find clock: $clkname.  Clock is not required assuming 10 GHz and proceeding."
           return [list 10000 $clkname]
        }
    } elseif {$retval < 0} { 
        error "Error: Failed search for clock $clkname (error $retval)"
    }

    # Update clock name to full clock name ($clkname as passed in may contain wildcards).
    set panel_id [lindex $result 1]
    set row_index [lindex $result 2]
    set clkname [get_report_panel_data -id $panel_id -row $row_index -col 0]
    set clk_period [get_report_panel_data -id $panel_id -row $row_index -col 2]

    post_message "Clock $clkname"
    post_message "  Period: $clk_period"

    # Determine the most negative slack across all relevant timing metrics (setup, recovery, minimum pulse width)
    # and across all timing corners. Hold and removal metrics are not taken into account
    # because their slack values are independent on the clock period (for kernel clocks at least).
    #
    # Paths that involve both a posedge and negedge of the kernel clocks are not handled properly (slack
    # adjustment needs to be doubled).
    set timing_metrics [list "Setup" "Recovery" "Minimum Pulse Width"]
    set timing_metric_colindex [list 1 3 5 ]
    set timing_metric_required [list 1 0 0]
    set wc_slack $clk_period
    set has_slack 0
    set fmax_from_summary 5000.0

    set panel_name "TimeQuest Timing Analyzer||Multicorner Timing Analysis Summary"
    set panel_id [get_report_panel_id $panel_name] 
    set result [find_report_panel_row $panel_name 0 equal " $clkname"]
    set retval [lindex $result 0]
    set single off
    if {$retval == -2} {
      post_message "Multicorner Analysis is off: analyzing single case"
      set single on
    }

    # Find the "Fmax Summary" numbers reported in Quartus.  This may not
    # account for clock transfers but it does account for pos-to-neg edge same
    # clock transfers.  Whatever we calculate should be less than this.
    set fmax_panel_name UNKNOWN
    if {[string match $single "off"]} {
      set fmax_panel_name "TimeQuest Timing Analyzer||* Model||*Fmax Summary"
    } else {
      set fmax_panel_name "TimeQuest Timing Analyzer||Fmax Summary"
    }
    foreach panel_name [get_report_panel_names] {
      if {[string match $fmax_panel_name $panel_name] == 1} {
        set result [find_report_panel_row $panel_name 2 equal $clkname]
        set retval [lindex $result 0]
        if {$retval == 0} {
          set restricted_fmax_field [get_report_panel_data -id [lindex $result 1] -row [lindex $result 2] -col 1]
          regexp {([0-9\.]+)} $restricted_fmax_field restricted_fmax 
          if {$restricted_fmax < $fmax_from_summary} {
            set fmax_from_summary $restricted_fmax
          }
        }
      }
    }
    post_message "  Restricted Fmax from STA: $fmax_from_summary"

    # Find the worst case slack across all corners and metrics
    foreach metric $timing_metrics metric_required $timing_metric_required col_ndx $timing_metric_colindex {
      if {[string match $single "on"]} {
      	set panel_name "TimeQuest Timing Analyzer||$metric Summary"
        set result [find_report_panel_row $panel_name 0 equal "$clkname"]
        set col_ndx 1
      } else {
        set panel_name "TimeQuest Timing Analyzer||Multicorner Timing Analysis Summary"
        set result [find_report_panel_row $panel_name 0 equal " $clkname"]
        set single off
      }
      set panel_id [get_report_panel_id $panel_name]
      set retval [lindex $result 0]

      if {$retval == -1} { 
        if {$required == 1 && $metric_required == 1} {
          error "Error: Could not find clock: $clkname" 
        }
      } elseif {$retval < 0 && $retval != -4 } { 
        error "Error: Failed search for clock $clkname (error $retval)"
      }

      if {$retval == 0 || $retval == -4} {
        set slack [get_report_panel_data -id [lindex $result 1] -row [lindex $result 2] -col $col_ndx ]
        post_message "    $metric slack: $slack"
        if {$slack != "N/A"} {
          if {$metric == "Setup" || $metric == "Recovery"} {
            set has_slack 1
            if {$metric == "Recovery"} {
              set normalized_slack [ expr $slack / 4.0 ]
              post_message "    normalized $metric slack: $normalized_slack"
              set slack $normalized_slack
            }
          }
        } 
        # Keep track of the most negative slack.
        if {$slack < $wc_slack} {
          set wc_slack $slack
          set wc_metric $metric
        }
      }
    }

    if {$has_slack == 1} {
        # Adjust the clock period to meet the worst-case slack requirement.
        set clk_period [expr $clk_period - $wc_slack]
        post_message "  Adjusted period: $clk_period ([format %+0.3f [expr -$wc_slack]], $wc_metric)"

        # Compute fmax from clock period. Clock period is in nanoseconds and the
        # fmax number should be in MHz.
        set fmax [expr 1000 / $clk_period]

        if {$fmax_from_summary < $fmax} {
            post_message "  Restricted Fmax from STA is lower than $fmax, using it instead."
            set fmax $fmax_from_summary
        }

        # Truncate to two decimal places. Truncate (not round to nearest) to avoid the
        # very small chance of going over the clock period when doing the computation.
        set fmax [expr floor($fmax * 100) / 100]
        post_message "  Fmax: $fmax"
    } else {
        post_message -type warning "No slack found for clock $clkname - assuming 10 GHz."
        set fmax 10000
    }

    return [list $fmax $clkname]
}

# Returns [k_fmax fmax1 k_clk_name fmax2 k_clk2x_name]
proc get_kernel_clks_and_fmax { k_clk_name k_clk2x_name } {
    set result [list]
    # Read in the achieved fmax
    post_message "Calculating maximum fmax..."
    set x [ get_fmax_from_report $k_clk_name 1 ]
    set fmax1 [ lindex $x 0 ]
    set k_clk_name [ lindex $x 1 ]
    set x [ get_fmax_from_report $k_clk2x_name 0 ]
    set fmax2 [ lindex $x 0 ]
    set k_clk2x_name [ lindex $x 1 ]

    # The maximum is determined by both the kernel-clock and the double-pumped clock
    set k_fmax $fmax1
    if { [expr 2 * $fmax1] > $fmax2 } {
       set k_fmax [expr $fmax2 / 2.0]
    }
    return [list $k_fmax $fmax1 $k_clk_name $fmax2 $k_clk2x_name]
}

##############################################################################
##############################       MAIN        #############################
##############################################################################

post_message "Running adjust PLLs script"

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

# adjust PLL settings
set k_clk_name_full   $k_clk_name
set k_clk2x_name_full $k_clk2x_name

# Process arguments.
set fmax1 unknown
set fmax2 unknown
set pll_search_string	"*kernel_pll*"

# get device speedgrade
set part_name [get_global_assignment -name DEVICE]
post_message "Device part name is $part_name"
set report [report_part_info $part_name]
regexp {Speed Grade.*$} $report speedgradeline
regexp {(\d+)} $speedgradeline speedgrade
if { $speedgrade < 1 || $speedgrade > 8 } {
  post_message "Speedgrade is $speedgrade and not in the range of 1 to 8"
  post_message "Terminating post-flow script"
  return TCL_ERROR
}
post_message "Speedgrade is $speedgrade"

if {$k_fmax == -1} {
    set x [get_kernel_clks_and_fmax $k_clk_name $k_clk2x_name]
    set k_fmax       [ lindex $x 0 ]
    set fmax1        [ lindex $x 1 ]
    set k_clk_name_full   [ lindex $x 2 ]
    set fmax2        [ lindex $x 3 ]
    set k_clk2x_name_full [ lindex $x 4 ]
}

post_message "Kernel Fmax determined to be $k_fmax";

design::unload_design
# Load post-fit atom netlist
if { [catch {read_atom_netlist -type cmp} bummer] } {
  post_message "Post-fit netlist not found. Please run quartus_fit."
  post_message $bummer
  return TCL_ERROR
# ERROR
}

set kernel_pll_name [find_kernel_pll_in_design $pll_search_string]

# Get the IOPLL node
if { [catch {set node [get_atom_node_by_name -name $kernel_pll_name]} ] } {
  post_message "IOPLL not found: $kernel_pll_name"
  list_plls_in_design
  return TCL_ERROR
  # ERROR
}
	
# Get the refclk frequency from the IOPLL node
# Using the netlist's refclk frequency gives us a santity check.
set refclk_MHz  [get_atom_node_info -key TIME_REFERENCE_CLOCK_FREQUENCY -node $node]
regexp {([0-9.]+)} $refclk_MHz refclk

post_message "PLL reference clock frequency:"
post_message "  $refclk MHz"

set actual_kernel_clk [get_nearest_achievable_frequency $k_fmax $refclk $speedgrade]
post_message "Desired kernel_clk frequency:"
post_message "  $k_fmax MHz"
post_message "Actual kernel_clk frequency:"
post_message "  $actual_kernel_clk MHz"

# Do changes for current revision (either base or import revision)
set success [adjust_iopll_frequency_in_postfit_netlist $revision_name $kernel_pll_name $speedgrade $actual_kernel_clk]
if {$success == "TCL_OK"} {
  post_message "IOPLL settings adjusted successfully for current revision"
}

write_atom_netlist -file abc
design::unload_design
project_close

# A little report
project_open $project_name -revision $revision_name
load_report $revision_name

post_message "Generating acl_quartus_report.txt"
set outfile   [open "acl_quartus_report.txt" w]
set aluts_l   [regsub "," [get_fitter_resource_usage -alut] "" ]
if {[catch {set aluts_m [regsub "," [get_fitter_resource_usage -resource "Memory ALUT usage"] "" ]} result]} {
  set aluts_m 0
}
if { [string length $aluts_m] < 1 || ! [string is integer $aluts_m] } {
  set aluts_m 0
}
set aluts     [expr $aluts_l + $aluts_m]
set registers [get_fitter_resource_usage -reg]
set logicutil [get_fitter_resource_usage -utilization]
set io_pin    [get_fitter_resource_usage -io_pin]
set dsp       [get_fitter_resource_usage -resource "*DSP*"]
set mem_bit   [get_fitter_resource_usage -mem_bit]
set m9k       [get_fitter_resource_usage -resource "M?0K*"]
puts $outfile "ALUTs: $aluts"
puts $outfile "Registers: $registers"
puts $outfile "Logic utilization: $logicutil"
puts $outfile "I/O pins: $io_pin"
puts $outfile "DSP blocks: $dsp"
puts $outfile "Memory bits: $mem_bit"
puts $outfile "RAM blocks: $m9k"
puts $outfile "Actual clock freq: $actual_kernel_clk"
puts $outfile "Kernel fmax: $k_fmax"
puts $outfile "1x clock fmax: $fmax1"
puts $outfile "2x clock fmax: $fmax2"

# Highest non-global fanout signal
set result [find_report_panel_row "Fitter||Place Stage||Fitter Resource Usage Summary" 0 equal "Highest non-global fan-out"]
if {[lindex $result 0] < 0} {error "Error: Could not find highest non-global fan-out (error $retval)"}
set high_fanout_signal_fanout_count [get_report_panel_data -id [lindex $result 1] -row [lindex $result 2] -col 1]

puts $outfile "Highest non-global fanout: $high_fanout_signal_fanout_count"

close $outfile
# End little report

# reconfigure IOPLL IP
# updating board.qsys pr_base_id component to include hash
qexec "qsys-script --quartus-project=$project_name --rev=opencl_bsp_ip --system-file=board.qsys --cmd=\"package require -exact qsys 16.1;set_validation_property AUTOMATIC_VALIDATION false;load_component kernel_clk_gen;set_component_parameter_value \"KERNEL_TARGET_CLOCK_RATE\" \"$actual_kernel_clk\";save_component;save_system board.qsys\""
# re-run board.qsys generation
qexec "qsys-generate -syn --family=\"Stratix 10\" --part=$part_name board.qsys"

# Preserve original sta report
file copy -force $revision_name.sta.rpt $revision_name.sta-orig.rpt

# Force sta timing netlist to be rebuilt
file delete [glob -nocomplain qdb/_compiler/$revision_name/root_partition/*/final/1/*cache*]
file delete [glob -nocomplain qdb/_compiler/$revision_name/root_partition/*/final/1/timing_netlist*]

# Re-run STA
set sdk_root [string map {"\\" "/"} $::env(INTELFPGAOCLSDKROOT)]
post_message "Launching STA with report script $sdk_root/ip/board/bsp/failing_clocks.tcl"
if {[catch {execute_module -tool sta -args "--report_script=$sdk_root/ip/board/bsp/failing_clocks.tcl"} result]} {
  post_message -type error "Error! $result"
  exit 2
}

design::unload_design
project_close

# quartus_asm (after PLL atom update)
if {[string match $revision_name "base"]} {
  post_message "Compiling base revision -> generating base.sof only!"
  qexec "quartus_asm --read_settings_files=on --write_settings_files=off top -c base"
} elseif {[string match $revision_name "top"]} {
  post_message "Compiling top revision -> generating base.sof and top.sof!"
  qexec "quartus_asm --read_settings_files=on --write_settings_files=off top -c base"
  qexec "quartus_asm --read_settings_files=on --write_settings_files=off top -c top"
} elseif {[string match $revision_name "flat"]} {
  post_message "Compiling flat revision -> generating flat.sof only!"
  qexec "quartus_asm --read_settings_files=on --write_settings_files=off top -c flat"
} 

