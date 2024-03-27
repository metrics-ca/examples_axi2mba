#ifndef _VPR_MATH_C_
#define _VPR_MATH_C_

#include <math.h>
#include "svdpi.h"

//import "DPI-C" function real vpr_math_pi();
//import "DPI-C" function real vpr_math_cos( real x );
//import "DPI-C" function real vpr_math_sin( real x );
//import "DPI-C" function real vpr_math_tan( real x );
//import "DPI-C" function real vpr_math_sqrt( real x );
//import "DPI-C" function real vpr_math_floor( real x );
//import "DPI-C" function real vpr_math_ceil( real x );
//import "DPI-C" function real vpr_math_modf( real x );
//import "DPI-C" function real vpr_math_modi( real x );
//import "DPI-C" function real vpr_math_cos2( real x );
//import "DPI-C" function real vpr_math_sin2( real x );

double vpr_math_pi();
double vpr_math_cos( double x );
double vpr_math_sin( double x );
double vpr_math_tan( double x );
double vpr_math_sqrt( double x );
double vpr_math_floor( double x );
double vpr_math_ceil( double x );
double vpr_math_modf( double x );
double vpr_math_modi( double x );
double vpr_math_cos2( double x );
double vpr_math_sin2( double x );

double vpr_math_pi() {
   return M_PI;
}
double vpr_math_cos( double x ) {
   return cos( x * M_PI * 2 );
}
double vpr_math_sin( double x ) {
   return sin( x * M_PI * 2 );
}
double vpr_math_tan( double x ) {
   return tan( x * M_PI * 2 );
}
double vpr_math_sqrt( double x ) {
   return sqrt( x );
}
double vpr_math_floor( double x ) {
   return floor( x );
}
double vpr_math_ceil( double x ) {
   return ceil( x );
}
double vpr_math_modf( double x ) {
   double y;
   x = modf( x, &y );
   return x;
}
double vpr_math_modi( double x ) {
   double y;
   x = modf( x, &y );
   return y;
}
double vpr_math_cos2( double x ) {
   double y;
   x = vpr_math_modf( x );
   if ( x < 0 ) x += 1;
   if ( x < 0.5 ) {
      y = -4 * x + 1;
   } else {
      x -= 0.5;
      y =  4 * x - 1;
   }
   return y;
}
double vpr_math_sin2( double x ) {
   double y;
   x = vpr_math_modf( x );
   if ( x < 0 ) x += 1;
   if ( x < 0.25 ) {
      y =  4 * x;
   } else if ( x < 0.75 ) {
      x -= 0.25;
      y = -4 * x + 1;
   } else {
      x -= 0.75;
      y =  4 * x - 1;
   }
   return y;
}

#endif // #ifndef _VPR_MATH_C_
