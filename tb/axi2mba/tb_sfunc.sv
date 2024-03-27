//----------------------------------------------------------------------
/**
 * @file tb_sfunc.sv
 * @brief Defines Testbench specific standard function class.
 */
/*
 * Copyright (C) 2009-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _TB_SFUNC_SV_
`define _TB_SFUNC_SV_
//`protect

//======================================================================
/**
 * Testbench specific Standard functions class.
 */
//======================================================================

class tb_sfunc_class extends vsl_sfunc_class;

   //===================================================================
   // psdisplay_initiator
   //===================================================================

   virtual function string psdisplay_initiator( int id,
                                                vpr_type::radix_e radix,
                                                bit short,
                                                int myid );
      string str;
      bit    en = 0;
      if ( radix == vpr_type::STR_TYP ) begin
         tb_type::initiator_id_e name;
         if ( $cast( name, id ) ) begin
            en = 1;
            str = { short ? "" : "initiator_id=", name.name() };
            str = str.substr( 0, str.len() - 3 );
         end
      end
      if ( ! en )
         str = super.psdisplay_initiator( id, radix, short, myid );
      return str;
   endfunction: psdisplay_initiator

   //===================================================================
   // psdisplay_target
   //===================================================================

   virtual function string psdisplay_target( int id,
                                             vpr_type::radix_e radix,
                                             bit short,
                                             int myid );
      string str;
      bit    en = 0;
      if ( radix == vpr_type::STR_TYP ) begin
         tb_type::target_id_e name;
         if ( $cast( name, id ) ) begin
            en = 1;
            str = { short ? "" : "target_id=", name.name() };
            str = str.substr( 0, str.len() - 3 );
         end
      end
      if ( ! en )
         str = super.psdisplay_target( id, radix, short, myid );
      return str;
   endfunction: psdisplay_target

endclass: tb_sfunc_class
//`endprotect
`endif // `ifndef _TB_SFUNC_SV_
