//----------------------------------------------------------------------
/**
 * @file DDR_A2M_TTLSIZE.v
 * @brief Defines AXI to MBA bridge: Total transfer size module.
 */
//----------------------------------------------------------------------

module DDR_A2M_TTLSIZE
   (
      AXLEN       ,   // i
      AXSIZE      ,   // i
      TOTAL       //, // o
   );

   //===================================================================
   // parameters
   //===================================================================

   `include       "DDR_A2M_AXI_PARAM.vh"

   //===================================================================
   // ports
   //===================================================================

   input    [  7:0]        AXLEN       ;
   input    [  2:0]        AXSIZE      ;
   output   [ 12:0]        TOTAL       ;

   //===================================================================
   // signals
   //===================================================================

   wire     [  8:0]        len         ;
   reg      [ 12:0]        size        ; // combinational

   //===================================================================
   // logic
   //===================================================================

   assign   TOTAL =  size;

   assign   len   =  { 1'b0, AXLEN } + 1'b1;

   always @*
      case ( AXSIZE )
         P_ASIZE_1   :  size  <= { {4{1'b0}}, len            };
         P_ASIZE_2   :  size  <= { {3{1'b0}}, len, {1{1'b0}} };
         P_ASIZE_4   :  size  <= { {2{1'b0}}, len, {2{1'b0}} };
         P_ASIZE_8   :  size  <= { {1{1'b0}}, len, {3{1'b0}} };
         P_ASIZE_16  :  size  <= {            len, {4{1'b0}} };
         default     :  size  <= {13{1'b0}};
      endcase // case ( AXSIZE )

endmodule
// end of file