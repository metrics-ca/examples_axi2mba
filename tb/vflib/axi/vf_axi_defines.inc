//----------------------------------------------------------------------
/**
 * @file vf_axi_defines.inc
 * @brief Defines VF AXI port defines.
 */
/*
 * Copyright (C) 2007-2011 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VF_AXI_DEFINES_INC_
`define _VF_AXI_DEFINES_INC_
//`protect

`define VF_AXI_ID_WIDTH         16
`define VF_AXI_ADDR_WIDTH       64
`define VF_AXI_DATA_WIDTH     1024
`define VF_AXI_STRB_WIDTH     (`VF_AXI_DATA_WIDTH/8)
`define VF_AXI_SIDE_WIDTH       32

//`endprotect
`endif // `ifndef _VF_AXI_DEFINES_INC_
