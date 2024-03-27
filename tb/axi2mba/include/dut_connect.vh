//----------------------------------------------------------------------
/**
 * @file dut_connect.vh
 * @brief Defines DUT Port Connections.
 */
/*
 * Copyright (C) 2009-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _DUT_CONNECT_VH_
`define _DUT_CONNECT_VH_
//`protect

   //-------------------------------------------------------------------
   // System
   //-------------------------------------------------------------------
   assign   CLK               =  tbclk                ; // input
   assign   ZRESET            =  tbrst_n              ; // input
   assign   SLP               =  dut_intf.slp         ; // input
   assign   DQTYPE            =  dut_intf.dqtype      ; // input
   assign   axi_intf.aclk     =  tbclk                ;
   assign   mba_intf.clk      =  tbclk                ;
   assign   dut_intf.clk      =  tbclk                ;
   assign   axi_intf.aresetn  =  tbrst_n              ;
   assign   mba_intf.zreset   =  tbrst_n              ;
   assign   dut_intf.zreset   =  tbrst_n              ;
   //-------------------------------------------------------------------
   // AXI Write address channel
   //-------------------------------------------------------------------
   assign   AWID        =  axi_intf.awid[P_WIW-1:0]   ; // input
   assign   AWADDR      =  axi_intf.awaddr[P_AW-1:0]  ; // input
   assign   AWLEN       =  axi_intf.awlen[  7:0]      ; // input
   assign   AWSIZE      =  axi_intf.awsize[  2:0]     ; // input
   assign   AWBURST     =  axi_intf.awburst[  1:0]    ; // input
   assign   AWLOCK      =  axi_intf.awlock[  0]       ; // input
 //assign   AWCACHE     =  axi_intf.awcache[  3:0]    ; // input
 //assign   AWPROT      =  axi_intf.awprot[  2:0]     ; // input
   assign   AWVALID     =  axi_intf.awvalid           ; // input
   assign   axi_intf.awready  =  AWREADY              ; // output
   //-------------------------------------------------------------------
   // AXI Write data channel
   //-------------------------------------------------------------------
 //assign   WID         =  axi_intf.wid[P_WIW-1:0]    ; // input
   assign   WDATA       =  axi_intf.wdata[P_DW-1:0]   ; // input
   assign   WSTRB       =  axi_intf.wstrb[P_SW-1:0]   ; // input
   assign   WLAST       =  axi_intf.wlast             ; // input
   assign   WVALID      =  axi_intf.wvalid            ; // input
   assign   axi_intf.wready   =  WREADY               ; // output
   //-------------------------------------------------------------------
   // AXI Write response channel
   //-------------------------------------------------------------------
   assign   axi_intf.bid[P_WIW-1:0] =  BID            ; // output
   assign   axi_intf.bresp[  1:0]   =  BRESP          ; // output
   assign   axi_intf.bvalid         =  BVALID         ; // output
   assign   BREADY      =  axi_intf.bready            ; // input
   //-------------------------------------------------------------------
   // AXI Read address channel
   //-------------------------------------------------------------------
   assign   ARID        =  axi_intf.arid[P_RIW-1:0]   ; // input
   assign   ARADDR      =  axi_intf.araddr[P_AW-1:0]  ; // input
   assign   ARLEN       =  axi_intf.arlen[  7:0]      ; // input
   assign   ARSIZE      =  axi_intf.arsize[  2:0]     ; // input
   assign   ARBURST     =  axi_intf.arburst[  1:0]    ; // input
   assign   ARLOCK      =  axi_intf.arlock[  0]       ; // input
 //assign   ARCACHE     =  axi_intf.arcache[  3:0]    ; // input
 //assign   ARPROT      =  axi_intf.arprot[  2:0]     ; // input
   assign   ARVALID     =  axi_intf.arvalid           ; // input
   assign   axi_intf.arready  =  ARREADY              ; // output
   //-------------------------------------------------------------------
   // AXI Read data channel
   //-------------------------------------------------------------------
   assign   axi_intf.rid[P_RIW-1:0]    =  RID         ; // output
   assign   axi_intf.rdata[P_DW-1:0]   =  RDATA       ; // output
   assign   axi_intf.rresp[  1:0]      =  RRESP       ; // output
   assign   axi_intf.rlast             =  RLAST       ; // output
   assign   axi_intf.rvalid            =  RVALID      ; // output
   assign   RREADY      =  axi_intf.rready            ; // input
   //-------------------------------------------------------------------
   // MBA I/F(monitor)
   //-------------------------------------------------------------------
   assign   mba_intf.arb_req           =  ARB_REQ     ; // output
   assign   mba_intf.arb_rel           =  ARB_REL     ; // input
   assign   mba_intf.arb_nel           =  ARB_NEL     ; // input
   assign   mba_intf.arb_rzw           =  ARB_RZW     ; // output
   assign   mba_intf.arb_adr[ 29:2]    =  ARB_ADR     ; // output
   assign   mba_intf.arb_bst[  9:2]    =  ARB_BST     ; // output
   assign   mba_intf.arb_wak           =  ARB_WAK     ; // input
   assign   mba_intf.arb_rdt[P_DW-1:0] =  ARB_RDT     ; // output
   assign   mba_intf.arb_ben[P_SW-1:0] =  ARB_BEN     ; // output
   assign   mba_intf.arb_rak           =  ARB_RAK     ; // input
   assign   mba_intf.arb_wdt[P_DW-1:0] =  ARB_WDT     ; // input

//`endprotect
`endif // `ifndef _DUT_CONNECT_VH_
