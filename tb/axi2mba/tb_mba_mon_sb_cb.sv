//----------------------------------------------------------------------
/**
 * @file tb_mba_mon_sb_cb.sv
 * @brief Defines DUT specific MBA monitor scoreboard callback class.
 */
/*
 * Copyright (C) 2007-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _TB_MBA_MON_SB_CB_SV_
`define _TB_MBA_MON_SB_CB_SV_
//`protect

//======================================================================
/**
 * DUT specific MBA monitor scoreboard callback class.
 */
//======================================================================

class tb_mba_mon_sb_cb_class extends vf_mba_mon_sb_cb_class;

   //===================================================================
   // public properties
   //===================================================================

   //===================================================================
   // private properties
   //===================================================================

   //===================================================================
   // new
   //===================================================================

   function new( string name = "tb_mba_mon_sb_cb_class",
                 string inst = "mba_mon_sb_cb",
                 vsl_mm_class          mm,
                 vsl_sb_class          sb,
                 vf_mba_sb_func_class  sb_func );
      super.new( name, inst, mm, sb, sb_func );
   endfunction: new

   //===================================================================
   // ins_sb
   //===================================================================

 //virtual function void ins_sb( vf_mba_xact_class xfer,
 //                              bit dir ); // 0: master, 1: slave
 //   if ( xfer != null ) begin
 //      $display( "%s @%0t", xfer.psdisplay_line( "mba: " ), $time );
 //      if ( xfer.addr == 'h2f08fb28 )
 //         xfer.display( "mba: " );
 //   end
 //   super.ins_sb( xfer, dir );
 //endfunction: ins_sb

   //===================================================================
   // lookup_id
   //===================================================================

   virtual function int lookup_id( int stream_id,
                                   bit dir, // 0: master, 1: slave
                                   vf_mba_xact_class xfer = null );
      if ( dir ) begin
         tb_type::stream_id_e    sid;
         tb_type::target_id_e    tid;
         if ( ! $cast( sid, stream_id ) )
            return int'( tb_type::UNKNOWN_T );
         case ( sid )
            tb_type::MBA_ID   : tid = tb_type::MBA_T     ;
            default           : tid = tb_type::RESERVED_T;
         endcase // case ( sid )
         return int'( tid );
      end
      return super.lookup_id( stream_id, dir, xfer );
   endfunction: lookup_id

endclass: tb_mba_mon_sb_cb_class
//`endprotect
`endif // `ifndef _TB_MBA_MON_SB_CB_SV_
