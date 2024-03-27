//----------------------------------------------------------------------
/**
 * @file dut_signal.vh
 * @brief Defines DUT Port Signals.
 */
/*
 * Copyright (C) 2009-2011 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _DUT_SIGNAL_VH_
`define _DUT_SIGNAL_VH_
//`protect

   //-------------------------------------------------------------------
   // System
   //-------------------------------------------------------------------
   wire                    CLK         ; // input
   wire                    ZRESET      ; // input
   wire                    SLP         ; // input
   wire                    DQTYPE      ; // input
   //-------------------------------------------------------------------
   // AXI Write address channel
   //-------------------------------------------------------------------
   wire     [P_WIW-1:0]    AWID        ; // input
   wire     [P_AW-1:0]     AWADDR      ; // input
   wire     [  7:0]        AWLEN       ; // input
   wire     [  2:0]        AWSIZE      ; // input
   wire     [  1:0]        AWBURST     ; // input
   wire                    AWLOCK      ; // input
 //wire     [  3:0]        AWCACHE     ; // input
 //wire     [  2:0]        AWPROT      ; // input
   wire                    AWVALID     ; // input
   wire                    AWREADY     ; // output
   //-------------------------------------------------------------------
   // AXI Write data channel
   //-------------------------------------------------------------------
 //wire     [P_WIW-1:0]    WID         ; // input
   wire     [P_DW-1:0]     WDATA       ; // input
   wire     [P_SW-1:0]     WSTRB       ; // input
   wire                    WLAST       ; // input
   wire                    WVALID      ; // input
   wire                    WREADY      ; // output
   //-------------------------------------------------------------------
   // AXI Write response channel
   //-------------------------------------------------------------------
   wire     [P_WIW-1:0]    BID         ; // output
   wire     [  1:0]        BRESP       ; // output
   wire                    BVALID      ; // output
   wire                    BREADY      ; // input
   //-------------------------------------------------------------------
   // AXI Read address channel
   //-------------------------------------------------------------------
   wire     [P_RIW-1:0]    ARID        ; // input
   wire     [P_AW-1:0]     ARADDR      ; // input
   wire     [  7:0]        ARLEN       ; // input
   wire     [  2:0]        ARSIZE      ; // input
   wire     [  1:0]        ARBURST     ; // input
   wire                    ARLOCK      ; // input
 //wire     [  3:0]        ARCACHE     ; // input
 //wire     [  2:0]        ARPROT      ; // input
   wire                    ARVALID     ; // input
   wire                    ARREADY     ; // output
   //-------------------------------------------------------------------
   // AXI Read data channel
   //-------------------------------------------------------------------
   wire     [P_RIW-1:0]    RID         ; // output
   wire     [P_DW-1:0]     RDATA       ; // output
   wire     [  1:0]        RRESP       ; // output
   wire                    RLAST       ; // output
   wire                    RVALID      ; // output
   wire                    RREADY      ; // input
   //-------------------------------------------------------------------
   // MBA I/F
   //-------------------------------------------------------------------
   wire                    ARB_REQ     ; // output
   wire                    ARB_REL     ; // input
   wire                    ARB_NEL     ; // input
   wire                    ARB_RZW     ; // output
   wire     [ 29:2]        ARB_ADR     ; // output
   wire     [  9:2]        ARB_BST     ; // output
   wire                    ARB_WAK     ; // input
   wire     [P_DW-1:0]     ARB_RDT     ; // output
   wire     [P_SW-1:0]     ARB_BEN     ; // output
   wire                    ARB_RAK     ; // input
   wire     [P_DW-1:0]     ARB_WDT     ; // input

//`endprotect
`endif // `ifndef _DUT_SIGNAL_VH_
