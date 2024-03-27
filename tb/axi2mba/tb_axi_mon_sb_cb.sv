//----------------------------------------------------------------------
/**
 * @file tb_axi_mon_sb_cb.sv
 * @brief Defines DUT specific AXI monitor scoreboard callback class.
 */
/*
 * Copyright (C) 2007-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _TB_AXI_MON_SB_CB_SV_
`define _TB_AXI_MON_SB_CB_SV_
//`protect

//======================================================================
/**
 * DUT specific AXI monitor scoreboard callback class.
 */
//======================================================================

class tb_axi_mon_sb_cb_class extends vf_axi_mon_sb_cb_class;

   //===================================================================
   // public properties
   //===================================================================

   bit                     rm_addr_offset = 1;
   int unsigned            data_bus_width = 128;

   //===================================================================
   // private properties
   //===================================================================

   //===================================================================
   // new
   //===================================================================

   function new( string name = "tb_axi_mon_sb_cb_class",
                 string inst = "axi_mon_sb_cb",
                 vsl_mm_class          mm,
                 vsl_sb_class          sb,
                 vf_axi_sb_func_class  sb_func );
      super.new( name, inst, mm, sb, sb_func );
   endfunction: new

   //===================================================================
   // ins_sb
   //===================================================================

   virtual function void ins_sb( vf_axi_xact_class xfer,
                                 bit dir ); // 0: master, 1: slave
      if ( xfer == null ) return;

      if ( this.rm_addr_offset )
         xfer.addr -= 'h4000_0000;

      super.ins_sb( xfer, dir );

      if ( xfer.aburst == vf_axi_type::BURST_FIXED || 
           xfer.xfer_bytes > ( this.data_bus_width >> 3 ) )
         this.error_resp( xfer, dir );

      this.clean_sb( xfer );
   endfunction: ins_sb

   //===================================================================
   // lookup_id
   //===================================================================

   virtual function int lookup_id( int stream_id,
                                   bit dir, // 0: master, 1: slave
                                   vf_axi_xact_class xfer = null );
      if ( ~dir ) begin
         tb_type::stream_id_e    sid;
         tb_type::initiator_id_e iid;
         if ( ! $cast( sid, stream_id ) )
            return int'( tb_type::UNKNOWN_I );
         case ( sid )
            tb_type::AXI_ID   : iid = tb_type::AXI_I     ;
            default           : iid = tb_type::RESERVED_I;
         endcase // case ( sid )
         return int'( iid );
      end
      return super.lookup_id( stream_id, dir, xfer );
   endfunction: lookup_id

   //===================================================================
   // clean_sb
   //===================================================================

   virtual function void clean_sb( vf_axi_xact_class xfer );
      case ( vf_axi_type::get_phase( xfer.status, xfer.kind ) )
         vf_axi_type::AXI_RDATA_RCVD:
            if ( xfer.last_xfer ) this.clean_rd_sb();
         vf_axi_type::AXI_WRESP_RCVD:
            this.clean_wr_sb();
      endcase // case ( vf_axi_type::get_phase( xfer.status, xfer.kind ) )
   endfunction: clean_sb

   //===================================================================
   // clean_rd_sb
   //===================================================================

   virtual function void clean_rd_sb();
      vsl_sbe_class sbes[$];
      vsl_sbe_class sbe;
      vpr_type::status_t find_status;
      find_status = vpr_type::ADDR_RCVD |
                    vpr_type::DATA_SENT |
                    vpr_type::ACK_SENT  ;
      sbe = new();
      sbe.status = find_status;
      if ( this.sb.find_status( sbes, sbe, vpr_type::ALL_STAT ) ) begin
         foreach ( sbes[i] )
            void'( this.sb.remove( sbes[i], vsl_type::REMOVE_CANCEL ) );
      end
   endfunction: clean_rd_sb

   //===================================================================
   // clean_wr_sb
   //===================================================================

   virtual function void clean_wr_sb();
      vsl_sbe_class sbes[$];
      vsl_sbe_class sbe;
      vpr_type::status_t find_status;
      find_status = vpr_type::ADDR_RCVD |
                    vpr_type::DATA_RCVD |
                    vpr_type::ACK_SENT  ;
      sbe = new();
      sbe.status = find_status;
      if ( this.sb.find_status( sbes, sbe, vpr_type::ALL_STAT ) ) begin
         vsl_sbe_byte_class tpe;
         foreach ( sbes[i] ) begin
            if ( $cast( tpe, sbes[i] ) && ! tpe.byte_en )
               void'( this.sb.remove( sbes[i], vsl_type::REMOVE_CANCEL ) );
         end
      end
   endfunction: clean_wr_sb

   //===================================================================
   // error_resp
   //===================================================================

   virtual function void error_resp( vf_axi_xact_class xfer, bit dir );
      vf_axi_xact_class t_xfer;
      vsl_sbe_class     e;
      string            msg;
      bit               rval;

      case ( vf_axi_type::get_phase( xfer.status, xfer.kind ) )
         vf_axi_type::AXI_ADDR_RCVD ,
         vf_axi_type::AXI_WDATA_RCVD,
         vf_axi_type::AXI_RDATA_RCVD,
         vf_axi_type::AXI_WRESP_RCVD: ; // nothing to do
         default: return;
      endcase

      dir = ~dir;

      $cast( t_xfer, xfer.copy() );
      $cast( e, this.setup_e( t_xfer, dir ) );
      if ( e == null ) return;

      fork
         begin
            this.sb.sb_lock.get(); // get a key
            case ( vf_axi_type::get_phase( t_xfer.status, t_xfer.kind ) )
               vf_axi_type::AXI_ADDR_RCVD :
                  rval  = this.sb_func.update_addr ( t_xfer, e,  dir, msg );
               vf_axi_type::AXI_WDATA_RCVD:
                  rval  = this.sb_func.update_wdata( t_xfer, e,  dir, msg );
               vf_axi_type::AXI_RDATA_RCVD:
                  rval  = this.sb_func.update_rdata( t_xfer, e, ~dir, msg );
               vf_axi_type::AXI_WRESP_RCVD:
                  rval  = this.sb_func.update_wresp( t_xfer, e, ~dir, msg );
            endcase
            if ( ! rval ) begin
               if ( this.stop_sb_err )
                  `vf_error( this.log, msg );
               else
                  `vf_warning( this.log, msg );
            end
            this.sb.sb_lock.put(); // put back a key
         end
      join_none
   endfunction: error_resp

endclass: tb_axi_mon_sb_cb_class
//`endprotect
`endif // `ifndef _TB_AXI_MON_SB_CB_SV_
