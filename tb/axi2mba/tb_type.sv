//----------------------------------------------------------------------
/**
 * @file tb_type.sv
 * @brief Defines Testbench common types.
 */
/*
 * Copyright (C) 2007-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _TB_TYPE_SV_
`define _TB_TYPE_SV_
//`protect

virtual class tb_type extends vpr_void_class;

   //===================================================================
   // Enumerations
   //===================================================================

   /// Stream ID
   typedef enum int
                  {  UNKNOWN_ID  = -1,
                     AXI_ID      ,
                     MBA_ID      ,
                     DUT_PIN_ID  ,
                     RESERVED_ID
                  }  stream_id_e;

   /// Initiator ID
   typedef enum int
                  {  UNKNOWN_I   = -1,
                     AXI_I       =  0,
                     RESERVED_I
                  }  initiator_id_e;

   /// Taget ID
   typedef enum int
                  {  UNKNOWN_T   = -1,
                     MBA_T       =  0,
                     RESERVED_T
                  }  target_id_e;

   //===================================================================
   // static methods
   //===================================================================

endclass: tb_type
//`endprotect
`endif // `ifndef _TB_TYPE_SV_
