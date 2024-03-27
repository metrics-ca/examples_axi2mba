module RAM1P1RW144B32W_B9W_WRAP
   (
      Q        ,   // o
      CLK      ,   // i
      CEN      ,   // i
      WEN      ,   // i
      GWEN     ,   // i
      A        ,   // i
      D        ,   // i
      SLP      //, // i
   );

   localparam              P_AW     =  5;
   localparam              P_DW     =  144;
   localparam              P_DEPTH  =  1 << P_AW;

   output   [P_DW-1:0]     Q        ;
   input                   CLK      ;
   input                   CEN      ;
   input    [P_DW/9-1:0]   WEN      ;
   input                   GWEN     ;
   input    [P_AW-1:0]     A        ;
   input    [P_DW-1:0]     D        ;
   input                   SLP      ;

   reg      [P_DW-1:0]     Q        ;

   reg      [P_DW-1:0]     mem[0:P_DEPTH-1];

   genvar i;
   generate
      for ( i = 0; i < P_DW/9; i = i + 1 ) begin: gen_loop
         always @( posedge CLK )
            if ( ~CEN ) begin
               if ( ~GWEN & ~WEN[i] )
                  mem[ A ][i*9+:9] <= D[i*9+:9];
            end
      end
   endgenerate

   always @( posedge CLK )
      if ( ~CEN ) begin
         Q <= mem[ A ];
      end

endmodule
// end of file
