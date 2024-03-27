//----------------------------------------------------------------------
/**
 * @file tb_top.v
 * @brief Defines Testbench top module.
 */
//----------------------------------------------------------------------

`ifndef  DQ_WIDTH
`define  DQ_WIDTH    32
`endif // `ifndef DQ_WIDTH

module tb_top;

   //===================================================================
   // parameters
   //===================================================================

   parameter               TB_T           =   10      ;
   parameter               SIMW           =   24      ;

   //===================================================================
   // signals
   //===================================================================

   reg                     tbclk          ;
   reg                     tbarst_n       ;
   reg                     tbsrst_n       ;

   event                   sim_end        ;
   reg      [SIMW-1:0]     sim_cntr       ;
   reg                     sim_dump       ;
   integer                 sim_errc       ;
   event                   sim_errt       ;

   wire                    cmd_done       ;
   wire                    cmd_err        ;
   wire                    cmd_dump       ;

   wire                    clk            ;
   wire                    rst_n          ;

   //-------------------------------------------------------------------
   // DUT
   //-------------------------------------------------------------------

   localparam     P_WIW       =  8;
   localparam     P_RIW       =  8;
   localparam     P_AW        =  40;
   localparam     P_DW        =  128;
   localparam     P_SW        =  P_DW / 8;

   // System
   wire                    CLK         ; // i
   wire                    ZRESET      ; // i
   wire                    DQTYPE      ; // i
   wire                    SLP         ; // i
   // AXI Write address channel
   wire     [P_WIW-1:0]    AWID        ; // i
   wire     [P_AW-1:0]     AWADDR      ; // i
   wire     [  7:0]        AWLEN       ; // i
   wire     [  2:0]        AWSIZE      ; // i
   wire     [  1:0]        AWBURST     ; // i
   wire                    AWLOCK      ; // i
 //wire     [  3:0]        AWCACHE     ; // i
 //wire     [  3:0]        AWPROT      ; // i
   wire                    AWVALID     ; // i
   wire                    AWREADY     ; // o
   // AXI Write data channel
 //wire     [P_WIW-1:0]    WID         ; // i
   wire     [P_DW-1:0]     WDATA       ; // i
   wire     [P_SW-1:0]     WSTRB       ; // i
   wire                    WLAST       ; // i
   wire                    WVALID      ; // i
   wire                    WREADY      ; // o
   // AXI Write response channel
   wire     [P_WIW-1:0]    BID         ; // o
   wire     [  1:0]        BRESP       ; // o
   wire                    BVALID      ; // o
   wire                    BREADY      ; // i
   // AXI Read address channel
   wire     [P_RIW-1:0]    ARID        ; // i
   wire     [P_AW-1:0]     ARADDR      ; // i
   wire     [  7:0]        ARLEN       ; // i
   wire     [  2:0]        ARSIZE      ; // i
   wire     [  1:0]        ARBURST     ; // i
   wire                    ARLOCK      ; // i
 //wire     [  3:0]        ARCACHE     ; // i
 //wire     [  2:0]        ARPROT      ; // i
   wire                    ARVALID     ; // i
   wire                    ARREADY     ; // o
   // AXI Read data channel
   wire     [P_RIW-1:0]    RID         ; // o
   wire     [P_DW-1:0]     RDATA       ; // o
   wire     [  1:0]        RRESP       ; // o
   wire                    RLAST       ; // o
   wire                    RVALID      ; // o
   wire                    RREADY      ; // i
   // MBA I/F
   wire                    ARB_REQ     ; // o
   wire                    ARB_REL     ; // i
   wire                    ARB_NEL     ; // i
   wire                    ARB_RZW     ; // o
   wire     [ 29:2]        ARB_ADR     ; // o
   wire     [  9:2]        ARB_BST     ; // o
   wire                    ARB_WAK     ; // i
   wire     [P_DW-1:0]     ARB_RDT     ; // o
   wire     [P_SW-1:0]     ARB_BEN     ; // o
   wire                    ARB_RAK     ; // i
   wire     [P_DW-1:0]     ARB_WDT     ; // i

   //===================================================================
   // logic
   //===================================================================

   initial begin
      tbclk    =  1'b0;
      tbarst_n =  1'b0;
      repeat ( 5 ) @( negedge tbclk );
      tbarst_n =  1'b1;
   end

   always #( TB_T / 2.0 )  tbclk    <= ~tbclk;
   always @( posedge tbclk or negedge tbarst_n )
      if ( ! tbarst_n )    tbsrst_n <= 1'b0;
      else                 tbsrst_n <= 1'b1;

   initial begin
      sim_errc =  0;
      sim_dump =  0;
