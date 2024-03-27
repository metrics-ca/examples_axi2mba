//----------------------------------------------------------------------
/**
 * @file DDR_A2M_RDCTL.v
 * @brief Defines AXI to MBA bridge: Read data control module.
 */
//----------------------------------------------------------------------

module DDR_A2M_RDCTL
   (
      CLK         ,   // i
      ZRESET      ,   // i
      SLP         ,   // i
      DQTYPE      ,   // i
      ARID        ,   // i
      ARADDR      ,   // i
      ARLEN       ,   // i
      ARSIZE      ,   // i
      ARBURST     ,   // i
      ARLOCK      ,   // i
      RID         ,   // o
      RDATA       ,   // o
      RRESP       ,   // o
      RLAST       ,   // o
      RVALID      ,   // o
      RREADY      ,   // i
      ARB_RAK     ,   // i
      ARB_WDT     ,   // i
      DADR        ,   // i
      DREQ        ,   // i
      DEND        ,   // o
      DREADY      ,   // o
      AVALID      ,   // i
      AMASK       ,   // i
      REQERR      //, // i
   );

   //===================================================================
   // parameters
   //===================================================================

   parameter      P_IW        =  8;
   parameter      P_DW        =  128;
   localparam     P_AW        =  8;
   localparam     P_MAW       =  4;
   localparam     P_MDW       =  P_DW;

   `include       "DDR_A2M_AXI_PARAM.vh"

   //===================================================================
   // ports
   //===================================================================

   // System
   input                   CLK         ;
   input                   ZRESET      ;
   input                   SLP         ;
   input                   DQTYPE      ; // DDR DQ select (0=x16 1=x32)
   // AXI Read address channel
   input    [P_IW-1:0]     ARID        ;
   input    [P_AW-1:0]     ARADDR      ;
   input    [  7:0]        ARLEN       ;
   input    [  2:0]        ARSIZE      ;
   input    [  1:0]        ARBURST     ;
   input                   ARLOCK      ; // AXI3: [1:0]
   // AXI Read data channel
   output   [P_IW-1:0]     RID         ;
   output   [P_DW-1:0]     RDATA       ;
   output   [  1:0]        RRESP       ;
   output                  RLAST       ;
   output                  RVALID      ;
   input                   RREADY      ;
   // MBA
   input                   ARB_RAK     ; // (Act-L)
   input    [P_DW-1:0]     ARB_WDT     ;
   // Data control
   input    [  5:2]        DADR        ;
   input                   DREQ        ;
   output                  DEND        ;
   output                  DREADY      ;
   input                   AVALID      ;
   input    [  7:0]        AMASK       ;
   input                   REQERR      ;

   //===================================================================
   // output registers
   //===================================================================

   reg      [P_IW-1:0]     RID         ;
   reg      [P_DW-1:0]     RDATA       ;
   reg      [  1:0]        RRESP       ;
   reg                     RLAST       ;
   reg                     RVALID      ;
   reg                     DEND        ;
   reg                     DREADY      ;

   //===================================================================
   // signals
   //===================================================================

   wire                    rvalid_in   ;
   wire                    rupdate     ;
   wire     [P_DW-1:0]     rdata_in    ;
   wire                    rlast_in    ;

   reg      [  7:0]        rcnt        ;
   reg                     buf_vld     ;
   reg      [P_DW-1:0]     buf_rdata   ;
   wire                    buf_update  ;

   wire                    axi_last    ;
   wire                    axi_empty   ;
   wire                    rak_done    ;
   wire                    dt_done     ;

   reg                     err_st      ;
   reg                     dt_st       ;
   reg                     dt_en       ;
   reg                     dt_sel      ;
   reg      [P_DW-1:0]     rdatar      ;

 //reg      [P_IW-1:0]     aid         ;
   reg      [P_AW-1:0]     aaddr       ;
   reg      [  7:0]        alen        ;
   reg      [  2:0]        asize       ;
   reg      [  1:0]        aburst      ;
 //reg                     alock       ;
   reg                     avldr       ;
   wire     [P_AW-1:0]     amask_m     ;
   wire     [P_AW-1:0]     aaddr_m     ;

   wire     [P_AW  :0]     addr_next0  ;
   wire     [P_AW  :0]     addr_next   ;
   reg      [P_AW-1:0]     addr        ;
   reg                     addr_end    ;
   reg      [  4:0]        addr_inc    ; // combinational

   wire                    mem_we      ; // Act-H
   reg      [P_MAW-1:0]    mem_wa      ;
   wire                    mem_wa_clr  ;
   wire     [P_MAW-1:0]    mem_wa_init ;
   wire     [P_MAW-1:0]    mem_wa_next ;

   wire                    mem_re_mask ;
   wire                    mem_re_full ;

   wire                    mem_re_in   ;
   wire                    mem_re      ; // Act-H
   reg                     mem_re0     ;
   reg                     mem_rv      ;
   reg      [  8:0]        mem_re_cnt  ;

   reg      [P_MAW-1:0]    mem_ra      ;
   wire                    mem_ra_clr  ;
   wire     [P_MAW-1:0]    mem_ra_init ;
   wire     [P_MAW-1:0]    mem_ra_next ;

   wire     [P_MAW-1:0]    mem_a       ;
   wire     [P_MDW-1:0]    mem_d       ;
   wire     [P_MDW-1:0]    mem_q       ;

   reg                     rakr        ;

   //===================================================================
   // logic
   //===================================================================

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         RID      <= {P_IW{1'b0}};
         RDATA    <= {P_DW{1'b0}};
         RRESP    <= P_ARESP_OKAY;
         RLAST    <= 1'b0;
      end
      else if ( rupdate ) begin
         RID      <= ARID;
         RDATA    <= rdata_in;
         RRESP    <= REQERR ? P_ARESP_SLVERR : P_ARESP_OKAY;
         RLAST    <= rlast_in;
      end

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         RVALID   <= 1'b0;
      else if ( ~RVALID &  rvalid_in )
         RVALID   <= 1'b1;
      else if (  RREADY & ~rvalid_in )
         RVALID   <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         DEND     <= 1'b0;
      else
         DEND     <= dt_done;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         DREADY   <= 1'b0;
      else if ( AVALID | dt_done )
         DREADY   <= 1'b1;
      else if ( DREQ )
         DREADY   <= 1'b0;

   //-----------------------------------------------------------

   assign   rvalid_in   =  mem_rv | buf_vld | err_st;
   assign   rupdate     =  rvalid_in & ( ~RVALID | RVALID & RREADY );
   assign   rdata_in    =  REQERR ? {P_DW{1'b0}} : buf_vld ? buf_rdata : mem_q;
   assign   rlast_in    =  ( rcnt == alen );

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         rcnt   <= {8{1'b0}};
      else if ( AVALID )
         rcnt   <= {8{1'b0}};
      else if ( rupdate )
         rcnt  <= rcnt + 1'b1;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         buf_vld     <= 1'b0;
      else if ( buf_update )
         buf_vld     <= 1'b1;
      else if ( RVALID & RREADY )
         buf_vld     <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         buf_rdata   <= {P_DW{1'b0}};
      else if ( buf_update )
         buf_rdata   <= mem_q;

   assign   buf_update  =  ( RVALID & ~RREADY & mem_rv & ~buf_vld ) |
                           ( RVALID &  RREADY & mem_rv &  buf_vld );

   assign   axi_last    =  RLAST & RVALID & RREADY ;
   assign   axi_empty   =  ( aburst == P_ABURST_INCR ) &
                           addr_end & ~( rlast_in & rupdate ) &
                           RVALID & RREADY;
   assign   rak_done    =  ~dt_st & ARB_RAK & ~rakr;
   assign   dt_done     =   dt_st & ( axi_last | axi_empty );

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         err_st   <= 1'b0;
      else if ( DREQ & REQERR )
         err_st   <= 1'b1;
      else if ( rlast_in & rupdate )
         err_st   <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         dt_st    <= 1'b0;
      else if ( rak_done | ( avldr & REQERR ) )
         dt_st    <= 1'b1;
      else if ( dt_done )
         dt_st    <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         dt_en    <= 1'b0;
      else
         dt_en    <= ~ARB_RAK;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         dt_sel   <= 1'b0;
      else if ( mem_wa_clr )
         dt_sel   <= 1'b0;
      else if ( ~ARB_RAK )
         dt_sel   <= ~dt_sel;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         rdatar   <= {P_DW{1'b0}};
      else if ( ~ARB_RAK ) begin
         rdatar[ 0+:32] <= DQTYPE ? ARB_WDT[ 0+:32] : ~dt_sel ? ARB_WDT[ 0+:32] : rdatar[ 0+:32];
         rdatar[32+:32] <= DQTYPE ? ARB_WDT[32+:32] : ~dt_sel ? ARB_WDT[64+:32] : rdatar[32+:32];
         rdatar[64+:32] <= DQTYPE ? ARB_WDT[64+:32] :  dt_sel ? ARB_WDT[ 0+:32] : rdatar[64+:32];
         rdatar[96+:32] <= DQTYPE ? ARB_WDT[96+:32] :  dt_sel ? ARB_WDT[64+:32] : rdatar[96+:32];
      end

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
       //aid      <= {P_IW{1'b0}};
         aaddr    <= {P_AW{1'b0}};
         alen     <= {   8{1'b0}};
         asize    <= {   3{1'b0}};
         aburst   <= {   2{1'b0}};
       //alock    <= {   1{1'b0}};
      end
      else if ( AVALID ) begin
       //aid      <= ARID     ;
         aaddr    <= ARADDR   ;
         alen     <= ARLEN    ;
         asize    <= ARSIZE   ;
         aburst   <= ARBURST  ;
       //alock    <= ARLOCK   ;
      end

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         avldr    <= 1'b0;
      else
         avldr    <= AVALID;

   assign   amask_m  =  aburst == P_ABURST_INCR ? AMASK : {P_AW{1'b1}};
   assign   aaddr_m  =  aaddr[P_AW-1:0] & amask_m;

   assign   addr_next0  =  { 1'b0, addr } + addr_inc;
   assign   addr_next   =  aburst == P_ABURST_INCR ?  addr_next0 :
                           { 1'b0, addr & AMASK } |
                           ( addr_next0 & { 1'b0, ~AMASK } );

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         addr     <= {P_AW{1'b0}};
         addr_end <= 1'b0;
      end
      else if ( mem_ra_clr ) begin
         addr     <= aaddr_m;
         addr_end <= 1'b0;
      end
      else if ( mem_re ) begin
         addr     <= addr_next[P_AW-1:0];
         addr_end <= addr_next[P_AW];
      end
      else if ( dt_done )
         addr_end <= 1'b0;

   always @*
      case ( asize )
         P_ASIZE_2   :  addr_inc <= 5'd2  ;
         P_ASIZE_4   :  addr_inc <= 5'd4  ;
         P_ASIZE_8   :  addr_inc <= 5'd8  ;
         P_ASIZE_16  :  addr_inc <= 5'd16 ;
         default     :  addr_inc <= 5'd1  ;
      endcase // case ( asize )

   assign   mem_we      =  dt_en & ( DQTYPE | ~dt_sel );
   assign   mem_wa_clr  =  DREQ;
   assign   mem_wa_init =  DADR;
   assign   mem_wa_next =  mem_wa + 1'b1;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         mem_wa   <= {P_MAW{1'b0}};
      else if ( mem_wa_clr )
         mem_wa   <= mem_wa_init;
      else if ( mem_we )
         mem_wa   <= mem_wa_next;

   assign   mem_re_mask =  addr_end | ( mem_re_cnt == { 1'b0, alen } ) | REQERR;
   assign   mem_re_full =  RVALID & ~RREADY;

   assign   mem_re_in   =  rak_done | ( dt_st & ~dt_done & ~mem_re_mask & ~mem_re_full );
   assign   mem_re      =  mem_re0 & ~mem_re_mask & ~mem_re_full;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         mem_re0  <= 1'b0;
         mem_rv   <= 1'b0;
      end
      else begin
         mem_re0  <= mem_re_in;
         mem_rv   <= mem_re;
      end

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         mem_re_cnt  <= {9{1'b1}};
      else if ( AVALID )
         mem_re_cnt  <= {9{1'b1}};
      else if ( mem_re )
         mem_re_cnt  <= mem_re_cnt + 1'b1;

   assign   mem_ra_clr  =  avldr;
   assign   mem_ra_init =  aaddr_m[4+:P_MAW];
   assign   mem_ra_next =  addr_next[4+:P_MAW];

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         mem_ra   <= {P_MAW{1'b0}};
      else if ( mem_ra_clr )
         mem_ra   <= mem_ra_init;
      else if ( mem_re )
         mem_ra   <= mem_ra_next;

   assign   mem_a    =  mem_we ? mem_wa : mem_ra;
   assign   mem_d    =  rdatar;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         rakr  <= 1'b1;
      else
         rakr  <= ARB_RAK;

   //===================================================================
   // instances
   //===================================================================

`ifdef USE_SRAM_MODEL
   sram_1rw
      #(
         .AW         ( P_MAW        ),
         .DW         ( P_MDW        )//,
      )
      rdmem
      (
         .clk        ( CLK          ),
         .we_n       ( ~mem_we      ),
         .re_n       ( ~mem_re      ),
         .a          ( mem_a        ),
         .d          ( mem_d        ),
         .q          ( mem_q        )//,
      );
`else
   RAM1P1RW128B32W_WRAP
      rdmem
      (
         .Q          ( mem_q                 ),
         .CLK        ( CLK                   ),
         .CEN        ( ~( mem_we | mem_re )  ),
         .WEN        ( ~mem_we               ),
         .A          ( { 1'b0, mem_a }       ),
         .D          ( mem_d                 ),
         .SLP        ( SLP                   )//,
      );
`endif // `ifdef USE_SRAM_MODEL

endmodule
// end of file
