//----------------------------------------------------------------------
/**
 * @file DDR_AXI2MBA.v
 * @brief Defines AXI to MBA bridge module.
 */
//----------------------------------------------------------------------

module DDR_AXI2MBA
   (
      CLK         ,   // i
      ZRESET      ,   // i
      SLP         ,   // i
      DQTYPE      ,   // i
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
    //WID         ,   // i
      WDATA       ,   // i
      WSTRB       ,   // i
      WLAST       ,   // i
      WVALID      ,   // i
      WREADY      ,   // o
      BID         ,   // o
      BRESP       ,   // o
      BVALID      ,   // o
      BREADY      ,   // i
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
      RID         ,   // o
      RDATA       ,   // o
      RRESP       ,   // o
      RLAST       ,   // o
      RVALID      ,   // o
      RREADY      ,   // i
      ARB_REQ     ,   // o
      ARB_REL     ,   // i
      ARB_NEL     ,   // i
      ARB_RZW     ,   // o
      ARB_ADR     ,   // o
      ARB_BST     ,   // o
      ARB_WAK     ,   // i
      ARB_RDT     ,   // o
      ARB_BEN     ,   // o
      ARB_RAK     ,   // i
      ARB_WDT     //, // i
   );

   //===================================================================
   // parameters
   //===================================================================

   parameter      P_OUTSTND   =  3; // Outstandings=(1<<P_OUTSTND)
   parameter      P_WIW       =  8;
   parameter      P_RIW       =  8;
   localparam     P_AW        =  40;
   localparam     P_DW        =  128;
   localparam     P_SW        =  P_DW / 8;
   localparam     P_IW        =  P_WIW < P_RIW ? P_RIW : P_WIW;

   //===================================================================
   // ports
   //===================================================================

   // System
   input                   CLK         ;
   input                   ZRESET      ;
   input                   SLP         ;
   input                   DQTYPE      ; // DDR DQ select (0=x16 1=x32)
   // AXI Write address channel
   input    [P_WIW-1:0]    AWID        ; // Cortex-A7: AWIDM[4:0]
   input    [P_AW-1:0]     AWADDR      ;
   input    [  7:0]        AWLEN       ;
   input    [  2:0]        AWSIZE      ;
   input    [  1:0]        AWBURST     ;
   input                   AWLOCK      ; // AXI3: [1:0]
 //input    [  3:0]        AWCACHE     ;
 //input    [  2:0]        AWPROT      ;
   input                   AWVALID     ;
   output                  AWREADY     ;
   // AXI Write data channel
 //input    [P_WIW-1:0]    WID         ; // AXI3
   input    [P_DW-1:0]     WDATA       ;
   input    [P_SW-1:0]     WSTRB       ;
   input                   WLAST       ;
   input                   WVALID      ;
   output                  WREADY      ;
   // AXI Write response channel
   output   [P_WIW-1:0]    BID         ;
   output   [  1:0]        BRESP       ;
   output                  BVALID      ;
   input                   BREADY      ;
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
   // AXI Read data channel
   output   [P_RIW-1:0]    RID         ;
   output   [P_DW-1:0]     RDATA       ;
   output   [  1:0]        RRESP       ;
   output                  RLAST       ;
   output                  RVALID      ;
   input                   RREADY      ;
   // MBA I/F
   output                  ARB_REQ     ; // MBA Request (Act-L)
   input                   ARB_REL     ; // MBA Request acknoledge (Act-H)
   input                   ARB_NEL     ; // MBA Request permission (Act-H)
   output                  ARB_RZW     ; // MBA Direction (0=Write)
   output   [ 29:2]        ARB_ADR     ; // MBA Address
   output   [  9:2]        ARB_BST     ; // MBA Transfer word size (BST+1=Size)
   input                   ARB_WAK     ; // MBA Write data enable (Act-L)
   output   [P_DW-1:0]     ARB_RDT     ; // MBA Write data
   output   [P_SW-1:0]     ARB_BEN     ; // MBA Write data byte enable (Act-L)
   input                   ARB_RAK     ; // MBA Read data enable (Act-L)
   input    [P_DW-1:0]     ARB_WDT     ; // MBA Read data

   /*
      AXI
      SIZE  LEN=AxLEN+1
         8  LEN[7:4]+|LEN[3:0]
        16  LEN[7:3]+|LEN[2:0]
        32  LEN[7:2]+|LEN[1:0]
        64  LEN[7:1]+LEN[0]
       128  LEN[7:0]

      AxADDR[1:0]
      D[31:24] D[23:16] D[15:8] D[7:0]
             3        2       1      0

      AxADDR[31:2] = ARB_ADR[29:0]
      AxADDR[4]    = ARB_ADR[2]
      AxADDR[3:2]  = ARB_ADR[1:0]

      4  2
      5  3
      6  4
      7  5
      8  6

      ARB_ADR[1:0] = AxADDR[3:2]
      x16
        DT[95:64] DT[31:0]
      0        1         0
      1        3         2

      ARB_ADR[2:0] = AxADDR[4:2]
      x16
        DT[127:96] DT[95:64] DT[63:32] DT[31:0]
      0          3         2         1        0
      1          7         6         5        4

      AxADDR[7:4] = RAM_ADDR[3:0] = ARB_ADR[5:2]

      111111          
      5432109876543210
              21
              52631
              68426842
   */

   //===================================================================
   // signals
   //===================================================================

   wire                    ax_re       ;
   wire                    ax_empty    ;
   wire     [P_IW-1:0]     axid        ;
   wire     [P_AW-1:0]     axaddr      ;
   wire     [  7:0]        axlen       ;
   wire     [  2:0]        axsize      ;
   wire     [  1:0]        axburst     ;
   wire                    axlock      ;
   wire                    axdir       ;

   wire     [  5:2]        wdadr       ;
   wire                    wdreq       ;
   wire                    wdend       ;
   wire                    wdready     ;
   wire                    wderr       ;
   wire     [  5:2]        rdadr       ;
   wire                    rdreq       ;
   wire                    rdend       ;
   wire                    rdready     ;

   wire                    wd_avalid   ;
   wire                    rd_avalid   ;

   wire                    rreqerr     ;
   wire     [  7:0]        ramask      ;

   reg                     dqtyper     ;
   reg                     slpr        ;
   wire                    addrtype    ;

   //===================================================================
   // logic
   //===================================================================

   assign   wdadr       =  ARB_ADR[5:2];
   assign   rdadr       =  ARB_ADR[5:2];

   assign   wd_avalid   =  AWVALID & AWREADY;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         dqtyper  <= 1'b0;
      else
         dqtyper  <= DQTYPE;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         slpr  <= 1'b1;
      else
         slpr  <= SLP;

   assign   addrtype =  1'b1;

   //===================================================================
   // instances
   //===================================================================

   DDR_A2M_REQBUF
      #(
         .P_FIFOD    ( P_OUTSTND    ),
         .P_WIW      ( P_WIW        ),
         .P_RIW      ( P_RIW        ),
         .P_AW       ( P_AW         )//,
      )
      reqbuf
      (
         .CLK        ( CLK          ),   // i
         .ZRESET     ( ZRESET       ),   // i
         .ADDRTYPE   ( addrtype     ),   // i
         .AWID       ( AWID         ),   // i
         .AWADDR     ( AWADDR       ),   // i
         .AWLEN      ( AWLEN        ),   // i
         .AWSIZE     ( AWSIZE       ),   // i
         .AWBURST    ( AWBURST      ),   // i
         .AWLOCK     ( AWLOCK       ),   // i
       //.AWCACHE    ( AWCACHE      ),   // i
       //.AWPROT     ( AWPROT       ),   // i
         .AWVALID    ( AWVALID      ),   // i
         .AWREADY    ( AWREADY      ),   // o
         .ARID       ( ARID         ),   // i
         .ARADDR     ( ARADDR       ),   // i
         .ARLEN      ( ARLEN        ),   // i
         .ARSIZE     ( ARSIZE       ),   // i
         .ARBURST    ( ARBURST      ),   // i
         .ARLOCK     ( ARLOCK       ),   // i
       //.ARCACHE    ( ARCACHE      ),   // i
       //.ARPROT     ( ARPROT       ),   // i
         .ARVALID    ( ARVALID      ),   // i
         .ARREADY    ( ARREADY      ),   // o
         .RE         ( ax_re        ),   // i
         .EMPTY      ( ax_empty     ),   // o
         .AXID       ( axid         ),   // o
         .AXADDR     ( axaddr       ),   // o
         .AXLEN      ( axlen        ),   // o
         .AXSIZE     ( axsize       ),   // o
         .AXBURST    ( axburst      ),   // o
         .AXLOCK     ( axlock       ),   // o
         .AXDIR      ( axdir        )//, // o
      );

   DDR_A2M_REQCTL
      #(
         .P_WIW      ( P_WIW        ),
         .P_IW       ( P_IW         ),
         .P_AW       ( P_AW         )//,
      )
      reqctl
      (
         .CLK        ( CLK          ),   // i
         .ZRESET     ( ZRESET       ),   // i
         .DQTYPE     ( dqtyper      ),   // i
         .BID        ( BID          ),   // o
         .BRESP      ( BRESP        ),   // o
         .BVALID     ( BVALID       ),   // o
         .BREADY     ( BREADY       ),   // i
         .ARB_REQ    ( ARB_REQ      ),   // o
         .ARB_REL    ( ARB_REL      ),   // i
         .ARB_NEL    ( ARB_NEL      ),   // i
         .ARB_RZW    ( ARB_RZW      ),   // o
         .ARB_ADR    ( ARB_ADR      ),   // o
         .ARB_BST    ( ARB_BST      ),   // o
         .RE         ( ax_re        ),   // o
         .EMPTY      ( ax_empty     ),   // i
         .AXID       ( axid         ),   // i
         .AXADDR     ( axaddr       ),   // i
         .AXLEN      ( axlen        ),   // i
         .AXSIZE     ( axsize       ),   // i
         .AXBURST    ( axburst      ),   // i
         .AXLOCK     ( axlock       ),   // i
         .AXDIR      ( axdir        ),   // i
         .WDREQ      ( wdreq        ),   // o
         .WDEND      ( wdend        ),   // i
         .WDREADY    ( wdready      ),   // i
         .WDERR      ( wderr        ),   // o
         .RDREQ      ( rdreq        ),   // o
         .RDEND      ( rdend        ),   // i
         .RDREADY    ( rdready      ),   // i
         .RD_AVALID  ( rd_avalid    ),   // o
         .RREQERR    ( rreqerr      ),   // o
         .RAMASK     ( ramask       )//, // o
      );


   DDR_A2M_WDCTL
      #(
         .P_FIFOD    ( P_OUTSTND    ),
       //.P_IW       ( P_WIW        ),
         .P_DW       ( P_DW         )//,
      )
      wdctl
      (
         .CLK        ( CLK          ),   // i
         .ZRESET     ( ZRESET       ),   // i
         .SLP        ( slpr         ),   // i
         .DQTYPE     ( dqtyper      ),   // i
       //.AWID       ( AWID         ),   // i
         .AWADDR     ( AWADDR[7:0]  ),   // i
         .AWLEN      ( AWLEN        ),   // i
         .AWSIZE     ( AWSIZE       ),   // i
         .AWBURST    ( AWBURST      ),   // i
         .AWLOCK     ( AWLOCK       ),   // i
       //.WID        ( WID          ),   // i
         .WDATA      ( WDATA        ),   // i
         .WSTRB      ( WSTRB        ),   // i
         .WLAST      ( WLAST        ),   // i
         .WVALID     ( WVALID       ),   // i
         .WREADY     ( WREADY       ),   // o
         .ARB_WAK    ( ARB_WAK      ),   // i
         .ARB_RDT    ( ARB_RDT      ),   // o
         .ARB_BEN    ( ARB_BEN      ),   // o
         .DADR       ( wdadr        ),   // i
         .DREQ       ( wdreq        ),   // i
         .DEND       ( wdend        ),   // o
         .DREADY     ( wdready      ),   // o
         .DERR       ( wderr        ),   // i
         .AVALID     ( wd_avalid    )//, // i
      );

   DDR_A2M_RDCTL
      #(
         .P_IW       ( P_RIW        ),
         .P_DW       ( P_DW         )//,
      )
      rdctl
      (
         .CLK        ( CLK          ),   // i
         .ZRESET     ( ZRESET       ),   // i
         .SLP        ( slpr         ),   // i
         .DQTYPE     ( dqtyper      ),   // i
         .ARID       ( axid[P_RIW-1:0] ),   // i
         .ARADDR     ( axaddr[7:0]  ),   // i
         .ARLEN      ( axlen        ),   // i
         .ARSIZE     ( axsize       ),   // i
         .ARBURST    ( axburst      ),   // i
         .ARLOCK     ( axlock       ),   // i
         .RID        ( RID          ),   // o
         .RDATA      ( RDATA        ),   // o
         .RRESP      ( RRESP        ),   // o
         .RLAST      ( RLAST        ),   // o
         .RVALID     ( RVALID       ),   // o
         .RREADY     ( RREADY       ),   // i
         .ARB_RAK    ( ARB_RAK      ),   // i
         .ARB_WDT    ( ARB_WDT      ),   // i
         .DADR       ( rdadr        ),   // i
         .DREQ       ( rdreq        ),   // i
         .DEND       ( rdend        ),   // o
         .DREADY     ( rdready      ),   // o
         .AVALID     ( rd_avalid    ),   // i
         .AMASK      ( ramask       ),   // i
         .REQERR     ( rreqerr      )//, // i
      );

endmodule
// end of file
