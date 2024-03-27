//----------------------------------------------------------------------
/**
 * @file vpr_type.sv
 * @brief Defines Common defined-type class.
 */
/*
 * Copyright (C) 2007-2011 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VPR_TYPE_SV_
`define _VPR_TYPE_SV_
//`protect

`include "../lib/vpr_defines.svi"

//======================================================================
/**
 * Common Defined-type Class.
 */
//======================================================================

virtual class vpr_type;

   //===================================================================
   // defined-types
   //===================================================================

   typedef int unsigned                   wt_t        ; ///< Weight  type
   typedef bit [`VPR_MAX_ADDR_WIDTH-1:0]  addr_t      ; ///< Address type
   typedef bit [ 8:0]                     status_t    ; ///< Status  type
   typedef bit [ 3:0]                     xact_type_t ; ///< Transaction type
   typedef real                           time_t      ; ///< Time stamp type

   typedef logic [ 7:0]                   logic8_t    ; ///< 4-state  8-bit
   typedef logic [31:0]                   logic32_t   ; ///< 4-state 32-bit

   //===================================================================
   // enumerations
   //===================================================================

   /// Kind of transaction
   typedef enum int
                  { READ         = 0,
                    WRITE        = 1,
                    BUS_SPECIFIC = 2,
                    USER_DEFINED = 3
                  } kind_e;

   /// Kind of status
   typedef enum status_t
                  { NO_STAT      = 9'b0_0000_0000,
                    GENERATED    = 9'b0_0000_0001,
                    REQUESTED    = 9'b0_0000_0010,
                    GRANTED      = 9'b0_0000_0100,
                    ADDR_SENT    = 9'b0_0000_1000,
                    ADDR_RCVD    = 9'b0_0001_0000,
                    DATA_SENT    = 9'b0_0010_0000,
                    DATA_RCVD    = 9'b0_0100_0000,
                    ACK_SENT     = 9'b0_1000_0000,
                    ACK_RCVD     = 9'b1_0000_0000,
                    ALL_STAT     = 9'b1_1111_1111
                  } status_e;

   /// Type of transaction
   typedef enum xact_type_t
                  { NO_XACT_TYPE    = 4'b0000,
                    INITIATOR       = 4'b0001,
                    TARGET          = 4'b0010,
                    MONITOR         = 4'b0100,
                    INITIATOR_MON   = 4'b0101,
                    TARGET_MON      = 4'b0110
                  } xact_type_e;

   /// Type of compare
   typedef enum int
                  { COMPARE_ALL     = -1,
                    COMPARE_REQ     =  1,
                    COMPARE_DATA    =  2,
                    COMPARE_RESP    =  4,
                    COMPARE_ANY     =  7
                  } compare_e;

   /// Data fill algorithm
   typedef enum int
                  { ALGO_NONE          = 0,
                    ALGO_INCR_BYTE     ,
                    ALGO_INCR_4BYTES   ,
                    ALGO_INCR_ENTRY    ,
                    ALGO_ALL_BITS_0    ,
                    ALGO_ALL_BITS_1    ,
                    ALGO_ALL_BITS_X
                  } algo_e;

   /// Bus idle pattern
   typedef enum int
                  { PATTERN_PREV = -1,
                    PATTERN_0    =  0,
                    PATTERN_1    ,
                    PATTERN_X    ,
                    PATTERN_Z
                  } pattern_e;

   /// String alignment
   typedef enum   { STR_LEFT     ,
                    STR_CENTER   ,
                    STR_RIGHT
                  } str_align_e;

   typedef enum int
                  { DEFAULT_TYP  = 0,
                    BIN_TYP      ,
                    OCT_TYP      ,
                    DEC_TYP      ,
                    HEX_TYP      ,
                    STR_TYP
                  } radix_e;

   //===================================================================
   // weight structures
   //===================================================================

   /// Weight of boolean
   typedef struct { wt_t   wt_of_false ;
                    wt_t   wt_of_true  ;
                  } boolean_wt_st;

   /// Weight of kind
   typedef struct { wt_t   wt_of_read           ;
                    wt_t   wt_of_write          ;
                    wt_t   wt_of_bus_specific   ;
                    wt_t   wt_of_user_defined   ;
                  } kind_wt_st;

`protect
   //===================================================================
   // static methods
   //===================================================================

   //===================================================================
   // expand_algo
   //===================================================================

   static function bit expand_algo( ref   logic [7:0]  bytes[]   ,
                                    input algo_e       algo      ,
                                    input int unsigned len       ,
                                    input int unsigned offset     = 0,
                                    input int unsigned first_data = 0 );
      if ( bytes.size() < len + int'( offset ) ) return 0;
      case ( algo )
         ALGO_INCR_BYTE,
         ALGO_INCR_ENTRY:
            for ( int i = 0; i < len; i++ ) bytes[i+offset] = first_data + i;
         ALGO_INCR_4BYTES:
            for ( int i = 0; i < len; i += 4 ) begin
               bit [31:0] four_bytes;
               four_bytes = first_data + ( i >> 2 );
                                  bytes[i+0+offset] = four_bytes[ 0+:8];
               if ( len > i + 1 ) bytes[i+1+offset] = four_bytes[ 8+:8];
               if ( len > i + 2 ) bytes[i+2+offset] = four_bytes[16+:8];
               if ( len > i + 3 ) bytes[i+3+offset] = four_bytes[24+:8];
            end
         ALGO_ALL_BITS_0:
            for ( int i = 0; i < len; i++ ) bytes[i+offset] = {8{1'b0}};
         ALGO_ALL_BITS_1:
            for ( int i = 0; i < len; i++ ) bytes[i+offset] = {8{1'b1}};
         ALGO_ALL_BITS_X:
            for ( int i = 0; i < len; i++ ) bytes[i+offset] = {8{1'bx}};
//         ALGO_NONE:
         default: return 0;
      endcase // case ( algo )
      return 1;
   endfunction: expand_algo

   //===================================================================
   // psdisplay_data
   //===================================================================

   static function string psdisplay_data( ref   logic [7:0]  data[]   ,
                                          ref   bit          byte_en[],
                                          input addr_t       addr      = 0,
                                          input int unsigned offset    = 0,
                                          input int unsigned len       = 0,
                                          input string       prefix    = "" );
      string       s;
      logic [7:0]  d;
      bit          e;
      string       str = "";
      int unsigned n   = 0;

      if ( ! len ) len = data.size() - offset;

      str   = "";
      addr += offset;
      while ( n < len ) begin: lp_n
         $sformat( s, "%s%8h", prefix, addr + n );
         for ( int unsigned i = 0; i < 16; i++ ) begin: lp_i
            d = data.size()    > offset + n ? data[ offset + n ] : {8{1'bx}};
            e = byte_en.size() > offset + n ? byte_en[ offset + n ] : 0;
            $sformat( s, "%s %2h(%0d)", s, d, e );
            if ( ++n >= len ) break;
         end: lp_i
         if ( n < len ) s = { s, "\n" };
         str = { str, s };
      end: lp_n
      return str;
   endfunction: psdisplay_data

   //===================================================================
   // psdisplay_status
   //===================================================================

   static function string psdisplay_status( status_t status,
                                            string   prefix = "" );
      string str;
      str = { status & GENERATED ? ":GEN" : "",
              status & REQUESTED ? ":REQ" : "",
              status & GRANTED   ? ":GRT" : "",
              status & ADDR_SENT ? ":ADS" : "",
              status & ADDR_RCVD ? ":ADR" : "",
              status & DATA_SENT ? ":DTS" : "",
              status & DATA_RCVD ? ":DTR" : "",
              status & ACK_SENT  ? ":ACS" : "",
              status & ACK_RCVD  ? ":ACR" : "",
              "" };
      if ( ! str.len() )
         str = "NONE";
      else if ( str.getc( 0 ) == ":" )
         str = str.substr( 1, str.len() - 1 );
      str = { prefix, str };
      return str;
   endfunction: psdisplay_status

   //===================================================================
   // get_pattern
   //===================================================================

   static function logic get_pattern( pattern_e pattern );
      case( pattern )
         PATTERN_0: return 1'b0;
         PATTERN_1: return 1'b1;
         PATTERN_X: return 1'bx;
         PATTERN_Z: return 1'bz;
         default:   return 1'b0;
      endcase // case( pattern )
   endfunction: get_pattern

   //===================================================================
   // pct
   //===================================================================

   static function real pct( int unsigned a, int unsigned b = 0 );
      if ( b == 0 ) return 0;
      return ( real'( a ) / real'( b ) * 100.0 );
   endfunction: pct

   //===================================================================
   // str_pct
   //===================================================================

   static function string str_pct();
      string str = `STR_PCT;
      return str;
   endfunction: str_pct

   //===================================================================
   // str_len
   //===================================================================

   static function int str_len( string str );
      return int'( str.len() );
   endfunction: str_len

   //===================================================================
   // str_align
   //===================================================================

   static function string str_align( string      str  ,
                                     int         len  ,
                                     str_align_e align = STR_LEFT );
      int    l, r;
      string sstr, fill = " ";
      int    slen = str_len( str );
      sstr = "";
      if ( slen > len ) len = slen;
      case ( align )
         STR_CENTER: begin l = ( len - slen ) / 2; r = len - slen - l; end
         STR_RIGHT : begin l = len - slen;         r = 0;              end
         default   : begin l = 0;                  r = len - slen;     end
      endcase // case ( align )
      if ( l ) sstr = { sstr, { l { fill } } };
      sstr = { sstr, str };
      if ( r ) sstr = { sstr, { r { fill } } };
      return sstr;
   endfunction: str_align

   //===================================================================
   // CRC methods
   //===================================================================

   /// CRC-16-CCITT Polynomial, x^16+x^12+x^5+x^0
   /// CRC-16-CCITT Initial value, 0xFFFF
   static bit  [15:0]   crc16init   = 'hFFFF;
   static bit  [15:0]   crc16code   = 'h1021;
   static bit  [15:0]   crc16tcode  = 'h8408;

   /// CRC-8-ATM Polynomial, x^8+x^2+x^1+x^0
   /// CRC-8-ATM Initial value, 0xFF
   static bit  [ 7:0]   crc8init    = 'hFF;
   static bit  [ 7:0]   crc8code    = 'h07;
   static bit  [ 7:0]   crc8tcode   = 'hE0;

   //===================================================================
   // calc_crc16
   //===================================================================

   static function bit [15:0] calc_crc16 ( const ref   logic [ 7:0] bytes[],
                                                 input bit   [15:0] init   ,
                                                 input bit   [15:0] code    );
      bit [15:0] crc;
      bit [ 7:0] d;
      crc = init;
      foreach ( bytes[i] ) begin
         d = bytes[i];
         for ( int p = 0; p < 8; p++ ) begin
            if ( ( crc[15] ^ d[7] ) > 0 )
               crc = ( crc << 1 ) ^ code;
            else
               crc = ( crc << 1 );
            d = ( d << 1 );
         end
      end
      return ~crc;
   endfunction: calc_crc16

   //===================================================================
   // calc_crc16t
   //===================================================================
   // Polynomial must be inverted logically

   static function bit [15:0] calc_crc16t( const ref   logic [ 7:0] bytes[],
                                                 input bit   [15:0] init   ,
                                                 input bit   [15:0] code    );
      bit [15:0] crc;
      bit [ 7:0] d;
      crc = init;
      foreach ( bytes[i] ) begin
         d = bytes[i];
         for ( int p = 0; p < 8; p++ ) begin
            if ( ( crc[0] ^ d[0] ) > 0 )
               crc = ( ( crc >> 1 ) & 'h7FFF ) ^ code;
            else
               crc = ( ( crc >> 1 ) & 'h7FFF );
            d = ( d >> 1 ) & 'h7F;
         end
      end
      return crc;
   endfunction: calc_crc16t

   //===================================================================
   // calc_crc8
   //===================================================================

   static function bit [ 7:0] calc_crc8 ( const ref   logic [ 7:0] bytes[],
                                                input bit   [ 7:0] init   ,
                                                input bit   [ 7:0] code    );
      bit [ 7:0] crc;
      bit [ 7:0] d;
      crc = init;
      foreach ( bytes[i] ) begin
         d = bytes[i];
         for ( int p = 0; p < 8; p++ ) begin
            if ( ( crc[7] ^ d[7] ) > 0 )
               crc = ( crc << 1 ) ^ code;
            else
               crc = ( crc << 1 );
            d = ( d << 1 );
         end
      end
      return ~crc;
   endfunction: calc_crc8

   //===================================================================
   // calc_crc8t
   //===================================================================
   // Polynomial must be inverted logically

   static function bit [ 7:0] calc_crc8t( const ref   logic [ 7:0] bytes[],
                                                input bit   [ 7:0] init   ,
                                                input bit   [ 7:0] code    );
      bit [ 7:0] crc;
      bit [ 7:0] d;
      crc = init;
      foreach ( bytes[i] ) begin
         d = bytes[i];
         for ( int p = 0; p < 8; p++ ) begin
            if ( ( crc[0] ^ d[0] ) > 0 )
               crc = ( ( crc >> 1 ) & 'h7F ) ^ code;
            else
               crc = ( ( crc >> 1 ) & 'h7F );
            d = ( d >> 1 ) & 'h7F;
         end
      end
      return crc;
   endfunction: calc_crc8t
//`endprotect

endclass: vpr_type
//`endprotect
`endif // `ifndef _VPR_TYPE_SV_
