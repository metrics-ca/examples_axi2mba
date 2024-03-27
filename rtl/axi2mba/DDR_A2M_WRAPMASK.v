//----------------------------------------------------------------------
/**
 * @file DDR_A2M_WRAPMASK.v
 * @brief Defines AXI to MBA bridge: Wrap address mask module.
 */
//----------------------------------------------------------------------

module DDR_A2M_WRAPMASK
   (
      AXLEN       ,   // i
      AXSIZE      ,   // i
      MASK        //, // o
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
   output   [  7:0]        MASK        ;

   //===================================================================
   // signals
   //===================================================================

   reg      [  2:0]        len         ; // combinational
   reg      [  7:0]        addr_en     ; // combinational
   reg      [  7:0]        addr_en1    ; // combinational
   reg      [  7:0]        addr_en2    ; // combinational
   reg      [  7:0]        addr_en4    ; // combinational
   reg      [  7:0]        addr_en8    ; // combinational
   reg      [  7:0]        addr_en16   ; // combinational

   //===================================================================
   // logic
   //===================================================================

   assign   MASK  =  addr_en;

   always @*
      if ( |AXLEN[7:4] )
         len   <= 3'h7;
      else
         case ( AXLEN[3:0] )
            4'h1:    len <= 3'h0;
            4'h3:    len <= 3'h1;
            4'h7:    len <= 3'h2;
            4'hf:    len <= 3'h3;
            default: len <= 3'h4;
         endcase // case ( AXLEN[3:0] )

   always @*
      if ( len[2] )
         addr_en  <= {8{1'b0}};
      else
         case ( AXSIZE )
            P_ASIZE_1   :  addr_en  <= addr_en1 ;
            P_ASIZE_2   :  addr_en  <= addr_en2 ;
            P_ASIZE_4   :  addr_en  <= addr_en4 ;
            P_ASIZE_8   :  addr_en  <= addr_en8 ;
            P_ASIZE_16  :  addr_en  <= addr_en16;
            default     :  addr_en  <= {8{1'b0}};
         endcase // case ( AXSIZE )

   // for P_ASIZE_1
   always @*
      case ( len[1:0] )
         2'h0: addr_en1 <= { {7{1'b1}}, {1{1'b0}} };
         2'h1: addr_en1 <= { {6{1'b1}}, {2{1'b0}} };
         2'h2: addr_en1 <= { {5{1'b1}}, {3{1'b0}} };
         2'h3: addr_en1 <= { {4{1'b1}}, {4{1'b0}} };
      endcase // case ( len[1:0] )

   // for P_ASIZE_2
   always @*
      case ( len[1:0] )
         2'h0: addr_en2 <= { {6{1'b1}}, {2{1'b0}} };
         2'h1: addr_en2 <= { {5{1'b1}}, {3{1'b0}} };
         2'h2: addr_en2 <= { {4{1'b1}}, {4{1'b0}} };
         2'h3: addr_en2 <= { {3{1'b1}}, {5{1'b0}} };
      endcase // case ( len[1:0] )

   // for P_ASIZE_4
   always @*
      case ( len[1:0] )
         2'h0: addr_en4 <= { {5{1'b1}}, {3{1'b0}} };
         2'h1: addr_en4 <= { {4{1'b1}}, {4{1'b0}} };
         2'h2: addr_en4 <= { {3{1'b1}}, {5{1'b0}} };
         2'h3: addr_en4 <= { {2{1'b1}}, {6{1'b0}} };
      endcase // case ( len[1:0] )

   // for P_ASIZE_8
   always @*
      case ( len[1:0] )
         2'h0: addr_en8 <= { {4{1'b1}}, {4{1'b0}} };
         2'h1: addr_en8 <= { {3{1'b1}}, {5{1'b0}} };
         2'h2: addr_en8 <= { {2{1'b1}}, {6{1'b0}} };
         2'h3: addr_en8 <= { {1{1'b1}}, {7{1'b0}} };
      endcase // case ( len[1:0] )

   // for P_ASIZE_16
   always @*
      case ( len[1:0] )
         2'h0: addr_en16 <= { {3{1'b1}}, {5{1'b0}} };
         2'h1: addr_en16 <= { {2{1'b1}}, {6{1'b0}} };
         2'h2: addr_en16 <= { {1{1'b1}}, {7{1'b0}} };
         2'h3: addr_en16 <=              {8{1'b0}};
      endcase // case ( len[1:0] )

endmodule
// end of file
