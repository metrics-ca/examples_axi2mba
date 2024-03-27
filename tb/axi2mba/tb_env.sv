//----------------------------------------------------------------------
/**
 * @file tb_env.sv
 * @brief Defines DUT specific Testbench Environment class.
 */
/*
 * Copyright (C) 2009-2011 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _TB_ENV_SV_
`define _TB_ENV_SV_
//`protect

//======================================================================
/**
 * DUT specific Testbench Environment class.
 */
//======================================================================

class tb_env_class extends vf_tb_env_class;

   //===================================================================
   // public properties
   //===================================================================

   // Environment Base Clock
   event                            clking            ;

   // Environment Configuration
   tb_cfg_class                     cfg               =  null;

   // Interface
   tb_intf_class                    intf              =  null;

   // Memory Manager
   vsl_mm_class                     mm                =  null;

   // Scoreboard
   vsl_sb_class                     sb                =  null;
   //tb_sb_func_class                 sb_func           =  null;

   // Functional Coverage
   tb_fc_class                      fc                =  null;

   // Standard function for vsl
   tb_sfunc_class                   sfunc             =  null;

   // AXI environment
   vf_axi_env_class                 axi_envs [ tb_type::stream_id_e ];
   tb_axi_xact_class                axi_xacts[ tb_type::stream_id_e ];
   vf_axi_mon_fc_cb_class           axi_mon_fc_cbs[ tb_type::stream_id_e ];
   tb_axi_mon_sb_cb_class           axi_mon_sb_cb     =  null;

   // MBA environment
   vf_mba_env_class                 mba_envs [ tb_type::stream_id_e ];
   tb_mba_mon_sb_cb_class           mba_mon_sb_cb     =  null;

   vf_pin_mstr_class                pin_mstr =  null;
   dut_pin_data_class               pin_data =  null;

   //===================================================================
   // private properties
   //===================================================================

   //===================================================================
   // new
   //===================================================================

   function new( string    name  = "tb_env_class",
                 string    inst  = "tb_env" );
      super.new( name, inst );
      this.intf   =  new();
      this.cfg    =  new( , { inst, ".cfg" } );
      this.axi_envs.delete();
      this.axi_xacts.delete();
      this.axi_mon_fc_cbs.delete();
      this.mba_envs.delete();

      this.create_envs();

      // Replace standard function
      this.sfunc = new();
      $cast( vsl_blk_class::sfunc, this.sfunc );
      $cast( vsl_data_class::sfunc, this.sfunc );

      // set by plusargs options
      this.set_by_plusargs();
   endfunction: new

   //===================================================================
   // gen_cfg
   //===================================================================

   virtual function void gen_cfg();
      super.gen_cfg();

      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( this.axi_envs.exists( i ) )
            this.axi_envs[i].gen_cfg();
         if ( this.mba_envs.exists( i ) )
            this.mba_envs[i].gen_cfg();
      end

      if ( this.en_rand_cfg ) begin
         if( ! this.cfg.randomize() ) begin
            string msg;
            msg = "gen_cfg(): cfg.randomize() failed";
            `vf_fatal( this.log, msg );
            return;
         end
      end

      this.build_factories();
   endfunction: gen_cfg

   //===================================================================
   // build
   //===================================================================

   virtual function void build();
      super.build();
      //this.build_factories();
      this.build_blks();
      this.build_cbs();
   endfunction: build

   //===================================================================
   // reset_dut
   //===================================================================

   virtual task reset_dut();
      super.reset_dut();
      this.watchdog_time = this.cfg.watchdog_time  ;
      this.clking        = this.intf.clking        ;
      this.ticktack( this.cfg.tick_time );
      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( this.axi_envs.exists( i ) )
            this.axi_envs[i].reset_dut();
         if ( this.mba_envs.exists( i ) )
            this.mba_envs[i].reset_dut();
      end
      if ( this.pin_mstr != null ) begin
         this.pin_mstr.drv( this.cfg.pin_cfg.factory );
      end
      this.intf.do_reset( this.cfg.rst_cycles );
   endtask: reset_dut

   //===================================================================
   // pre_start
   //===================================================================

   virtual task pre_start();
      super.pre_start();
      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( this.axi_envs.exists( i ) )
            this.axi_envs[i].pre_start();
         if ( this.mba_envs.exists( i ) )
            this.mba_envs[i].pre_start();
      end
   endtask: pre_start

   //===================================================================
   // start
   //===================================================================

   virtual task start();
      super.start();
      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( this.axi_envs.exists( i ) )
            this.axi_envs[i].start();
         if ( this.mba_envs.exists( i ) )
            this.mba_envs[i].start();
      end
   endtask: start

   //===================================================================
   // post_start
   //===================================================================

   virtual task post_start();
      super.post_start();
      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( this.axi_envs.exists( i ) )
            this.axi_envs[i].post_start();
         if ( this.mba_envs.exists( i ) )
            this.mba_envs[i].post_start();
      end
   endtask: post_start

   //===================================================================
   // wait_for_end
   //===================================================================

   virtual task wait_for_end();
      super.wait_for_end();
      //this.main( this.cfg.watchdog_time ); // call at shenv_class
   endtask: wait_for_end

   //===================================================================
   // wait_for_done
   //===================================================================

   virtual task wait_for_done();
      #( this.cfg.sim_time );
      $display( "Reached sim_time=%0t", this.cfg.sim_time );
   endtask: wait_for_done

   //===================================================================
   // drain_dut
   //===================================================================

   virtual task drain_dut();
      super.drain_dut();
      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( this.axi_envs.exists( i ) )
            this.axi_envs[i].drain_dut();
         if ( this.mba_envs.exists( i ) )
            this.mba_envs[i].drain_dut();
      end
      if ( this.cfg.drain_cycles > 0 )
         repeat ( this.cfg.drain_cycles ) @( this.clking );
      if ( this.cfg.drain_time > 0 )
         #( this.cfg.drain_time );
   endtask: drain_dut

   //===================================================================
   // stop
   //===================================================================

   virtual task stop();
      super.stop();
      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( this.axi_envs.exists( i ) )
            this.axi_envs[i].stop();
         if ( this.mba_envs.exists( i ) )
            this.mba_envs[i].stop();
      end
   endtask: stop

   //===================================================================
   // cleanup
   //===================================================================

   virtual task cleanup();
      super.cleanup();
      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( this.axi_envs.exists( i ) )
            this.axi_envs[i].cleanup();
         if ( this.mba_envs.exists( i ) )
            this.mba_envs[i].cleanup();
      end
   endtask: cleanup

   //===================================================================
   // restart
   //===================================================================

   virtual task restart( bit reconfig = 0 );
      super.restart( reconfig );
      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( this.axi_envs.exists( i ) )
            this.axi_envs[i].restart( reconfig );
         if ( this.mba_envs.exists( i ) )
            this.mba_envs[i].restart( reconfig );
      end
   endtask: restart

   //===================================================================
   // report
   //===================================================================

   virtual function void report();
      super.report();

      this.close();

      begin
         string s;
         s = "========================";
         $display( { s, " Simulation REPORT ", s } );
      end

      `vf_report( this.log, { "Configuration:\n",
                              this.cfg.psdisplay( "  " ) } );

      for ( int i = 0; i < int'( tb_type::RESERVED_ID ); i++ ) begin
         if ( this.axi_envs.exists( i ) ) begin
            if ( this.axi_envs[i].is_activity() )
               this.axi_envs[i].report();
            else
               `vf_trace( this.axi_envs[i].log, "no activity" );
         end
         if ( this.mba_envs.exists( i ) ) begin
            if ( this.mba_envs[i].is_activity() )
               this.mba_envs[i].report();
            else
               `vf_trace( this.mba_envs[i].log, "no activity" );
         end
      end
      if ( this.mm != null ) begin
         this.mm.report( , vsl_type::REPORT_ENTRIES );
      end

      if ( this.sb != null ) begin
         this.sb.report();
         if ( this.sb.get_num_entries() > 0 ) begin
            string str;
            $sformat( str, "There are %0d leftover entries in the scoreboard",
                           this.sb.get_num_entries() );
            `vf_warning( this.log, str );
         end
      end
   endfunction: report

   //===================================================================
   // timeout
   //===================================================================

   virtual function void timeout();
      super.timeout();
      //this.report();
   endfunction: timeout

   //===================================================================
   // close
   //===================================================================

   virtual function void close();
      if ( this.sb != null ) this.sb.close();
   endfunction: close

   //===================================================================
   // abort
   //===================================================================

   virtual function void abort();
      string s;
      super.abort();
      s = "========================";
      $display( { s, " ABORT REPORT BEGIN ", s } );
      this.report();
      $display( { s, " ABORT REPORT END ", s } );
   endfunction: abort

   //===================================================================
   // Additional Methods
   //===================================================================

   //===================================================================
   // Extern methods
   //===================================================================

   extern virtual function void create_envs();
   extern virtual function void set_by_plusargs();
   extern virtual function void build_factories();
   extern virtual function void build_blks();
   extern virtual function void build_cbs();

endclass: tb_env_class

// Define Extern Methods
`include "tb_env_func.svi"

//`endprotect
`endif // `ifndef _TB_ENV_SV_
