//----------------------------------------------------------------------
/**
 * @file dut_pin_data.sv
 * @brief Defines DUT Specific Pin data class.
 */
/*
 * Copyright (C) 2007-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _DUT_PIN_DATA_SV_
`define _DUT_PIN_DATA_SV_
//`protect

//======================================================================
/**
 * DUT Specific Pin data class.
 */
//======================================================================

class dut_pin_data_class extends vf_pin_data_class;

   //===================================================================
   // public properties
   //===================================================================

   /// DQTYPE
   typedef enum bit
                  {  DQTYPEx16   =  0,
                     DQTYPEx32   =  1
                  }  dqtype_e;

   //---------------------------------------------------
   // non-randomized properties
   //---------------------------------------------------

   static vf_log_class     log = new( "dut_pin_data_class", "dut_pin_data" );

   //---------------------------------------------------
   // randomized properties
   //---------------------------------------------------

   rand  bit               dqtype   ;
   rand  bit               slp      ;

   //===================================================================
   // private properties
   //===================================================================

   //===================================================================
   // constraints
   //===================================================================

   constraint slp_con { slp == 0; }

   //===================================================================
   // new
   //===================================================================

   function new( vf_log_class log = null );
      super.new( log == null ? this.log : log );
   endfunction: new

   //===================================================================
   // psdisplay
   //===================================================================

   virtual function string psdisplay( string prefix = "" );
      string str, sep;
      dqtype_e dqtype_s;
      $cast( dqtype_s, this.dqtype );
      sep = { "\n", prefix };
      str = { super.psdisplay( prefix ),
              sep, $psprintf( "dqtype=%s(%0d)", dqtype_s.name(), this.dqtype ),
              sep, $psprintf( "slp=%0d", this.slp ),
              "" };
      return str;
   endfunction: psdisplay

   //===================================================================
   // psdisplay_line
   //===================================================================

   virtual function string psdisplay_line( string prefix = "" );
      string str, sep;
      sep = " ";
      str = { super.psdisplay_line( prefix ),
              sep, $psprintf( "dqtype=%0d", this.dqtype ),
              sep, $psprintf( "slp=%0d", this.slp ),
              "" };
      return str;
   endfunction: psdisplay_line

   //===================================================================
   // allocate
   //===================================================================

   virtual function vf_data_class allocate();
      dut_pin_data_class o;
      o = new();
      $cast( allocate, o );
   endfunction: allocate

   //===================================================================
   // copy
   //===================================================================

   virtual function vf_data_class copy( vf_data_class to   = null,
                                        int           kind = -1    );
      dut_pin_data_class cpy;
      if ( to == null ) cpy = new();
      else if ( ! $cast( cpy, to ) ) begin
         `vf_fatal( this.log,
                    "Cannot copy to a NON dut_pin_data_class instance" );
         return null;
      end
      void'( super.copy( cpy ) );

      cpy.dqtype  =  this.dqtype ;
      cpy.slp     =  this.slp    ;

      return cpy;
   endfunction: copy

   //===================================================================
   // compare
   //===================================================================

   virtual function bit compare( vf_data_class to,
                                 output string diff,
                                 input  int    kind = -1 );
      bit cval;
      dut_pin_data_class cmp;
      if ( to == null ) begin
         $sformat( diff, "Cannot compare to a NULL instance" );
         `vf_fatal( this.log, diff );
         return 0;
      end
      if ( ! $cast( cmp, to ) ) begin
         $sformat( diff, "%s%s", "Cannot compare to ",
                                 "NON dut_pin_data_class instance" );
         `vf_fatal( this.log, diff );
         return 0;
      end

      diff = "";
      cval  =  super.compare( cmp, diff, kind );
      cval  =  cval &&
               cmp.dqtype  == this.dqtype &&
               cmp.slp     == this.slp    ;

      if( ! cval )
         $sformat( diff, "Compare failed\n%s\n%s",
                   this.psdisplay( "this: " ),
                     to.psdisplay( "  to: " ) );
      return cval;
   endfunction: compare

endclass: dut_pin_data_class
//`endprotect
`endif // `ifndef _DUT_PIN_DATA_SV_
