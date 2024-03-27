//----------------------------------------------------------------------
/**
 * @file vsl_type.sv
 * @brief Defines VSL common defined-type class.
 */
/*
 * Copyright (C) 2007-2010 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VSL_TYPE_SV_
`define _VSL_TYPE_SV_
//`protect

//======================================================================
/**
 * VSL common Defined-type Class.
 */
//======================================================================

virtual class vsl_type extends vsl_void_class;

   //===================================================================
   // defined-types
   //===================================================================

   //===================================================================
   // enumerations
   //===================================================================

   // Kind of report type.
   typedef enum int { REPORT_ALL     = -1,
                      REPORT_ENTRIES =  1,
                      REPORT_STAT    =  2,
                      REPORT_STAT_I  =  4,
                      REPORT_STAT_T  =  8,
                      REPORT_RANGES  = 16,
                      REPORT_ALLOCS  = 32
                      } report_kind_e;

   /// Kind of compare_entry(), copy_entry() and psdisplay_entry().
   typedef enum int { SBE_ALL  = -1,
                      SBE_ID   =  1,
                      SBE_ADDR =  2,
                      SBE_DATA =  4,
                      SBE_ACK  =  8,
                      SBE_PERF = 16
                      } sbe_kind_e;

   // Kind of sb find method.
   typedef enum int { FIND_ALL     , // for find()
                      FIND_STATUS  , // for find()
                      FIND_FIRST   , // for find_one()
                      FIND_LAST    , // for find_one()
                      FIND_IN_ORDER  // for find_one()
                      } sb_find_e;

   // Kind of remove from sb.
   typedef enum int { REMOVE_AUTO    = 0,
                      REMOVE_NORMAL  = 1,
                      REMOVE_CANCEL  = 2,
                      REMOVE_ERROR   = 4,
                      REMOVE_UNKNOWN = 8
                      } sb_remove_e;

   // Kind of sbe trace/logging type.
   typedef enum int { TRACE_INSERT = 1,
                      TRACE_UPDATE = 2,
                      TRACE_MOVE   = 4,
                      TRACE_REMOVE = 8
                      } sb_trace_e;

   // Kind of range access.
   typedef enum int { READ           = 0,
                      WRITE          = 1,
                      //BUS_SPECIFIC   = 2,
                      //USER_DEFINED   = 3,
                      READ_AND_WRITE = 4,
                      READ_OR_WRITE  = 5
                      } access_e;

   // Kind of range type.
   typedef enum int { INTERNAL_R = -3,
                      RESERVED_R = -2,
                      UNKNOWN_R  = -1,
                      NORMAL_R   =  0
                      } range_e;

   /// Type of transaction.
   typedef enum int { INITIATOR_TYP = 1,
                      TARGET_TYP    = 2,
                      MONITOR_TYP   = 4,
                      PROTOCOL_TYP  = 8,
                      RANGE_TYP     = 16
                      } sfunc_type_e;


   /// Kind of report target
   typedef enum int { REPORT_NONE    = 0,
                      REPORT_LOG     = 1,
                      REPORT_DISPLAY = 2,
                      REPORT_FILE    = 4,
                      REPORT_DB      = 8
                      } report_target_e;

   /// Kind of log severity of log wrapper
   typedef enum int { SEV_REPORT  = -1,
                      SEV_NONE    =  0,
                      SEV_FATAL   =  1,
                      SEV_ERROR   =  2,
                      SEV_WARNING =  4,
                      SEV_NOTE    =  8,
                      SEV_TRACE   = 16,
                      SEV_DEBUG   = 32,
                      SEV_VERBOSE = 64
                      } log_sev_e;

endclass: vsl_type
//`endprotect
`endif // `ifndef _VSL_TYPE_SV_
