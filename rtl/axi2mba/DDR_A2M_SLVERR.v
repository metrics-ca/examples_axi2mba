//----------------------------------------------------------------------
/**
 * @file DDR_A2M_SLVERR.v
 * @brief Defines AXI to MBA bridge: Request error module.
 */
//----------------------------------------------------------------------

module DDR_A2M_SLVERR
   (
    //AXLEN       ,   // i
      AXSIZE      ,   // i
      AXBURST     ,   // i
      SLVERR      //, // o
   );

   //===================================================================
   // parameters
   //===================================================================

   `include       "DDR_A2M_AXI_PARAM.vh"

   //===================================================================
   // ports
   //===================================================================

 //input    [  7:0]        AXLEN       ;
   input    [  2:0]        AXSIZE      ;
   input    [  1:0]        AXBURST     ;
   output                  SLVERR      ;

   //===================================================================
   // signals
   //===================================================================

   wire                    size_err    ;
   wire                    burst_err   ;

   //===================================================================
   // logic
   //===================================================================

   assign   SLVERR      =  size_err | burst_err;

   assign   size_err    =  ( AXSIZE  == P_ASIZE_32  ) |
                           ( AXSIZE  == P_ASIZE_64  ) |
                           ( AXSIZE  == P_ASIZE_128 );
   assign   burst_err   =  ( AXBURST == P_ABURST_FIXED ) |
                           ( AXBURST == P_ABURST_RSVD  );

endmodule
// end of file