`ifdef VCS // VCS implicitly defines
      if ( $test$plusargs( "vpdon" ) ) $vcdpluson; // VCD+
`endif // `ifdef VCS
      @( sim_end );
      sim_dump =  1;
      #1;
      if ( sim_errc > 0 )
         $display( "Detect %0d ERROR(s)", sim_errc );
      $finish;
   end

   always @( sim_errt )
      sim_errc = sim_errc + 1;

   always @( posedge tbclk or negedge tbarst_n )
      if ( ! tbarst_n )
         sim_cntr  <= {SIMW{1'b0}};
      else if ( &sim_cntr )
         sim_cntr  <= sim_cntr;
      else
         sim_cntr  <= sim_cntr + 1'b1;

   always @( posedge cmd_err )
      ->sim_errt;

   always @( posedge tbclk )
   begin
      if ( &sim_cntr ) ->sim_end;
      if ( ( sim_cntr % 10000 ) == 0 & sim_cntr > 0 )
         $display( "@%0t", $time );
   end

   assign   rst_n    =  tbsrst_n ;
   assign   clk      =  tbclk    ;

   always @( posedge tbclk )
   begin
      if ( sim_cntr > 100000 ) ->sim_end;
   end

   //-------------------------------------------------------------------

   assign   SLP      =  1'b0;

   //===================================================================
   // instances
   //===================================================================

   axi_mstr
      axi_mstr
      (
         .ACLK       ( clk       ),   // i
         .ARESETN    ( rst_n     ),   // i
         .AWID       ( AWID      ),   // o
         .AWADDR     ( AWADDR    ),   // o
         .AWLEN      ( AWLEN     ),   // o
         .AWSIZE     ( AWSIZE    ),   // o
         .AWBURST    ( AWBURST   ),   // o
         .AWLOCK     ( AWLOCK    ),   // o
       //.AWCACHE    ( AWCACHE   ),   // o
       //.AWPROT     ( AWPROT    ),   // o
         .AWVALID    ( AWVALID   ),   // o
         .AWREADY    ( AWREADY   ),   // i
       //.WID        ( WID       ),   // o
         .WDATA      ( WDATA     ),   // o
         .WSTRB      ( WSTRB     ),   // o
         .WLAST      ( WLAST     ),   // o
         .WVALID     ( WVALID    ),   // o
         .WREADY     ( WREADY    ),   // i
         .BID        ( BID       ),   // i
         .BRESP      ( BRESP     ),   // i
         .BVALID     ( BVALID    ),   // i
         .BREADY     ( BREADY    ),   // o
         .ARID       ( ARID      ),   // o
         .ARADDR     ( ARADDR    ),   // o
         .ARLEN      ( ARLEN     ),   // o
         .ARSIZE     ( ARSIZE    ),   // o
         .ARBURST    ( ARBURST   ),   // o
         .ARLOCK     ( ARLOCK    ),   // o
       //.ARCACHE    ( ARCACHE   ),   // o
       //.ARPROT     ( ARPROT    ),   // o
         .ARVALID    ( ARVALID   ),   // o
         .ARREADY    ( ARREADY   ),   // i
         .RID        ( RID       ),   // i
         .RDATA      ( RDATA     ),   // i
         .RRESP      ( RRESP     ),   // i
         .RLAST      ( RLAST     ),   // i
         .RVALID     ( RVALID    ),   // i
         .RREADY     ( RREADY    )//, // o
      );

   mba_slv
      #(
         .DQW        ( `DQ_WIDTH )//,
      )
      mba_slv
      (
         .CLK        ( clk       ),   // i
         .ZRESET     ( rst_n     ),   // i
         .DQTYPE     (           ),   // i
         .DQTYPE_O   ( DQTYPE    ),   // o
         .ARB_REQ    ( ARB_REQ   ),   // i
         .ARB_REL    ( ARB_REL   ),   // o
         .ARB_NEL    ( ARB_NEL   ),   // o
         .ARB_RZW    ( ARB_RZW   ),   // i
         .ARB_ADR    ( ARB_ADR   ),   // i
         .ARB_BST    ( ARB_BST   ),   // i
         .ARB_WAK    ( ARB_WAK   ),   // o
         .ARB_RDT    ( ARB_RDT   ),   // i
         .ARB_BEN    ( ARB_BEN   ),   // i
         .ARB_RAK    ( ARB_RAK   ),   // o
         .ARB_WDT    ( ARB_WDT   )//, // o
      );

/*
   mba_mstr
      mba_mstr
      (
         .CLK        ( clk       ),   // i
         .ZRESET     ( rst_n     ),   // i
         .DQTYPE     ( DQTYPE    ),   // i
         .ARB_REQ    ( ARB_REQ   ),   // o
         .ARB_REL    ( ARB_REL   ),   // i
         .ARB_NEL    ( ARB_NEL   ),   // i
         .ARB_RZW    ( ARB_RZW   ),   // o
         .ARB_ADR    ( ARB_ADR   ),   // o
         .ARB_BST    ( ARB_BST   ),   // o
         .ARB_WAK    ( ARB_WAK   ),   // i
         .ARB_RDT    ( ARB_RDT   ),   // o
         .ARB_BEN    ( ARB_BEN   ),   // o
         .ARB_RAK    ( ARB_RAK   ),   // i
         .ARB_WDT    ( ARB_WDT   )//, // i
      );
*/

   //-------------------------------------------------------------------
   // DUT
   //-------------------------------------------------------------------

   DDR_AXI2MBA
      axi2mba
      (
         .CLK        ( clk       ),   // i
         .ZRESET     ( rst_n     ),   // i
         .DQTYPE     ( DQTYPE    ),   // i
         .SLP        ( SLP       ),   // i
         .AWID       ( AWID      ),   // i
         .AWADDR     ( AWADDR    ),   // i
         .AWLEN      ( AWLEN     ),   // i
         .AWSIZE     ( AWSIZE    ),   // i
         .AWBURST    ( AWBURST   ),   // i
         .AWLOCK     ( AWLOCK    ),   // i
       //.AWCACHE    ( AWCACHE   ),   // i
       //.AWPROT     ( AWPROT    ),   // i
         .AWVALID    ( AWVALID   ),   // i
         .AWREADY    ( AWREADY   ),   // o
       //.WID        ( WID       ),   // i
         .WDATA      ( WDATA     ),   // i
         .WSTRB      ( WSTRB     ),   // i
         .WLAST      ( WLAST     ),   // i
         .WVALID     ( WVALID    ),   // i
         .WREADY     ( WREADY    ),   // o
         .BID        ( BID       ),   // o
         .BRESP      ( BRESP     ),   // o
         .BVALID     ( BVALID    ),   // o
         .BREADY     ( BREADY    ),   // i
         .ARID       ( ARID      ),   // i
         .ARADDR     ( ARADDR    ),   // i
         .ARLEN      ( ARLEN     ),   // i
         .ARSIZE     ( ARSIZE    ),   // i
         .ARBURST    ( ARBURST   ),   // i
         .ARLOCK     ( ARLOCK    ),   // i
       //.ARCACHE    ( ARCACHE   ),   // i
       //.ARPROT     ( ARPROT    ),   // i
         .ARVALID    ( ARVALID   ),   // i
         .ARREADY    ( ARREADY   ),   // o
         .RID        ( RID       ),   // o
         .RDATA      ( RDATA     ),   // o
         .RRESP      ( RRESP     ),   // o
         .RLAST      ( RLAST     ),   // o
         .RVALID     ( RVALID    ),   // o
         .RREADY     ( RREADY    ),   // i
         .ARB_REQ    ( ARB_REQ   ),   // o
         .ARB_REL    ( ARB_REL   ),   // i
         .ARB_NEL    ( ARB_NEL   ),   // i
         .ARB_RZW    ( ARB_RZW   ),   // o
         .ARB_ADR    ( ARB_ADR   ),   // o
         .ARB_BST    ( ARB_BST   ),   // o
         .ARB_WAK    ( ARB_WAK   ),   // i
         .ARB_RDT    ( ARB_RDT   ),   // o
         .ARB_BEN    ( ARB_BEN   ),   // o
         .ARB_RAK    ( ARB_RAK   ),   // i
         .ARB_WDT    ( ARB_WDT   )//, // i
      );

   //===================================================================
   // load data
   //===================================================================

endmodule
// end of file
