//----------------------------------------------------------------------
/**
 * @file mba_slv.v
 * @brief Defines MBA slave model.
 */
//----------------------------------------------------------------------

module mba_slv
   (
      CLK         ,   // i
      ZRESET      ,   // i
      DQTYPE      ,   // i
      DQTYPE_O    ,   // o
      ARB_REQ     ,   // i
      ARB_REL     ,   // o
      ARB_NEL     ,   // o
      ARB_RZW     ,   // i
      ARB_ADR     ,   // i
      ARB_BST     ,   // i
      ARB_WAK     ,   // o
      ARB_RDT     ,   // i
      ARB_BEN     ,   // i
      ARB_RAK     ,   // o
      ARB_WDT     //, // o
   );

   //===================================================================
   // parameters
   //===================================================================

   parameter               DQW         =  0;
   parameter               LFSR_INIT   =  {32{1'b1}};
   parameter               XDATA_X16   =  1;
   localparam              P_DW        =  128;
   localparam              P_SW        =  P_DW / 8;

   //===================================================================
   // ports
   //===================================================================

   // System
   input                   CLK         ;
   input                   ZRESET      ;
   input                   DQTYPE      ;
   output                  DQTYPE_O    ; // DDR DQ select (0=x16 1=x32)
   // MBA I/F
   input                   ARB_REQ     ; // MBA Request (Act-L)
   output                  ARB_REL     ; // MBA Request acknoledge (Act-H)
   output                  ARB_NEL     ; // MBA Request permission (Act-H)
   input                   ARB_RZW     ; // MBA Direction (0=Write)
   input    [ 29:2]        ARB_ADR     ; // MBA Address
   input    [  9:2]        ARB_BST     ; // MBA Transfer word size (BST+1=Size)
   output                  ARB_WAK     ; // MBA Write data enable (Act-L)
   input    [P_DW-1:0]     ARB_RDT     ; // MBA Write data
   input    [P_SW-1:0]     ARB_BEN     ; // MBA Write data byte enable (Act-L)
   output                  ARB_RAK     ; // MBA Read data enable (Act-L)
   output   [P_DW-1:0]     ARB_WDT     ; // MBA Read data

   //===================================================================
   // output registers
   //===================================================================

   reg                     ARB_REL     ;
   reg                     ARB_NEL     ;
   reg                     ARB_WAK     ;
   reg                     ARB_RAK     ;
   reg      [P_DW-1:0]     ARB_WDT     ;

   //===================================================================
   // signals
   //===================================================================

   wire                    req_trig    ;
   wire                    data_trig   ;
   wire                    data_done   ;

   reg      [ 10:0]        bst         ;
   reg                     rzw         ;
   wire     [ 10:0]        blen        ;

   reg                     req_st      ;
   reg                     data_st     ;
   reg      [  7:0]        trxa        ;
   reg      [ 10:0]        txal        ;

   wire                    arb_rel_en  ;
   wire                    data_trig_en;
   wire     [  7:0]        rnd_data    ;
   wire                    rnd_in      ;
   wire     [ 31:0]        rnd         ;

   //===================================================================
   // logic
   //===================================================================

   assign   DQTYPE_O =  DQW < 0 ? DQTYPE :
                        DQW == 1 | DQW == 32 ? 1'b1 : 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         ARB_NEL  <= 1'b1;
      else if ( ~ARB_REQ )
         ARB_NEL  <= 1'b0;
      else if ( data_done )
         ARB_NEL  <= 1'b1;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         ARB_REL  <= 1'b0;
      else if ( ~ARB_REQ & ~ARB_REL )
         ARB_REL  <= arb_rel_en;
      else
         ARB_REL  <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         ARB_WAK  <= 1'b1;
      else if ( data_trig )
         ARB_WAK  <= ~( rzw == 1'b0 );
      else if ( data_done )
         ARB_WAK  <= 1'b1;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         ARB_RAK  <= 1'b1;
      else if ( data_trig )
         ARB_RAK  <= ~( rzw == 1'b1 );
      else if ( data_done )
         ARB_RAK  <= 1'b1;

   integer  i;
   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         ARB_WDT  <= {P_DW{1'b0}};
      else if ( data_trig & rzw ) begin
         for ( i = 0; i < P_DW / 8; i = i + 1 )
            if ( ~DQTYPE_O & XDATA_X16 & ( ( i % 8 ) >=4 ) )
               ARB_WDT[i*8+:8] <= {8{1'bx}};
            else
               ARB_WDT[i*8+:8] <= rnd_data + i;
      end
      else if ( ~ARB_RAK & ~data_done ) begin
         for ( i = 0; i < P_DW / 8; i = i + 1 )
            ARB_WDT[i*8+:8] <= ARB_WDT[i*8+:8] + 16;
      end
      else
         ARB_WDT  <= {P_DW{1'b0}};

   assign   req_trig =  ~ARB_REQ & ARB_REL;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         bst   <= {11{1'b0}};
         rzw   <= 1'b0;
      end
      else if ( req_trig ) begin
//         bst[10:2]   <= { 1'b0, ARB_BST } + 1'b1;
//         bst[ 1:0]   <= {2{1'b0}};
         bst   <= { 1'b0, ARB_BST, 2'b11 } + 1'b1;
         rzw   <= ARB_RZW;
      end

   assign   blen  =  DQTYPE_O ? { 2'b00, bst[10:2] } : { 1'b0, bst[10:1] };

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         req_st   <= 1'b0;
      else if ( req_trig )
         req_st   <= 1'b1;
      else if ( data_done )
         req_st   <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         data_st   <= 1'b0;
      else if ( req_trig | data_done )
         data_st   <= 1'b0;
      else if ( data_trig )
         data_st   <= 1'b1;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         trxa  <= {8{1'b0}};
      else if ( req_trig )
         trxa  <= {8{1'b0}};
      else if ( req_st )
         trxa  <= trxa + 1'b1;

   assign   data_trig   =  ( trxa >  8'h03 ) & data_trig_en &
                           ( ARB_WAK & ARB_RAK ) & req_st;
   assign   data_done   =  ( txal == ( blen - 1'b1 ) ) & data_st;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         txal  <= {11{1'b0}};
      else if ( data_trig )
         txal  <= {11{1'b0}};
      else if ( data_st )
         txal  <= txal + 1'b1;

   assign   arb_rel_en     =  ( rnd[1:0] == 2'b11 );
   assign   data_trig_en   =  ( rnd[3:2] == 2'b11 );
   assign   rnd_data       =  rnd[15:8];
   assign   rnd_in         =  ~ARB_REQ;

   //===================================================================
   // instances
   //===================================================================

   crc32
      #(
         .W          ( 32           ),
         .INIT       ( LFSR_INIT    )//,
      )
      rand_data
      (
         .clk        ( CLK          ),
         .rst_n      ( ZRESET       ),
         .clr        ( 1'b0         ),
         .din        ( rnd_in       ),
         .dout       (              ),
         .crc        ( rnd          )//,
      );

endmodule
// end of file
