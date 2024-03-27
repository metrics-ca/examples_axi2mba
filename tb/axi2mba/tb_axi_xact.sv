//----------------------------------------------------------------------
/**
 * @file tb_axi_xact.sv
 * @brief Defines DUT specific AXI transaction class.
 */
/*
 * Copyright (C) 2007-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _TB_AXI_XACT_SV_
`define _TB_AXI_XACT_SV_
//`protect

//======================================================================
/**
 * DUT specific AXI transaction class.
 */
//======================================================================

class tb_axi_xact_class extends vf_axi_xact_class;

   //===================================================================
   // public properties
   //===================================================================

   //---------------------------------------------------
   // non-randomized properties
   //---------------------------------------------------

   typedef struct { vpr_type::wt_t  wt_of_1  ;
                    vpr_type::wt_t  wt_of_2  ;
                    vpr_type::wt_t  wt_of_4  ;
                    vpr_type::wt_t  wt_of_8  ;
                    vpr_type::wt_t  wt_of_16 ;
                    vpr_type::wt_t  wt_of_32 ;
                  } tb_asize_wt_st;

   static vf_log_class     log = new( "tb_axi_xact_class", "tb_axi_xact" );

   tb_asize_wt_st awsize_wts  = '{  wt_of_1  :  1,
                                    wt_of_2  :  1,
                                    wt_of_4  :  4,
                                    wt_of_8  :  4,
                                    wt_of_16 :  4,
                                    wt_of_32 :  0 };

   tb_asize_wt_st arsize_wts  = '{  wt_of_1  :  1,
                                    wt_of_2  :  1,
                                    wt_of_4  :  4,
                                    wt_of_8  :  4,
                                    wt_of_16 :  4,
                                    wt_of_32 :  0 };

   //---------------------------------------------------
   // randomized properties
   //---------------------------------------------------

   //===================================================================
   // private properties
   //===================================================================

   //===================================================================
   // constraints
   //===================================================================

   /// Constraint of weight of xfer_bytes.
   constraint tb_asize_wts_con {
      if ( xact_type == vpr_type::INITIATOR ) {
         if ( kind == vpr_type::WRITE )
            xfer_bytes dist {
               1  := awsize_wts.wt_of_1 ,
               2  := awsize_wts.wt_of_2 ,
               4  := awsize_wts.wt_of_4 ,
               8  := awsize_wts.wt_of_8 ,
               16 := awsize_wts.wt_of_16,
               32 := awsize_wts.wt_of_32
            };
         else if ( kind == vpr_type::READ )
            xfer_bytes dist {
               1  := arsize_wts.wt_of_1 ,
               2  := arsize_wts.wt_of_2 ,
               4  := arsize_wts.wt_of_4 ,
               8  := arsize_wts.wt_of_8 ,
               16 := arsize_wts.wt_of_16,
               32 := arsize_wts.wt_of_32
            };
      }
   }

   //===================================================================
   // new
   //===================================================================

   function new( vf_log_class log = null );
      super.new( log == null ? this.log : log );
   endfunction: new

   //===================================================================
   // pre_randomize
   //===================================================================

/*
   function void pre_randomize();
      super.pre_randomize();
   endfunction: pre_randomize
*/

   //===================================================================
   // post_randomize
   //===================================================================

/*
   function void post_randomize();
      super.post_randomize();
      if ( this.kind == vpr_type::READ )
         foreach ( this.byte_en[i] ) this.byte_en[i] = 1;
   endfunction: post_randomize
*/

   //===================================================================
   // allocate
   //===================================================================

   virtual function vf_data_class allocate();
      tb_axi_xact_class o;
      o = new();
      $cast( allocate, o );
   endfunction: allocate

   //===================================================================
   // copy
   //===================================================================

   virtual function vf_data_class copy( vf_data_class to   = null,
                                        int           kind = -1 );
      tb_axi_xact_class cpy;
      if ( to == null ) cpy = new();
      else if ( ! $cast( cpy, to ) ) begin
         `vf_fatal( this.log,
                    "Cannot copy to a NON tb_axi_xact_class instance" );
         return null;
      end
      void'( super.copy( cpy ) );
      cpy.awsize_wts    =  this.awsize_wts   ;
      cpy.arsize_wts    =  this.arsize_wts   ;
      return cpy;
   endfunction: copy

   //===================================================================
   // compare
   //===================================================================

   virtual function bit compare( vf_data_class to,
                                 output string diff,
                                 input  int    kind = -1 );
      bit cval;
      tb_axi_xact_class cmp;
      if ( ! ( kind < 0 && kind > int'( vpr_type::COMPARE_ANY ) ) ) begin
         cval = this.compare_kind( to, diff, kind );
         return cval;
      end
      if ( to == null ) begin
         $sformat( diff, "Cannot compare to a NULL instance" );
         `vf_fatal( this.log, diff );
         return 0;
      end
      if ( ! $cast( cmp, to ) ) begin
         $sformat( diff,
                   "Cannot compare to a NON tb_axi_xact_class instance" );
         `vf_fatal( this.log, diff );
         return 0;
      end
      diff  =  "";
      cval  =  super.compare( cmp, diff, kind );
      cval  =  cval &&
               cmp.awsize_wts.wt_of_1  == this.awsize_wts.wt_of_1  &&
               cmp.awsize_wts.wt_of_2  == this.awsize_wts.wt_of_2  &&
               cmp.awsize_wts.wt_of_4  == this.awsize_wts.wt_of_4  &&
               cmp.awsize_wts.wt_of_8  == this.awsize_wts.wt_of_8  &&
               cmp.awsize_wts.wt_of_16 == this.awsize_wts.wt_of_16 &&
               cmp.awsize_wts.wt_of_32 == this.awsize_wts.wt_of_32 ;
      cval  =  cval &&
               cmp.arsize_wts.wt_of_1  == this.arsize_wts.wt_of_1  &&
               cmp.arsize_wts.wt_of_2  == this.arsize_wts.wt_of_2  &&
               cmp.arsize_wts.wt_of_4  == this.arsize_wts.wt_of_4  &&
               cmp.arsize_wts.wt_of_8  == this.arsize_wts.wt_of_8  &&
               cmp.arsize_wts.wt_of_16 == this.arsize_wts.wt_of_16 &&
               cmp.arsize_wts.wt_of_32 == this.arsize_wts.wt_of_32 ;
      if ( ! cval )
         $sformat( diff, "Compare failed\n%s\n%s",
                         this.psdisplay( "this: " ),
                           to.psdisplay( "  to: " ) );
      return cval;
   endfunction: compare

endclass: tb_axi_xact_class
//`endprotect
`endif // `ifndef _TB_AXI_XACT_SV_
