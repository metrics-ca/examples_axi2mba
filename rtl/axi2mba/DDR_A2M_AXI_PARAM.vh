//----------------------------------------------------------------------
/**
 * @file DDR_A2M_AXI_PARAM.vh
 * @brief Defines AXI paramters.
 */
//----------------------------------------------------------------------
//`ifndef _DDR_A2M_AXI_PARAM_VH_
//`define _DDR_A2M_AXI_PARAM_VH_

   //===================================================================
   // parameters
   //===================================================================

   localparam     P_ASIZE_1      =  3'b000; //   1-byte,    8-bit
   localparam     P_ASIZE_2      =  3'b001; //   2-byte,   16-bit
   localparam     P_ASIZE_4      =  3'b010; //   4-byte,   32-bit
   localparam     P_ASIZE_8      =  3'b011; //   8-byte,   64-bit
   localparam     P_ASIZE_16     =  3'b100; //  16-byte,  128-bit
   localparam     P_ASIZE_32     =  3'b101; //  32-byte,  256-bit
   localparam     P_ASIZE_64     =  3'b110; //  64-byte,  512-bit
   localparam     P_ASIZE_128    =  3'b111; // 128-byte, 1024-bit
   localparam     P_ABURST_FIXED =  2'b00 ;
   localparam     P_ABURST_INCR  =  2'b01 ;
   localparam     P_ABURST_WRAP  =  2'b10 ;
   localparam     P_ABURST_RSVD  =  2'b11 ;
   localparam     P_ARESP_OKAY   =  2'b00 ;
   localparam     P_ARESP_EXOKAY =  2'b01 ;
   localparam     P_ARESP_SLVERR =  2'b10 ;
   localparam     P_ARESP_DECERR =  2'b11 ;

//`endif // `ifndef _DDR_A2M_AXI_PARAM_VH_
// end of file
