/****************************************************************
 *								*
 * Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "gtmxc_types.h"

#define ERRBUF_SIZE	1024

/* Routine to take the name of an M routine as an argument and invoke it via a call-in. Probably not useful in
 * real world applications but makes writing test cases for call-ins much easier.
 */
gtm_status_t drivecirtn(gtm_int_t count, gtm_char_t *rtnname)
{
	gtm_status_t		status;
	char			errbuf[ERRBUF_SIZE];

	status = gtm_init();
	if (status)
	{
		gtm_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
		fflush(stdout);
		return 0;
	}
	status = gtm_ci(rtnname);
	if (status)
	{
		gtm_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
		fflush(stdout);
		return 0;
	}
	return 0;
}
