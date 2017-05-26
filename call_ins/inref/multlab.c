#include "gtm_stdio.h"
#include "gtmxc_types.h"


int main()
{
	gtm_status_t status;
	char err[500];

	gtm_long_t arg1=1,arg2=2,arg3=3,arg4=4,arg5=5,arg6=6,arg7=7,arg8=8;
	gtm_long_t arg9 =9,arg10=10,arg11=11,arg12=12;
	gtm_long_t arg13=13,arg14=14,arg15=15,arg16=16; 
	gtm_long_t arg17=17,arg18=18,arg19=19,arg20=20,arg21=21,arg22=22,arg23=23,arg24=24,arg25=25,arg26=26,arg27=27;
	gtm_long_t arg28=28,arg29=29,arg30=30,arg31=31,arg32=32; 
	gtm_long_t var1= 100,var2=200,var3=300,var4=400;


	status = gtm_init();
	if(status != 0)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s \n",err);
	fflush(stdout);
	}
	status = gtm_ci("truncated31", arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32);
	if(status != 0)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s \n",err);
		fflush(stdout);
	}

	status = gtm_exit();
	if(status != 0)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s \n",err);
		fflush(stdout);
	}
	/* To check for Long labels filenames & entryrefs from here */

	status = gtm_ci("morethan31", arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32);
	if(status != 0)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s \n",err);
		fflush(stdout);
	}

	status = gtm_exit();
	if(status != 0)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s \n",err);
		fflush(stdout);
	}

}
