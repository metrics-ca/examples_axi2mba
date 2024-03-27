//----------------------------------------------------------------------
/**
 * @file DDR_A2M_FIFO.v
 * @brief Defines AXI2MBA bridge: FIFO module.
 */
//----------------------------------------------------------------------

module DDR_A2M_FIFO
   (
      CLK         ,   // i
      ZRESET      ,   // i
      CLR         ,   // i
      WE          ,   // i
      D           ,   // i
      RE          ,   // i
      Q           ,   // o
      EMPTY       ,   // o
      FULL        //, // o
   );

   //===================================================================
   // parameters
   //===================================================================

   parameter      P_DEPTH     =  3;
   parameter      P_WIDTH     =  8;

   //===================================================================
   // ports
   //===================================================================

   input                   CLK         ;
   input                   ZRESET      ;
   input                   CLR         ;
   input                   WE          ;
   input    [P_WIDTH-1:0]  D           ;
   input                   RE          ;
   output   [P_WIDTH-1:0]  Q           ;
   output                  EMPTY       ;
   output                  FULL        ;

   //===================================================================
   // output registers
   //===================================================================

   reg      [P_WIDTH-1:0]  Q           ;
 //reg                     EMPTY       ;
 //reg                     FULL        ;

   //===================================================================
   // signals
   //===================================================================

   reg      [P_WIDTH-1:0]  mem   [0:(1<<P_DEPTH)-1];
   reg      [P_DEPTH:0]    wptr     ;
   reg      [P_DEPTH:0]    rptr     ;

   wire     [P_DEPTH:0]    wptr_in  ;
   wire     [P_DEPTH:0]    rptr_in  ;
   reg                     empty_in ; // combinational
   reg                     full_in  ; // combinational

   //===================================================================
   // logic
   //===================================================================

   assign   wptr_in  =  wptr + 1'b1;
   assign   rptr_in  =  rptr + 1'b1;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         wptr  <= {P_DEPTH+1{1'b0}};
      else if ( CLR )
         wptr  <= {P_DEPTH+1{1'b0}};
      else if ( WE )
         wptr  <= wptr_in;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         rptr  <= {P_DEPTH+1{1'b0}};
      else if ( CLR )
         rptr  <= {P_DEPTH+1{1'b0}};
      else if ( RE )
         rptr  <= rptr_in;

   assign   EMPTY =  empty_in ;
   assign   FULL  =  full_in  ;

   //always @( posedge CLK or negedge ZRESET )
   //   if ( ! ZRESET )
   //      EMPTY <= 1'b1;
   //   else if ( CLR )
   //      EMPTY <= 1'b1;
   //   else
   //      EMPTY <= empty_in;

   //always @( posedge CLK or negedge ZRESET )
   //   if ( ! ZRESET )
   //      FULL  <= 1'b0;
   //   else if ( CLR )
   //      FULL  <= 1'b0;
   //   else
   //      FULL  <= full_in;

   always @*
      case ( { WE, RE } )
         2'b00:   empty_in <= ( wptr    == rptr    );
         2'b01:   empty_in <= ( wptr    == rptr_in );
         2'b10:   empty_in <= 1'b0;
         2'b11:   empty_in <= ( wptr_in == rptr_in );
      endcase // case ( { WE, RE } )

   always @*
      case ( { WE, RE } )
         2'b00:   full_in <= ( wptr[P_DEPTH-1:0]    == rptr[P_DEPTH-1:0]    ) &
                             ( wptr[P_DEPTH]        ^  rptr[P_DEPTH]        );
         2'b01:   full_in <= 1'b0;
         2'b10:   full_in <= ( wptr_in[P_DEPTH-1:0] == rptr[P_DEPTH-1:0]    ) &
                             ( wptr_in[P_DEPTH]     ^  rptr[P_DEPTH]        );
         2'b11:   full_in <= ( wptr_in[P_DEPTH-1:0] == rptr_in[P_DEPTH-1:0] ) &
                             ( wptr_in[P_DEPTH]     ^  rptr_in[P_DEPTH]     );
      endcase // case ( { WE, RE } )

   always @( posedge CLK )
      if ( WE )
         mem[ wptr[P_DEPTH-1:0] ] <= D;

   always @( posedge CLK or negedge ZRESET )
      if ( ! ZRESET )
         Q <= {P_WIDTH{1'b0}};
      else if ( RE )
         Q <= mem[ rptr[P_DEPTH-1:0] ];

endmodule
// end of file
