//----------------------------------------------------------------------
/**
 * @file tb_fc.sv
 * @brief Defines Testbench specific functional coverage class.
 */
/*
 * Copyright (C) 2009-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _TB_FC_SV_
`define _TB_FC_SV_
//`protect

//======================================================================
/**
 * Testbench specific functional coverage class.
 */
//======================================================================

class tb_fc_class extends vf_void_class;

   //===================================================================
   // public properties
   //===================================================================

   vf_log_class               log      ;
   vf_axi_fc_class            axi_fc1s[ tb_type::stream_id_e ];
   vf_axi_opt_fc_class        axi_fc2s[ tb_type::stream_id_e ];

   //===================================================================
   // private properties
   //===================================================================

   //===================================================================
   // new
   //===================================================================

   function new( string name = "tb_fc_class",
                 string inst = "tb_fc" );
      this.axi_fc1s.delete();
      this.axi_fc2s.delete();
   endfunction: new

   //===================================================================
   // create_fc
   //===================================================================

   virtual function void create_fc( tb_cfg_class cfg );
      tb_type::stream_id_e ide;
      string               inst;
      if ( ! cfg.en_fc ) return;

      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         $cast( ide, i );
         inst = ide.name();
         inst = inst.substr( 0, inst.len() - 4 );
         if ( cfg.axi_cfgs.exists( i ) ) begin
            this.axi_fc1s[i] = new( { inst, "_fc" } );
            this.axi_fc2s[i] = new( { inst, "_opt_fc" } );
         end
      end

   endfunction: create_fc

endclass: tb_fc_class
//`endprotect
`endif // `ifndef _TB_FC_SV_
