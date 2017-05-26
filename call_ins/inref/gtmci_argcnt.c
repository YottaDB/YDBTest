#include "gtm_stdio.h"
#include "gtmxc_types.h"


int main()
{
  gtm_status_t ret;
  gtm_char_t msg[800];

  gtm_long_t arg1=1,arg2=22,arg3=333,arg4=4444,arg5=55555;

  ret = gtm_init();
  if(ret)
    {
      gtm_zstatus(&msg[0],800);
      PRINTF(" %s\n",msg);
    }
  if(gtm_ci("more_actual",arg1,arg2,arg3,arg4,arg5) != 0)
    {
      gtm_zstatus(&msg[0],800);
      PRINTF(" %s \n",msg);
    }

  if(gtm_ci("less_actual",arg1,arg2,arg3,arg4,arg5) != 0)
    {
      gtm_zstatus(&msg[0],800);
      PRINTF(" %s \n",msg);
      fflush(stdout);
    }

  ret = gtm_exit();
  if(ret)
    {
      gtm_zstatus(&msg[0],800);
      PRINTF(" %s\n",msg);
    }
	
}
