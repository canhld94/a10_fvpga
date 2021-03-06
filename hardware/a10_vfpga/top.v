// (C) 1992-2017 Intel Corporation.                            
// Intel, the Intel logo, Intel, MegaCore, NIOS II, Quartus and TalkBack words    
// and logos are trademarks of Intel Corporation or its subsidiaries in the U.S.  
// and/or other countries. Other marks and brands may be claimed as the property  
// of others. See Trademarks on intel.com for full list of Intel trademarks or    
// the Trademarks & Brands Names Database (if Intel) or See www.Intel.com/legal (if Altera) 
// Your use of Intel Corporation's design tools, logic functions and other        
// software and tools, and its AMPP partner logic functions, and any output       
// files any of the foregoing (including device programming or simulation         
// files), and any associated documentation or information are expressly subject  
// to the terms and conditions of the Altera Program License Subscription         
// Agreement, Intel MegaCore Function License Agreement, or other applicable      
// license agreement, including, without limitation, that your use is for the     
// sole purpose of programming logic devices manufactured by Intel and sold by    
// Intel or its authorized distributors.  Please refer to the applicable          
// agreement for further details.                                                 


module top(
  //////// CLOCK //////////
  input        config_clk,  		// 50MHz clock
  input        pll_ref_clk,  		// reference clock for the DDR Memory PLL
  input        kernel_pll_refclk,       // 125MHz clock

  //////// PCIe //////////
  input        pcie_refclk, 		// 100MHz clock
  input        perstl0_n,   		// Reset to embedded PCIe
  input  [7:0] hip_serial_rx_in,
  output [7:0] hip_serial_tx_out,

  //////// DDR4 //////////
  input         oct_rzqin,
  output [1:0]  mem_ba,
  output [0:0]  mem_bg,
  output [0:0]  mem_cke,
  output [0:0]  mem_ck,
  output [0:0]  mem_ck_n,
  output [0:0]  mem_cs_n,
  output [0:0]  mem_reset_n,
  output [0:0]  mem_odt,
  output [0:0]  mem_act_n,
  output [16:0] mem_a,
  inout  [63:0] mem_dq,
  inout  [7:0]  mem_dqs,
  inout  [7:0]  mem_dqs_n,
  inout  [7:0]  mem_dbi_n,

   //////// Push Button (used for debugging) //////////
   input         push_button,       // connects to PB0 on the board

   //////// LEDs //////////
  output [15:0] leds                // LEDs 0-7 are GREEN D3-D10 on the PCB, 8-15 are RED D3-D10 on the PCB
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire 		npor;
wire 		local_cal_fail;
wire 		local_cal_success;
// Four PR signals
wire         	alt_pr_freeze_freeze;	
wire         	alt_pr_freeze_freeze_1;	
wire         	alt_pr_freeze_freeze_2;	
wire         	alt_pr_freeze_freeze_3;	
// Four clock signals
wire		board_kernel_clk_clk;
wire		board_kernel_clk_1_clk;
wire		board_kernel_clk_2_clk;
wire		board_kernel_clk_3_clk;

wire		board_kernel_clk2x_clk;
wire		board_kernel_clk2x_1_clk;
wire		board_kernel_clk2x_2_clk;
wire		board_kernel_clk2x_3_clk;
// Four reset signals
wire         	board_kernel_reset_reset_n;
wire         	board_kernel_reset_1_reset_n;
wire         	board_kernel_reset_2_reset_n;
wire         	board_kernel_reset_3_reset_n;
// Four IRQ signals 
wire [0:0]   	board_kernel_irq_irq;
wire [0:0]   	board_kernel_irq_1_irq;
wire [0:0]   	board_kernel_irq_2_irq;
wire [0:0]   	board_kernel_irq_3_irq;

// Dont care about snooping now
wire [30:0]	board_acl_internal_snoop_data;
wire 		board_acl_internal_snoop_valid;
wire		board_acl_internal_snoop_ready;

// Dupplicated all kernel interface and DDR interface

wire		board_kernel_cra_waitrequest;
wire [63:0]	board_kernel_cra_readdata;
wire         	board_kernel_cra_readdatavalid;
wire [0:0]  	board_kernel_cra_burstcount;
wire [63:0]  	board_kernel_cra_writedata;
wire [29:0]  	board_kernel_cra_address;
wire         	board_kernel_cra_write;
wire         	board_kernel_cra_read;
wire [7:0]   	board_kernel_cra_byteenable;
wire         	board_kernel_cra_debugaccess;
wire         	board_kernel_mem0_waitrequest;
wire [511:0] 	board_kernel_mem0_readdata;
wire         	board_kernel_mem0_readdatavalid;
wire [4:0]   	board_kernel_mem0_burstcount;
wire [511:0] 	board_kernel_mem0_writedata;
wire [30:0]  	board_kernel_mem0_address;
wire         	board_kernel_mem0_write;
wire         	board_kernel_mem0_read;
wire [63:0]  	board_kernel_mem0_byteenable;
wire         	board_kernel_mem0_debugaccess;

wire		board_kernel_cra_1_waitrequest;
wire [63:0]	board_kernel_cra_1_readdata;
wire         	board_kernel_cra_1_readdatavalid;
wire [0:0]  	board_kernel_cra_1_burstcount;
wire [63:0]  	board_kernel_cra_1_writedata;
wire [29:0]  	board_kernel_cra_1_address;
wire         	board_kernel_cra_1_write;
wire         	board_kernel_cra_1_read;
wire [7:0]   	board_kernel_cra_1_byteenable;
wire         	board_kernel_cra_1_debugaccess;
wire         	board_kernel_mem1_waitrequest;
wire [511:0] 	board_kernel_mem1_readdata;
wire         	board_kernel_mem1_readdatavalid;
wire [4:0]   	board_kernel_mem1_burstcount;
wire [511:0] 	board_kernel_mem1_writedata;
wire [30:0]  	board_kernel_mem1_address;
wire         	board_kernel_mem1_write;
wire         	board_kernel_mem1_read;
wire [63:0]  	board_kernel_mem1_byteenable;
wire         	board_kernel_mem1_debugaccess;

wire		board_kernel_cra_2_waitrequest;
wire [63:0]	board_kernel_cra_2_readdata;
wire         	board_kernel_cra_2_readdatavalid;
wire [0:0]  	board_kernel_cra_2_burstcount;
wire [63:0]  	board_kernel_cra_2_writedata;
wire [29:0]  	board_kernel_cra_2_address;
wire         	board_kernel_cra_2_write;
wire         	board_kernel_cra_2_read;
wire [7:0]   	board_kernel_cra_2_byteenable;
wire         	board_kernel_cra_2_debugaccess;
wire         	board_kernel_mem2_waitrequest;
wire [511:0] 	board_kernel_mem2_readdata;
wire         	board_kernel_mem2_readdatavalid;
wire [4:0]   	board_kernel_mem2_burstcount;
wire [511:0] 	board_kernel_mem2_writedata;
wire [30:0]  	board_kernel_mem2_address;
wire         	board_kernel_mem2_write;
wire         	board_kernel_mem2_read;
wire [63:0]  	board_kernel_mem2_byteenable;
wire         	board_kernel_mem2_debugaccess;

wire		board_kernel_cra_3_waitrequest;
wire [63:0]	board_kernel_cra_3_readdata;
wire         	board_kernel_cra_3_readdatavalid;
wire [0:0]  	board_kernel_cra_3_burstcount;
wire [63:0]  	board_kernel_cra_3_writedata;
wire [29:0]  	board_kernel_cra_3_address;
wire         	board_kernel_cra_3_write;
wire         	board_kernel_cra_3_read;
wire [7:0]   	board_kernel_cra_3_byteenable;
wire         	board_kernel_cra_3_debugaccess;
wire         	board_kernel_mem3_waitrequest;
wire [511:0] 	board_kernel_mem3_readdata;
wire         	board_kernel_mem3_readdatavalid;
wire [4:0]   	board_kernel_mem3_burstcount;
wire [511:0] 	board_kernel_mem3_writedata;
wire [30:0]  	board_kernel_mem3_address;
wire         	board_kernel_mem3_write;
wire         	board_kernel_mem3_read;
wire [63:0]  	board_kernel_mem3_byteenable;
wire         	board_kernel_mem3_debugaccess;

//=======================================================
// LEDs for debug
//=======================================================
assign leds[15] = push_button;               // connected only as an example, push_button and LEDs can be useful for debugging during board bring-up
assign leds[14:9] = 6'b111111;
assign leds[8]    = ~local_cal_fail;
assign leds[7:1]  = 7'b1111111;
assign leds[0]    = ~local_cal_success;

//=======================================================
// board instantiation
//=======================================================
board board_inst
(
  // Global signals
  .config_clk_clk( config_clk ),
  .kernel_refclk_clk ( kernel_pll_refclk ),
  .reset_n( perstl0_n ),

  // PCIe pins
  .pcie_refclk_clk( pcie_refclk ),
  .pcie_npor_pin_perst( perstl0_n ),
  .pcie_npor_npor( npor ),
  .pcie_npor_out_reset_n( npor ),
  .pcie_hip_serial_rx_in0( hip_serial_rx_in[0] ),
  .pcie_hip_serial_rx_in1( hip_serial_rx_in[1] ),
  .pcie_hip_serial_rx_in2( hip_serial_rx_in[2] ),
  .pcie_hip_serial_rx_in3( hip_serial_rx_in[3] ),
  .pcie_hip_serial_rx_in4( hip_serial_rx_in[4] ),
  .pcie_hip_serial_rx_in5( hip_serial_rx_in[5] ),
  .pcie_hip_serial_rx_in6( hip_serial_rx_in[6] ),
  .pcie_hip_serial_rx_in7( hip_serial_rx_in[7] ),
  .pcie_hip_serial_tx_out0( hip_serial_tx_out[0] ),
  .pcie_hip_serial_tx_out1( hip_serial_tx_out[1] ),
  .pcie_hip_serial_tx_out2( hip_serial_tx_out[2] ),
  .pcie_hip_serial_tx_out3( hip_serial_tx_out[3] ),
  .pcie_hip_serial_tx_out4( hip_serial_tx_out[4] ),
  .pcie_hip_serial_tx_out5( hip_serial_tx_out[5] ),
  .pcie_hip_serial_tx_out6( hip_serial_tx_out[6] ),
  .pcie_hip_serial_tx_out7( hip_serial_tx_out[7] ),

  // DDR4 pins
  .ddr4a_pll_ref_clk_clk( pll_ref_clk ),
  .ddr4a_oct_oct_rzqin( oct_rzqin ),
  .ddr4a_mem_mem_ba( mem_ba ),
  .ddr4a_mem_mem_bg( mem_bg ),
  .ddr4a_mem_mem_cke( mem_cke ),
  .ddr4a_mem_mem_ck( mem_ck ),
  .ddr4a_mem_mem_ck_n( mem_ck_n ),
  .ddr4a_mem_mem_cs_n( mem_cs_n ),
  .ddr4a_mem_mem_reset_n( mem_reset_n ),
  .ddr4a_mem_mem_odt( mem_odt ),
  .ddr4a_mem_mem_act_n( mem_act_n ),
  .ddr4a_mem_mem_a( mem_a ),
  .ddr4a_mem_mem_dq( mem_dq ),
  .ddr4a_mem_mem_dqs( mem_dqs ),
  .ddr4a_mem_mem_dqs_n( mem_dqs_n ),
  .ddr4a_mem_mem_dbi_n( mem_dbi_n ),
  .ddr4a_status_local_cal_fail( local_cal_fail ),
  .ddr4a_status_local_cal_success( local_cal_success ),

  // signals for PR
  .alt_pr_freeze_freeze(alt_pr_freeze_freeze),
  .alt_pr_freeze_1_freeze_1(alt_pr_freeze_freeze_1),
  .alt_pr_freeze_2_freeze_2(alt_pr_freeze_freeze_2),
  .alt_pr_freeze_3_freeze_3(alt_pr_freeze_freeze_3),

  // board ports
  .kernel_clk_clk(board_kernel_clk_clk),
  .kernel_clk_1_clk(board_kernel_clk_1_clk),
  .kernel_clk_2_clk(board_kernel_clk_2_clk),
  .kernel_clk_3_clk(board_kernel_clk_3_clk),

  .kernel_clk2x_clk(board_kernel_clk2x_clk),
  .kernel_clk2x_1_clk(board_kernel_clk2x_1_clk),
  .kernel_clk2x_2_clk(board_kernel_clk2x_2_clk),
  .kernel_clk2x_3_clk(board_kernel_clk2x_3_clk),

  .kernel_reset_reset_n(board_kernel_reset_reset_n),
  .kernel_reset_1_reset_n(board_kernel_reset_1_reset_n),
  .kernel_reset_2_reset_n(board_kernel_reset_2_reset_n),
  .kernel_reset_3_reset_n(board_kernel_reset_3_reset_n),

  .kernel_irq_irq(board_kernel_irq_irq),
  .kernel_irq_1_irq(board_kernel_irq_1_irq),
  .kernel_irq_2_irq(board_kernel_irq_2_irq),
  .kernel_irq_3_irq(board_kernel_irq_3_irq),

  .acl_internal_snoop_data(board_acl_internal_snoop_data),
  .acl_internal_snoop_valid(board_acl_internal_snoop_valid),
  .acl_internal_snoop_ready(board_acl_internal_snoop_ready),

  .kernel_cra_waitrequest(board_kernel_cra_waitrequest),
  .kernel_cra_readdata(board_kernel_cra_readdata),
  .kernel_cra_readdatavalid(board_kernel_cra_readdatavalid),
  .kernel_cra_burstcount(board_kernel_cra_burstcount),
  .kernel_cra_writedata(board_kernel_cra_writedata),
  .kernel_cra_address(board_kernel_cra_address),
  .kernel_cra_write(board_kernel_cra_write),
  .kernel_cra_read(board_kernel_cra_read),
  .kernel_cra_byteenable(board_kernel_cra_byteenable),
  .kernel_cra_debugaccess(board_kernel_cra_debugaccess),
  .kernel_mem0_waitrequest(board_kernel_mem0_waitrequest),
  .kernel_mem0_readdata(board_kernel_mem0_readdata),
  .kernel_mem0_readdatavalid(board_kernel_mem0_readdatavalid),
  .kernel_mem0_burstcount(board_kernel_mem0_burstcount),
  .kernel_mem0_writedata(board_kernel_mem0_writedata),
  .kernel_mem0_address(board_kernel_mem0_address),
  .kernel_mem0_write(board_kernel_mem0_write),
  .kernel_mem0_read(board_kernel_mem0_read),
  .kernel_mem0_byteenable(board_kernel_mem0_byteenable),
  .kernel_mem0_debugaccess(board_kernel_mem0_debugaccess),

  .kernel_cra_1_waitrequest(board_kernel_cra_1_waitrequest),
  .kernel_cra_1_readdata(board_kernel_cra_1_readdata),
  .kernel_cra_1_readdatavalid(board_kernel_cra_1_readdatavalid),
  .kernel_cra_1_burstcount(board_kernel_cra_1_burstcount),
  .kernel_cra_1_writedata(board_kernel_cra_1_writedata),
  .kernel_cra_1_address(board_kernel_cra_1_address),
  .kernel_cra_1_write(board_kernel_cra_1_write),
  .kernel_cra_1_read(board_kernel_cra_1_read),
  .kernel_cra_1_byteenable(board_kernel_cra_1_byteenable),
  .kernel_cra_1_debugaccess(board_kernel_cra_1_debugaccess),
  .kernel_mem1_waitrequest(board_kernel_mem1_waitrequest),
  .kernel_mem1_readdata(board_kernel_mem1_readdata),
  .kernel_mem1_readdatavalid(board_kernel_mem1_readdatavalid),
  .kernel_mem1_burstcount(board_kernel_mem1_burstcount),
  .kernel_mem1_writedata(board_kernel_mem1_writedata),
  .kernel_mem1_address(board_kernel_mem1_address),
  .kernel_mem1_write(board_kernel_mem1_write),
  .kernel_mem1_read(board_kernel_mem1_read),
  .kernel_mem1_byteenable(board_kernel_mem1_byteenable),
  .kernel_mem1_debugaccess(board_kernel_mem1_debugaccess),

  .kernel_cra_2_waitrequest(board_kernel_cra_2_waitrequest),
  .kernel_cra_2_readdata(board_kernel_cra_2_readdata),
  .kernel_cra_2_readdatavalid(board_kernel_cra_2_readdatavalid),
  .kernel_cra_2_burstcount(board_kernel_cra_2_burstcount),
  .kernel_cra_2_writedata(board_kernel_cra_2_writedata),
  .kernel_cra_2_address(board_kernel_cra_2_address),
  .kernel_cra_2_write(board_kernel_cra_2_write),
  .kernel_cra_2_read(board_kernel_cra_2_read),
  .kernel_cra_2_byteenable(board_kernel_cra_2_byteenable),
  .kernel_cra_2_debugaccess(board_kernel_cra_2_debugaccess),
  .kernel_mem2_waitrequest(board_kernel_mem2_waitrequest),
  .kernel_mem2_readdata(board_kernel_mem2_readdata),
  .kernel_mem2_readdatavalid(board_kernel_mem2_readdatavalid),
  .kernel_mem2_burstcount(board_kernel_mem2_burstcount),
  .kernel_mem2_writedata(board_kernel_mem2_writedata),
  .kernel_mem2_address(board_kernel_mem2_address),
  .kernel_mem2_write(board_kernel_mem2_write),
  .kernel_mem2_read(board_kernel_mem2_read),
  .kernel_mem2_byteenable(board_kernel_mem2_byteenable),
  .kernel_mem2_debugaccess(board_kernel_mem2_debugaccess),

  .kernel_cra_3_waitrequest(board_kernel_cra_3_waitrequest),
  .kernel_cra_3_readdata(board_kernel_cra_3_readdata),
  .kernel_cra_3_readdatavalid(board_kernel_cra_3_readdatavalid),
  .kernel_cra_3_burstcount(board_kernel_cra_3_burstcount),
  .kernel_cra_3_writedata(board_kernel_cra_3_writedata),
  .kernel_cra_3_address(board_kernel_cra_3_address),
  .kernel_cra_3_write(board_kernel_cra_3_write),
  .kernel_cra_3_read(board_kernel_cra_3_read),
  .kernel_cra_3_byteenable(board_kernel_cra_3_byteenable),
  .kernel_cra_3_debugaccess(board_kernel_cra_3_debugaccess),
  .kernel_mem3_waitrequest(board_kernel_mem3_waitrequest),
  .kernel_mem3_readdata(board_kernel_mem3_readdata),
  .kernel_mem3_readdatavalid(board_kernel_mem3_readdatavalid),
  .kernel_mem3_burstcount(board_kernel_mem3_burstcount),
  .kernel_mem3_writedata(board_kernel_mem3_writedata),
  .kernel_mem3_address(board_kernel_mem3_address),
  .kernel_mem3_write(board_kernel_mem3_write),
  .kernel_mem3_read(board_kernel_mem3_read),
  .kernel_mem3_byteenable(board_kernel_mem3_byteenable),
  .kernel_mem3_debugaccess(board_kernel_mem3_debugaccess)

);

//=======================================================
// freeze wrapper instantiation
//=======================================================

// Originral OpenCL PR region
freeze_wrapper freeze_wrapper_inst
(
  .freeze(alt_pr_freeze_freeze),  
  
  // board ports
  .board_kernel_clk_clk(board_kernel_clk_clk),
  .board_kernel_clk2x_clk(board_kernel_clk2x_clk),
  .board_kernel_reset_reset_n(board_kernel_reset_reset_n),
  .board_kernel_irq_irq(board_kernel_irq_irq),
  .board_acl_internal_snoop_data(board_acl_internal_snoop_data),
  .board_acl_internal_snoop_valid(board_acl_internal_snoop_valid),
  .board_acl_internal_snoop_ready(board_acl_internal_snoop_ready),
  .board_kernel_cra_waitrequest(board_kernel_cra_waitrequest),
  .board_kernel_cra_readdata(board_kernel_cra_readdata),
  .board_kernel_cra_readdatavalid(board_kernel_cra_readdatavalid),
  .board_kernel_cra_burstcount(board_kernel_cra_burstcount),
  .board_kernel_cra_writedata(board_kernel_cra_writedata),
  .board_kernel_cra_address(board_kernel_cra_address),
  .board_kernel_cra_write(board_kernel_cra_write),
  .board_kernel_cra_read(board_kernel_cra_read),
  .board_kernel_cra_byteenable(board_kernel_cra_byteenable),
  .board_kernel_cra_debugaccess(board_kernel_cra_debugaccess),
  .board_kernel_mem0_waitrequest(board_kernel_mem0_waitrequest),
  .board_kernel_mem0_readdata(board_kernel_mem0_readdata),
  .board_kernel_mem0_readdatavalid(board_kernel_mem0_readdatavalid),
  .board_kernel_mem0_burstcount(board_kernel_mem0_burstcount),
  .board_kernel_mem0_writedata(board_kernel_mem0_writedata),
  .board_kernel_mem0_address(board_kernel_mem0_address),
  .board_kernel_mem0_write(board_kernel_mem0_write),
  .board_kernel_mem0_read(board_kernel_mem0_read),
  .board_kernel_mem0_byteenable(board_kernel_mem0_byteenable),
  .board_kernel_mem0_debugaccess(board_kernel_mem0_debugaccess)
);

// Custom PR region 1
freeze_wrapper freeze_wrapper_inst_1
(
  .freeze(alt_pr_freeze_freeze_1),  
  
  // board ports
  .board_kernel_clk_clk(board_kernel_clk_1_clk),
  .board_kernel_clk2x_clk(board_kernel_clk2x_1_clk),
  .board_kernel_reset_reset_n(board_kernel_reset_1_reset_n),
  .board_kernel_irq_irq(board_kernel_irq_1_irq),
  .board_acl_internal_snoop_data(),
  .board_acl_internal_snoop_valid(),
  .board_acl_internal_snoop_ready(),
  .board_kernel_cra_waitrequest(board_kernel_cra_1_waitrequest),
  .board_kernel_cra_readdata(board_kernel_cra_1_readdata),
  .board_kernel_cra_readdatavalid(board_kernel_cra_1_readdatavalid),
  .board_kernel_cra_burstcount(board_kernel_cra_1_burstcount),
  .board_kernel_cra_writedata(board_kernel_cra_1_writedata),
  .board_kernel_cra_address(board_kernel_cra_1_address),
  .board_kernel_cra_write(board_kernel_cra_1_write),
  .board_kernel_cra_read(board_kernel_cra_1_read),
  .board_kernel_cra_byteenable(board_kernel_cra_1_byteenable),
  .board_kernel_cra_debugaccess(board_kernel_cra_1_debugaccess),
  .board_kernel_mem0_waitrequest(board_kernel_mem1_waitrequest),
  .board_kernel_mem0_readdata(board_kernel_mem1_readdata),
  .board_kernel_mem0_readdatavalid(board_kernel_mem1_readdatavalid),
  .board_kernel_mem0_burstcount(board_kernel_mem1_burstcount),
  .board_kernel_mem0_writedata(board_kernel_mem1_writedata),
  .board_kernel_mem0_address(board_kernel_mem1_address),
  .board_kernel_mem0_write(board_kernel_mem1_write),
  .board_kernel_mem0_read(board_kernel_mem1_read),
  .board_kernel_mem0_byteenable(board_kernel_mem1_byteenable),
  .board_kernel_mem0_debugaccess(board_kernel_mem1_debugaccess)
);

// // Custom PR region 1
freeze_wrapper freeze_wrapper_inst_2
(
  .freeze(alt_pr_freeze_freeze_2),  
  
  // board ports
  .board_kernel_clk_clk(board_kernel_clk_2_clk),
  .board_kernel_clk2x_clk(board_kernel_clk2x_2_clk),
  .board_kernel_reset_reset_n(board_kernel_reset_2_reset_n),
  .board_kernel_irq_irq(board_kernel_irq_2_irq),
  .board_acl_internal_snoop_data(),
  .board_acl_internal_snoop_valid(),
  .board_acl_internal_snoop_ready(),
  .board_kernel_cra_waitrequest(board_kernel_cra_2_waitrequest),
  .board_kernel_cra_readdata(board_kernel_cra_2_readdata),
  .board_kernel_cra_readdatavalid(board_kernel_cra_2_readdatavalid),
  .board_kernel_cra_burstcount(board_kernel_cra_2_burstcount),
  .board_kernel_cra_writedata(board_kernel_cra_2_writedata),
  .board_kernel_cra_address(board_kernel_cra_2_address),
  .board_kernel_cra_write(board_kernel_cra_2_write),
  .board_kernel_cra_read(board_kernel_cra_2_read),
  .board_kernel_cra_byteenable(board_kernel_cra_2_byteenable),
  .board_kernel_cra_debugaccess(board_kernel_cra_2_debugaccess),
  .board_kernel_mem0_waitrequest(board_kernel_mem2_waitrequest),
  .board_kernel_mem0_readdata(board_kernel_mem2_readdata),
  .board_kernel_mem0_readdatavalid(board_kernel_mem2_readdatavalid),
  .board_kernel_mem0_burstcount(board_kernel_mem2_burstcount),
  .board_kernel_mem0_writedata(board_kernel_mem2_writedata),
  .board_kernel_mem0_address(board_kernel_mem2_address),
  .board_kernel_mem0_write(board_kernel_mem2_write),
  .board_kernel_mem0_read(board_kernel_mem2_read),
  .board_kernel_mem0_byteenable(board_kernel_mem2_byteenable),
  .board_kernel_mem0_debugaccess(board_kernel_mem2_debugaccess)
);

// // Custom PR region 1
freeze_wrapper freeze_wrapper_inst_3
(
  .freeze(alt_pr_freeze_freeze_3),  
  
  // board ports
  .board_kernel_clk_clk(board_kernel_clk_3_clk),
  .board_kernel_clk2x_clk(board_kernel_clk2x_3_clk),
  .board_kernel_reset_reset_n(board_kernel_reset_3_reset_n),
  .board_kernel_irq_irq(board_kernel_irq_3_irq),
  .board_acl_internal_snoop_data(),
  .board_acl_internal_snoop_valid(),
  .board_acl_internal_snoop_ready(),
  .board_kernel_cra_waitrequest(board_kernel_cra_3_waitrequest),
  .board_kernel_cra_readdata(board_kernel_cra_3_readdata),
  .board_kernel_cra_readdatavalid(board_kernel_cra_3_readdatavalid),
  .board_kernel_cra_burstcount(board_kernel_cra_3_burstcount),
  .board_kernel_cra_writedata(board_kernel_cra_3_writedata),
  .board_kernel_cra_address(board_kernel_cra_3_address),
  .board_kernel_cra_write(board_kernel_cra_3_write),
  .board_kernel_cra_read(board_kernel_cra_3_read),
  .board_kernel_cra_byteenable(board_kernel_cra_3_byteenable),
  .board_kernel_cra_debugaccess(board_kernel_cra_3_debugaccess),
  .board_kernel_mem0_waitrequest(board_kernel_mem3_waitrequest),
  .board_kernel_mem0_readdata(board_kernel_mem3_readdata),
  .board_kernel_mem0_readdatavalid(board_kernel_mem3_readdatavalid),
  .board_kernel_mem0_burstcount(board_kernel_mem3_burstcount),
  .board_kernel_mem0_writedata(board_kernel_mem3_writedata),
  .board_kernel_mem0_address(board_kernel_mem3_address),
  .board_kernel_mem0_write(board_kernel_mem3_write),
  .board_kernel_mem0_read(board_kernel_mem3_read),
  .board_kernel_mem0_byteenable(board_kernel_mem3_byteenable),
  .board_kernel_mem0_debugaccess(board_kernel_mem3_debugaccess)
);



endmodule
