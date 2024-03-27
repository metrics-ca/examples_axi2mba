//----------------------------------------------------------------------
/**
 * @file tb_cfg.sv
 * @brief Defines DUT specific testbench configuration class.
 */
/*
 * Copyright (C) 2009-2011 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _TB_CFG_SV_
`define _TB_CFG_SV_
//`protect

//======================================================================
/**
 * DUT specific testbench configuration class.
 */
//======================================================================

class tb_cfg_class extends vpr_cfg_class;

   //===================================================================
   // public properties
   //===================================================================

   //---------------------------------------------------
   // non-randomized properties
   //---------------------------------------------------

   bit                              en_fc             =  1;
   bit                              en_sb             =  1;
   bit                              en_start_gen      =  1;
   int                              drain_cycles      =  0;
   time                             drain_time        =  10us  ;
   time                             tick_time         =  1ms   ;
   time                             watchdog_time     =  100ms ;
   time                             sim_time          =  2000us;

   int                              default_num_gens  =  10;
   int                              num_gens[ tb_type::stream_id_e ];

   //---------------------------------------------------
   // randomized properties
   //---------------------------------------------------

   rand  int                        rst_cycles        = -1;
   rand  vf_axi_cfg_class           axi_cfgs[ tb_type::stream_id_e ];
   rand  vf_mba_cfg_class           mba_cfgs[ tb_type::stream_id_e ];
   rand  dut_pin_cfg_class          pin_cfg           = null;

   //===================================================================
   // private properties
   //===================================================================

   protected vpr_cfg_class          cfgs[$]           ;

   //===================================================================
   // constraints
   //===================================================================

   constraint rst_cycles_con { rst_cycles == -1; }

   //===================================================================
   // new
   //===================================================================

   function new( string name = "tb_cfg_class",
                 string inst = "tb_cfg" );
      super.new( name, inst );
      this.init();
   endfunction: new

   //===================================================================
   // pre_randomize
   //===================================================================

   function void pre_randomize();
      super.pre_randomize();
      this.pre_axi_cfgs();
      this.pre_mba_cfgs();
   endfunction: pre_randomize

   //===================================================================
   // post_randomize
   //===================================================================

   function void post_randomize();
      super.post_randomize();
      this.post_axi_cfgs();
      this.post_mba_cfgs();
      this.set_num_gens( this.default_num_gens );
   endfunction: post_randomize

   //===================================================================
   // psdisplay
   //===================================================================

   virtual function string psdisplay( string prefix = "" );
      string str, sep;
      sep = { "\n", prefix };
      str = { super.psdisplay( prefix ),
              sep, $psprintf( "en_fc=%0d", this.en_fc ),
              sep, $psprintf( "en_sb=%0d", this.en_sb ),
              sep, $psprintf( "en_start_gen=%0d", this.en_start_gen ),
              sep, $psprintf( "rst_cycles=%0d", this.rst_cycles ),
              sep, $psprintf( "drain_cycles=%0d", this.drain_cycles ),
              sep, $psprintf( "drain_time=%0t", this.drain_time ),
              sep, $psprintf( "tick_time=%0t", this.tick_time ),
              sep, $psprintf( "watchdog_time=%0t", this.watchdog_time ),
              "" };
      foreach ( this.cfgs[i] )
         if ( this.cfgs[i] != null  ) begin
            str = { str, "\n",
                    this.cfgs[i].psdisplay(
                        { prefix, this.cfgs[i].inst, ": " } ),
                    "" };
         end
      return str;
   endfunction: psdisplay

   //===================================================================
   // init
   //===================================================================

   virtual function void init();
      `CLEAR_QUEUE( this.cfgs );
      this.alloc_cfgs();
      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( this.axi_cfgs.exists( i ) )
            this.cfgs.push_back( this.axi_cfgs[i] );
         if ( this.mba_cfgs.exists( i ) )
            this.cfgs.push_back( this.mba_cfgs[i] );
      end
   endfunction: init

   //===================================================================
   // append_cfg
   //===================================================================

   virtual function void append_cfg( vpr_cfg_class cfg );
      if ( cfg == null ) return;
      this.cfgs.push_back( cfg );
   endfunction: append_cfg

   //===================================================================
   // alloc_cfgs
   //===================================================================

   virtual function void alloc_cfgs();
      this.axi_cfgs.delete();
      this.mba_cfgs.delete();
      this.axi_cfgs[ tb_type::AXI_ID  ]   =  null;
      this.mba_cfgs[ tb_type::MBA_ID  ]   =  null;
      begin
         tb_type::stream_id_e ide;
         string               inst;
         for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
            $cast( ide, i );
            inst = ide.name();
            inst = { inst.substr( 0, inst.len() - 4 ), "_cfg" };
            if ( this.axi_cfgs.exists( i ) ) begin
               this.axi_cfgs[i] = new(  , inst );
            end
            if ( this.mba_cfgs.exists( i ) ) begin
               this.mba_cfgs[i] = new(  , inst );
            end
            this.num_gens[i] = -1;
         end
      end
   endfunction: alloc_cfgs

   //===================================================================
   // set_num_gens
   //===================================================================

   virtual function void set_num_gens( int num = -1 );
      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ )
         if ( this.num_gens.exists( i ) )
            this.num_gens[i] = num;
   endfunction: set_num_gens

   //===================================================================
   // pre_axi_cfgs
   //===================================================================

   virtual function void pre_axi_cfgs();
      tb_type::stream_id_e ide;
      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( ! this.axi_cfgs.exists( i ) ) continue;
         this.axi_cfgs[i].little_endian   =  1;
         this.axi_cfgs[i].addr_bus_width  = 40;
         this.axi_cfgs[i].use_cache       =  0;
         this.axi_cfgs[i].use_prot        =  0;
         this.axi_cfgs[i].use_lock        =  1;
         case ( tb_type::stream_id_e'( i ) )
            tb_type::AXI_ID : begin
               this.axi_cfgs[i].port_type       = vf_axi_type::AXI_MSTR;
               this.axi_cfgs[i].data_bus_width  = 128;
               this.axi_cfgs[i].id_bus_width    = 8;
            end
         endcase // case ( tb_type::stream_id_e'( i ) )
      end
   endfunction: pre_axi_cfgs

   //===================================================================
   // post_axi_cfgs
   //===================================================================

   virtual function void post_axi_cfgs();
   endfunction: post_axi_cfgs

   //===================================================================
   // pre_mba_cfgs
   //===================================================================

   virtual function void pre_mba_cfgs();
   endfunction: pre_mba_cfgs

   //===================================================================
   // post_mba_cfgs
   //===================================================================

   virtual function void post_mba_cfgs();
   endfunction: post_mba_cfgs

   //===================================================================
   // set_mem_map
   //===================================================================

   virtual function bit set_mem_map( vsl_mm_class mm );
      vpr_type::addr_t  base_addr, last_addr;
      if ( mm == null ) begin
         return 0;
      end
      base_addr   =  'h0000_0000;
      last_addr   =  'hFFFF_FFFF;
      for ( int t = 0; t < int'( tb_type::RESERVED_T ); t++ ) begin
         mm.set_range( t, base_addr,
                          last_addr,
                          int'( vsl_type::NORMAL_R ) );
      end
      return 1;
   endfunction: set_mem_map

   //===================================================================
   // set_mem_wts
   //===================================================================

   virtual function bit set_mem_wts( vsl_mm_class mm );
      vpr_type::wt_t rd_wt, wr_wt;
      if ( mm == null ) begin
         return 0;
      end
      for ( int i = 0; i < int'( tb_type::RESERVED_I ); i++ ) begin
         for ( int t = 0; t < int'( tb_type::RESERVED_T ); t++ ) begin
            rd_wt = 1;
            wr_wt = rd_wt;
            mm.set_wts( i, t, rd_wt, wr_wt );
         end
      end
      return mm.update_elects();
   endfunction: set_mem_wts

endclass: tb_cfg_class
//`endprotect
`endif // `ifndef _TB_CFG_SV_
