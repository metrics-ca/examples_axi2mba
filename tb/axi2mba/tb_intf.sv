//----------------------------------------------------------------------
/**
 * @file tb_intf.sv
 * @brief Defines DUT specific Interface class.
 */
/*
 * Copyright (C) 2009-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _TB_INTF_SV_
`define _TB_INTF_SV_
//`protect

`ifndef TB_TOP
`define TB_TOP tb_top
`define _DEFINE_TB_TOP_
`endif // `ifndef TB_TOP

//======================================================================
/**
 * DUT specific Interface class.
 */
//======================================================================

class tb_intf_class extends vpr_void_class;

   //===================================================================
   // public properties
   //===================================================================

   event                            clking      ;
   virtual  vf_axi_intf.mstr        axi_mstrs[ tb_type::stream_id_e ];
   virtual  vf_axi_intf.mon         axi_mons [ tb_type::stream_id_e ];
   virtual  vf_mba_intf.mon         mba_mons [ tb_type::stream_id_e ];
   virtual  dut_pin_intf.mstr       dut_mstr    = null;
   virtual  dut_pin_intf.mon        dut_mon     = null;

   //===================================================================
   // private properties
   //===================================================================

   local bit                        en_clking   = 0;

   //===================================================================
   // new
   //===================================================================

   function new( bit auto_bind = 1,
                 bit auto_mon  = 1 );
      if ( auto_bind )
         this.bind_intfs();
      if ( auto_mon )
         fork
            this.mon_clking();
         join_none
      `TB_TOP.tb_util.set_rst_min_max( 100, 200 );
   endfunction: new

   //===================================================================
   // do_reset
   //===================================================================

   virtual task do_reset( int n = -1, longint unsigned dly = 0 );
      `TB_TOP.tb_util.do_reset( n, dly );
   endtask: do_reset

   //===================================================================
   // mon_clking
   //===================================================================

   virtual task mon_clking();
      if ( this.en_clking ) return;
      this.en_clking = 1;
      fork
         forever begin
            @( `TB_TOP.tb_util.cb );
            ->this.clking;
         end
      join_none
   endtask: mon_clking

   //===================================================================
   // bind_intfs
   //===================================================================

   virtual function void bind_intfs();

      // Initialize arrays
      this.axi_mstrs.delete() ;
      this.axi_mons.delete()  ;
      this.mba_mons.delete()  ;

      // Master or Slave
      this.axi_mstrs[ tb_type::AXI_ID  ]  =  `TB_TOP.axi_intf.mstr   ;
      this.dut_mstr                       =  `TB_TOP.dut_intf.mstr   ;

      // Monitor
      this.axi_mons [ tb_type::AXI_ID  ]  =  `TB_TOP.axi_intf.mon    ;
      this.mba_mons [ tb_type::MBA_ID  ]  =  `TB_TOP.mba_intf.mon    ;
      this.dut_mon                        =  `TB_TOP.dut_intf.mon    ;

   endfunction: bind_intfs

endclass: tb_intf_class

`ifdef _DEFINE_TB_TOP_
`undef TB_TOP
`undef _DEFINE_TB_TOP_
`endif // `ifndef _DEFINE_TB_TOP_

//`endprotect
`endif // `ifndef _TB_INTF_SV_
