/****************************************************************
*								*
*	Copyright 2004, 2014 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include "gtm_stdio.h"
#include "gtmxc_types.h"

/*
 * This is a simplistic C program that exists only to call a target label as
 * defined by the executables name. When compiling this executable, you must
 * compile it with the name of the label that you wish to execute.
 *
 * WARNING: This program does not pass or receive parameters from the call-in
 * interface.
 */

int main(int argc, char *argv[])
{
	gtm_status_t ret;
	gtm_char_t msg[800];

	ret = gtm_init();
	if(ret)
	{
		gtm_zstatus(&msg[0],800);
		PRINTF(" %s\n",msg);
	}

	if((ret = gtm_ci(argv[0])) != 0)
	{
		gtm_zstatus(&msg[0],800);
		PRINTF(" %s \n",msg);
	}

	ret = gtm_exit();
	if(ret)
	{
		gtm_zstatus(&msg[0],800);
		PRINTF(" %s\n",msg);
	}
	return 0;
}
