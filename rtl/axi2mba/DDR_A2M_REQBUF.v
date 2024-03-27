//----------------------------------------------------------------------
/**
 * @file DDR_A2M_REQBUF.v
 * @brief Defines AXI2MBA bridge: Request buffer module.
 */
//----------------------------------------------------------------------

module DDR_A2M_REQBUF
   (
      CLK         ,   // i
      ZRESET      ,   // i
      ADDRTYPE    ,   // i
      AWID        ,   // i
      AWADDR      ,   // i
      AWLEN       ,   // i
      AWSIZE      ,   // i
      AWBURST     ,   // i
      AWLOCK      ,   // i
    //AWCACHE     ,   // i
    //AWPROT      ,   // i
      AWVALID     ,   // i
      AWREADY     ,   // o
      ARID        ,   // i
      ARADDR      ,   // i
      ARLEN       ,   // i
      ARSIZE      ,   // i
      ARBURST     ,   // i
      ARLOCK      ,   // i
    //ARCACHE     ,   // i
    //ARPROT      ,   // i
      ARVALID     ,   // i
      ARREADY     ,   // o
      RE          ,   // i
      EMPTY       ,   // o
      AXID        ,   // o
      AXADDR      ,   // o
      AXLEN       ,   // o
      AXSIZE      ,   // o
      AXBURST     ,   // o
      AXLOCK      ,   // o
      AXDIR       //, // o
   );

   //===================================================================
   // parameters
   //===================================================================

   parameter      P_FIFOD     =  3;
   parameter      P_WIW       =  8;
   parameter      P_RIW       =  8;
   parameter      P_AW        =  40;
   localparam     P_IW        =  P_WIW < P_RIW ? P_RIW : P_WIW;
   localparam     P_FIFOW     =  P_IW + P_AW + 8 + 3 + 2 + 1 + 1;

   //===================================================================
   // ports
   //===================================================================

   // System
   input                   CLK         ;
   input                   ZRESET      ;
   input                   ADDRTYPE    ;
   // AXI Write address channel
   input    [P_WIW-1:0]    AWID        ; // Cortex-A7: AWIDM[4:0]
   input    [P_AW-1:0]     AWADDR      ;
   input    [  7:0]        AWLEN       ;
   input    [  2:0]        AWSIZE      ;
   input    [  1:0]        AWBURST     ;
   input                   AWLOCK      ; // AXI3: [1:0]
 //input    [  3:0]        AWCACHE     ;
 //input    [  3:0]        AWPROT      ;
   input                   AWVALID     ;
   output                  AWREADY     ;
   // AXI Read address channel
   input    [P_RIW-1:0]    ARID        ; // Cortex-A7: ARIDM[5:0]
   input    [P_AW-1:0]     ARADDR      ;
   input    [  7:0]        ARLEN       ;
   input    [  2:0]        ARSIZE      ;
   input    [  1:0]        ARBURST     ;
   input                   ARLOCK      ; // AXI3: [1:0]
 //input    [  3:0]        ARCACHE     ;
 //input    [  2:0]        ARPROT      ;
   input                   ARVALID     ;
   output                  ARREADY     ;
   // AXI Request
   input                   RE          ;
   output                  EMPTY       ;
   output   [P_IW-1:0]     AXID        ;
   output   [P_AW-1:0]     AXADDR      ;
   output   [  7:0]        AXLEN       ;
   output   [  2:0]        AXSIZE      ;
   output   [  1:0]        AXBURST     ;
   output                  AXLOCK      ;
   output                  AXDIR       ;

   //===================================================================
   // output registers
   //===================================================================

   reg                     AWREADY     ;
   reg                     ARREADY     ;

   //===================================================================
   // signals
   //===================================================================

   reg      [P_WIW-1:0]    awidr       ;
   reg      [P_AW-1:0]     awaddrr     ;
   reg      [  7:0]        awlenr      ;
   reg      [  2:0]        awsizer     ;
   reg      [  1:0]        awburstr    ;
   reg                     awlockr     ;
 //reg      [  3:0]        awcacher    ;
 //reg      [  3:0]        awprotr     ;

   reg      [P_RIW-1:0]    aridr       ;
   reg      [P_AW-1:0]     araddrr     ;
   reg      [  7:0]        arlenr      ;
   reg      [  2:0]        arsizer     ;
   reg      [  1:0]        arburstr    ;
   reg                     arlockr     ;
 //reg      [  3:0]        arcacher    ;
 //reg      [  2:0]        arprotr     ;

   wire     [P_AW-1:0]     awaddrr_m   ;
   wire     [P_AW-1:0]     araddrr_m   ;

   wire     [P_IW-1:0]     awidr_m     ;
   wire     [P_IW-1:0]     aridr_m     ;

   reg                     awrite      ;
   reg                     aread       ;
   reg                     awriter     ;
   reg                     areadr      ;

   wire                    fclr        ;
   reg                     fwe         ;
   wire                    fwe_in      ;
   wire                    fre         ;
   wire     [P_FIFOW-1:0]  fdi         ;
   wire     [P_FIFOW-1:0]  fdo         ;
   wire                    fempty      ;
   wire                    ffull       ;

   //===================================================================
   // logic
   //===================================================================

   assign   EMPTY =  fempty;
   assign   { AXID, AXADDR, AXLEN, AXSIZE, AXBURST, AXLOCK, AXDIR } = fdo;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         AWREADY  <= 1'b0;
      else if ( AWVALID & AWREADY )
         AWREADY  <= 1'b0;
      else if ( ~awrite & ~aread & ~ffull )
         AWREADY  <= 1'b1;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         ARREADY  <= 1'b0;
      else if ( ARVALID & ARREADY )
         ARREADY  <= 1'b0;
      else if ( ~awrite & ~aread & ~ffull )
         ARREADY  <= 1'b1;

   //-----------------------------------------------------------

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         awidr    <= {P_WIW{1'b0}};
         awaddrr  <= {P_AW{1'b0}};
         awlenr   <= { 8{1'b0}};
         awsizer  <= { 3{1'b0}};
         awburstr <= { 2{1'b0}};
         awlockr  <= { 1{1'b0}};
      end
      else if ( AWVALID & AWREADY ) begin
         awidr    <= AWID     ;
         awaddrr  <= AWADDR   ;
         awlenr   <= AWLEN    ;
         awsizer  <= AWSIZE   ;
         awburstr <= AWBURST  ;
         awlockr  <= AWLOCK   ;
      end

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         aridr    <= {P_RIW{1'b0}};
         araddrr  <= {P_AW{1'b0}};
         arlenr   <= { 8{1'b0}};
         arsizer  <= { 3{1'b0}};
         arburstr <= { 2{1'b0}};
         arlockr  <= { 1{1'b0}};
      end
      else if ( ARVALID & ARREADY ) begin
         aridr    <= ARID     ;
         araddrr  <= ARADDR   ;
         arlenr   <= ARLEN    ;
         arsizer  <= ARSIZE   ;
         arburstr <= ARBURST  ;
         arlockr  <= ARLOCK   ;
      end

   assign   awaddrr_m[P_AW-1:30] =  ADDRTYPE ?
                                    awaddrr[P_AW-1:30] - 1'b1 :
                                    awaddrr[P_AW-1:30];
   assign   araddrr_m[P_AW-1:30] =  ADDRTYPE ?
                                    araddrr[P_AW-1:30] - 1'b1 :
                                    araddrr[P_AW-1:30];
   assign   awaddrr_m[29:0]      =  awaddrr[29:0];
   assign   araddrr_m[29:0]      =  araddrr[29:0];

   assign   awidr_m  =  {P_IW{1'b0}} | awidr;
   assign   aridr_m  =  {P_IW{1'b0}} | aridr;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         awrite   <= 1'b0;
      else if ( AWVALID & AWREADY )
         awrite   <= 1'b1;
      else if ( awrite & fwe_in )
         awrite   <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         aread    <= 1'b0;
      else if ( ARVALID & ARREADY )
         aread    <= 1'b1;
      else if ( aread & ~awrite & fwe_in )
         aread    <= 1'b0;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET ) begin
         awriter  <= 1'b0;
         areadr   <= 1'b0;
      end
      else begin
         awriter  <= awrite;
         areadr   <= aread ;
      end

   assign   fclr     =  1'b0;
   assign   fwe_in   =  ( awrite | aread ) & ~ffull;
   assign   fre      =  RE;
   assign   fdi      =  awriter ? { awidr_m, awaddrr_m, awlenr, awsizer, awburstr, awlockr, 1'b1 } :
                        areadr  ? { aridr_m, araddrr_m, arlenr, arsizer, arburstr, arlockr, 1'b0 } :
                                  {P_FIFOW{1'b0}};

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         fwe   <= 1'b0;
      else
         fwe   <= fwe_in;

   //===================================================================
   // instances
   //===================================================================

   DDR_A2M_FIFO
      #(
         .P_WIDTH    ( P_FIFOW   ),
         .P_DEPTH    ( P_FIFOD   )//,
      )
      axfifo
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

endmodule
// end of file
