//----------------------------------------------------------------------
/**
 * @file DDR_A2M_WDCTL.v
 * @brief Defines AXI to MBA bridge: Write data control module.
 */
//----------------------------------------------------------------------

module DDR_A2M_WDCTL
   (
      CLK         ,   // i
      ZRESET      ,   // i
      SLP         ,   // i
      DQTYPE      ,   // i
    //AWID        ,   // i
      AWADDR      ,   // i
      AWLEN       ,   // i
      AWSIZE      ,   // i
      AWBURST     ,   // i
      AWLOCK      ,   // i
    //WID         ,   // i
      WDATA       ,   // i
      WSTRB       ,   // i
      WLAST       ,   // i
      WVALID      ,   // i
      WREADY      ,   // o
      ARB_WAK     ,   // i
      ARB_RDT     ,   // o
      ARB_BEN     ,   // o
      DADR        ,   // i
      DREQ        ,   // i
      DEND        ,   // o
      DREADY      ,   // o
      DERR        ,   // i
      AVALID      //, // i
   );

   //===================================================================
   // parameters
   //===================================================================

   parameter      P_FIFOD     =  3;
 //parameter      P_IW        =  8;
   parameter      P_DW        =  128;
   localparam     P_AW        =  8;
   localparam     P_SW        =  P_DW / 8;
   localparam     P_FIFOW     =  P_AW + 8 + 3 + 2 + 1; // adr+len+siz+bst+lock
   localparam     P_MAW       =  4;
   localparam     P_MBW       =  P_SW;
   localparam     P_MDW       =  P_DW + P_SW;

   `include       "DDR_A2M_AXI_PARAM.vh"

   //===================================================================
   // ports
   //===================================================================

   // System
   input                   CLK         ;
   input                   ZRESET      ;
   input                   SLP         ;
   input                   DQTYPE      ; // DDR DQ select (0=x16 1=x32)
   // AXI Write address channel
 //input    [P_IW-1:0]     AWID        ;
   input    [P_AW-1:0]     AWADDR      ;
   input    [  7:0]        AWLEN       ;
   input    [  2:0]        AWSIZE      ;
   input    [  1:0]        AWBURST     ;
   input                   AWLOCK      ; // AXI3: [1:0]
   // AXI Write data channel
 //input    [P_IW-1:0]     WID         ; // AXI3
   input    [P_DW-1:0]     WDATA       ;
   input    [P_SW-1:0]     WSTRB       ;
   input                   WLAST       ;
   input                   WVALID      ;
   output                  WREADY      ;
   // MBA
   input                   ARB_WAK     ; // (Act-L)
   output   [P_DW-1:0]     ARB_RDT     ;
   output   [P_SW-1:0]     ARB_BEN     ; // (Act-L)
   // Data control
   input    [  5:2]        DADR        ;
   input                   DREQ        ;
   output                  DEND        ;
   output                  DREADY      ;
   input                   DERR        ;
   input                   AVALID      ;

   //===================================================================
   // output registers
   //===================================================================

   reg                     WREADY      ;
   reg      [P_DW-1:0]     ARB_RDT     ;
   reg      [P_SW-1:0]     ARB_BEN     ;
   reg                     DEND        ;
   reg                     DREADY      ;

   //===================================================================
   // signals
   //===================================================================

   wire                    fclr        ;
   wire                    fwe         ;
   wire                    fre_in      ;
   reg                     fre         ;
   reg                     frer        ;
   reg                     fre_mask    ;
   wire     [P_FIFOW-1:0]  fdi         ;
   wire     [P_FIFOW-1:0]  fdo         ;
   wire                    fempty      ;
   wire                    ffull       ;

   wire                    axi_last    ;
   wire                    axi_full    ;
   wire                    wak_done    ;
   wire                    err_done    ;
   wire                    dt_done     ;
   reg                     last_st     ;

   reg                     err_st      ;
   reg                     dt_st       ;
   reg                     sel_ra      ;
   reg                     sel_rv      ;

 //reg      [P_IW-1:0]     widr        ;
   reg      [P_DW-1:0]     wdatar      ;
   reg      [P_SW-1:0]     wstrbr      ;
 //reg                     wlastr      ;
   reg                     wdata_vld   ;
   wire     [P_SW-1:0]     wstrbr_m    ;
   wire                    wready_in   ;
   wire                    wready_off0 ;
   wire                    wready_off1 ;

   wire     [P_AW-1:0]     aaddr_in    ;
   wire     [  7:0]        alen_in     ;
   wire     [  2:0]        asize_in    ;
   wire     [  1:0]        aburst_in   ;
   wire                    alock_in    ;

 //reg      [P_AW-1:0]     aaddr       ;
   reg      [  7:0]        alen        ;
   reg      [  2:0]        asize       ;
   reg      [  1:0]        aburst      ;
 //reg                     alock       ;
   reg                     reqerr      ;
   wire     [P_AW-1:0]     aaddr_m     ;

   wire     [P_AW  :0]     addr_next0  ;
   wire     [P_AW  :0]     addr_next   ;
   reg      [P_AW-1:0]     addr        ;
   reg                     addr_end    ;
   reg      [  4:0]        addr_inc    ; // combinational
   reg                     addr_vld    ;
   reg                     addr_ready  ;

   wire                    mem_we      ; // Act-H
   reg      [P_MAW-1:0]    mem_wa      ;
   wire                    mem_wa_clr  ;
   wire     [P_MAW-1:0]    mem_wa_init ;
   wire     [P_MAW-1:0]    mem_wa_next ;

   wire                    mem_re      ; // Act-H
   reg                     mem_rv      ;
   reg      [P_MAW-1:0]    mem_ra      ;
   wire                    mem_ra_clr  ;
   wire     [P_MAW-1:0]    mem_ra_init ;
   wire     [P_MAW-1:0]    mem_ra_next ;

   wire     [P_MAW-1:0]    mem_a       ;
   reg      [P_MAW-1:0]    mem_ar      ;
   reg      [P_MBW-1:0]    mem_be0     ; // combinational
   reg      [P_MBW-1:0]    mem_be1     ; // combinational
   reg      [P_MBW-1:0]    mem_be2     ; // combinational
   reg      [P_MBW-1:0]    mem_be4     ; // combinational
   reg      [P_MBW-1:0]    mem_be8     ; // combinational
   wire     [P_MBW-1:0]    mem_be      ; // Act-H
   wire     [P_MDW-1:0]    mem_d       ;
   wire     [P_MDW-1:0]    mem_q       ;

   reg      [(1<<P_MAW)-1:0]  mem_en   ;
   wire                    mem_en_clr  ;

   wire     [  7:0]        addr_mask   ;
   wire     [  7:0]        wrap_mask   ;
   wire                    req_error   ;

   wire     [P_DW-1:0]     wd          ;
   wire     [P_SW-1:0]     wbe         ;
   reg                     wakr        ;
   reg                     dreqr       ;

   //===================================================================
   // logic
   //===================================================================

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         WREADY   <= 1'b0;
      else
         WREADY   <= wready_in;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         ARB_RDT  <= {P_DW{1'b0}};
         ARB_BEN  <= {P_SW{1'b1}};
      end
      else if ( mem_rv ) begin
         ARB_RDT[ 0+:32]   <= DQTYPE ?  wd[ 0+:32] : ~sel_rv ?  wd[ 0+:32] :  wd[64+:32];
         ARB_RDT[32+:32]   <= DQTYPE ?  wd[32+:32] : {32{1'b0}};
         ARB_RDT[64+:32]   <= DQTYPE ?  wd[64+:32] : ~sel_rv ?  wd[32+:32] :  wd[96+:32];
         ARB_RDT[96+:32]   <= DQTYPE ?  wd[96+:32] : {32{1'b0}};
         ARB_BEN[ 0+: 4]   <= DQTYPE ? ~wbe[ 0+:4] : ~sel_rv ? ~wbe[ 0+:4] : ~wbe[ 8+:4];
         ARB_BEN[ 4+: 4]   <= DQTYPE ? ~wbe[ 4+:4] : { 4{1'b1}};
         ARB_BEN[ 8+: 4]   <= DQTYPE ? ~wbe[ 8+:4] : ~sel_rv ? ~wbe[ 4+:4] : ~wbe[12+:4];
         ARB_BEN[12+: 4]   <= DQTYPE ? ~wbe[12+:4] : { 4{1'b1}};
      end

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         DEND     <= 1'b0;
      else if ( DEND )
         DEND     <= 1'b0;
      else
         DEND     <= reqerr ? err_done & err_st : wak_done & last_st;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         DREADY   <= 1'b0;
      else if ( dt_done )
         DREADY   <= 1'b1;
      else if ( DREQ )
         DREADY   <= 1'b0;

   //-----------------------------------------------------------

   assign   fclr     =  1'b0;
   assign   fwe      =  AVALID;
   assign   fre_in   =  ~fempty & ~fre_mask;
   assign   fdi      =  { AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK };
   assign   { aaddr_in, alen_in, asize_in, aburst_in, alock_in } = fdo;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         fre   <= 1'b0;
         frer  <= 1'b0;
      end
      else begin
         fre   <= fre_in;
         frer  <= fre;
      end

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         fre_mask <= 1'b0;
      else if ( fre_in )
         fre_mask <= 1'b1;
      else if ( wak_done | err_done )
         fre_mask <= ~last_st;

   assign   axi_last    =  WLAST & WVALID & WREADY ;
   assign   axi_full    =  ( aburst == P_ABURST_INCR ) & addr_end;
   assign   wak_done    =   dt_st & ARB_WAK & ~wakr;
   assign   err_done    =   dt_st & DERR & reqerr;
   assign   dt_done     =  ~dt_st & ( axi_last | axi_full );

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         last_st  <= 1'b0;
      else if ( axi_last )
         last_st  <= 1'b1;
      else if ( wak_done | err_done )
         last_st  <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         err_st   <= 1'b0;
      else if ( addr_ready & reqerr )
         err_st   <= 1'b1;
      else if ( err_done )
         err_st   <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         dt_st    <= 1'b0;
      else if ( dt_done )
         dt_st    <= 1'b1;
      else if ( wak_done | err_done )
         dt_st    <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         sel_ra   <= 1'b0;
      else if ( mem_ra_clr )
         sel_ra   <= 1'b0;
      else if ( mem_re )
         sel_ra   <= ~sel_ra;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         sel_rv   <= 1'b0;
      else
         sel_rv   <= sel_ra;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
       //widr     <= {P_WIW{1'b0}};
         wdatar   <= {P_DW{1'b0}};
         wstrbr   <= {P_SW{1'b0}};
       //wlastr   <= {   1{1'b0}};
      end
      else if ( WVALID & WREADY ) begin
       //widr     <= WID      ;
         wdatar   <= WDATA    ;
         wstrbr   <= WSTRB    ;
       //wlastr   <= WLAST    ;
      end

   assign   wstrbr_m =  wstrbr & mem_be0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         wdata_vld <= 1'b0;
      else if ( WVALID & WREADY )
         wdata_vld <= 1'b1;
      else if ( wdata_vld & mem_we )
         wdata_vld <= 1'b0;

   assign   wready_in   =  ~( wready_off0 | wready_off1 );
   assign   wready_off0 =  addr_end | axi_last | last_st |
                           ( (&mem_wa[P_MAW-1:1]) & WVALID & WREADY );
   assign   wready_off1 =  ( ~addr_vld | addr_next[P_AW] ) &
                           ( ( WVALID & WREADY ) | wdata_vld );

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
       //aaddr    <= {P_AW{1'b0}};
         alen     <= {   8{1'b0}};
         asize    <= {   3{1'b0}};
         aburst   <= {   2{1'b0}};
       //alock    <= {   1{1'b0}};
         reqerr   <= {   1{1'b0}};
      end
      else if ( frer ) begin
       //aaddr    <= aaddr_m  ;
         alen     <= alen_in  ;
         asize    <= asize_in ;
         aburst   <= aburst_in;
       //alock    <= alock_in ;
         reqerr   <= req_error;
      end

   assign   aaddr_m  =  aaddr_in[P_AW-1:0] & addr_mask;

   assign   addr_next0  =  { 1'b0, addr } + addr_inc;
   assign   addr_next   =  aburst == P_ABURST_INCR ? addr_next0 :
                           { 1'b0, addr & wrap_mask } |
                           ( addr_next0 & { 1'b0, ~wrap_mask } );

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         addr     <= {P_AW{1'b0}};
         addr_end <= 1'b0;
      end
      else if ( mem_wa_clr ) begin
         addr     <= aaddr_m;
         addr_end <= 1'b0;
      end
      else if ( mem_we ) begin
         addr     <= addr_next[P_AW-1:0];
         addr_end <= addr_next[P_AW] & ~reqerr;
      end
      else if ( wak_done )
         addr_end <= 1'b0;

   always @*
      case ( asize )
         P_ASIZE_2   :  addr_inc <= 5'd2  ;
         P_ASIZE_4   :  addr_inc <= 5'd4  ;
         P_ASIZE_8   :  addr_inc <= 5'd8  ;
         P_ASIZE_16  :  addr_inc <= 5'd16 ;
         default     :  addr_inc <= 5'd1  ;
      endcase // case ( size )

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         addr_vld    <= 1'b0;
      else if ( frer )
         addr_vld    <= 1'b1;
      else if ( dt_st & last_st & addr_vld )
         addr_vld    <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         addr_ready  <= 1'b0;
      else
         addr_ready  <= frer;

   assign   mem_we      =  addr_vld & wdata_vld;
   assign   mem_wa_clr  =  frer;
   assign   mem_wa_init =  aaddr_m[4+:P_MAW];
   assign   mem_wa_next =  addr_next[4+:P_MAW];

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         mem_wa   <= {P_MAW{1'b0}};
      else if ( mem_wa_clr )
         mem_wa   <= mem_wa_init;
      else if ( mem_we )
         mem_wa   <= mem_wa_next;

   assign   mem_re      =  dreqr | ~ARB_WAK;
   assign   mem_ra_clr  =  DREQ;
   assign   mem_ra_init =  DADR;
   assign   mem_ra_next =  mem_ra + ( DQTYPE | sel_ra );

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         mem_rv   <= 1'b0;
      else
         mem_rv   <= mem_re;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         mem_ra   <= {P_MAW{1'b0}};
      else if ( mem_ra_clr )
         mem_ra   <= mem_ra_init;
      else if ( mem_re )
         mem_ra   <= mem_ra_next;

   assign   mem_a =  mem_we ? mem_wa : mem_ra;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         mem_ar   <= {P_MAW{1'b0}};
      else
         mem_ar   <= mem_a;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         mem_en   <= {(1<<P_MAW){1'b0}};
      else if ( mem_en_clr )
         mem_en   <= {(1<<P_MAW){1'b0}};
      else if ( mem_we )
         mem_en[mem_a]  <= 1'b1;

   assign   mem_en_clr  =  mem_wa_clr | ( axi_full & wak_done );
   assign   mem_be   =  mem_en[mem_a] ? mem_be0 : {P_MBW{1'b1}};

   always @*
   begin
      case ( asize )
         P_ASIZE_1   :  mem_be0  <= mem_be1;
         P_ASIZE_2   :  mem_be0  <= mem_be2;
         P_ASIZE_4   :  mem_be0  <= mem_be4;
         P_ASIZE_8   :  mem_be0  <= mem_be8;
         P_ASIZE_16  :  mem_be0  <= {16{1'b1}};
         default     :  mem_be0  <= {16{1'b0}};
      endcase // case ( size )
   end

   // for P_ASIZE_1
   always @*
   begin
      case ( addr[3:0] )
         4'h0: mem_be1  <= { {15{1'b0}}, {1{1'b1}}             };
         4'h1: mem_be1  <= { {14{1'b0}}, {1{1'b1}}, { 1{1'b0}} };
         4'h2: mem_be1  <= { {13{1'b0}}, {1{1'b1}}, { 2{1'b0}} };
         4'h3: mem_be1  <= { {12{1'b0}}, {1{1'b1}}, { 3{1'b0}} };
         4'h4: mem_be1  <= { {11{1'b0}}, {1{1'b1}}, { 4{1'b0}} };
         4'h5: mem_be1  <= { {10{1'b0}}, {1{1'b1}}, { 5{1'b0}} };
         4'h6: mem_be1  <= { { 9{1'b0}}, {1{1'b1}}, { 6{1'b0}} };
         4'h7: mem_be1  <= { { 8{1'b0}}, {1{1'b1}}, { 7{1'b0}} };
         4'h8: mem_be1  <= { { 7{1'b0}}, {1{1'b1}}, { 8{1'b0}} };
         4'h9: mem_be1  <= { { 6{1'b0}}, {1{1'b1}}, { 9{1'b0}} };
         4'ha: mem_be1  <= { { 5{1'b0}}, {1{1'b1}}, {10{1'b0}} };
         4'hb: mem_be1  <= { { 4{1'b0}}, {1{1'b1}}, {11{1'b0}} };
         4'hc: mem_be1  <= { { 3{1'b0}}, {1{1'b1}}, {12{1'b0}} };
         4'hd: mem_be1  <= { { 2{1'b0}}, {1{1'b1}}, {13{1'b0}} };
         4'he: mem_be1  <= { { 1{1'b0}}, {1{1'b1}}, {14{1'b0}} };
         4'hf: mem_be1  <= {             {1{1'b1}}, {15{1'b0}} };
      endcase // case ( addr[3:0] )
   end

   // for P_ASIZE_2
   always @*
   begin
      case ( addr[3:1] )
         3'h0: mem_be2  <= { {14{1'b0}}, {2{1'b1}}             };
         3'h1: mem_be2  <= { {12{1'b0}}, {2{1'b1}}, { 2{1'b0}} };
         3'h2: mem_be2  <= { {10{1'b0}}, {2{1'b1}}, { 4{1'b0}} };
         3'h3: mem_be2  <= { { 8{1'b0}}, {2{1'b1}}, { 6{1'b0}} };
         3'h4: mem_be2  <= { { 6{1'b0}}, {2{1'b1}}, { 8{1'b0}} };
         3'h5: mem_be2  <= { { 4{1'b0}}, {2{1'b1}}, {10{1'b0}} };
         3'h6: mem_be2  <= { { 2{1'b0}}, {2{1'b1}}, {12{1'b0}} };
         3'h7: mem_be2  <= {             {2{1'b1}}, {14{1'b0}} };
      endcase // case ( addr[3:1] )
   end

   // for P_ASIZE_4
   always @*
   begin
      case ( addr[3:2] )
         2'h0: mem_be4  <= { {12{1'b0}}, {4{1'b1}}             };
         2'h1: mem_be4  <= { { 8{1'b0}}, {4{1'b1}}, { 4{1'b0}} };
         2'h2: mem_be4  <= { { 4{1'b0}}, {4{1'b1}}, { 8{1'b0}} };
         2'h3: mem_be4  <= {             {4{1'b1}}, {12{1'b0}} };
      endcase // case ( addr[3:2] )
   end

   // for P_ASIZE_8
   always @*
   begin
      case ( addr[3] )
         1'h0: mem_be8  <= { { 8{1'b0}}, {8{1'b1}}             };
         1'h1: mem_be8  <= {             {8{1'b1}}, { 8{1'b0}} };
      endcase // case ( addr[3] )
   end

   genvar   i;
   generate
      for ( i = 0; i < P_MBW; i = i + 1 ) begin: gen_d_loop
         assign   mem_d[i*9+:9]           =  { wstrbr_m[i],
                                               wdatar[i*8+:8] };
         assign   { wbe[i], wd[i*8+:8] }  =  mem_en[mem_ar] ?
                                             mem_q[i*9+:9] : {9{1'b0}};
      end
   endgenerate

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         wakr  <= 1'b1;
         dreqr <= 1'b0;
      end
      else begin
         wakr  <= ARB_WAK;
         dreqr <= DREQ;
      end

   //===================================================================
   // instances
   //===================================================================

   DDR_A2M_FIFO
      #(
         .P_WIDTH    ( P_FIFOW   ),
         .P_DEPTH    ( P_FIFOD   )//,
      )
      awfifo
      (
         .CLK        ( CLK       ),
         .ZRESET     ( ZRESET    ),
         .CLR        ( fclr      ),
         .WE         ( fwe       ),
         .D          ( fdi       ),
         .RE         ( fre       ),
         .Q          ( fdo       ),
         .EMPTY      ( fempty    ),
         .FULL       ( ffull     )//,
      );

`ifdef USE_SRAM_MODEL
   sram_1rwb
      #(
         .AW         ( P_MAW        ),
         .DW         ( P_MDW        ),
         .BSIZE      ( 9            )//,
      )
      wdmem
      (
         .clk        ( CLK          ),
         .we_n       ( ~mem_we      ),
         .re_n       ( ~mem_re      ),
         .a          ( mem_a        ),
         .be_n       ( ~mem_be      ),
         .d          ( mem_d        ),
         .q          ( mem_q        )//,
      );
`else
   RAM1P1RW144B32W_B9W_WRAP
      wdmem
      (
         .Q          ( mem_q                 ),
         .CLK        ( CLK                   ),
         .CEN        ( ~( mem_we | mem_re )  ),
         .WEN        ( ~mem_be               ),
         .GWEN       ( ~mem_we               ),
         .A          ( { 1'b0, mem_a }       ),
         .D          ( mem_d                 ),
         .SLP        ( SLP                   )//,
      );
`endif // `ifdef USE_SRAM_MODEL

   DDR_A2M_ADDRMASK
      addrmask
      (
         .AXSIZE     ( asize_in     ),   // i
         .MASK       ( addr_mask    )//, // o
      );

   DDR_A2M_WRAPMASK
      wrapmask
      (
         .AXLEN      ( alen         ),   // i
         .AXSIZE     ( asize        ),   // i
         .MASK       ( wrap_mask    )//, // o
      );

   DDR_A2M_SLVERR
      slverr
      (
       //.AXLEN      ( alen_in      ),   // i
         .AXSIZE     ( asize_in     ),   // i
         .AXBURST    ( aburst_in    ),   // i
         .SLVERR     ( req_error    )//, // o
      );


endmodule
// end of file
