/****************************************************************
*								*
*	Copyright 2013 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include <stdio.h>
#include "gtmxc_types.h"
#define ERR_MAX	500

int main()
{
        gtm_status_t status;
        char err[ERR_MAX];

        status = gtm_init();
        if(status != 0)
        {
                gtm_zstatus(&err[0],500);
                printf(" %s \n",err);
                fflush(stdout);
        }

        status = gtm_ci("jobmumps");
        if(status != 0)
        {
                gtm_zstatus(&err[0],500);
                printf(" %s \n",err);
                fflush(stdout);
        }


        status = gtm_exit();
        if(status != 0)
        {
                gtm_zstatus(&err[0],500);
                printf(" %s \n",err);
                fflush(stdout);
        }
        return 0;
}
