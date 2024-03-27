//----------------------------------------------------------------------
/**
 * @file DDR_A2M_REQCTL.v
 * @brief Defines AXI to MBA bridge: Request control module.
 */
//----------------------------------------------------------------------

module DDR_A2M_REQCTL
   (
      CLK         ,   // i
      ZRESET      ,   // i
      DQTYPE      ,   // i
      BID         ,   // o
      BRESP       ,   // o
      BVALID      ,   // o
      BREADY      ,   // i
      ARB_REQ     ,   // o
      ARB_REL     ,   // i
      ARB_NEL     ,   // i
      ARB_RZW     ,   // o
      ARB_ADR     ,   // o
      ARB_BST     ,   // o
      RE          ,   // o
      EMPTY       ,   // i
      AXID        ,   // i
      AXADDR      ,   // i
      AXLEN       ,   // i
      AXSIZE      ,   // i
      AXBURST     ,   // i
      AXLOCK      ,   // i
      AXDIR       ,   // i
      WDREQ       ,   // o
      WDEND       ,   // i
      WDREADY     ,   // i
      WDERR       ,   // o
      RDREQ       ,   // o
      RDEND       ,   // i
      RDREADY     ,   // i
      RD_AVALID   ,   // o
      RREQERR     ,   // o
      RAMASK      //, // o
   );

   //===================================================================
   // parameters
   //===================================================================

   parameter      P_WIW       =  8;
   parameter      P_IW        =  8;
   parameter      P_AW        =  40;

   `include       "DDR_A2M_AXI_PARAM.vh"

   //===================================================================
   // ports
   //===================================================================

   // System
   input                   CLK         ;
   input                   ZRESET      ;
   input                   DQTYPE      ; // DDR DQ select (0=x16 1=x32)
   // AXI Write response channel
   output   [P_WIW-1:0]    BID         ;
   output   [  1:0]        BRESP       ;
   output                  BVALID      ;
   input                   BREADY      ;
   // MBA I/F
   output                  ARB_REQ     ; // (Act-L)
   input                   ARB_REL     ; // (Act-H)
   input                   ARB_NEL     ; // (Act-H)
   output                  ARB_RZW     ; // (0=Write)
   output   [ 29:2]        ARB_ADR     ;
   output   [  9:2]        ARB_BST     ;
   // AXI Request
   output                  RE          ;
   input                   EMPTY       ;
   input    [P_IW-1:0]     AXID        ;
   input    [P_AW-1:0]     AXADDR      ;
   input    [  7:0]        AXLEN       ;
   input    [  2:0]        AXSIZE      ;
   input    [  1:0]        AXBURST     ;
   input                   AXLOCK      ;
   input                   AXDIR       ;
   // Data control
   output                  WDREQ       ;
   input                   WDEND       ;
   input                   WDREADY     ;
   output                  WDERR       ;
   output                  RDREQ       ;
   input                   RDEND       ;
   input                   RDREADY     ;
   output                  RD_AVALID   ;
   output                  RREQERR     ;
   output   [  7:0]        RAMASK      ;

   //===================================================================
   // output registers
   //===================================================================

   reg      [P_WIW-1:0]    BID         ;
   reg      [  1:0]        BRESP       ;
   reg                     BVALID      ;
   reg                     ARB_REQ     ;
   reg                     ARB_RZW     ;
   reg      [ 29:2]        ARB_ADR     ;
   reg      [  9:2]        ARB_BST     ;
   reg                     RE          ;
   reg                     WDREQ       ;
   reg                     WDERR       ;
   reg                     RDREQ       ;

   //===================================================================
   // signals
   //===================================================================

   reg                     rer         ;
   wire                    re_in       ;

   reg      [  2:0]        wderrr      ;

   reg      [P_IW-1:0]     aid         ;
   reg      [P_AW-1:0]     aaddr       ;
 //reg      [  7:0]        alen        ;
 //reg      [  2:0]        asize       ;
 //reg      [  1:0]        aburst      ;
 //reg                     alock       ;
   reg                     adir        ;
   reg      [  7:0]        amask       ;
   reg      [ 12:0]        total       ;
   reg                     reqerr      ;
   wire     [P_AW-1:0]     aaddr_m     ;

   reg                     req_st      ;
   reg                     req_ready   ;
   reg                     req_on      ;
   wire                    req_en      ;
   wire                    req_next    ; // INCR
   wire                    req_end     ;
   reg                     next_trig   ;
   reg                     arb_cal     ;
   wire                    dreq_in     ;
   wire                    dend        ;

   wire                    sizey_sel0  ;
   wire                    sizey_sel1  ;
   wire     [  8:0]        sizex       ;
   reg      [  8:0]        sizey       ;
   reg      [ 12:0]        sizet       ;

   wire     [ 29:2]        adr_m       ;

   wire     [  7:0]        aaddr_l     ;
   wire     [  8:0]        aaddr_l0    ;
   wire     [  8:0]        aaddr_l1    ;

   reg      [ 29:2]        adr_pre     ;
   reg      [  9:2]        bst_pre     ;
   wire     [  9:2]        bst_pre1    ;
   wire     [  9:2]        bst_pre2    ;

   wire     [ 29:2]        adr_next    ;
   wire     [  9:2]        bst_next    ;

   wire     [ 12:0]        ttl_size    ;
   wire     [  7:0]        addr_mask   ;
   wire     [  7:0]        wrap_mask   ;
   wire                    req_error   ;

   //===================================================================
   // logic
   //===================================================================

   assign   RD_AVALID   =  rer & ~AXDIR;
   assign   RREQERR     =  reqerr & ~AXDIR;
   assign   RAMASK      =  amask;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         BID      <= {P_WIW{1'b0}};
         BRESP    <= P_ARESP_OKAY;
      end
      else if ( req_end & adir ) begin
         BID      <= aid[P_WIW-1:0];
         BRESP    <= reqerr ? P_ARESP_SLVERR : P_ARESP_OKAY;
      end

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         BVALID   <= 1'b0;
      else if ( req_end & adir )
         BVALID   <= 1'b1;
      else if (  BVALID & BREADY )
         BVALID   <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         ARB_REQ  <= 1'b1;
      else if ( req_on & ARB_NEL )
         ARB_REQ  <= 1'b0;
      else if ( ~ARB_REQ & ARB_REL )
         ARB_REQ  <= 1'b1;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         ARB_RZW  <= {   1{1'b0}};
         ARB_ADR  <= {30-2{1'b0}};
         ARB_BST  <= {   8{1'b0}};
      end
      else if ( req_on & ARB_NEL ) begin
         ARB_RZW  <= ~adir;
         ARB_ADR  <= adr_next;
         ARB_BST  <= bst_next;
      end

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         WDREQ    <= 1'b0;
         RDREQ    <= 1'b0;
      end
      else begin
         WDREQ    <= dreq_in &  adir;
         RDREQ    <= dreq_in & ~adir;
      end

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         RE    <= 1'b0;
         rer   <= 1'b0;
      end
      else begin
         RE    <= re_in;
         rer   <= RE;
      end

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         wderrr   <= {3{1'b0}};
         WDERR    <= 1'b0;
      end
      else begin
         wderrr   <= { wderrr[1:0], req_en & reqerr & adir };
         WDERR    <= wderrr[2];
      end

   //-----------------------------------------------------------

   assign   re_in    =  ~EMPTY & ~req_st;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         aid      <= {P_IW{1'b0}};
         aaddr    <= {P_AW{1'b0}};
       //alen     <= {   8{1'b0}};
       //asize    <= {   3{1'b0}};
       //aburst   <= {   2{1'b0}};
       //alock    <= {   1{1'b0}};
         adir     <= {   1{1'b0}};
         amask    <= {   8{1'b0}};
         total    <= {  13{1'b0}};
         reqerr   <= {   1{1'b0}};
      end
      else if ( rer ) begin
         aid      <= AXID     ;
         aaddr    <= AXADDR   ;
       //alen     <= AXLEN    ;
       //asize    <= AXSIZE   ;
       //aburst   <= AXBURST  ;
       //alock    <= AXLOCK   ;
         adir     <= AXDIR    ;
         amask    <= AXBURST == P_ABURST_WRAP ? wrap_mask : addr_mask;
         total    <= ttl_size ;
         reqerr   <= req_error;
      end

   assign   aaddr_m  =  { aaddr[P_AW-1:8], aaddr[7:0] & amask };

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         req_st   <= 1'b0;
      else if ( req_end )
         req_st   <= 1'b0;
      else if ( re_in )
         req_st   <= 1'b1;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         req_ready   <= 1'b0;
      else
         req_ready   <= rer;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         req_on   <= 1'b0;
      else if ( req_ready | req_on & ARB_NEL )
         req_on   <= 1'b0;
      else if ( req_en & ~reqerr )
         req_on   <= 1'b1;

   assign   req_en   =  arb_cal & ( ( adir & WDREADY ) | ( ~adir & RDREADY ) );
   assign   req_next =  (|sizet) & next_trig;
   assign   req_end  =  ( ~(|sizet) | reqerr ) & dend;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         next_trig   <= 1'b0;
      else
         next_trig   <= ~ARB_REQ & ARB_REL;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         arb_cal  <= 1'b0;
      else if ( req_ready | req_next )
         arb_cal  <= 1'b1;
      else if ( req_en )
         arb_cal  <= 1'b0;

   assign   dreq_in  =  ( ~ARB_REQ & ARB_REL ) | ( req_en & reqerr );
   assign   dend     =  adir & WDEND | ~adir & RDEND  ;

   assign   sizey_sel0  =  (|total[12:9]) | ( total[8:0] >= sizex  );
   assign   sizey_sel1  =  (|sizet[12:9]) | ( sizet[8:0] >= 9'h100 );

   assign   sizex    =  9'h100 - aaddr_m[7:0];

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         sizey    <= {9{1'b0}};
      else if ( req_ready )
         sizey    <= sizey_sel0 ? sizex  : total[8:0];
      else if ( req_next )
         sizey    <= sizey_sel1 ? 9'h100 : sizet[8:0];

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         sizet    <= {13{1'b0}};
      else if ( req_ready )
         sizet    <= total;
      else if ( req_on & ARB_NEL )
         sizet    <= sizet - sizey;

   assign   adr_m[29:6] =  adr_pre[29:6] + 1'b1; // addr[31:8]
   assign   adr_m[ 5:2] =  {4{1'b0}};

   assign   aaddr_l  =  aaddr_m[7:0] + total[7:0];
   assign   aaddr_l0 =  sizey_sel0 ? 9'h100 : { 1'b0, aaddr_l };
   assign   aaddr_l1 =  sizey_sel1 ? 9'h100 : { 1'b0, aaddr_l };

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         adr_pre     <= {30-2{1'b0}};
      else if ( req_ready )
         adr_pre     <= aaddr_m[31:4]; // AxADDR[31:2] = ARB_ADR[29:0]
      else if ( req_next )
         adr_pre     <= adr_m;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         bst_pre     <= {10-2{1'b0}};
      else if ( req_ready )
         bst_pre     <= { {3{1'b0}}, aaddr_l0[8:4] } + |aaddr_l0[3:0] - aaddr_m[7:4];
      else if ( req_next )
         bst_pre     <= { {3{1'b0}}, aaddr_l1[8:4] } + |aaddr_l1[3:0];

   assign   bst_pre1 =  DQTYPE & adr_pre[2]  ? bst_pre  + 1'b1 : bst_pre ;
   assign   bst_pre2 =  DQTYPE & bst_pre1[2] ? bst_pre1 + 1'b1 : bst_pre1;

   assign   adr_next =  DQTYPE ? { adr_pre[29:3], 1'b0 } : adr_pre;
   assign   bst_next =  bst_pre2 - 1'b1;

   //===================================================================
   // instances
   //===================================================================

   DDR_A2M_TTLSIZE
      ttlsize
      (
         .AXLEN      ( AXLEN        ),   // i
         .AXSIZE     ( AXSIZE       ),   // i
         .TOTAL      ( ttl_size     )//, // o
      );

   DDR_A2M_ADDRMASK
      addrmask
      (
         .AXSIZE     ( AXSIZE       ),   // i
         .MASK       ( addr_mask    )//, // o
      );

   DDR_A2M_WRAPMASK
      wrapmask
      (
         .AXLEN      ( AXLEN        ),   // i
         .AXSIZE     ( AXSIZE       ),   // i
         .MASK       ( wrap_mask    )//, // o
      );

   DDR_A2M_SLVERR
      slverr
      (
       //.AXLEN      ( AXLEN        ),   // i
         .AXSIZE     ( AXSIZE       ),   // i
         .AXBURST    ( AXBURST      ),   // i
         .SLVERR     ( req_error    )//, // o
      );

endmodule
// end of file
