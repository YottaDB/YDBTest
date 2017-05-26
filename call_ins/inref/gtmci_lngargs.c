/****************************************************************
*								*
*	Copyright 2003, 2014 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include "gtm_stdio.h"
#include "gtmxc_types.h"


int main()
{
	gtm_status_t ret;
	gtm_char_t errmsg[200];

	gtm_long_t arg1=1,arg2=2,arg3=3,arg4=4,arg5=5,arg6=6,arg7=7,arg8=8;
	gtm_long_t arg9 =9,arg10=10,arg11=11,arg12=12;
	gtm_long_t arg13=13,arg14=14,arg15=15,arg16=16;
	gtm_long_t arg17=17,arg18=18,arg19=19,arg20=20,arg21=21,arg22=22,arg23=23,arg24=24,arg25=25,arg26=26,arg27=27;
	gtm_long_t arg28=28,arg29=29,arg30=30,arg31=31,arg32=32;
	gtm_long_t arg33=33;

	ret = gtm_init();
	if(ret)
	{
		gtm_zstatus(&errmsg[0],200);
		PRINTF(" %s \n",errmsg);
	}
	ret =   gtm_ci("toolong", arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20,arg21,arg22,arg23,arg24,arg25,arg26,arg27,arg28,arg29,arg30,arg31,arg32,arg33);
	if(ret !=0)
	{
		gtm_zstatus(&errmsg[0],200);
		PRINTF(" %s \n",errmsg);
	}
	ret = gtm_exit();
	if(ret)
	{
		gtm_zstatus(&errmsg[0],200);
		PRINTF(" %s \n",errmsg);
	}
	return 0;
}
