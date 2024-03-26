/****************************************************************
 *								*
 * Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdlib.h>

/* Helper external call that displays current terminal characteristics. Used by ydb350.m as "do &sttydisp" */
void	ydb350_sttydisp(void)
{
        system("stty -a -F $term_env | sed 's/ /\\n/g;' | grep -w echo");
}
