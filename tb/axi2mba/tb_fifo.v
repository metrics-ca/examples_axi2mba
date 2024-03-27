//----------------------------------------------------------------------
/**
 * @file tb_top.v
 * @brief Defines Testbench top module.
 */
//----------------------------------------------------------------------

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

 //wire                    clk            ; // i
 //wire                    zreset         ; // i
   wire                    clr            ; // i
   reg                     we             ; // i
   reg      [  7:0]        d              ; // i
   reg                     re             ; // i
   wire     [  7:0]        q              ; // o
   wire                    empty          ; // o
   wire                    full           ; // o

   reg      [ 15:0]        rnd            ;
   reg                     emptyr         ;
   reg                     fullr          ;
   wire                    we_in          ;
   wire                    re_in          ;

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

   always @( posedge clk )
      begin
         if ( we & fullr ) begin
            $display( "TB ERROR: we=H at full=H, d='h%h @%0t", d, $time );
            #1 ->sim_end;
         end
         if ( re & emptyr ) begin
            $display( "TB ERROR: re=H at empty=H @%0t", $time );
            #1 ->sim_end;
         end
      end

   always @( posedge clk or negedge rst_n )
      if ( ! rst_n )
         rnd   <= {16{1'b0}};
      else
         rnd   <= $random;

   assign   clr      =  1'b0;

   always @( posedge clk or negedge rst_n )
      if ( ! rst_n ) begin
         fullr    <= 1'b0;
         emptyr   <= 1'b1;
      end
      else begin
         fullr    <= full  ;
         emptyr   <= empty ;
      end

   always @( posedge clk or negedge rst_n )
      if ( ! rst_n )
         d     <= {8{1'b0}};
      else if ( we_in )
         d     <= $random;

   always @( posedge clk or negedge rst_n )
      if ( ! rst_n )
         we    <= 1'b0;
      else
         we    <= we_in;

   always @( posedge clk or negedge rst_n )
      if ( ! rst_n )
         re    <= 1'b0;
      else
         re    <= re_in;

   assign   we_in    =  ( rnd[1:0] === 2'b10 ) & ~full   ;
   assign   re_in    =  ( rnd[8:7] === 2'b10 ) & ~empty  ;

   //-------------------------------------------------------------------

`ifndef noSVTB

   logic    [  7:0]        fifo_d[$]      ;
   reg      [  7:0]        fq             ;
   reg                     fre            ;
   integer                 match          ;

   initial begin
      match = 0;
      $display( "Checking FIFO data using SV queue" );
      @( sim_end );
      $display( "Match %0d data", match );
   end

   always @( posedge clk or negedge rst_n )
      if ( ! rst_n ) begin
         while( fifo_d.size() > 0 ) fifo_d.delete( 0 );
      end
      else if ( we )
         fifo_d.push_back( d );

   always @( posedge clk or negedge rst_n )
      if ( ! rst_n ) begin
      end
      else if ( re ) begin
         if ( fifo_d.size() > 0 )
            fq    <= fifo_d.pop_front();
         else begin
            $display( "FIFO ERROR: FIFO is empty @%0t", $time );
            #1 ->sim_end;
         end
      end

   always @( posedge clk or negedge rst_n )
      if ( ! rst_n )
         fre   <= 1'b0;
      else begin
         fre   <= re;
         if ( fre ) begin
            if ( q === fq )
               match <= match + 1;
            else begin
               $display( "FIFO ERROR: Data mismatch q='h%h fq='h%h @%0t",
                         q, fq, $time );
               #1 ->sim_end;
            end
         end
      end

`endif // `ifndef noSVTB

   //===================================================================
   // instances
   //===================================================================

   //-------------------------------------------------------------------
   // DUT
   //-------------------------------------------------------------------

   DDR_A2M_FIFO
      #(
         .P_DEPTH    ( 3         ),
         .P_WIDTH    ( 8         )//,
      )
      fifo
      (
         .CLK        ( clk       ),   // i
         .ZRESET     ( rst_n     ),   // i
         .CLR        ( clr       ),   // i
         .WE         ( we        ),   // i
         .D          ( d         ),   // i
         .RE         ( re        ),   // i
         .Q          ( q         ),   // o
         .EMPTY      ( empty     ),   // o
         .FULL       ( full      )//, // o
      );

   //===================================================================
   // load data
   //===================================================================

endmodule
// end of file
