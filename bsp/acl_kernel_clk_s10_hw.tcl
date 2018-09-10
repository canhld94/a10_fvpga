package require -exact qsys 16.1

# module properties
set_module_property NAME {acl_kernel_clk_s10}
set_module_property DISPLAY_NAME {OpenCL S10 Kernel Clock Generator}

# default module properties
set_module_property VERSION {17.0}
set_module_property GROUP {OpenCL BSP Components}
set_module_property DESCRIPTION {default description}
set_module_property AUTHOR {author}

# Set the name of the procedure to manipulate parameters
set_module_property COMPOSITION_CALLBACK comp

# +-----------------------------------
# | parameters
# | 
add_parameter REF_CLK_RATE FLOAT 125.0
set_parameter_property REF_CLK_RATE DEFAULT_VALUE 125.0
set_parameter_property REF_CLK_RATE DISPLAY_NAME "REF_CLK_RATE"
set_parameter_property REF_CLK_RATE AFFECTS_ELABORATION true

add_parameter KERNEL_TARGET_CLOCK_RATE FLOAT 400.0
set_parameter_property KERNEL_TARGET_CLOCK_RATE DEFAULT_VALUE 400.0
set_parameter_property KERNEL_TARGET_CLOCK_RATE DISPLAY_NAME "KERNEL_TARGET_CLOCK_RATE"
set_parameter_property KERNEL_TARGET_CLOCK_RATE AFFECTS_ELABORATION true
# | 
# +-----------------------------------

