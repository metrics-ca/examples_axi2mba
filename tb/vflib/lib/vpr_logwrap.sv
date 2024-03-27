//----------------------------------------------------------------------
/**
 * @file vpr_logwrap.sv
 * @brief Defines VPR log wrapper class.
 */
/*
 * Copyright (C) 2007-2009 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VPR_LOGWRAP_SV_
`define _VPR_LOGWRAP_SV_
//`protect

//======================================================================
/**
 * Log wrapper class.
 * Independent from any Methodologies version
 */
//======================================================================

`ifdef _VFLIB_SV_
   `include "vpr_logwrap_vf.svi"
`else // `ifdef _VFLIB_SV_
   `include "vpr_logwrap_na.svi"
`endif // `ifdef _VFLIB_SV_

//`endprotect
`endif // `ifndef _VPR_LOGWRAP_SV_
