//----------------------------------------------------------------------
/**
 * @file dut_pin_cfg.sv
 * @brief Defines DUT Specific Pin configuration class.
 */
/*
 * Copyright (C) 2007-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _DUT_PIN_CFG_SV_
`define _DUT_PIN_CFG_SV_
//`protect

`include "dut_pin_intf.svi"

//======================================================================
/**
 * DUT Specific Pin configuration class.
 */
//======================================================================

class dut_pin_cfg_class extends vf_pin_cfg_class;

   //===================================================================
   // public properties
   //===================================================================

   virtual  dut_pin_intf.mstr    dut_mstr;
   virtual  dut_pin_intf.mon     dut_mon ;

   //---------------------------------------------------
   // randomized properties
   //---------------------------------------------------

   //===================================================================
   // private properties
   //===================================================================

   protected rand dut_pin_data_class  fd ; // factory data.

   //===================================================================
   // constraints
   //===================================================================

   //===================================================================
   // new
   //===================================================================

   function new( string inst = "dut_pin_cfg",
                 vf_pin_data_class         factory,
                 virtual dut_pin_intf.mstr dut_mstr,
                 virtual dut_pin_intf.mon  dut_mon = null );
      super.new( "dut_pin_cfg_class", inst, factory );
      if ( dut_mstr == null )
         `vf_fatal( this.log, "Attempting to use a NULL interface" );
      if ( ! $cast( this.fd, factory ) )
         `vf_fatal( this.log,
                    "Cannot use factory of a NON dut_pin_data_class instance" );
      this.dut_mstr = dut_mstr;
      this.dut_mon  = dut_mon;
   endfunction: new

   //===================================================================
   // psdisplay
   //===================================================================

   virtual function string psdisplay( string prefix = "" );
      string str, sep;
      sep = { "\n", prefix };
      str = { super.psdisplay( prefix ),
              "" };
      return str;
   endfunction: psdisplay

   //===================================================================
   // mon_clking
   //===================================================================

   virtual task mon_clking();
      fork
         forever begin
            @( this.dut_mstr.mstr_clking );
            ->this.clking;
         end
      join_none
   endtask: mon_clking

   //===================================================================
   // drv_intf
   //===================================================================

   virtual task drv_intf( vf_pin_data_class d = null );
      if ( d == null ) begin // reset value
      end
      else begin
         dut_pin_data_class dd;
         if ( ! $cast( dd, d ) ) begin
            string msg;
            msg = "Cannot use a NON dut_pin_data_class instance";
            `vf_fatal( this.log, msg );
            return;
         end
         this.fd.dqtype =  dd.dqtype;
         this.fd.slp    =  dd.slp;
      end
      this.dut_mstr.mstr_clking.dqtype  <= this.fd.dqtype;
      this.dut_mstr.mstr_clking.slp     <= this.fd.slp;
   endtask: drv_intf

   //===================================================================
   // mon_intf
   //===================================================================

   virtual function vf_pin_data_class mon_intf();
      if ( this.dut_mon != null ) begin
         this.fd.dqtype    =  this.dut_mon.mon_clking.dqtype;
         this.fd.slp       =  this.dut_mon.mon_clking.slp;
      end
      return this.fd;
   endfunction: mon_intf

   //===================================================================
   // is_chg_intf
   //===================================================================

   virtual function bit is_chg_intf( vf_pin_data_class prev = null );
      `vf_pin_is_chg_intf_head( dut_pin_data_class )

      // write only check signals
      if ( this.dut_mon != null ) begin
         `vf_pin_is_chg_intf( dqtype, this.dut_mon.mon_clking )
         `vf_pin_is_chg_intf( slp   , this.dut_mon.mon_clking )
      end

      `vf_pin_is_chg_intf_tail
   endfunction: is_chg_intf

endclass: dut_pin_cfg_class
//`endprotect
`endif // `ifndef _DUT_PIN_CFG_SV_