proc comp { } {

  # Instances and instance parameters
  # (disabled instances are intentionally culled)
  add_instance clk clock_source 17.0
  set_instance_parameter_value clk {clockFrequency} {50000000.0}
  set_instance_parameter_value clk {clockFrequencyKnown} {1}
  set_instance_parameter_value clk {resetSynchronousEdges} {DEASSERT}

  add_instance counter acl_timer 10.0
  set_instance_parameter_value counter {WIDTH} {32}

  add_instance ctrl altera_avalon_mm_bridge 17.0
  set_instance_parameter_value ctrl {DATA_WIDTH} {32}
  set_instance_parameter_value ctrl {SYMBOL_WIDTH} {8}
  set_instance_parameter_value ctrl {ADDRESS_WIDTH} {12}
  set_instance_parameter_value ctrl {USE_AUTO_ADDRESS_WIDTH} {0}
  set_instance_parameter_value ctrl {ADDRESS_UNITS} {SYMBOLS}
  set_instance_parameter_value ctrl {MAX_BURST_SIZE} {1}
  set_instance_parameter_value ctrl {MAX_PENDING_RESPONSES} {4}
  set_instance_parameter_value ctrl {LINEWRAPBURSTS} {0}
  set_instance_parameter_value ctrl {PIPELINE_COMMAND} {0}
  set_instance_parameter_value ctrl {PIPELINE_RESPONSE} {0}
  set_instance_parameter_value ctrl {USE_RESPONSE} {0}

  add_instance kernel_clk clock_source 17.0
  set_instance_parameter_value kernel_clk {clockFrequency} {50000000.0}
  set_instance_parameter_value kernel_clk {clockFrequencyKnown} {0}
  set_instance_parameter_value kernel_clk {resetSynchronousEdges} {NONE}

  add_instance kernel_clk2x clock_source 17.0
  set_instance_parameter_value kernel_clk2x {clockFrequency} {100000000.0}
  set_instance_parameter_value kernel_clk2x {clockFrequencyKnown} {0}
  set_instance_parameter_value kernel_clk2x {resetSynchronousEdges} {NONE}

  add_instance kernel_pll altera_iopll 17.0
  set_instance_parameter_value kernel_pll {gui_en_reconf} {1}
  set_instance_parameter_value kernel_pll {gui_en_dps_ports} {0}
  set_instance_parameter_value kernel_pll {gui_pll_mode} {Integer-N PLL}
  set_instance_parameter_value kernel_pll {gui_reference_clock_frequency} {100.0}
  set_instance_parameter_value kernel_pll {gui_fractional_cout} {32}
  set_instance_parameter_value kernel_pll {gui_dsm_out_sel} {1st_order}
  set_instance_parameter_value kernel_pll {gui_use_locked} {1}
  set_instance_parameter_value kernel_pll {gui_en_adv_params} {0}
  set_instance_parameter_value kernel_pll {gui_pll_bandwidth_preset} {Low}
  set_instance_parameter_value kernel_pll {gui_lock_setting} {Low Lock Time}
  set_instance_parameter_value kernel_pll {gui_pll_auto_reset} {0}
  set_instance_parameter_value kernel_pll {gui_en_lvds_ports} {Disabled}
  set_instance_parameter_value kernel_pll {gui_operation_mode} {direct}
  set_instance_parameter_value kernel_pll {gui_feedback_clock} {Global Clock}
  set_instance_parameter_value kernel_pll {gui_clock_to_compensate} {0}
  set_instance_parameter_value kernel_pll {gui_use_NDFB_modes} {0}
  set_instance_parameter_value kernel_pll {gui_refclk_switch} {0}
  set_instance_parameter_value kernel_pll {gui_refclk1_frequency} {100.0}
  set_instance_parameter_value kernel_pll {gui_en_phout_ports} {0}
  set_instance_parameter_value kernel_pll {gui_phout_division} {1}
  set_instance_parameter_value kernel_pll {gui_en_extclkout_ports} {0}
  set_instance_parameter_value kernel_pll {gui_number_of_clocks} {2}
  set_instance_parameter_value kernel_pll {gui_multiply_factor} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_n} {1}
  set_instance_parameter_value kernel_pll {gui_frac_multiply_factor} {1.0}
  set_instance_parameter_value kernel_pll {gui_fix_vco_frequency} {0}
  set_instance_parameter_value kernel_pll {gui_fixed_vco_frequency} {600.0}
  set_instance_parameter_value kernel_pll {gui_vco_frequency} {600.0}
  set_instance_parameter_value kernel_pll {gui_enable_output_counter_cascading} {0}
  set_instance_parameter_value kernel_pll {gui_mif_gen_options} {Generate New MIF File}
  set_instance_parameter_value kernel_pll {gui_new_mif_file_path} {pll.mif}
  set_instance_parameter_value kernel_pll {gui_existing_mif_file_path} {pll.mif}
  set_instance_parameter_value kernel_pll {gui_mif_config_name} {unnamed}
  set_instance_parameter_value kernel_pll {gui_active_clk} {0}
  set_instance_parameter_value kernel_pll {gui_clk_bad} {0}
  set_instance_parameter_value kernel_pll {gui_switchover_mode} {Automatic Switchover}
  set_instance_parameter_value kernel_pll {gui_switchover_delay} {0}
  set_instance_parameter_value kernel_pll {gui_enable_cascade_out} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_outclk_index} {0}
  set_instance_parameter_value kernel_pll {gui_enable_cascade_in} {0}
  set_instance_parameter_value kernel_pll {gui_pll_cascading_mode} {adjpllin}
  set_instance_parameter_value kernel_pll {gui_enable_mif_dps} {0}
  set_instance_parameter_value kernel_pll {gui_dps_cntr} {C0}
  set_instance_parameter_value kernel_pll {gui_dps_num} {1}
  set_instance_parameter_value kernel_pll {gui_dps_dir} {Positive}
  set_instance_parameter_value kernel_pll {gui_extclkout_0_source} {C0}
  set_instance_parameter_value kernel_pll {gui_extclkout_1_source} {C0}
  set_instance_parameter_value kernel_pll {gui_clock_name_global} {0}
  set_instance_parameter_value kernel_pll {gui_clock_name_string0} {outclk0}
  set_instance_parameter_value kernel_pll {gui_clock_name_string1} {outclk1}
  set_instance_parameter_value kernel_pll {gui_clock_name_string2} {outclk2}
  set_instance_parameter_value kernel_pll {gui_clock_name_string3} {outclk3}
  set_instance_parameter_value kernel_pll {gui_clock_name_string4} {outclk4}
  set_instance_parameter_value kernel_pll {gui_clock_name_string5} {outclk5}
  set_instance_parameter_value kernel_pll {gui_clock_name_string6} {outclk6}
  set_instance_parameter_value kernel_pll {gui_clock_name_string7} {outclk7}
  set_instance_parameter_value kernel_pll {gui_clock_name_string8} {outclk8}
  set_instance_parameter_value kernel_pll {gui_clock_name_string9} {outclk9}
  set_instance_parameter_value kernel_pll {gui_clock_name_string10} {outclk10}
  set_instance_parameter_value kernel_pll {gui_clock_name_string11} {outclk11}
  set_instance_parameter_value kernel_pll {gui_clock_name_string12} {outclk12}
  set_instance_parameter_value kernel_pll {gui_clock_name_string13} {outclk13}
  set_instance_parameter_value kernel_pll {gui_clock_name_string14} {outclk14}
  set_instance_parameter_value kernel_pll {gui_clock_name_string15} {outclk15}
  set_instance_parameter_value kernel_pll {gui_clock_name_string16} {outclk16}
  set_instance_parameter_value kernel_pll {gui_clock_name_string17} {outclk17}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c0} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c1} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c2} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c3} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c4} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c5} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c6} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c7} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c8} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c9} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c10} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c11} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c12} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c13} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c14} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c15} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c16} {6}
  set_instance_parameter_value kernel_pll {gui_divide_factor_c17} {6}
  set_instance_parameter_value kernel_pll {gui_cascade_counter0} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter1} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter2} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter3} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter4} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter5} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter6} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter7} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter8} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter9} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter10} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter11} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter12} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter13} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter14} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter15} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter16} {0}
  set_instance_parameter_value kernel_pll {gui_cascade_counter17} {0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency0} {350.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency1} {700.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency2} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency3} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency4} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency5} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency6} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency7} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency8} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency9} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency10} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency11} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency12} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency13} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency14} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency15} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency16} {100.0}
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency17} {100.0}
  set_instance_parameter_value kernel_pll {gui_ps_units0} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units1} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units2} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units3} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units4} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units5} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units6} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units7} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units8} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units9} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units10} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units11} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units12} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units13} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units14} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units15} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units16} {ps}
  set_instance_parameter_value kernel_pll {gui_ps_units17} {ps}
  set_instance_parameter_value kernel_pll {gui_phase_shift0} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift1} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift2} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift3} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift4} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift5} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift6} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift7} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift8} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift9} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift10} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift11} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift12} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift13} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift14} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift15} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift16} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift17} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg0} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg1} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg2} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg3} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg4} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg5} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg6} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg7} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg8} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg9} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg10} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg11} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg12} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg13} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg14} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg15} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg16} {0.0}
  set_instance_parameter_value kernel_pll {gui_phase_shift_deg17} {0.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle0} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle1} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle2} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle3} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle4} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle5} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle6} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle7} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle8} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle9} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle10} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle11} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle12} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle13} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle14} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle15} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle16} {50.0}
  set_instance_parameter_value kernel_pll {gui_duty_cycle17} {50.0}

  add_instance pll_lock_avs pll_lock_avs 10.0
  set_instance_parameter_value pll_lock_avs {WIDTH} {32}

  add_instance pll_sw_reset sw_reset 10.0
  set_instance_parameter_value pll_sw_reset {WIDTH} {32}
  set_instance_parameter_value pll_sw_reset {LOG2_RESET_CYCLES} {10}

  add_instance version_id version_id 10.0
  set_instance_parameter_value version_id {WIDTH} {32}
  set_instance_parameter_value version_id {VERSION_ID} {-1598029822}

  # connections and connection parameters
  add_connection ctrl.m0 counter.s avalon
  set_connection_parameter_value ctrl.m0/counter.s arbitrationPriority {1}
  set_connection_parameter_value ctrl.m0/counter.s baseAddress {0x0100}
  set_connection_parameter_value ctrl.m0/counter.s defaultConnection {0}

  add_connection ctrl.m0 pll_sw_reset.s avalon
  set_connection_parameter_value ctrl.m0/pll_sw_reset.s arbitrationPriority {1}
  set_connection_parameter_value ctrl.m0/pll_sw_reset.s baseAddress {0x0110}
  set_connection_parameter_value ctrl.m0/pll_sw_reset.s defaultConnection {0}

  add_connection ctrl.m0 version_id.s avalon
  set_connection_parameter_value ctrl.m0/version_id.s arbitrationPriority {1}
  set_connection_parameter_value ctrl.m0/version_id.s baseAddress {0x0000}
  set_connection_parameter_value ctrl.m0/version_id.s defaultConnection {0}

  add_connection ctrl.m0 pll_lock_avs.s avalon
  set_connection_parameter_value ctrl.m0/pll_lock_avs.s arbitrationPriority {1}
  set_connection_parameter_value ctrl.m0/pll_lock_avs.s baseAddress {0x0120}
  set_connection_parameter_value ctrl.m0/pll_lock_avs.s defaultConnection {0}

  add_connection clk.clk ctrl.clk clock

  add_connection clk.clk pll_sw_reset.clk clock

  add_connection clk.clk version_id.clk clock

  add_connection clk.clk pll_lock_avs.clk clock

  add_connection kernel_pll.outclk0 counter.clk clock

  add_connection kernel_pll.outclk0 kernel_clk.clk_in clock

  add_connection kernel_pll.outclk1 counter.clk2x clock

  add_connection kernel_pll.outclk1 kernel_clk2x.clk_in clock

  add_connection pll_lock_avs.lock kernel_pll.locked conduit
  set_connection_parameter_value pll_lock_avs.lock/kernel_pll.locked endPort {}
  set_connection_parameter_value pll_lock_avs.lock/kernel_pll.locked endPortLSB {0}
  set_connection_parameter_value pll_lock_avs.lock/kernel_pll.locked startPort {}
  set_connection_parameter_value pll_lock_avs.lock/kernel_pll.locked startPortLSB {0}
  set_connection_parameter_value pll_lock_avs.lock/kernel_pll.locked width {0}

  add_connection clk.clk_reset kernel_clk.clk_in_reset reset

  add_connection clk.clk_reset kernel_clk2x.clk_in_reset reset

  add_connection clk.clk_reset pll_sw_reset.clk_reset reset

  add_connection clk.clk_reset counter.clk_reset reset

  add_connection clk.clk_reset version_id.clk_reset reset

  add_connection clk.clk_reset pll_lock_avs.clk_reset reset

  add_connection clk.clk_reset ctrl.reset reset

  add_connection clk.clk_reset kernel_pll.reset reset

  add_connection pll_sw_reset.sw_reset kernel_pll.reset reset

  # exported interfaces
  add_interface clk clock sink
  set_interface_property clk EXPORT_OF clk.clk_in
  add_interface ctrl avalon slave
  set_interface_property ctrl EXPORT_OF ctrl.s0
  add_interface kernel_clk clock source
  set_interface_property kernel_clk EXPORT_OF kernel_clk.clk
  add_interface kernel_clk2x clock source
  set_interface_property kernel_clk2x EXPORT_OF kernel_clk2x.clk
  add_interface kernel_pll_locked conduit end
  set_interface_property kernel_pll_locked EXPORT_OF pll_lock_avs.lock_export
  add_interface kernel_pll_refclk clock sink
  set_interface_property kernel_pll_refclk EXPORT_OF kernel_pll.refclk
  add_interface reset reset sink
  set_interface_property reset EXPORT_OF clk.clk_in_reset

  set_instance_parameter_value kernel_pll {gui_reference_clock_frequency} [get_parameter_value REF_CLK_RATE]
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency0} [get_parameter_value KERNEL_TARGET_CLOCK_RATE]
  set_instance_parameter_value kernel_pll {gui_output_clock_frequency1} [expr 2.0 * [get_parameter_value KERNEL_TARGET_CLOCK_RATE] ] 
}
