//----------------------------------------------------------------------
/**
 * @file test2.sv
 * @brief Baseline test scenario for error response.
 */
/*
 * Copyright (C) 2009-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------

`include "files_tb.svi"

//======================================================================
// Main program
//======================================================================

program test;

   tb_env_class   env;

   function automatic int get_arg(reg [127:0] what, int def);
       int      temp;
       int      rc = $value$plusargs(what, temp);

       if (rc > 0) return temp;
       else return def;
   endfunction

   initial begin

      env   =  new();
      env.cfg.default_num_gens = get_arg("num_gens=%d", 100);
      env.cfg.sim_time         = get_arg("sim_time=%d", 10) * 1ms;
      env.cfg.tick_time        = get_arg("tick_time=%d", 10) * 1ms;
      env.cfg.watchdog_time    = 1000s;    // must be bigger
      env.gen_cfg();
      env.build();

      $display( "================================================");
      $display( "sim_time cfg=%0t", env.cfg.sim_time );
      $display( "================================================");

      begin
         tb_axi_xact_class xact;
         $cast( xact, env.axi_xacts[ tb_type::AXI_ID ] );
         xact.awburst_wts.wt_of_fixed = 1;
         xact.awburst_wts.wt_of_incr  = 2;
         xact.awburst_wts.wt_of_wrap  = 2;
         xact.arburst_wts.wt_of_fixed = 1;
         xact.arburst_wts.wt_of_incr  = 2;
         xact.arburst_wts.wt_of_wrap  = 2;
         xact.data_bus_width  =  256;
         xact.arsize_wts.wt_of_32 = 8;
         xact.awsize_wts.wt_of_32 = 8;
      end

      env.run();

   end // initial begin

endprogram: test
