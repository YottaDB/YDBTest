/****************************************************************
*								*
*	Copyright 2013, 2014 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/

/****************************************************************
 * Test that specifying an empty call-in table does not cause   *
 * SIG-11s if a call is made from C to M.                       *
 ***************************************************************/
#include "gtmxc_types.h"
#include "gtm_sizeof.h"

#include <stdio.h>

#define BUF_LEN 1024

#define PRINT_ERROR()			\
{					\
	gtm_zstatus(&buf[0], BUF_LEN);	\
	printf("%s\n", buf);		\
	fflush(stdout);			\
	return -1;			\
}

int main()
{
	gtm_char_t buf[BUF_LEN];

	/* Initialize the interface. */
	if (gtm_init())
		PRINT_ERROR();

	/* Invoke a non-existant routine. */
	if (gtm_ci("abcdef"))
		PRINT_ERROR();

	/* Rundown the interface. */
	if (gtm_exit())
		PRINT_ERROR();
	return 0;
}
