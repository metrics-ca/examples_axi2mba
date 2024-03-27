module RAM1P1RW128B32W_WRAP
   (
      Q        ,   // o
      CLK      ,   // i
      CEN      ,   // i
      WEN      ,   // i
      A        ,   // i
      D        ,   // i
      SLP      //, // i
   );

   localparam              P_AW     =  5;
   localparam              P_DW     =  128;
   localparam              P_DEPTH  =  1 << P_AW;

   output   [P_DW-1:0]     Q        ;
   input                   CLK      ;
   input                   CEN      ;
   input                   WEN      ;
   input    [P_AW-1:0]     A        ;
   input    [P_DW-1:0]     D        ;
   input                   SLP      ;

   reg      [P_DW-1:0]     Q        ;

   reg      [P_DW-1:0]     mem[0:P_DEPTH-1];

   always @( posedge CLK )
      if ( ~CEN ) begin
         if ( ~WEN )
            mem[ A ] <= D;
         Q <= mem[ A ];
      end

endmodule
// end of file
