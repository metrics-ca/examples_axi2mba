//----------------------------------------------------------------------
/**
 * @file test1.sv
 * @brief Baseline test scenario.
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

   initial begin

      env   =  new();
      env.cfg.default_num_gens = 100;

      env.gen_cfg();

      env.build();

      env.run();

   end // initial begin

endprogram: test
