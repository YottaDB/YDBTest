#include <string.h>
#include <stdio.h>

#include "shrenv.h"
#include "gtm_stdio.h" 
#include "gtmxc_types.h"

void square(int count,xc_long_t val)
 {
   xc_long_t cube;
   fflush(stdout);
   PRINTF("\nC2, C-> M -> C -> M\n");
   PRINTF("val = %ld\n",val);
   PRINTF("The square of %ld is %ld\n",val,val*val);
   gtm_ci("cube",&cube,val);
   PRINTF("The cube of %ld is %ld\n",val,cube);
   fflush(stdout);
 }
